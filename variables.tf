# variables.tf
# Owner: Saurav Mitra
# Description: Variables used by terraform config to create the Cloudflare resources
# https://www.terraform.io/docs/configuration/variables.html

# Cloudflare Provider
variable "cloudflare_email" {
  description = "The email associated with the Cloudflare account."
}

variable "cloudflare_api_key" {
  description = "The Cloudflare API key."
}

variable "cloudflare_account_id" {
  description = "The Cloudflare Account ID."
}

variable "cloudflare_logging" {
  description = "Print logs from the API client."
  default     = true
}

# Cloudflare Zone
variable "domain_name" {
  description = "The DNS zone or Domain name."
}

variable "domain_plan" {
  description = "The name of the commercial plan to apply to the zone."
  default     = "free"
}

# DNS Records
variable "subdomain_name" {
  description = "The Sub Domain Name."
}

variable "subdomain_address" {
  description = "The Sub Domain Address."
}

variable "www_subdomain_name" {
  description = "The Sub Domain WWW Record."
}

# Firewall Rule Filters
variable "filters" {
  description = "Firewall Filters."
  type        = map(any)
  default = {
    filter1 = { description = "Block KP", expression = "(ip.geoip.country eq \"KP\")", action = "block", priority = 101 }
    filter2 = { description = "Block CU", expression = "(ip.geoip.country eq \"CU\")", action = "block", priority = 102 }
    filter3 = { description = "Block SY", expression = "(ip.geoip.country eq \"SY\")", action = "block", priority = 103 }
    filter4 = { description = "Block Opera", expression = "(http.user_agent eq \"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/87.0.4280.141 Safari/537.36 OPR/73.0.3856.344\")", action = "block", priority = 104 }
    filter5 = { description = "Method Get", expression = "(http.request.method eq \"GET\")", action = "allow", priority = 105 }
  }
}

# Access Rules
variable "access_rules" {
  description = "Country wise blocked access rules."
  type        = map(any)
  default = {
    KP = "KP",
    CU = "CU",
    SY = "SY"
  }
}

# Account Member
variable "member_roles" {
  description = "Account Member Roles."
  default = {
    user1 = { email_address = "saurav.mitra@ashnik.com", role_ids = ["05784afa30c1afe1440e79d9351c7430"] },
    user2 = { email_address = "saurav.karate@gmail.com", role_ids = ["05784afa30c1afe1440e79d9351c7430"] }
  }
}
