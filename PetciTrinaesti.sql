SET language hrvatski
DECLARE @start date='2024/01/01'
	, @end date ='2030/01/01';

WITH datumi(dat) AS (
      SELECT Datum=DATEADD(day, number, @start)
      FROM master..spt_values
      WHERE type = 'P' AND number <= datediff(day, @start, @end)
)
SELECT *
FROM datumi
WHERE DATENAME(WEEKDAY, dat)='petak' and day(dat)=13
ORDER by dat
