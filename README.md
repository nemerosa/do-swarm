# Generation of a Docker Swarm in Digital Ocean

> Work in progress - still experimental.

## Overview

The goal is to create a Digital Ocean Docker Swarm.

## Prerequisites

Generate a Digital Ocean API key and expose it as a `TF_VAR_do_token` environment variable.

Generate a SSH key pair - your can use the `do-key.sh` script. The key pair will be generated with `do-key` and
`do-key.pub` names in the current directory.

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

### SSH to the Docker swarm

Run the `./do-swarm.sh` script to open a SSH session on the Docker Swarm master.

You can also append some commands to run them directy. For example:

```bash
./connect.sh docker service ls
```
