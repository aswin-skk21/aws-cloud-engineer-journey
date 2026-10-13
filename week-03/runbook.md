# Week 3 runbook — PropertyLite on EC2

**Date:** 2026-10-13
**Region:** us-east-1
**Purpose:** Boot the supplied PropertyLite API on one Amazon Linux 2023 EC2 instance, verify its public endpoint, practice a root-volume snapshot, and remove the lab resources.

## 1. Prepare the launch

I used the current Amazon Linux 2023 x86_64 AMI from AWS Systems Manager Parameter Store, a t3.micro instance, the account's default VPC, and one public subnet. I created a dedicated temporary RSA key pair. The private key remained in a restricted local work folder with mode `400`; it was never committed or uploaded to S3.

I created a security group with two inbound rules:

| Port | Source | Reason |
|---|---|---|
| TCP 22 | My current public IP `/32` | SSH administration during the lab |
| TCP 8080 | `0.0.0.0/0` | Test the PropertyLite API from my laptop |

The 8080 rule exposes a training Flask server and is appropriate only for this short lab. For a durable deployment, I would put the API behind a load balancer, use HTTPS, and restrict direct instance access.

## 2. Bootstrap PropertyLite

I passed [user-data.sh](user-data.sh) at launch. It installs Python and Flask 3.0.3, writes the exact Week 0 PropertyLite app and three-row sample CSV into `/opt/property-api`, and registers a `systemd` service. The service starts at boot and restarts if the process fails. This is more reliable than a background `nohup` command.

After the instance reached `running` and status checks passed, I checked the bootstrap log and service from SSH:

```sh
chmod 400 training-key.pem
ssh -i training-key.pem ec2-user@<public-ip>
sudo systemctl status property-api --no-pager
sudo tail -n 40 /var/log/property-api-bootstrap.log
```

From my laptop I checked both endpoints:

```sh
curl --fail --show-error http://<public-ip>:8080/health
curl --fail --show-error http://<public-ip>:8080/properties/R100234
```

Expected results are `{"status":"ok"}` and the Sacramento `R100234` listing. Actual results are recorded in [evidence.md](evidence.md).

## 3. Snapshot the root volume

I found the EBS volume attached as `/dev/xvda` to the instance, created a manual snapshot, and waited for `completed`. A new volume made from that snapshot would contain the root volume's blocks at snapshot time; to boot it as a replacement, I would attach it as the root device of a compatible EC2 instance and confirm its OS/application configuration.

The snapshot is a point-in-time EBS backup, not a substitute for a database backup or a tested restore. I removed this training snapshot after recording its completion.

## 4. Diagnose an SSH timeout

First I would confirm the instance is `running`, has passed status checks, and still has a public IPv4 address. Then I would compare my present public IP with the security group's TCP 22 `/32` rule. I would also inspect the subnet route to an internet gateway and the network ACL. A stale “My IP” rule is a likely cause when switching networks: it stores one IP address at creation time and does not update automatically. I would replace the rule with the new `/32`, keeping SSH limited to my address.

A timeout points to a network path or filtering problem. A permission error for the PEM file, a rejected key, and an authentication error are different failures and need different fixes.

## 5. Cleanup

I kept the instance only long enough to act as the Week 4 RDS client. Then I terminated it, checked that its root EBS volume was deleted, removed the manual snapshot, deleted the security group, and deleted the training key pair and local private key. The cleanup outcome is recorded in [evidence.md](evidence.md).

## Reference

- [EC2 user data behavior](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/user-data.html)
