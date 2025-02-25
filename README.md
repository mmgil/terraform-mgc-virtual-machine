# INTRODUCTION

**PROJECT**: IaC (Infrastructure as a Code) with terraform for deploying azure resource group

## What Is Terraform?

Terraform is an infrastructure as code (IaC) tool that allows you to build, change, and version infrastructure safely and efficiently. This includes both low-level components like compute instances, storage, and networking, as well as high-level components like DNS entries and SaaS features.

## What Is MGC Virtual Machine?

Magalu Cloud Virtual Machines operate trought a virtualization infrastructure that allows multiples Operational Systems and Applications to run on a single server. Each VM is isolated and indepentent, allowing users to have full control over their computing environment.

[more](https://docs.magalu.cloud/docs/computing/virtual-machine/overview)

# NAMING CONVENTIONS

An effective naming convention consists of resource names from important information about each resource. A good name helps you quickly identify the resource's type, associated workload, environment, and the region hosting it.

In our environment we adopt the following convention:

| Business Cost Center (any characters) | Environment (3 characters and 1 number) | Azure Region (4 characters) | Resource Type (5 characters max) | Instance (3 characters) |
| ----------------------------------- | --------------------------------------- | --------------------------- | -------------------------------- | :---------------------: |

Environments possibles:

| Name        | Acronym | Description                                         |
| ----------- | ------- | --------------------------------------------------- |
| Production  | pro1    | Production Environment                              |
| Staging     | sta1    | Homologation Environment                            |
| Development | dev1    | Development Environment                             |
| Shared      | sha1    | Shared Environment                                  |
| hub         | hub1    | Transit Environment to network resources            |
| Spoke       | spk1    | Hub Environment to traffic requests to on-premisses |

Magalu Cloud Region (5 characters) according this table:

| ACRONYM | REGION            |
| ------- | ----------------- |
| `brse1`  | `br-se1`         |
| `brne1`  | `br-ne1`         |

For example, a virtual machine for a business costcenter called cliente01 for a production workload in the Brasil Sudeste Region might be cliente01-pro1-brse1-prj-001.

cliente01-pro1-brse1-prj-001

# INSTALL TERRAFORM

## Linux

### Ubuntu

```bash
  curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
  sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
  sudo apt-get update && sudo apt-get install terraform
  terraform version
```

### CentOS/RHEL/Oracle Linux

```bash
  sudo yum install -y yum-utils
  sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
  sudo yum -y install terraform
  terraform version
```

## Windows

```powershell
 Invoke-WebRequest -Uri https://releases.hashicorp.com/terraform/1.1.9/terraform_1.1.9_windows_amd64.zip -OutFile terraform.zip
 Expand-Archive .\terraform.zip -DestinationPath C:\Windows\System32\ -Force
 terraform version
```

# AUTHENTICATING IN HASHICORP ENVIRONMENT

We are using hashicorp's SAAS to host the service states. By default, Terraform will obtain an API token and save it in plain text in a local CLI configuration file called credentials.tfrc.json. When you run terraform login, it will explain specifically where it intends to save the API token and give you a chance to cancel if the current configuration is not as desired.

You can get more details about these features from the following links:

[CLI Authentication](https://www.terraform.io/cli/auth)

[terraform login](https://www.terraform.io/cli/commands/login)

[CLI Configuration File](https://www.terraform.io/cli/config/config-file)

You can find the API Token that has already been generated in the environment in our keepass and configure your CLI as follows:

**In Windows**:

```powershell
@"
{
  "credentials": {
    "app.terraform.io": {
      "token": "SEE IN THE KEEPASS OR CONSULTE OURS ADMINS"
    }
  }
}
"@ | Set-Content ~\AppData\Roaming\terraform.d\credentials.tfrc.json
```

**In Linux**:

```bash
cat <<EOF | tee ~/.terraform.d/credentials.tfrc.json
{
  "credentials": {
    "app.terraform.io": {
      "token": "SEE IN THE KEEPASS OR CONSULTE OURS ADMINS"
    }
  }
}
EOF
```

# AUTHENTICATING IN MAGALU CLOUD

If workspace in Hashicorp's environment is configured to operate locally, you will need to authenticate to the API of the Magalu Cloud using an API KEY.

You can more information how to generate this API KEY in [Create API Key](https://docs.magalu.cloud/docs/devops-tools/api-keys/how-to/other-products/create-api-key)

In our environment we use the credentials as environment variables to autenticate in API of the Magalu Cloud, for example:

**Linux**:

```bash
  export MGC_API_KEY="00000000-0000-0000-0000-000000000000"
```

**Windows**:

```powershell
  $env:MGC_API_KEY="00000000-0000-0000-0000-000000000000"
```

To persist environment variables at user level

```powershell
  [System.Environment]::SetEnvironmentVariable("MGC_API_KEY","00000000-0000-0000-0000-000000000000","User")
```

To persist environment variables at machine level

```powershell
  [System.Environment]::SetEnvironmentVariable("MGC_API_KEY","00000000-0000-0000-0000-000000000000","Machine")
```

**ATTENTION**: On Linux operating systems it is not possible to persist environment variables

By declaring these environment variables, terraform will be able to authenticate through this SPN

# MODULE DOCUMENTATION

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_mgc"></a> [mgc](#requirement\_mgc) | 0.32.2 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_mgc"></a> [mgc](#provider\_mgc) | 0.32.2 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [mgc_block_storage_volume_attachment.attach](https://registry.terraform.io/providers/MagaluCloud/mgc/0.32.2/docs/resources/block_storage_volume_attachment) | resource |
| [mgc_block_storage_volumes.storage](https://registry.terraform.io/providers/MagaluCloud/mgc/0.32.2/docs/resources/block_storage_volumes) | resource |
| [mgc_network_public_ips.pip](https://registry.terraform.io/providers/MagaluCloud/mgc/0.32.2/docs/resources/network_public_ips) | resource |
| [mgc_network_public_ips_attach.pip](https://registry.terraform.io/providers/MagaluCloud/mgc/0.32.2/docs/resources/network_public_ips_attach) | resource |
| [mgc_network_security_groups.secgroup](https://registry.terraform.io/providers/MagaluCloud/mgc/0.32.2/docs/resources/network_security_groups) | resource |
| [mgc_network_security_groups_attach.attach](https://registry.terraform.io/providers/MagaluCloud/mgc/0.32.2/docs/resources/network_security_groups_attach) | resource |
| [mgc_network_security_groups_rules.rules](https://registry.terraform.io/providers/MagaluCloud/mgc/0.32.2/docs/resources/network_security_groups_rules) | resource |
| [mgc_network_vpcs_interfaces.nic](https://registry.terraform.io/providers/MagaluCloud/mgc/0.32.2/docs/resources/network_vpcs_interfaces) | resource |
| [mgc_ssh_keys.key](https://registry.terraform.io/providers/MagaluCloud/mgc/0.32.2/docs/resources/ssh_keys) | resource |
| [mgc_virtual_machine_instances.vm](https://registry.terraform.io/providers/MagaluCloud/mgc/0.32.2/docs/resources/virtual_machine_instances) | resource |
| [mgc_virtual_machine_interface_attach.attach_vm](https://registry.terraform.io/providers/MagaluCloud/mgc/0.32.2/docs/resources/virtual_machine_interface_attach) | resource |
| [mgc_availability_zones.availability_zones](https://registry.terraform.io/providers/MagaluCloud/mgc/0.32.2/docs/data-sources/availability_zones) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_availability_zone"></a> [availability\_zone](#input\_availability\_zone) | [OPTIONAL] The availability zone of the virtual machine instance. | `string` | `null` | no |
| <a name="input_image"></a> [image](#input\_image) | [REQUIRED] The image name used for the virtual machine instance. | `string` | `"cloud-ubuntu-24.04 LTS"` | no |
| <a name="input_machine_type"></a> [machine\_type](#input\_machine\_type) | [REQUIRED] The machine type used for the virtual machine instance. | `string` | `"BV1-1-10"` | no |
| <a name="input_nic"></a> [nic](#input\_nic) | [REQUIRED] Network Interface Card (NIC) to be used on resource. | <pre>map(<br>    object(<br>      {<br>        enabled = bool<br>        vpc_id  = optional(string)<br>        public_ips = optional(<br>          map(<br>            object(<br> {<br>                enabled     = bool<br>                description = optional(string)<br>              }<br>            )<br>          )<br>        )<br>        security_groups = map(<br>          object(<br>            {<br>              enabled               = bool<br>              description           = optional(string)<br>              disable_default_rules = bool<br>              rules = map(<br>                object(<br> {<br>                    description      = optional(string)<br>                    direction        = string<br>                    enabled          = bool<br>                    ethertype        = string<br>                    port_range_max   = optional(number)<br>                    port_range_min   = optional(number)<br>                    protocol         = optional(string)<br>                    remote_ip_prefix = string<br>                  }<br>                )<br>              )<br>            }<br>          )<br>        )<br>      }<br>    )<br>  )</pre> | <pre>{<br>  "nic1": {<br>    "enabled": true,<br>    "public_ips": {<br>      "pip1": {<br>        "description": "Managed by Terraform.",<br>        "enabled": false<br>      }<br>    },<br>    "security_groups": {<br>      "default": {<br>        "description": "Managed by Terraform.",<br>        "disable_default_rules": true,<br>        "enabled": true,<br>        "rules": {<br>          "allow-http": {<br>            "description": "Managed by Terraform.",<br>            "direction": "ingress",<br>            "enabled": true,<br>            "ethertype": "IPv4",<br>            "port_range_max": 80,<br>            "port_range_min": 80,<br>            "protocol": "tcp",<br>            "remote_ip_prefix": "0.0.0.0/0"<br>          },<br>          "allow-office": {<br>            "description": "Managed by Terraform.",<br>            "direction": "ingress",<br>            "enabled": true,<br>            "ethertype": "IPv4",<br>            "protocol": "tcp",<br>            "remote_ip_prefix": "187.10.108.201/32"<br>          }<br>        }<br>      }<br>    }<br>  }<br>}</pre> | no |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | [REQUIRED] Name of an existing Project Name | `string` | n/a | yes |       
| <a name="input_sequence"></a> [sequence](#input\_sequence) | [REQUIRED] Sequence to be used on resource naming. | `number` | `1` | no |
| <a name="input_ssh_key"></a> [ssh\_key](#input\_ssh\_key) | [REQUIRED] SSH Key to be used on resource. | `string` | `"ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDaWZr3Ui3MJ57goKM7lWYPmjqYQCOgo2EUYW/a1Zqeo/EzaNhSOeP5r268bKKH6vkMdiTSksOpfr/XGZyf5idGQTUkgFXT0Kt79vhk5eZ/ce4BF4WoFZgr1XJCcsrtuQm3ybzkDV+qT7486LSbKHIr2e9j+t9M7EAbki+wMRV0p9I/3ACZ99YZw2kXODetfYuJxeBDplPgleoDo7aYXmoIuv8uZf/jcIUuDJ6/Pb7jvOHwtStuOCM14x5P1CAXHnLuW1KXdXHXPpSzUzhP57G8TGhzVghjnSHD9YCmc43v81BIN/HRdSr7dJ013uHrHISOWwq4z815YNZEmrVDoyl6zSnqn3DXN6zicfHJjz16s3z4knlXzuj9lXxesvYhWzsfuXN/y152XP+qFw4MfYVyllzBtzsotyFvNB9w2SxUCWKjFjLb1ckrRXEk5QwmlerkGFCWvUY2Qxpiw2f/VY4BgWZ4eT4bGoC5qlc7aTlkRiVJ8YHcRpmowKZl1dmViME= m@cloud"` | no |
| <a name="input_storage"></a> [storage](#input\_storage) | [OPTIONAL] One or more storage\_data\_disk blocks. | <pre>map(object({<br>    enabled           = bool<br>    size              = number<br>    type              = string<br>    availability_zone = optional(string)<br>    encrypted         = optional(bool)<br>    snapshot_id       = optional(string)<br>  }))</pre> | `{}` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | [REQUIRED] VPC ID to be used on resource. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_resources"></a> [resources](#output\_resources) | n/a |


# DOCUMENTATION

Some of this documentation was generated through terraform-docs using the following command:

```bash
  docker run --rm --volume "$(pwd):/terraform-docs" quay.io/terraform-docs/terraform-docs:0.16.0 markdown /terraform-docs
```
