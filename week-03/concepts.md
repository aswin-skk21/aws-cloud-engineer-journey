# Week 3 concepts in the PropertyLite deployment

| Concept | What it means here |
|---|---|
| AMI | The Amazon Linux 2023 machine image supplied the operating system for the EC2 instance. An image is a starting template; subsequent app setup came from user data. |
| Instance type | `t3.micro` defined the instance's CPU and memory capacity. It was enough for this three-row teaching API, but I would check actual CPU, memory, and network demand before sizing a production service. |
| Security group | The stateful firewall on the instance admitted SSH only from my current `/32` and the demo API on TCP 8080. Return traffic for allowed connections was handled automatically. |
| Network ACL | A stateless subnet-level rule set. Both inbound and outbound paths must permit traffic. I left the default VPC ACL unchanged for this lab. |
| EBS | The instance root disk persisted independently of the running process. Its `DeleteOnTermination` flag was true, and I created a point-in-time snapshot before teardown. |
| User data | The boot script installed the app and registered a `systemd` service. EC2 user data normally runs on first launch, so reboot persistence came from `systemd`, not from re-running the script. |

The key operational distinction is that the API process can be restarted without rebuilding the instance, while a new instance needs the bootstrap script (or a prepared image) to recreate its software. The snapshot captures disk blocks, but restoring service still requires instance/network configuration.
