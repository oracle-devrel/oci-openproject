resource "oci_core_vcn" "openproject" {
  dns_label      = "openproject"
  cidr_block     = "10.0.0.0/16"
  compartment_id = var.compartment_ocid
  display_name   = "OpenProjectVCN"
}

resource "oci_core_internet_gateway" "ig" {
  compartment_id = var.compartment_ocid
  display_name   = "OpenProjectIGW"

  vcn_id = oci_core_vcn.openproject.id
}

resource "oci_core_nat_gateway" "ng" {
  #Required
  compartment_id = var.compartment_ocid
  display_name   = "OpenProjectNG"
  vcn_id         = oci_core_vcn.openproject.id
}


resource "oci_core_subnet" "dmz" {
  vcn_id                     = oci_core_vcn.openproject.id
  cidr_block                 = "10.0.0.0/24"
  compartment_id             = var.compartment_ocid
  display_name               = "dmz"
  prohibit_public_ip_on_vnic = false
  dns_label                  = "dmz"
  security_list_ids          = tolist([oci_core_security_list.dmz-sl.id])
  route_table_id             = oci_core_route_table.dmz_route_table.id
}


resource "oci_core_subnet" "application" {
  vcn_id                     = oci_core_vcn.openproject.id
  cidr_block                 = "10.0.1.0/24"
  compartment_id             = var.compartment_ocid
  display_name               = "application"
  prohibit_public_ip_on_vnic = true
  dns_label                  = "application"
  route_table_id             = oci_core_route_table.route_table.id
  security_list_ids          = tolist([oci_core_security_list.application-sl.id])
}

resource "oci_core_subnet" "database" {
  vcn_id                     = oci_core_vcn.openproject.id
  cidr_block                 = "10.0.2.0/24"
  compartment_id             = var.compartment_ocid
  display_name               = "database"
  prohibit_public_ip_on_vnic = true
  dns_label                  = "database"
  route_table_id             = oci_core_route_table.route_table.id
  security_list_ids          = tolist([oci_core_security_list.database-sl.id])
}

resource "oci_core_route_table" "route_table" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.openproject.id

  display_name = "Route Table"


  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_nat_gateway.ng.id
  }
}

resource "oci_core_route_table" "dmz_route_table" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.openproject.id

  display_name = "Route Table"


  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.ig.id
  }
}

resource "oci_core_security_list" "dmz-sl" {
  #Required
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.openproject.id

  #Optional
  display_name = "DMZ Security List"

  egress_security_rules {
    #Required
    destination = "0.0.0.0/0"
    protocol    = "all"

    #Optional
    description = "All Protocols"
    #destination_type = var.security_list_egress_security_rules_destination_type
  }

  ingress_security_rules {
    #Required
    protocol = "6"
    source   = "0.0.0.0/0"

    #Optional
    description = "SSH Access"

    source_type = "CIDR_BLOCK"
    #stateless = var.security_list_ingress_security_rules_stateless
    tcp_options {

      #Optional
      max = 22
      min = 22
      #source_port_range {
      #Required
      #max = 80
      #min = 80
      #}
    }
  }

  ingress_security_rules {
    #Required
    protocol = "6"
    source   = "0.0.0.0/0"

    #Optional
    description = "HTTP Access"

    source_type = "CIDR_BLOCK"
    #stateless = var.security_list_ingress_security_rules_stateless
    tcp_options {

      #Optional
      max = 80
      min = 80
      #source_port_range {
      #Required
      #max = 80
      #min = 80
      #}
    }
  }

  ingress_security_rules {
    #Required
    protocol = "6"
    source   = "0.0.0.0/0"

    #Optional
    description = "HTTPS Access"

    source_type = "CIDR_BLOCK"
    #stateless = var.security_list_ingress_security_rules_stateless
    tcp_options {

      #Optional
      max = 443
      min = 443
    }
  }
}

