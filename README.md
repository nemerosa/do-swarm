# Generation of a Docker Swarm in Digital Ocean

> Work in progress - still experimental.

## Overview

The goal is to create a Digital Ocean Docker Swarm.

## Prerequisites

Generate a Digital Ocean API key and expose it as a `TF_VAR_do_token` environment variable.

Generate a SSH key pair - your can use the `do-key.sh` script. The key pair will be generated with `do-key` and
`do-key.pub` names in the current directory.

## Docker Droplet image

At the time of writing, Digital Ocean does not provide yet a ready-to-go
image for Docker 1.13, only for Docker 1.12.

See the appendixes below to build your custom image with
[Packer](https://www.packer.io/).

## Configuration

All configuration items are exposed as [Terraform variables](https://www.terraform.io/docs/configuration/variables.html)
in the `variables.tf` file. Read their description to get their meaning. Most of them have default values.

## Creating the swarm

In the local directory, just run:

```bash
terraform apply
```

## Remaining actions

- [ ] Storage - planning to use [REX-Ray](https://github.com/codedellemc/rexray),
waiting for issue [197](https://github.com/codedellemc/libstorage/issues/197)
to be closed.

## Appendixes

### Building the Digital Ocean image

Export your Digital Ocean token:

```bash
export DIGITALOCEAN_API_TOKEN=[...]
```

and run:

```bash
packer build -machine-readable \
   packer-ubuntu-docker.json \
   | tee packer-ubuntu-docker.log
```

The region to create the image into is set to `fra1` by default, but you
can change it by adding the following command line option:

```bash
-var 'do_region=...'
```

### SSH to the Docker swarm

Run the `./do-swarm.sh` script to open a SSH session on the Docker Swarm master.

You can also append some commands to run them directy. For example:

```bash
./connect.sh docker service ls
```
