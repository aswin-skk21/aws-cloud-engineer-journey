# Week 4 runbook — S3, RDS MySQL, and DynamoDB

**Date:** 2026-10-13
**Region:** us-east-1
**Scope:** Short-lived training resources in a dedicated AWS account/VPC. The source export was cleared for this lab. The raw SQL and database password are excluded from this folder and from Git.

## Lab 4.1 — S3 lifecycle

I created a private, uniquely named S3 bucket and blocked all public access. I uploaded the Week 3 runbook as `runbook.md`, listed the object, and confirmed it was still in S3 Standard storage. I added an enabled `archive-after-30-days` lifecycle rule that transitions eligible objects to Glacier Flexible Retrieval after 30 days. The same-day lab cannot prove a future transition; the evidence confirms the rule was accepted and enabled.

Commands used (replace the bucket name with your own if repeating):

```sh
aws s3api create-bucket --bucket <unique-training-bucket> --region us-east-1
aws s3 cp week-03/runbook.md s3://<unique-training-bucket>/runbook.md
aws s3 ls s3://<unique-training-bucket>/
aws s3api get-bucket-lifecycle-configuration --bucket <unique-training-bucket>
```

## Lab 4.2 — Private RDS MySQL and safe training data

I created a MySQL 8.0.46 `db.t3.micro` RDS instance with 20 GiB of storage and no public endpoint. Its inbound TCP 3306 rule names the temporary EC2 security group as its source, so only that instance can reach the database. The client runs on the Week 3 EC2 instance in the same VPC. The database password is in a restricted temporary file, never in these documents or a repository.

The licensed 658 MB production export has 126 columns and real identifiers. The handbook's 17-column deletion list omits other potentially identifying fields, including `L_DisplayId` and free-text `L_Remarks`. I therefore used an allowlist: the sanitized table contains only synthetic `L_ListingID`, `L_City`, `L_Keyword2`, `LM_Dec_3`, `LM_Int2_3`, `L_SystemPrice`, and `L_Status`. [sanitize.sql](sanitize.sql) shows the transformation. I compare raw and sanitized row counts before dropping the raw table, then verify the final schema and aggregate output. The raw SQL is streamed over SSH to the EC2 client; it is never saved on the instance or uploaded to S3.

The database lab is temporary. The raw table exists only during import and transformation, and the full RDS instance is deleted after the evidence is recorded.

## Lab 4.3 — DynamoDB lookup

I created `Properties` with `L_ListingID` as a string partition key and `PAY_PER_REQUEST` billing. I loaded one row from the sanitized RDS table and read it back with `get-item`. The item contains only fields from the allowlist. See [evidence.md](evidence.md) for the returned item.

## Debug Lab 4.4 — RDS connection timeout

For a timeout, I would verify the RDS instance is `available`, the EC2 client and RDS are in the same VPC, and the RDS security group allows inbound TCP 3306 from the EC2 security group ID. I would also check the EC2 outbound rule and any network ACL restrictions. I would distinguish a timeout from `Access denied`, which means the network path works but the credentials or database grants need attention. Keeping RDS nonpublic does not block EC2 clients in the VPC when the security groups allow them.

## Cleanup

I deleted the DynamoDB table, RDS instance without a final snapshot (the training copy was disposable), S3 lifecycle rule and object while still in Standard storage, and the bucket. I also terminated the temporary EC2 client and removed its key pair, EBS snapshot, security groups, and local credentials. See [evidence.md](evidence.md) for final checks.