resource "oci_core_security_list" "application-sl" {
  #Required
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.openproject.id

  #Optional
  display_name = "Application Security List"
  egress_security_rules {
    #Required
    destination = "0.0.0.0/0"
    protocol    = "all"

    #Optional
    description = "All Protocols"
    #destination_type = var.security_list_egress_security_rules_destination_type
  }

  ingress_security_rules {
    #Required
    protocol = "6"
    source   = "0.0.0.0/0" #oci_core_subnet.dmz.cidr_block

    #Optional
    description = "SHH Access"

    source_type = "CIDR_BLOCK"
    #stateless = var.security_list_ingress_security_rules_stateless
    tcp_options {

      #Optional
      max = 22
      min = 22
    }
  }

  ingress_security_rules {
    #Required
    protocol = "6"
    source   = oci_core_subnet.dmz.cidr_block

    #Optional
    description = "HTTP Access"

    source_type = "CIDR_BLOCK"
    #stateless = var.security_list_ingress_security_rules_stateless
    tcp_options {

      #Optional
      max = 80
      min = 80
    }
  }
}

resource "oci_core_security_list" "database-sl" {
  #Required
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.openproject.id

  #Optional
  display_name = "Database Security List"
  egress_security_rules {
    #Required
    destination = "0.0.0.0/0"
    protocol    = "all"

    #Optional
    description = "All Protocols"
    #destination_type = var.security_list_egress_security_rules_destination_type
  }
  ingress_security_rules {
    #Required
    protocol = "6"
    source   = "0.0.0.0/0" #oci_core_subnet.application.cidr_block

    #Optional
    description = "SHH Access"

    source_type = "CIDR_BLOCK"
    #stateless = var.security_list_ingress_security_rules_stateless
    tcp_options {

      #Optional
      max = 22
      min = 22
    }
  }

  ingress_security_rules {
    #Required
    protocol = "6"
    source   = oci_core_subnet.application.cidr_block

    #Optional
    description = "PSQL Access"

    source_type = "CIDR_BLOCK"
    #stateless = var.security_list_ingress_security_rules_stateless
    tcp_options {

      #Optional
      max = 5432
      min = 5432
    }
  }
}

## Instances

resource "oci_core_instance" "bastion" {
  #Required 
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_id      = var.compartment_ocid
  shape               = "VM.Standard.E4.Flex"

  #Optional

  display_name = "bastion"

  create_vnic_details {
    #Required 
    subnet_id = oci_core_subnet.dmz.id

    #Optional
    display_name     = "primaryvnic"
    assign_public_ip = true
    hostname_label   = "bastion"
    #private_ip       = "10.0.0.2"
  }

  source_details {
    source_type = "image"
    source_id   = data.oci_core_images.ubuntu_latest.images[0].id

    # Apply this to set the size of the boot volume that's created for this instance.
    # Otherwise, the default boot volume size of the image is used.
    # This should only be specified when source_type is set to "image".
    boot_volume_size_in_gbs = "100"
  }

  shape_config {

    #Optional
    #baseline_ocpu_utilization = var.instance_shape_config_baseline_ocpu_utilization
    memory_in_gbs = 16
    #nvmes = var.instance_shape_config_nvmes
    ocpus = 2
  }

  metadata = {
    ssh_authorized_keys = tls_private_key.key01.public_key_openssh # var.compute_ssh_authorized_keys #
    #user_data           = "${base64encode(data.template_file.cloud-config-postgres.rendered)}"

  }
  #preserve_boot_volume = true

  timeouts {
    create = "60m"
  }

  agent_config {
    plugins_config {
      desired_state = "ENABLED"
      name          = "Bastion"
    }
  }
}

