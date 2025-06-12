# multivendor-project

Draw.io file :https://drive.google.com/file/d/1DEfiP5_Wgqw7MbjFItdOLXwHaE7lO4JL/view?usp=drive_link
---

## Network Architecture Overview

This project designs a network environment with clear segmentation for different functions and vendor simulations. Here is configured three vendors firewall under which two instances will be created.

### VPC Details

| Attribute      | Value                               |
| :------------- | :---------------------------------- |
| **Name** | `MULTIVENDOR-VPC` (from `var.vpc_name`) |
| **CIDR Block** | `172.16.0.0/16` (from `var.vpc_cidr`) |
| **DNS Support** | Enabled                             |
| **DNS Hostnames** | Enabled                             |
| **Tags** | `Project: MULTIVENDOR-PROJECT`, `Name: LAB`, `Vendor: ALL` |

### Subnets

All subnets are created within the `us-east-1a` Availability Zone and have `map_public_ip_on_launch` set to `false`.

| Name                | CIDR Block       | Vendor    |
| :------------------ | :--------------- | :-------- |
| `PUBLIC-SUBNET`     | `172.16.5.0/24`  | `ALL`     |
| `MANAGEMENT-SUBNET` | `172.16.10.0/24` | `ALL`     |
| `VENDOR1-SUBNET`    | `172.16.101.0/24`| `VENDOR1` |
| `VENDOR2-SUBNET`    | `172.16.102.0/24`| `VENDOR2` |
| `VENDOR3-SUBNET`    | `172.16.103.0/24`| `VENDOR3` |

### Security Groups

Only one security group is created and applied to all network interfaces:

| Name                        | Description                                     |
| :-------------------------- | :---------------------------------------------- |
| `MULTIVENDOR-INSTANCE-SG` | Security group for instances in the MULTIVENDOR project |

**Inbound Rules:**
* **Port 22 (SSH):** TCP from `0.0.0.0/0` (anywhere)
* **Port 3389 (RDP):** TCP from `0.0.0.0/0` (anywhere)

**Outbound Rules:**
* **All Traffic:** All protocols, all ports, to `0.0.0.0/0` (anywhere)

### Network Interfaces (ENIs)

ENIs are created using `aws_network_interface.multi_interfaces`. Each ENI is attached to the `MULTIVENDOR-INSTANCE-SG` security group and has `source_dest_check` disabled.

| Name                                | Subnet              | Private IP Suffix (e.g., `.10` or `.11`) | Primary (is_primary) | Vendor    |
| :---------------------------------- | :------------------ | :--------------------------------------- | :------------------- | :-------- |
| `VENDOR1-VICTIM-WIN-PRIMARY-ENI`    | `VENDOR1-SUBNET`    | `10`                                     | `true`               | `VENDOR1` |
| `VENDOR1-VICTIM-WIN-MGMT-ENI`       | `MANAGEMENT-SUBNET` | `10`                                     | `false`              | `VENDOR1` |
| `VENDOR1-VICTIM-UBUNTU-PRIMARY-ENI` | `VENDOR1-SUBNET`    | `11`                                     | `true`               | `VENDOR1` |
| `VENDOR1-VICTIM-UBUNTU-MGMT-ENI`    | `MANAGEMENT-SUBNET` | `11`                                     | `false`              | `VENDOR1` |
| `VENDOR2-VICTIM-WIN-PRIMARY-ENI`    | `VENDOR2-SUBNET`    | `10`                                     | `true`               | `VENDOR2` |
| `VENDOR2-VICTIM-WIN-MGMT-ENI`       | `MANAGEMENT-SUBNET` | `12`                                     | `false`              | `VENDOR2` |
| `VENDOR2-VICTIM-UBUNTU-PRIMARY-ENI` | `VENDOR2-SUBNET`    | `11`                                     | `true`               | `VENDOR2` |
| `VENDOR2-VICTIM-UBUNTU-MGMT-ENI`    | `MANAGEMENT-SUBNET` | `13`                                     | `false`              | `VENDOR2` |
| `VENDOR3-VICTIM-WIN-PRIMARY-ENI`    | `VENDOR3-SUBNET`    | `10`                                     | `true`               | `VENDOR3` |
| `VENDOR3-VICTIM-WIN-MGMT-ENI`       | `MANAGEMENT-SUBNET` | `14`                                     | `false`              | `VENDOR3` |
| `VENDOR3-VICTIM-UBUNTU-PRIMARY-ENI` | `VENDOR3-SUBNET`    | `10`                                     | `true`               | `VENDOR3` |
| `VENDOR3-VICTIM-UBUNTU-MGMT-ENI`    | `MANAGEMENT-SUBNET` | `15`                                     | `false`              | `VENDOR3` |

