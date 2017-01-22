#!/bin/bash

rm -f do-key,do-key.pub
ssh-keygen -t rsa -f ./do-key -N ""
