# VPC Peering Requester Module

This Terraform module creates a VPC peering connection request from your Braintrust VPC (source) to another VPC (destination). This module handles the requester side of the VPC peering connection, including setting up the necessary routes in your VPC's route tables.

A common use case is to peer your Braintrust VPC with your production VPC in a different AWS account. After peering is set up you will still need to add security group rules to allow traffic between the two VPCs.

WARNING: This module requires coordination with the destination VPC owner to complete the peering connection. It will require multiple terraform applies and sharing of variables.

Steps:
1. Copy the module definition into a new file called `peering.tf` along side your existing terraform code for the Braintrust data plane.
  a. Ask the destination VPC owner for the `destination_account_id`, `destination_vpc_id`, `destination_cidr`, and `destination_region`.
2. Set `initiate_request_only` to `true` and run `terraform apply`.
3. Note the `vpc_peering_connection_id` from the outputs and share it with the destination VPC owner.
4. Wait for the destination VPC owner to accept the peering request. They should apply the `vpc-peering-accepter` module in their account.
4. Set `initiate_request_only` to `false` and run `terraform apply` again. Your VPCs are now peered.
5. Set up any security group rules needed to allow traffic between the two VPCs. This module does not handle security group rules.


## Example Usage

```hcl
module "vpc_peering_requester" {
  source = "./modules/vpc-peering-requester"

  # Set this to true on your first apply. Set it to false after the peering request has been accepted.
  initiate_request_only = true

  source_vpc_id           = module.braintrust-data-plane.main_vpc_id
  source_route_table_ids  = [
    module.braintrust-data-plane.main_vpc_public_route_table_id,
    module.braintrust-data-plane.main_vpc_private_route_table_id
  ]

  # Get these details from the destination VPC owner
  destination_account_id  = ""
  destination_vpc_id      = ""
  destination_cidr        = ""
  destination_region      = ""
}
```

## Prerequisites

- You must have access to both AWS accounts (source and destination) or at least be in in communication with the destination VPC owner.
- The CIDR blocks of the source and destination VPCs must not overlap
- The necessary IAM permissions to create VPC peering connections and modify route tables

## Input Variables

| Name | Description | Type | Required |
|------|-------------|------|----------|
| `source_vpc_id` | The ID of your VPC | `string` | Yes |
| `source_route_table_ids` | The IDs of the route tables in your VPC that you want to be able to communicate with the destination VPC | `list(string)` | Yes |
| `destination_account_id` | The account ID of the destination VPC you will be requesting to peer with | `string` | Yes |
| `destination_vpc_id` | The ID of the destination VPC you will be requesting to peer with | `string` | Yes |
| `destination_cidr` | The CIDR block of the destination VPC you will be requesting to peer with | `string` | Yes |
| `destination_region` | The region of the destination VPC you will be requesting to peer with | `string` | Yes |
| `initiate_request_only` | When set to true, only creates the peering request without setting up routes. Set to false after the peering request is accepted to create routes. | `bool` | Yes |

## Outputs

| Name | Description |
|------|-------------|
| `vpc_peering_connection_id` | The ID of the VPC Peering Connection. Share this with the destination VPC owner to peer with them. |

## Important Notes

1. The `initiate_request_only` variable is crucial for the two-step setup process:
   - First apply: Set to `true` to only create the peering request
   - Second apply: Set to `false` after the request is accepted to create the routes
2. This module only creates the peering request. The owner of the destination VPC must accept the peering request for the connection to become active.
3. DNS resolution between VPCs is enabled by default in both the requester and accepter configurations.
4. The module will automatically create routes in the specified source route tables to direct traffic to the destination VPC.
5. Make sure to configure the corresponding routes in the destination VPC's route tables (this is handled by the `vpc-peering-accepter` module).
