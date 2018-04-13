# Terraform Bitcoin nodes on AWS
Easy terraform setup for Bitcoin nodes on AWS.

## Requirements
To start using this tool you need [Terraform](https://www.terraform.io) installed. On macOS with `homebrew` installed you can simply run:

```
$ brew install terraform
```

## How to configure
Terraform will ask specific tokens that are missing (Like the DigitalOcean Token), but it is possible to change the amount of nodes or their size by modifying the file called `variables.tf`.

## How to run
Clone this repository and then you can get an overview of what will be executed by running

```
$ terraform plan
```

If the planned changes are what you wanted, you can apply them by using the following command:

```
$ terraform apply
```
