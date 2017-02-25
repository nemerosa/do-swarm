##################################################################################################################
# Digital Ocean provider
##################################################################################################################

provider "digitalocean" {
  token = "${var.do_token}"
}

##################################################################################################################
# SSH Key
##################################################################################################################

resource "digitalocean_ssh_key" "docker_swarm_ssh_key" {
  name = "${var.swarm_name}-ssh-key"
  public_key = "${file(var.do_ssh_key_public)}"
}

##################################################################################################################
# All node tags
##################################################################################################################

resource "digitalocean_tag" "docker_swarm_tags" {
  count = "${length(var.swarm_tags)}"
  name = "${var.swarm_tags[count.index]}"
}

resource "digitalocean_tag" "docker_swarm_tag_name" {
  name = "swarm-name:${var.swarm_name}"
}

resource "digitalocean_tag" "docker_swarm_tag_role_master" {
  name = "swarm-role:master"
}

resource "digitalocean_tag" "docker_swarm_tag_role_agent" {
  name = "swarm-role:agent"
}

resource "digitalocean_tag" "docker_swarm_tag_master_tag" {
  name = "swarm-master-tag:${var.swarm_name}-master"
}

##################################################################################################################
# Initial master node
##################################################################################################################

resource "digitalocean_droplet" "docker_swarm_master_initial" {
  count = 1
  name = "${format("${var.swarm_name}-master-%02d", count.index)}"

  image = "${var.do_image}"
  size = "${var.do_agent_size}"
  region = "${var.do_region}"
  private_networking = true

  user_data = <<EOF
#cloud-config
ssh_authorized_keys:
  - "${file("${var.do_ssh_key_public}")}"
EOF

  ssh_keys = [
    "${digitalocean_ssh_key.docker_swarm_ssh_key.id}"
  ]

  tags = [
    "${digitalocean_tag.docker_swarm_tag_name.id}",
    "${digitalocean_tag.docker_swarm_tag_role_master.id}",
    "${digitalocean_tag.docker_swarm_tag_master_tag.id}",
    "${digitalocean_tag.docker_swarm_tags.*.id}",
  ]

  connection {
    user = "${var.do_user}"
    private_key = "${file(var.do_ssh_key_private)}"
    agent = false
  }

  provisioner "remote-exec" {
    inline = [
      "docker swarm init --advertise-addr ${self.ipv4_address_private}",
      "docker swarm join-token --quiet worker > ${var.swarm_token_dir}/do-swarm-worker.token",
      "docker swarm join-token --quiet manager > ${var.swarm_token_dir}/do-swarm-manager.token"
    ]
  }

  provisioner "local-exec" {
    command = "scp -o StrictHostKeyChecking=no -o NoHostAuthenticationForLocalhost=yes -o UserKnownHostsFile=/dev/null -i ${var.do_ssh_key_private} ${var.do_user}@${self.ipv4_address}:${var.swarm_token_dir}/do-swarm-worker.token ."
  }

  provisioner "local-exec" {
    command = "scp -o StrictHostKeyChecking=no -o NoHostAuthenticationForLocalhost=yes -o UserKnownHostsFile=/dev/null -i ${var.do_ssh_key_private} ${var.do_user}@${self.ipv4_address}:${var.swarm_token_dir}/do-swarm-manager.token ."
  }

  provisioner "remote-exec" {
    inline = [
      "curl -sSL https://dl.bintray.com/emccode/rexray/install | sh -s -- stable"
    ]
  }

}

##################################################################################################################
# Other masters
##################################################################################################################

resource "digitalocean_droplet" "docker_swarm_master" {
  count = "${var.swarm_master_count}"
  name = "${format("${var.swarm_name}-master-%02d", count.index + 1)}"

  image = "${var.do_image}"
  size = "${var.do_agent_size}"
  region = "${var.do_region}"
  private_networking = true

  user_data = <<EOF
#cloud-config

ssh_authorized_keys:
  - "${file("${var.do_ssh_key_public}")}"
EOF

  ssh_keys = [
    "${digitalocean_ssh_key.docker_swarm_ssh_key.id}"]

  tags = [
    "${digitalocean_tag.docker_swarm_tag_name.id}",
    "${digitalocean_tag.docker_swarm_tag_role_master.id}",
    "${digitalocean_tag.docker_swarm_tag_master_tag.id}",
    "${digitalocean_tag.docker_swarm_tags.*.id}",
  ]

  connection {
    user = "${var.do_user}"
    private_key = "${file(var.do_ssh_key_private)}"
    agent = false
  }

  provisioner "file" {
    source = "do-swarm-manager.token"
    destination = "${var.swarm_token_dir}/do-swarm-manager.token"
  }

  provisioner "remote-exec" {
    inline = [
      "docker swarm join --token $(cat ${var.swarm_token_dir}/do-swarm-manager.token) ${digitalocean_droplet.docker_swarm_master_initial.ipv4_address_private}:2377"
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "curl -sSL https://dl.bintray.com/emccode/rexray/install | sh -s -- stable"
    ]
  }
}

##################################################################################################################
# Swarm agents
##################################################################################################################

resource "digitalocean_droplet" "docker_swarm_agent" {
  count = "${var.swarm_agent_count}"
  name = "${format("${var.swarm_name}-agent-%02d", count.index)}"

  image = "${var.do_image}"
  size = "${var.do_agent_size}"
  region = "${var.do_region}"
  private_networking = true

  user_data = <<EOF
#cloud-config

ssh_authorized_keys:
  - "${file("${var.do_ssh_key_public}")}"
EOF

  ssh_keys = [
    "${digitalocean_ssh_key.docker_swarm_ssh_key.id}"]

  tags = [
    "${digitalocean_tag.docker_swarm_tag_name.id}",
    "${digitalocean_tag.docker_swarm_tag_role_agent.id}",
    "${digitalocean_tag.docker_swarm_tags.*.id}",
  ]

  connection {
    user = "${var.do_user}"
    private_key = "${file(var.do_ssh_key_private)}"
    agent = false
  }

  provisioner "file" {
    source = "do-swarm-worker.token"
    destination = "${var.swarm_token_dir}/do-swarm-worker.token"
  }

  provisioner "remote-exec" {
    inline = [
      "docker swarm join --token $(cat ${var.swarm_token_dir}/do-swarm-worker.token) ${digitalocean_droplet.docker_swarm_master_initial.ipv4_address_private}:2377"
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "curl -sSL https://dl.bintray.com/emccode/rexray/install | sh -s -- stable"
    ]
  }
}
