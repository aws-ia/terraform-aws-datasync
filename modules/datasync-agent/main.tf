##################################
## Activate DataSync Agent      ##
##################################

# Wait for the agent EC2 instance to fully boot and start its HTTP server on port 80
resource "time_sleep" "wait_for_agent" {
  create_duration = var.agent_boot_wait

  depends_on = [var.agent_depends_on]
}

# Retrieve the activation key from the agent via HTTP
# Using activation_key instead of ip_address avoids EOF issues with the provider's built-in HTTP client
data "http" "activation" {
  url = "http://${var.agent_ip_address}/?gatewayType=SYNC&activationRegion=${var.activation_region}&no_redirect"

  retry {
    attempts     = 5
    min_delay_ms = 30000
    max_delay_ms = 60000
  }

  depends_on = [time_sleep.wait_for_agent]
}

# Activate the DataSync agent using the retrieved activation key
resource "aws_datasync_agent" "agent" {
  activation_key = trimspace(data.http.activation.response_body)
  name           = var.agent_name

  # Optional: VPC endpoint configuration for private connectivity
  vpc_endpoint_id       = var.vpc_endpoint_id
  private_link_endpoint = var.private_link_endpoint
  security_group_arns   = var.security_group_arns
  subnet_arns           = var.subnet_arns

  tags = var.tags
}
