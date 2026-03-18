# DataSync Agent Deployment Test

This is a minimal test example to verify the DataSync agent modules work correctly.

## What This Creates

1. VPC with a public subnet
2. DataSync agent EC2 instance (m6a.2xlarge, Enhanced mode)
3. Elastic IP for the agent
4. Security group with required ports
5. Activated DataSync agent registered with AWS

## How to Test

### 1. Navigate to this directory
```bash
cd examples/test-agent-deployment
```

### 2. Initialize Terraform
```bash
terraform init
```

### 3. Review the plan
```bash
terraform plan
```

### 4. Deploy
```bash
terraform apply
```

Type `yes` when prompted.

### 5. Wait for completion
The deployment takes about 5-10 minutes:
- EC2 instance creation: ~2 minutes
- Agent boot time: ~2-3 minutes
- Activation: ~1 minute

### 6. Verify the outputs
```bash
terraform output
```

You should see:
- `agent_public_ip` - The public IP of the agent
- `agent_arn` - The ARN of the activated agent (this confirms activation worked!)
- `agent_instance_id` - The EC2 instance ID

### 7. Verify in AWS Console

**EC2 Console:**
- Go to EC2 → Instances
- Find the instance named "test-datasync-agent"
- Verify it's running

**DataSync Console:**
- Go to DataSync → Agents
- Find the agent named "test-datasync-agent"
- Status should be "Online"

### 8. Clean up
```bash
terraform destroy
```

Type `yes` when prompted.

## Expected Costs

While running:
- EC2 m6a.2xlarge: ~$0.35/hour (~$8.40/day)
- EBS volume: ~$0.10/GB/month
- Elastic IP: Free while attached

**Total: ~$10-15 for a full day of testing**

## Troubleshooting

### Activation Fails

If you see an error like "timeout while waiting for agent activation":

1. **Wait longer**: The agent needs 2-3 minutes to boot after EC2 instance is ready
2. **Check security group**: Port 80 must be open from your IP
3. **Verify AMI**: The SSM parameter might not exist in your region

Try running `terraform apply` again - it will retry activation.

### AMI Not Found

If you see "SSM parameter not found":
- The DataSync agent AMI might not be available in your region
- Try a different region (us-east-1, us-west-2 are most likely to work)
- Check AWS documentation for DataSync agent availability

### Instance Type Not Available

If m6a.2xlarge is not available in your region:
- Edit `main.tf` and change `instance_type = "m5.2xlarge"`
- m5.2xlarge is more widely available

## What to Test

1. ✅ **Module loads**: `terraform init` succeeds
2. ✅ **Plan works**: `terraform plan` shows resources to create
3. ✅ **Deployment succeeds**: `terraform apply` completes
4. ✅ **Agent activates**: `agent_arn` output is populated
5. ✅ **Agent is online**: Check DataSync console
6. ✅ **Cleanup works**: `terraform destroy` removes everything

## Next Steps

After verifying this works:
1. Create NFS/SMB location modules
2. Create a full example with on-premises storage
3. Test actual data transfers
