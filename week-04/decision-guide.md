# Week 4 storage and database decision guide

| Service | What it stores / exposes | Use this when… | Key consideration |
|---|---|---|---|
| Amazon S3 | Objects reached through an API | You need durable files, exports, backups, or static assets that do not need a mounted disk. | Choose a storage class and lifecycle rule for the access pattern; Glacier retrieval is delayed and has minimum storage duration charges. |
| Amazon EBS | Block volume attached to an EC2 instance | One instance needs a boot disk or low-latency persistent application disk. | Volumes belong to an Availability Zone; snapshots are needed for a portable backup. |
| Amazon EFS | Shared file system mounted over NFS | Several compute instances need concurrent access to the same files. | Network and mount permissions matter; it usually costs more than object storage for archive data. |
| Amazon RDS for MySQL | Managed relational database | Data needs SQL joins, constraints, transactions, and familiar MySQL tooling. | Put it on private networking, restrict port 3306 to client security groups, and plan backups and instance/storage cost. |
| Amazon DynamoDB | Managed key-value/document table | Access is primarily by a known partition key and traffic may vary widely. | Design keys from access patterns; scans and hot partitions can be costly or slow. |

For PropertyLite's listings, S3 fits the runbook upload, EBS fits the EC2 root disk, RDS fits SQL aggregate queries over listings, and DynamoDB fits direct lookup by synthetic `L_ListingID`. EFS is unnecessary for this small API because its instances do not share a filesystem.

## Lab notes

- The S3 rule is configured to move eligible objects to Glacier Flexible Retrieval after 30 days. This short lab verifies the rule configuration; a transition cannot be observed during same-day teardown.
- The RDS training copy keeps only the seven fields needed by PropertyLite and the lab's aggregate query. I remove raw identifying columns and real listing IDs before any data analysis. The original `rets_property.sql` never belongs in Git or this deliverable.
- The sample DynamoDB item comes from the sanitized RDS table, keyed by its synthetic listing ID.
- At teardown, I delete the DynamoDB table, RDS instance, S3 lifecycle rule/object/bucket, and the temporary EC2 client. Deleting a Glacier object early would incur a minimum-duration charge, so the S3 object is removed while it is still in Standard storage.

## References

- [S3 lifecycle transition considerations](https://docs.aws.amazon.com/AmazonS3/latest/userguide/lifecycle-transition-general-considerations.html)
- [Connecting EC2 and RDS with security groups](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/tutorial-ec2-rds-option3.html)