### EC2 Instances

The project currently deploys Ubuntu 24.04 LTS (Noble Numbat) instances. Each instance will have its specified ENIs attached. Elastic IPs will be allocated and associated with the **primary ENI** of each Ubuntu instance for public access.

| Instance Name           | Type       | Vendor    | Attached ENIs (by key)                                                               | EIP Attached to ENI                                   |
| :---------------------- | :--------- | :-------- | :----------------------------------------------------------------------------------- | :---------------------------------------------------- |
| `VENDOR1-VICTIM-UBUNTU` | `t2.micro` | `VENDOR1` | `VENDOR1-VICTIM-UBUNTU-PRIMARY-ENI`, `VENDOR1-VICTIM-UBUNTU-MGMT-ENI`                 | `VENDOR1-VICTIM-UBUNTU-PRIMARY-ENI`                   |
| `VENDOR2-VICTIM-UBUNTU` | `t2.micro` | `VENDOR2` | `VENDOR2-VICTIM-UBUNTU-PRIMARY-ENI`, `VENDOR2-VICTIM-UBUNTU-MGMT-ENI`                 | `VENDOR2-VICTIM-UBUNTU-PRIMARY-ENI`                   |
| `VENDOR3-VICTIM-UBUNTU` | `t2.micro` | `VENDOR3` | `VENDOR3-VICTIM-UBUNTU-PRIMARY-ENI`, `VENDOR3-VICTIM-UBUNTU-MGMT-ENI`                 | `VENDOR3-VICTIM-UBUNTU-PRIMARY-ENI`                   |

**Note:** The Windows instances (`VENDORx-VICTIM-WIN-PRIMARY-ENI`, `VENDORx-VICTIM-WIN-MGMT-ENI`) are currently defined as ENIs but are **not yet associated with any `aws_instance` resources** in the provided `main.tf`. You'd need to add similar `aws_instance` blocks for them, referencing their respective ENI keys and an appropriate Windows AMI.

---

## Configuration

All customizable aspects are managed via variables in `variables.tf`.

### Key Variables to Review in `variables.tf`

* **`key_pair_name`**: **This is mandatory.** Set its `default` value to the exact name of an existing EC2 Key Pair in your AWS account. This key pair is essential for SSH access to your Linux instances.
    ```terraform
    variable "key_pair_name" {
      description = "The name of the EC2 Key Pair to allow SSH access."
      type        = string
      default     = "your-actual-ssh-key-name" # <--- IMPORTANT: Change this!
    }
    ```
* **`instance_configs`**: This map defines the specifics of each EC2 instance. You can add or modify instance configurations here, including their types and which ENIs they should attach.
* **`subnet_configs`** and **`network_interface_configs`**: Adjust these maps to define additional subnets or ENIs, or to change their properties as needed for your simulation.

---

## Deployment

Follow these steps to deploy the infrastructure:

1.  **Initialize Terraform:**
    Navigate to the project root directory in your terminal and run:
    ```bash
    terraform init
    ```
    This command initializes the working directory, downloads the necessary AWS provider, and configures the S3 backend. Make sure your S3 backend bucket (`udbhas-terraform-state-20250607` in `us-east-1`) exists before running `terraform init`.

2.  **Review the Plan:**
    Generate an execution plan to see what Terraform will create, modify, or destroy:
    ```bash
    terraform plan
    ```
    **Carefully review the output.** Ensure that Terraform plans to create the resources you expect. Pay close attention to any warnings or errors.

3.  **Apply the Configuration:**
    If the plan looks correct, apply the changes to your AWS account:
    ```bash
    terraform apply
    ```
    You will be prompted to confirm the action by typing `yes`.

---

## Cleanup

To destroy all the resources created by this Terraform configuration, run:

```bash
terraform destroy