resource "null_resource" "remote-exec" {
  depends_on = [oci_core_instance.bastion]
  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      host        = oci_core_instance.bastion.public_ip
      user        = "ubuntu"
      agent       = false
      timeout     = "2m"
      private_key = tls_private_key.key01.private_key_openssh # var.ssh_private_key # 
    }

    inline = [
      "echo ======== SSH Key Install ===========",
      "echo '${tls_private_key.key01.private_key_pem}' > /home/ubuntu/.ssh/id_rsa",
      "sudo chown ubuntu  /home/ubuntu/.ssh/id_rsa",
      "sudo chmod 700 /home/ubuntu/.ssh/id_rsa",
      "echo '${tls_private_key.key01.public_key_openssh}' > /home/ubuntu/.ssh/id_rsa.pub",
      "chown ubuntu  /home/ubuntu/.ssh/id_rsa.pub",
      "chown chmod 700 /home/ubuntu/.ssh/id_rsa.pub",
      "echo ======== End of SSH Key Install ===="
    ]
  }




}


resource "oci_core_instance" "postgresql" {
  #Required 
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_id      = var.compartment_ocid
  shape               = "VM.Standard.E4.Flex"

  #Optional

  display_name = "postgresql"

  create_vnic_details {
    #Required 
    subnet_id = oci_core_subnet.database.id

    #Optional
    display_name     = "primaryvnic"
    assign_public_ip = false
    hostname_label   = "postgresql"
    #private_ip       = "10.0.0.2"
  }

  source_details {
    source_type = "image"
    source_id   = data.oci_core_images.ubuntu_latest.images[0].id

    # Apply this to set the size of the boot volume that's created for this instance.
    # Otherwise, the default boot volume size of the image is used.
    # This should only be specified when source_type is set to "image".
    boot_volume_size_in_gbs = "100"
  }

  shape_config {

    #Optional
    #baseline_ocpu_utilization = var.instance_shape_config_baseline_ocpu_utilization
    memory_in_gbs = 16
    #nvmes = var.instance_shape_config_nvmes
    ocpus = 2
  }

  metadata = {
    ssh_authorized_keys = tls_private_key.key01.public_key_openssh # var.compute_ssh_authorized_keys #
    #user_data           = "${base64encode(data.template_file.cloud-config-postgres.rendered)}"

  }
  #preserve_boot_volume = true

  timeouts {
    create = "60m"
  }

  agent_config {
    plugins_config {
      desired_state = "ENABLED"
      name          = "Bastion"
    }
  }

  connection {
    type        = "ssh"
    host        = self.private_ip
    user        = "ubuntu"
    private_key = tls_private_key.key01.private_key_openssh # var.ssh_private_key # 

    bastion_host        = oci_core_instance.bastion.public_ip
    bastion_user        = "ubuntu"
    bastion_private_key = tls_private_key.key01.private_key_openssh # var.ssh_private_key # 
  }
  provisioner "file" {
    source      = "scripts/psqlinstall.sh"
    destination = "/tmp/psqlinstall.sh"
  }
  provisioner "remote-exec" {
    inline = [
      "echo ======== Postgresql Install ===========",
      "sudo chmod +x /tmp/psqlinstall.sh",
      "sudo /tmp/psqlinstall.sh",
      "echo ======== End of Postgresql Install ====",
    ]
  }
}

