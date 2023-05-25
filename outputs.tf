output "vcn_state" {
  description = "The state of the VCN."
  value       = oci_core_vcn.openproject.state
}

output "vcn_cidr" {
  description = "CIDR block of the OpenProject VCN"
  value       = oci_core_vcn.openproject.cidr_block
}

output "Application01PrivateIP" {
  description = "Application Private IP"
  value       = "xx" #oci_core_instance.openproject[0].private_ip

}

output "Application02PrivateIP" {
  description = "Application Private IP"
  value       = "xx" #oci_core_instance.openproject[1].private_ip

}

output "LoadBalacerIp" {
  description = "Load Balancer Public IP"
  value       = oci_load_balancer_load_balancer.openproject_lb.ip_address_details
}

output "password" {
  description = "Postgresql Password"
  value       = random_string.random.result

}


output "key-private-pem" {
  value     = tls_private_key.key01.private_key_pem
  sensitive = true
}

output "key-public-openssh" {
  value = tls_private_key.key01.public_key_openssh
}

# Output the result
output "show-ads" {
  value = data.oci_identity_availability_domains.ads.availability_domains[0].name
}

# Output the result
output "mod-ads" {
  value = 4 % length(data.oci_identity_availability_domains.ads.availability_domains)
}

# now let's print the OCID
output "latest_ubuntu_image" {
  value = data.oci_core_images.ubuntu_latest.images[0].id
}
