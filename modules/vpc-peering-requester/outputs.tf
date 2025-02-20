output "vpc_peering_connection_id" {
  description = "The ID of the VPC Peering Connection. Share this with the destination VPC owner to peer with them."
  value       = aws_vpc_peering_connection.requester.id
}
