# terraform-aws / aws_vpc 
Sample terraform state to management aws pvc

# Requirements (on host that executes module)
> Terraform v0.11.1

# How to use

Export enviroment variables with AWS credentials:
```sh
export AWS_ACCESS_KEY_ID=YOUR_AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY=YOUR_AWS_SECRET_ACCESS_KEY
```

Edit input.auto.tfvars file and set variables:
```sh
aws_region="eu-west-1"
aws_vpc_name = "example-vpc"
aws_vpc_cidr = "172.16.0.0/12" # Default 10.0.0.0/16
```

Run terraform:
```sh
terraform init
terraform plan
terraform apply
```

To destroy run:
```sh
terraform destroy
```
