SET language hrvatski
DECLARE @start date='2024/01/01'
	, @end date ='2030/01/01';

WITH datumi(dat) AS (
      SELECT Datum=DATEADD(day, number, @start)
      FROM master..spt_values
      WHERE type = 'P' AND number <= datediff(day, @start, @end)
), izracun as (SELECT dat as datum
	, ROW_NUMBER() over (partition by month(dat) order by year(dat)) as kojidan
FROM datumi
WHERE DATENAME(WEEKDAY, dat)='petak' )
SELECT convert(varchar, datum, 104)	
FROM izracun
WHERE kojidan=1
ORDER by datum
