# terraform-aws / aws-peering-connections
Sample terraform state to management aws pvc peering connections over two region in same account

# Requirements (on host that executes module)
> Terraform v0.11.1

# Default variables
```sh
variable aws_region_a {
    default = "eu-west-1"
}
variable aws_region_b {
    default = "us-east-1"
}
variable aws_vpc_region_a {
    default = "eu-west-1-vpc"
}
variable aws_vpc_region_b {
    default = "us-east-1-vpc"
}
variable aws_vpc_cidr_a {
    default = "10.1.0.0/16"
}
variable aws_vpc_cidr_b {
    default = "10.2.0.0/16"
}
```
You can edit variable file for change default values, or override variables in to input.auto.tfvars file.

# How to use

Update submodules
```sh
git submodule update --init --recursive
```

Export enviroment variables with AWS credentials:
```sh
export AWS_ACCESS_KEY_ID=YOUR_AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY=YOUR_AWS_SECRET_ACCESS_KEY
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
