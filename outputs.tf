# Master IP
output "swarm_ip" {
  value = "${digitalocean_droplet.docker_swarm_master_initial.ipv4_address}"
}

output "swarm_user" {
  value = "${var.do_user}"
}
