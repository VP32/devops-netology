#!/bin/bash

set -e

function delete_vm {
  local NAME=$1
  $(yc compute instance delete --name="$NAME")
}

delete_vm "master1"
delete_vm "master2"
delete_vm "master3"
delete_vm "node1"
delete_vm "node2"
delete_vm "node3"
delete_vm "node4"
