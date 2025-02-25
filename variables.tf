###############################
# .BASICS VARIABLES
variable "project_name" {
  type        = string
  description = "[REQUIRED] Name of an existing Project Name"

  validation {
    condition     = length(split("-", var.project_name)) == 5
    error_message = "Workspace Name cant respect naming conventions. In README.md we shown how to create a name to environment."
  }

  validation {
    condition     = can(regex("^[a-z]{3}\\d{1}$", split("-", var.project_name)[1]))
    error_message = "Environment defined in Name of the Workspace cant respect naming conventions. In README.md we shown how to create a name to environment."
  }

  validation {
    condition     = contains(["pro", "sta", "dev", "sha", "hub", "spk"], substr(split("-", var.project_name)[1], 0, 3))
    error_message = "Environment defined in Name of the Workspace cant respect naming conventions. The allowed values are: `pro`, `sta`, `dev`, `sha`, `hub` or `spk`."
  }

  validation {
    condition     = contains(["brse1", "brne1"], split("-", var.project_name)[2])
    error_message = "Region defined wihtout support in ours services. Only regions US and Brazil are permited. The allowed values are: `brse1` or `brne1`."
  }

  validation {
    condition     = length(split("-", var.project_name)[4]) == 3
    error_message = "Workspace Sequence cant respect naming conventions. The variable Worskapce Sequence be 3 (three) algarisms."
  }

  validation {
    condition     = tonumber(split("-", var.project_name)[4]) > 0 && tonumber(split("-", var.project_name)[4]) <= 999
    error_message = "Workspace Sequence cant respect naming conventions. The variable Worskapce Sequence be between 1 and 999."
  }
}

variable "sequence" {
  type        = number
  description = "[REQUIRED] Sequence to be used on resource naming."
  default     = 1
  validation {
    condition     = var.sequence > 0 && var.sequence <= 999
    error_message = "The variable sequence must be between 1 and 999."
  }
}

###############################
# .MODULE VARIABLE RESOURCES
variable "availability_zone" {
  type        = string
  description = "[OPTIONAL] The availability zone of the virtual machine instance."
  default     = null
}

variable "image" {
  type        = string
  description = "[REQUIRED] The image name used for the virtual machine instance."
  default     = "cloud-ubuntu-24.04 LTS"

  validation {
    condition     = contains(["cloud-ubuntu-24.04 LTS", "cloud-oraclelinux-9", "cloud-ubuntu-22.04 LTS", "cloud-rocky-09", "cloud-oraclelinux-8", "cloud-debian-12 LTS", "cloud-opensuse-15.6", "cloud-fedora-41", "cloud-fedora-40", "cloud-opensuse-15.5", "windows-server-2022"], var.image)
    error_message = "The allowed values are: `cloud-ubuntu-24.04 LTS`, `cloud-oraclelinux-9`, `cloud-ubuntu-22.04 LTS`, `cloud-rocky-09`, `cloud-oraclelinux-8`, `cloud-debian-12 LTS`, `cloud-opensuse-15.6`, `cloud-fedora-41`, `cloud-fedora-40`, `cloud-opensuse-15.5` or `windows-server-2022`."
  }
}

