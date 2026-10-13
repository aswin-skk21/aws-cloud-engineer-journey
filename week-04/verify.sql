-- Run after sanitize.sql has replaced the raw table with the allowlisted table.
USE training_data;
SHOW TABLES;
DESCRIBE rets_property;
SELECT COUNT(*) AS rows_kept,
       MIN(L_ListingID) AS first_synthetic_id,
       MAX(L_ListingID) AS last_synthetic_id,
       SUM(L_ListingID NOT LIKE 'R1%') AS non_synthetic_ids
FROM rets_property;
SELECT L_City, COUNT(*) AS listings, AVG(L_SystemPrice) AS average_price
FROM rets_property
GROUP BY L_City
ORDER BY listings DESC
LIMIT 10;