resource "oci_core_instance" "openproject" {
  #Required 
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[count.index % length(data.oci_identity_availability_domains.ads.availability_domains)].name #"NoEK:EU-FRANKFURT-1-AD-${count.index + 1}"
  compartment_id      = var.compartment_ocid
  shape               = "VM.Standard.E4.Flex"

  #Optional
  count        = var.appvmcount
  display_name = "openproject${count.index}"

  create_vnic_details {
    #Required 
    subnet_id = oci_core_subnet.application.id

    #Optional
    display_name     = "primaryvnic"
    assign_public_ip = false
    hostname_label   = "openproject${count.index}"
    #private_ip       = "10.0.0.2"
  }

  source_details {
    source_type = "image"
    source_id   = data.oci_core_images.ubuntu_latest.images[0].id

    # Apply this to set the size of the boot volume that's created for this instance.
    # Otherwise, the default boot volume size of the image is used.
    # This should only be specified when source_type is set to "image".
    boot_volume_size_in_gbs = "100"
  }

  shape_config {

    #Optional
    #baseline_ocpu_utilization = var.instance_shape_config_baseline_ocpu_utilization
    memory_in_gbs = 16
    #nvmes = var.instance_shape_config_nvmes
    ocpus = 2
  }

  metadata = {
    ssh_authorized_keys = tls_private_key.key01.public_key_openssh # var.compute_ssh_authorized_keys #
    #user_data           = "${base64encode(data.template_file.cloud-config-openproject.rendered)}"
  }
  #preserve_boot_volume = true

  timeouts {
    create = "60m"
  }
  agent_config {
    plugins_config {
      desired_state = "ENABLED"
      name          = "Bastion"
    }
  }

  depends_on = [oci_core_instance.postgresql]

  connection {
    type        = "ssh"
    host        = self.private_ip
    user        = "ubuntu"
    private_key = tls_private_key.key01.private_key_openssh # var.ssh_private_key # 

    bastion_host        = oci_core_instance.bastion.public_ip
    bastion_user        = "ubuntu"
    bastion_private_key = tls_private_key.key01.private_key_openssh # var.ssh_private_key # 
  }

  provisioner "file" {
    source      = "scripts/openinstall.sh"
    destination = "/tmp/openinstall.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "echo ====== Running OpenProject Install Script =========",
      "sudo chmod +x /tmp/openinstall.sh",
      "sudo /tmp/openinstall.sh",
      "echo ====== End OpenProject Install Script =========",
      "echo 'openproject/edition default\npostgres/autoinstall reuse\npostgres/db_host ${oci_core_instance.postgresql.private_ip}\npostgres/db_port 5432\npostgres/db_username openproject\npostgres/db_password WelCome2021##\npostgres/db_name openproject\nserver/autoinstall install\nserver/variant apache2\nserver/hostname openproject0\nserver/server_path_prefix /\nserver/ssl no\nrepositories/api-key kLZWMFqm1Kl8ct305Ifu728ICLwHgVnE\nrepositories/svn-install skip\nrepositories/git-install skip\nmemcached/autoinstall install\nopenproject/admin_email admin@example.net' | sudo tee -a sudo /etc/openproject/installer.dat",
      "sudo sleep ${count.index}5",
      "sudo openproject configure"
    ]
  }

}

data "template_file" "cloud-config-postgres" {
  template = <<YAML
#cloud-config
runcmd:
 - apt update
 - apt install -y postgresql postgresql-contrib
 - sudo -u postgres createuser openproject
 - sudo -u postgres createdb openproject
 - sudo -u postgres psql -c "alter user openproject with encrypted password 'WelCome2021##';"
 - sudo -u postgres psql -c "grant all privileges on database openproject to openproject;"
 - iptables -I INPUT 6 -m state --state NEW -p tcp --dport 5432 -j ACCEPT
 - netfilter-persistent save
 - echo "listen_addresses = '*'" >> /etc/postgresql/14/main/postgresql.conf
 - echo "host    all             all              0.0.0.0/0                       md5" >> /etc/postgresql/14/main/pg_hba.conf
 - echo "host    all             all              ::/0                            md5" >> /etc/postgresql/14/main/pg_hba.conf
 - service postgresql restart
YAML
}

