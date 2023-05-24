variable "compartment_ocid" {
  description = "OCID from your Compartment"
  type        = string
}
variable "region" {
  description = "Region where you have OCI tenancy"
  type        = string
  default     = "eu-frankfurt-1"
}

#variable "compute_ssh_authorized_keys" {
#  type = string
#}

variable "appvmcount" {
  description = "Number of Application VM"
  type = number
}

#variable "ssh_private_key" {
#  description = "the content of the ssh public key used to access the compute instance. set this or the ssh_public_key_path"
#  default     = ""
#  type        = string
#}


