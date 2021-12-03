#!/usr/bin/env bash
# Filename: deploy.sh
cd tf/f5
terraform destroy --auto-approve -lock=false


cd ../k8s
terraform destroy --auto-approve -lock=false