data "template_file" "cloud-config-openproject" {
  template = <<YAML
#cloud-config
runcmd:
 - apt update
 - apt-get install apt-transport-https ca-certificates wget -y
 - wget -qO- https://dl.packager.io/srv/opf/openproject/key | apt-key add -
 - wget -O /etc/apt/sources.list.d/openproject.list https://dl.packager.io/srv/opf/openproject/stable/12/installer/ubuntu/22.04.repo
 - apt-get update -y
 - apt-get install openproject -y
 - iptables -I INPUT 6 -m state --state NEW -p tcp --dport 80 -j ACCEPT
 - netfilter-persistent save
 - echo "openproject/edition default" >> /etc/openproject/installer.dat
 - echo "postgres/autoinstall reuse" >> /etc/openproject/installer.dat
 - echo "postgres/db_host ${oci_core_instance.postgresql.private_ip}" >> /etc/openproject/installer.dat
 - echo "postgres/db_port 5432" >> /etc/openproject/installer.dat
 - echo "postgres/db_username openproject" >> /etc/openproject/installer.dat
 - echo "postgres/db_password WelCome2021##" >> /etc/openproject/installer.dat
 - echo "postgres/db_name openproject" >> /etc/openproject/installer.dat
 - echo "server/autoinstall install" >> /etc/openproject/installer.dat
 - echo "server/variant apache2" >> /etc/openproject/installer.dat
 - echo "server/hostname openproject0" >> /etc/openproject/installer.dat
 - echo "server/server_path_prefix /" >> /etc/openproject/installer.dat 
 - echo "server/ssl no" >> /etc/openproject/installer.dat
 - echo "repositories/api-key kLZWMFqm1Kl8ct305Ifu728ICLwHgVnE" >> /etc/openproject/installer.dat
 - echo "repositories/svn-install skip" >> /etc/openproject/installer.dat
 - echo "repositories/git-install skip" >> /etc/openproject/installer.dat
 - echo "memcached/autoinstall install" >> /etc/openproject/installer.dat
 - echo "openproject/admin_email admin@example.net" >> /etc/openproject/installer.dat
 - openproject configure >> /etc/openproject/vm_install.log
 - openproject configure >> /etc/openproject/vm_install2.log
YAML
}

resource "random_string" "random" {
  length           = 16
  special          = true
  override_special = "/@£$"
}

## Load Balancer

resource "oci_load_balancer_load_balancer" "openproject_lb" {
  compartment_id = var.compartment_ocid
  display_name   = "OpenProject-lb"

  ip_mode    = "IPV4"
  is_private = "false"
  shape      = "flexible"
  shape_details {
    minimum_bandwidth_in_mbps = 10
    maximum_bandwidth_in_mbps = 100
  }
  subnet_ids = [
    oci_core_subnet.dmz.id
  ]
}

resource "oci_load_balancer_backend_set" "openproject_load_balancer_set" {
  health_checker {
    interval_ms         = "10000"
    port                = "80"
    protocol            = "HTTP"
    response_body_regex = ""
    retries             = "3"
    return_code         = "200"
    timeout_in_millis   = "3000"
    url_path            = "/"
  }
  load_balancer_id = oci_load_balancer_load_balancer.openproject_lb.id
  name             = "openproject_load_balancer_set_LC"
  policy           = "ROUND_ROBIN"
}

resource "oci_load_balancer_backend" "openproject_instance_backend" {
  count            = var.appvmcount
  backendset_name  = oci_load_balancer_backend_set.openproject_load_balancer_set.name
  backup           = "false"
  drain            = "false"
  ip_address       = oci_core_instance.openproject[count.index].private_ip
  load_balancer_id = oci_load_balancer_load_balancer.openproject_lb.id
  offline          = "false"
  port             = "80"
  weight           = "1"
}

resource "oci_load_balancer_listener" "openproject_lb_listener" {
  connection_configuration {
    backend_tcp_proxy_protocol_version = "0"
    idle_timeout_in_seconds            = "60"
  }
  default_backend_set_name = oci_load_balancer_backend_set.openproject_load_balancer_set.name
  load_balancer_id         = oci_load_balancer_load_balancer.openproject_lb.id
  name                     = "openproject_listener_lb"
  port                     = "80"
  protocol                 = "HTTP"
}