variable "machine_type" {
  type        = string
  description = "[REQUIRED] The machine type used for the virtual machine instance."
  default     = "BV1-1-10"

  validation {
    condition     = contains(["BV1-1-10", "BV1-1-20", "BV1-1-40", "BV1-1-100", "BV1-1-150", "BV1-2-10", "BV1-2-20", "BV1-2-40", "BV1-2-100", "BV1-2-150", "BV1-4-10", "BV1-4-20", "BV1-4-40", "BV1-4-100", "BV1-4-150", "BV2-2-10", "BV2-2-20", "BV2-2-40", "BV2-2-100", "BV2-2-150", "BV2-4-10", "BV2-4-20", "BV2-4-40", "BV2-4-100", "BV2-4-150", "BV2-8-10", "BV2-8-20", "BV2-8-40", "BV2-8-100", "BV2-8-150", "BV4-8-10", "BV4-8-20", "BV4-8-40", "BV4-8-100", "BV4-8-150", "BV4-16-10", "BV4-16-20", "BV4-16-40", "BV4-16-100", "BV4-16-150", "BV8-16-10", "BV8-16-20", "BV8-16-40", "BV8-16-100", "BV8-16-150", "BV8-32-10", "BV8-32-20", "BV8-32-40", "BV8-32-100", "BV8-32-150"], var.machine_type)
    error_message = "The allowed values are: `BV1-1-10`, `BV1-1-20`, `BV1-1-40`, `BV1-1-100`, `BV1-1-150`, `BV1-2-10`, `BV1-2-20`, `BV1-2-40`, `BV1-2-100`, `BV1-2-150`, `BV1-4-10`, `BV1-4-20`, `BV1-4-40`, `BV1-4-100`, `BV1-4-150`, `BV2-2-10`, `BV2-2-20`, `BV2-2-40`, `BV2-2-100`, `BV2-2-150`, `BV2-4-10`, `BV2-4-20`, `BV2-4-40`, `BV2-4-100`, `BV2-4-150`, `BV2-8-10`, `BV2-8-20`, `BV2-8-40`, `BV2-8-100`, `BV2-8-150`, `BV4-8-10`, `BV4-8-20`, `BV4-8-40`, `BV4-8-100`, `BV4-8-150`, `BV4-16-10`, `BV4-16-20`, `BV4-16-40`, `BV4-16-100`, `BV4-16-150`, `BV8-16-10`, `BV8-16-20`, `BV8-16-40`, `BV8-16-100`, `BV8-16-150`, `BV8-32-10`, `BV8-32-20`, `BV8-32-40`, `BV8-32-100` or `BV8-32-150`."
  }
}

variable "nic" {
  type = map(
    object(
      {
        enabled = bool
        vpc_id  = optional(string)
        public_ips = optional(
          map(
            object(
              {
                enabled     = bool
                description = optional(string)
              }
            )
          )
        )
        security_groups = map(
          object(
            {
              enabled               = bool
              description           = optional(string)
              disable_default_rules = bool
              rules = map(
                object(
                  {
                    description      = optional(string)
                    direction        = string
                    enabled          = bool
                    ethertype        = string
                    port_range_max   = optional(number)
                    port_range_min   = optional(number)
                    protocol         = optional(string)
                    remote_ip_prefix = string
                  }
                )
              )
            }
          )
        )
      }
    )
  )
  description = "[REQUIRED] Network Interface Card (NIC) to be used on resource."
  default = {
    "nic1" = {
      enabled = true
      public_ips = {
        "pip1" = {
          description = "Managed by Terraform."
          enabled     = false
        }
      }
      security_groups = {
        "default" = {
          description           = "Managed by Terraform."
          disable_default_rules = true
          enabled               = true
          rules = {
            "allow-office" = {
              description      = "Managed by Terraform."
              direction        = "ingress"
              enabled          = true
              ethertype        = "IPv4"
              protocol         = "tcp"
              remote_ip_prefix = "187.10.108.201/32"
            }
            "allow-http" = {
              description      = "Managed by Terraform."
              direction        = "ingress"
              enabled          = true
              ethertype        = "IPv4"
              port_range_max   = 80
              port_range_min   = 80
              protocol         = "tcp"
              remote_ip_prefix = "0.0.0.0/0"
            }
          }
        }
      }
    }
  }

  validation {
    condition = alltrue(
      flatten(
        [
          for key, value in var.nic : [
            for key2, value2 in value.security_groups : [
              for key3, value3 in value2.rules : [
                contains(["ingress", "egress"], value3.direction)
              ]
            ]
          ]
        ]
      )
    )
    error_message = "Allowed values: `ingress` or `egress`."
  }

  validation {
    condition = alltrue(
      flatten(
        [
          for key, value in var.nic : [
            for key2, value2 in value.security_groups : [
              for key3, value3 in value2.rules : [
                contains(["IPv4", "IPv6"], value3.ethertype)
              ]
            ]
          ]
        ]
      )
    )
    error_message = "Allowed values: `IPv4` or `IPv6`."
  }

  validation {
    condition = alltrue(
      flatten(
        [
          for key, value in var.nic : [
            for key2, value2 in value.security_groups : [
              for key3, value3 in value2.rules : [
                value3.port_range_max == null ? true : value3.port_range_max >= 1 && value3.port_range_max <= 65535
              ]
            ]
          ]
        ]
      )
    )
    error_message = "Valid values: 1-65535. Example: `22`."
  }

  validation {
    condition = alltrue(
      flatten(
        [
          for key, value in var.nic : [
            for key2, value2 in value.security_groups : [
              for key3, value3 in value2.rules : [
                value3.port_range_min == null ? true : value3.port_range_min >= 1 && value3.port_range_min <= 65535
              ]
            ]
          ]
        ]
      )
    )
    error_message = "Valid values: 1-65535. Example: `22`."
  }

  validation {
    condition = alltrue(
      flatten(
        [
          for key, value in var.nic : [
            for key2, value2 in value.security_groups : [
              for key3, value3 in value2.rules : [
                value3.protocol == null ? true : contains(["tcp", "udp", "icmp", "icmpv6"], value3.protocol)
              ]
            ]
          ]
        ]
      )
    )
    error_message = "Allowed values: `tcp`, `udp`, `icmp`, `icmpv6`. Example: `tcp`."
  }

  # validation {
  #   condition = alltrue(
  #     flatten(
  #       [
  #         for key, value in var.nic : [
  #           for key2, value2 in value.security_groups : [
  #             for key3, value3 in value2.rules : [
  #               can(cidrhost(value3.remote_ip_prefix, 32))
  #             ]
  #           ]
  #         ]
  #       ]
  #     )
  #   )
  #   error_message = "Must be valid IPv4 CIDR."
  # }
}

