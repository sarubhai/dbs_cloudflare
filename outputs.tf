# outputs.tf
# Owner: Saurav Mitra
# Description: Outputs the relevant resources ID & other attributes
# https://www.terraform.io/docs/configuration/outputs.html

# Cloudflare Zone
output "zone_id" {
  value       = cloudflare_zone.site.id
  description = "The zone ID."
}

output "zone_status" {
  value       = cloudflare_zone.site.status
  description = "Status of the zone."
}

output "zone_name_servers" {
  value       = cloudflare_zone.site.name_servers
  description = "Cloudflare assigned name servers."
}


# Zone Settings
# output "zone_initial_settings" {
#   value       = cloudflare_zone_settings_override.site_settings.initial_settings
#   description = "Initial Settings of the zone at the time of creation."
# }

# output "zone_readonly_settings" {
#   value       = cloudflare_zone_settings_override.site_settings.readonly_settings
#   description = "Which of the current settings are not applied due to plan level."
# }


# DNS Records
output "subdomain_record_id" {
  value       = cloudflare_record.subdomain.id
  description = "Subdomain DNS Record ID."
}

output "subdomain_record_fqdn" {
  value       = cloudflare_record.subdomain.hostname
  description = "Subdomain DNS Record FQDN."
}

output "www_subdomain_record_id" {
  value       = cloudflare_record.www_subdomain.id
  description = "Subdomain WWW DNS Record ID."
}

output "www_subdomain_record_fqdn" {
  value       = cloudflare_record.www_subdomain.hostname
  description = "Subdomain WWW DNS Record FQDN."
}


# WAF Rule
# output "cloudflare_waf_groups" {
#   value = data.cloudflare_waf_groups.cloudflare_waf.groups
# }

# output "owasp_waf_groups" {
#   value = data.cloudflare_waf_groups.owasp_waf.groups
# }


# Worker Script
# output "worker_scripts" {
#   value = cloudflare_worker_script.worker_script
# }
