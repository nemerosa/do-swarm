## Digital Ocean credentials

variable "do_token" {
  description = "Your DigitalOcean API key"
}

## Digital Ocean settings

variable "do_region" {
  description = "DigitalOcean Region"
  default = "fra1"
}

variable "do_image" {
  description = "Image slug"
  default = "docker-16-04"
}

variable "do_agent_size" {
  description = "Agent Droplet Size"
  default = "2GB"
}

variable "do_ssh_key_public" {
  description = "Path to the SSH public key"
  default = "./do-key.pub"
}

variable "do_ssh_key_private" {
  description = "Path to the SSH private key"
  default = "./do-key"
}

variable "do_user" {
  description = "User to use to connect the machine using SSH. Depends on the image being installed."
  default = "root"
}

## Swarm setup

variable "swarm_tags" {
  type = "list"
  description = "List of tags to associate to all nodes in the cluster"
  default = [ "application:swarm" ]
}

variable "swarm_token_dir" {
  description = "Path (on the remote machine) which contains the generated swarm tokens"
  default = "/root"
}

variable "swarm_name" {
  description = "Name of the cluster, used also for networking"
  default = "swarm"
}

variable "swarm_master_count" {
  description = "Number of additional master nodes (at least one is created)."
  default = "0"
}

variable "swarm_agent_count" {
  description = "Number of agents to deploy"
  default = "2"
}
