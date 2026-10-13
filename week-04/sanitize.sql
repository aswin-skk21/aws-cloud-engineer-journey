-- Run only against the dedicated Week 4 training_data database immediately
-- after importing the licensed raw dump. Do not run analysis on the raw table.
-- Keep only the columns the training API and aggregate query need.
USE training_data;
DROP TABLE IF EXISTS training_properties;
CREATE TABLE training_properties (
  L_ListingID VARCHAR(20) NOT NULL PRIMARY KEY,
  L_City VARCHAR(50),
  L_Keyword2 INT,
  LM_Dec_3 DECIMAL(4,1),
  LM_Int2_3 INT,
  L_SystemPrice INT,
  L_Status VARCHAR(50)
);
INSERT INTO training_properties
  (L_ListingID, L_City, L_Keyword2, LM_Dec_3, LM_Int2_3, L_SystemPrice, L_Status)
SELECT CONCAT('R', 100000 + numbered.rn), numbered.L_City,
       numbered.L_Keyword2, numbered.LM_Dec_3, numbered.LM_Int2_3,
       numbered.L_SystemPrice, numbered.L_Status
FROM (
  SELECT ROW_NUMBER() OVER (ORDER BY id, L_ListingID) AS rn,
         L_City, L_Keyword2, LM_Dec_3, LM_Int2_3, L_SystemPrice, L_Status
  FROM rets_property
) AS numbered;
-- Before dropping the raw table, compare these counts. If different, stop.
SELECT (SELECT COUNT(*) FROM rets_property) AS imported_rows,
       (SELECT COUNT(*) FROM training_properties) AS sanitized_rows;
-- Execute the following only when counts match:
-- DROP TABLE rets_property;
-- RENAME TABLE training_properties TO rets_property;
-- DESCRIBE rets_property;
-- SELECT L_City, COUNT(*), AVG(L_SystemPrice)
--   FROM rets_property GROUP BY L_City ORDER BY 2 DESC LIMIT 10;
