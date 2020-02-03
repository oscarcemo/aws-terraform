#!/usr/bin/env bash

case $1 in
    prod|production)
        echo "Please enter the aws_access_key followed by ENTER:"
        read aws_access_key 
        echo "aws_access_key = \"$aws_access_key\"" >> ./terraform/prod/terraform.tfvars
        export AWS_ACCESS_KEY_ID=$aws_access_key
        echo "Please enter the aws_secret_key followed by ENTER:"
        read aws_secret_key 
        echo "aws_secret_key = \"$aws_secret_key\"" >> ./terraform/prod/terraform.tfvars
        export AWS_SECRET_ACCESS_KEY=$aws_secret_key
        echo "Please enter the the public key to propagate to all the ec2 instances followed by ENTER:"
        read public_key 
        echo "public_key = \"$public_key\"" >> ./terraform/prod/terraform.tfvars
        cd packer
        packer build new_ami.json
        cd ../terraform/prod/
        terraform init
        terraform workspace new prod
        terraform apply
        ;;
    dev|devolpment)
        echo "Please enter the aws_access_key followed by ENTER:"
        read aws_access_key 
        echo "aws_access_key = \"$aws_access_key\"" >> ./terraform/dev/terraform.tfvars
        export AWS_ACCESS_KEY_ID=$aws_access_key
        echo "Please enter the aws_secret_key followed by ENTER:"
        read aws_secret_key 
        echo "aws_secret_key = \"$aws_secret_key\"" >> ./terraform/dev/terraform.tfvars
        export AWS_SECRET_ACCESS_KEY=$aws_secret_key
        echo "Please enter the the public key to propagate to all the ec2 instances followed by ENTER:"
        read public_key 
        echo "public_key = \"$public_key\"" >> ./terraform/dev/terraform.tfvars
        echo "packer pushing image"
        cd packer
        packer build new_ami.json
        cd ../terraform/dev/
        terraform init
        terraform workspace new dev
        terraform apply
        ;;
    *)
        echo "run the script with the correct environment 'dev' or 'prod'"
        exit 0
        ;;
esac