variable "ssh_key" {
  type        = string
  description = "[REQUIRED] SSH Key to be used on resource."
  default     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDaWZr3Ui3MJ57goKM7lWYPmjqYQCOgo2EUYW/a1Zqeo/EzaNhSOeP5r268bKKH6vkMdiTSksOpfr/XGZyf5idGQTUkgFXT0Kt79vhk5eZ/ce4BF4WoFZgr1XJCcsrtuQm3ybzkDV+qT7486LSbKHIr2e9j+t9M7EAbki+wMRV0p9I/3ACZ99YZw2kXODetfYuJxeBDplPgleoDo7aYXmoIuv8uZf/jcIUuDJ6/Pb7jvOHwtStuOCM14x5P1CAXHnLuW1KXdXHXPpSzUzhP57G8TGhzVghjnSHD9YCmc43v81BIN/HRdSr7dJ013uHrHISOWwq4z815YNZEmrVDoyl6zSnqn3DXN6zicfHJjz16s3z4knlXzuj9lXxesvYhWzsfuXN/y152XP+qFw4MfYVyllzBtzsotyFvNB9w2SxUCWKjFjLb1ckrRXEk5QwmlerkGFCWvUY2Qxpiw2f/VY4BgWZ4eT4bGoC5qlc7aTlkRiVJ8YHcRpmowKZl1dmViME= m@cloud"
}

variable "storage" {
  type = map(object({
    enabled           = bool
    size              = number
    type              = string
    availability_zone = optional(string)
    encrypted         = optional(bool)
    snapshot_id       = optional(string)
  }))
  description = "[OPTIONAL] One or more storage_data_disk blocks."
  default     = {}

  validation {
    condition = alltrue(
      flatten(
        [
          for key, value in var.storage : [
            contains(["cloud_nvme1k", "cloud_nvme5k", "cloud_nvme10k", "cloud_nvme15k", "cloud_nvme20k"], value.type)
          ]
        ]
      )
    )
    error_message = "The allowed values are: `cloud_nvme1k`, `cloud_nvme5k`, `cloud_nvme10k`, `cloud_nvme15k` or `cloud_nvme20k`."
  }
}

variable "vpc_id" {
  type        = string
  description = "[REQUIRED] VPC ID to be used on resource."
}
