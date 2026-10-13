# Week 4 concepts in the PropertyLite data lab

| Concept | What it means here |
|---|---|
| S3 Standard | The runbook object remained immediately accessible during the lab. This was the appropriate class for a newly uploaded file that I needed to list and remove the same day. |
| S3 Standard-IA | A lower storage price for infrequently accessed objects, with retrieval and minimum-duration considerations. It would be a poor fit for a tiny, short-lived lab file. |
| S3 Glacier Flexible Retrieval | Archival storage with a restore step before normal access. The 30-day lifecycle rule was configured, but not allowed to execute before teardown; archived objects carry a 90-day minimum storage duration charge. |
| Lifecycle rule | An automated policy that changes storage class or expires objects after an age threshold. A configured rule does not prove the transition happened. |
| Versioning | Keeps multiple versions when an S3 object is replaced or deleted. It was not necessary for this disposable lab bucket, so I left it off. |
| RDS Multi-AZ | A high-availability deployment with a standby in another Availability Zone and automatic failover. This single-AZ training database did not provide that availability. |
| DynamoDB partition key | `L_ListingID` is the exact string required for direct `GetItem` access. It should have high cardinality and distribute requests well in a larger workload. |
| DynamoDB capacity mode | `PAY_PER_REQUEST` bills for actual requests and avoids choosing provisioned read/write units for a brief, unpredictable lab. |

For the current app, RDS supports the SQL city/price aggregate, while DynamoDB demonstrates direct listing-ID lookup. Neither database is wired into the Week 3 Flask app yet; that change belongs to the later capstone in the handbook.
