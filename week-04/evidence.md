# Week 4 evidence — 2026-10-13

| Check | Observed result |
|---|---|
| S3 bucket | `idx-training-aswin-820567439337-20261013` created with public access blocked |
| S3 object | `runbook.md` listed, 3,763 bytes, still in Standard storage |
| Lifecycle rule | `archive-after-30-days` returned `Enabled`, transition at 30 days to `GLACIER` (Glacier Flexible Retrieval) |
| DynamoDB table | `Properties` reached `ACTIVE`; `L_ListingID` is the string partition key; `PAY_PER_REQUEST` billing |
| RDS instance | MySQL 8.0.46 `training-db`, private endpoint; reached `available` |

The lifecycle transition itself cannot be observed in a same-day lab. The rule was verified through the S3 API. The object will be removed before the 30-day transition to avoid early Glacier deletion charges.

## RDS import and DynamoDB item

The RDS client negotiated TLS (`TLS_AES_256_GCM_SHA384`). The licensed export imported **55,212** rows. The allowlist transformation produced **55,212** rows; the counts matched before I dropped the raw table and renamed the sanitized table to `rets_property`. `SHOW COLUMNS` returned exactly these seven fields: `L_ListingID`, `L_City`, `L_Keyword2`, `LM_Dec_3`, `LM_Int2_3`, `L_SystemPrice`, `L_Status`. The synthetic IDs ranged from `R100001` to `R155212`, with **0** IDs outside the `R1%` pattern. The source dump remains outside this deliverable and was never committed or placed on the EC2 disk.

The requested aggregate query returned city and average-price results, including:

| City | Listings | Average list price |
|---|---:|---:|
| Los Angeles | 4,015 | 2,639,425.06 |
| San Diego | 2,198 | 1,151,292.52 |
| San Jose | 1,047 | 1,387,793.29 |

A cleaned row was loaded into DynamoDB and retrieved with consistent `GetItem`:

```json
{
  "L_ListingID": {"S": "R100001"},
  "L_City": {"S": "Beverly Hills"},
  "L_Keyword2": {"N": "4"},
  "L_SystemPrice": {"N": "3950000"}
}
```

## Teardown verification

Final AWS checks returned **absent** for the RDS instance, RDS subnet group, DynamoDB table, S3 bucket, both training security groups, EBS root volume, EBS snapshot, and EC2 key pair. The EC2 instance was `terminated`. The local PEM, database password, and MySQL client configuration files were removed. AWS billing data can lag resource deletion, so this confirms resource cleanup rather than a final charge amount.
