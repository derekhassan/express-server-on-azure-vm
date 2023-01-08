# Express Web Server on Azure Virtual Machine

This project contains a simple Express web server and the infrastructure to create a virtual machine with Node.js and Nginx installed. There is also a GitHub Action to copy the files over `rsync` and restart the server over `ssh`.

## Getting Started

### Running the Express Server Locally

1. `npm install` all dependencies
2. `npm run dev` to run server in dev mode

### Provisioning the Infrastructure

1. `cd` into the `infrastructure` directory
2. `terraform init` to initialize Terraform
3. `terraform plan` to check what additions/modifications Terraform plans to make
4. `terraform apply` to apply the changes to your infrastructure
5. `terraform destroy` to destroy your infrastructure

### Connecting to the VM

Once you have provisioned the infrastructure, you can SSH into your VM using the output variables. First we will create an ssh key file to use when connecting to the VM:

```sh
terraform output -raw ssh_private_key > ssh_key && chmod 400 ssh_key
```

Next, using the file created in the previous step, we can connect to our VM with the following command:

```sh
ssh -i ssh_key $(terraform output -raw vm_username)@$(terraform output -raw vm_ip_address)
```

### Setting up the GitHub Action

The GitHub Action requires 3 secrets:

-   `HOST` (the IP address of the VM)
-   `SSH_KEY_BASE64` (the ssh private key generated from Terraform as a base 64 string)
-   `USERNAME` (the username of the VM)

You can get the all these secrets from the terraform output by running `terraform output -raw <output name>`. For the base64 encoded SSH key, we can easily convert this to base 64 with the linux command `terraform output -raw ssh_private_key | base64`.
