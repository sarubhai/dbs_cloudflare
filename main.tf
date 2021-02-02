# main.tf
# Owner: Saurav Mitra
# Description: This terraform config will create the Cloudflare resources
#
# cloudflare_filter	                  -    5
# cloudflare_firewall_rule	          -    5
# cloudflare_record	                  -    2
# cloudflare_waf_group	              -   30        [Cloudflare(10) + OWASP(20)]
# cloudflare_worker_script	          -    2
# cloudflare_worker_route	            -    2
# cloudflare_zone	                    -    1
# cloudflare_zone_settings_override	  -    1
# ------------------------------------------
# Grand Total	                            48

# Configure Terraform 
terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 2.17.0"
    }
  }
}


# Configure Cloudflare Provider
# https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs
# $ export CLOUDFLARE_EMAIL="john.doe@example.com"
# $ export CLOUDFLARE_API_KEY="a1b2c3d4e5f6g7h8i9j"
# $ export CLOUDFLARE_ACCOUNT_ID="z1y2x3w4v5u6t7s8r9q"
# $ export CLOUDFLARE_API_CLIENT_LOGGING=true
provider "cloudflare" {
  # email              = var.cloudflare_email
  # api_key            = var.cloudflare_api_key
  # account_id         = var.cloudflare_account_id
  # api_client_logging = var.cloudflare_logging
}



#################
# Cloudflare Zone
#################
resource "cloudflare_zone" "site" {
  zone = var.domain_name
  plan = var.domain_plan
  type = "full"
}


###############
# Zone Settings
###############
resource "cloudflare_zone_settings_override" "site_settings" {
  zone_id = cloudflare_zone.site.id
  settings {
    always_online            = "on"
    always_use_https         = "on"
    automatic_https_rewrites = "off"
    brotli                   = "on"
    browser_cache_ttl        = 0
    browser_check            = "on"
    cache_level              = "aggressive"
    challenge_ttl            = 300
    cname_flattening         = "flatten_at_root"
    development_mode         = "off"
    email_obfuscation        = "on"
    h2_prioritization        = "off"
    hotlink_protection       = "off"
    http2                    = "on"
    http3                    = "off"
    # image_resizing           = "off"
    ip_geolocation  = "on"
    ipv6            = "off"
    max_upload      = 100
    min_tls_version = "1.0"
    minify {
      css  = "on"
      html = "on"
      js   = "on"
    }
    mirage = "off"
    mobile_redirect {
      mobile_subdomain = ""
      status           = "off"
      strip_uri        = false
    }
    opportunistic_encryption = "off"
    opportunistic_onion      = "on"
    # origin_error_page_pass_thru = "off"
    polish = "off"
    # prefetch_preload            = "off"
    privacy_pass = "on"
    pseudo_ipv4  = "off"
    # response_buffering = "off"
    rocket_loader = "off"
    security_header {
      enabled            = true
      include_subdomains = true
      max_age            = 0
      nosniff            = false
      preload            = false
    }
    security_level      = "medium"
    server_side_exclude = "on"
    # sort_query_string_for_cache = "off"
    ssl             = "flexible"
    tls_1_3         = "off"
    tls_client_auth = "off"
    # true_client_ip_header = "off"
    universal_ssl = "off"
    waf           = "on"
    # webp                        = "off"
    websockets = "on"
    zero_rtt   = "off"
  }
}


#############
# DNS Records
#############
resource "cloudflare_record" "subdomain" {
  zone_id = cloudflare_zone.site.id
  name    = var.subdomain_name
  value   = var.subdomain_address
  type    = "A"
  ttl     = 1
  proxied = true
}

resource "cloudflare_record" "www_subdomain" {
  zone_id = cloudflare_zone.site.id
  name    = var.www_subdomain_name
  value   = var.subdomain_address
  type    = "A"
  ttl     = 1
  proxied = true
}


########
# Filter
########
resource "cloudflare_filter" "firewall_filter" {
  for_each = var.filters

  zone_id     = cloudflare_zone.site.id
  description = each.value["description"]
  expression  = each.value["expression"]
  ref         = each.key
}

###############
# Firewall Rule
###############
resource "cloudflare_firewall_rule" "firewall_rule" {
  for_each = var.filters

  zone_id     = cloudflare_zone.site.id
  description = each.value["description"]
  filter_id   = cloudflare_filter.firewall_filter[each.key].id
  action      = each.value["action"]
  priority    = each.value["priority"]
  paused      = false
}


##########
# WAF Rule
##########
# Cloudflare WAF Rule Groups
data "cloudflare_waf_groups" "cloudflare_waf" {
  zone_id = cloudflare_zone.site.id
  filter {
    name = ".*Cloudflare.*"
  }
}

resource "cloudflare_waf_group" "cloudflare_waf_group" {
  count    = length(data.cloudflare_waf_groups.cloudflare_waf.groups)
  zone_id  = cloudflare_zone.site.id
  group_id = data.cloudflare_waf_groups.cloudflare_waf.groups[count.index].id
  mode     = "on"
}

# OWASP WAF Rule Groups
data "cloudflare_waf_groups" "owasp_waf" {
  zone_id = cloudflare_zone.site.id
  filter {
    name = ".*OWASP.*"
  }
}

resource "cloudflare_waf_group" "owasp_waf_group" {
  count    = length(data.cloudflare_waf_groups.owasp_waf.groups)
  zone_id  = cloudflare_zone.site.id
  group_id = data.cloudflare_waf_groups.owasp_waf.groups[count.index].id
  mode     = "on"
}


###############
# Worker Script
###############
resource "cloudflare_worker_script" "worker_script" {
  for_each = fileset("${path.module}/scripts", "*.js")

  name    = trim(each.value, ".js")
  content = file("${path.module}/scripts/${each.value}")
}

resource "cloudflare_worker_route" "worker_route" {
  for_each = fileset("${path.module}/scripts", "*.js")

  zone_id     = cloudflare_zone.site.id
  pattern     = "cloudflare.gridcompute.com/${trim(each.value, ".js")}/*"
  script_name = cloudflare_worker_script.worker_script[each.key].name
}





#############
# Access Rule
#############
# resource "cloudflare_access_rule" "access_rule_block_country" {
#   for_each = var.access_rules

#   # zone_id = cloudflare_zone.site.id
#   notes = "Geo block"
#   mode  = "block"
#   configuration = {
#     target = "country"
#     value  = each.value
#   }
# }


################
# Account Member
################
# resource "cloudflare_account_member" "account_member" {
#   for_each = var.member_roles

#   email_address = each.value["email_address"]
#   role_ids      = each.value["role_ids"]
# }
