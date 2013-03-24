#!/bin/sh

if [[ !-d ~/.ssh ]]; then
  mkdir ~/.ssh
  chmod 700 ~/.ssh
fi
ssh-keygen -t rsa -b 4096
