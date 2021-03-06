# Master IP
output "swarm_ip" {
  value = "${digitalocean_droplet.docker_swarm_master_initial.ipv4_address}"
}

# All master IPs
output "swarm_ips" {
  value = ["${digitalocean_droplet.docker_swarm_master.*.ipv4_address}"]
}

output "swarm_user" {
  value = "${var.do_user}"
}

# ID of the master Droplet
output "swarm_primary_droplet_id" {
  value = "${digitalocean_droplet.docker_swarm_master_initial.id}"
}
