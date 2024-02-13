SET LANGUAGE hrvatski;
GO

CREATE OR ALTER FUNCTION dbo.VratiDatumUskrsa (@godina INT) -- function from: https://medium.com/@diangermishuizen/calculate-easter-sunday-dynamically-using-sql-447235cb8906
RETURNS DATE
AS
BEGIN
    DECLARE @varA TINYINT, @varB TINYINT, @varC TINYINT, @varD TINYINT, @varE TINYINT, @varF TINYINT, @varG TINYINT
		  , @varH TINYINT, @varI TINYINT, @varK TINYINT, @varL TINYINT, @varM TINYINT,  @datumUskrsa DATE;    
	SELECT @varA = @godina % 19, @varB = FLOOR(1.0 * @godina / 100), @varC = @godina % 100;
    SELECT @varD = FLOOR(1.0 * @varB / 4), @varE = @varB % 4, @varF = FLOOR((8.0 + @varB) / 25);
    SELECT  @varG = FLOOR((1.0 + @varB - @varF) / 3);
    SELECT @varH = (19 * @varA + @varB - @varD - @varG + 15) % 30, @varI = FLOOR(1.0 * @varC / 4), @varK = @godina % 4;
    SELECT  @varL = (32.0 + 2 * @varE + 2 * @varI - @varH - @varK) % 7;
    SELECT @varM = FLOOR((1.0 * @varA + 11 * @varH + 22 * @varL) / 451);
    SELECT  @datumUskrsa = DATEADD(dd, (@varH + @varL - 7 * @varM + 114) % 31, DATEADD(mm, FLOOR((1.0 * @varH + @varL - 7 * @varM + 114) / 31) - 1, DATEADD(yy, @godina - 2000, {d '2000-01-01' })));
    RETURN @datumUskrsa;
END;
GO
DECLARE @start DATE=dateadd(year, datediff(year, 0, getdate()), 0);
DECLARE @end DATE=dateadd(year, datediff(year, 0, getdate()), 364);

DECLARE 
	@Uskrs date;
	SELECT @Uskrs= dbo.VratiDatumUskrsa(YEAR(GETDATE()));
DECLARE
    @CistaSrijeda date = dateadd(day, -46, @Uskrs),
	@Cvjetnica date = dateadd(day, -7, @Uskrs),
    @VelikaSubota date = dateadd(day, -1, @Uskrs),
	@VelikiPetak date = dateadd(day, -2, @Uskrs),
    @VelikiCetvrtak date = dateadd(day, -3, @Uskrs);

DECLARE @datumi TABLE (
    Dat DATE PRIMARY KEY,
    [Broj dana] INT,
    [Dan u tjednu] NVARCHAR(20),
    [TipDana] NVARCHAR(60),
    racunaSe nvarchar(20)
);

INSERT INTO @datumi (Dat, [Broj dana], [Dan u tjednu], [TipDana], racunaSE)
SELECT
    Dat
    , ROW_NUMBER() OVER (ORDER BY Dat) as 'Broj dana'
    , DATENAME(weekday, Dat) as 'Dan u tjednu'
	, CASE
        WHEN Dat=@CistaSrijeda THEN 'PEPELNICA'
        WHEN Dat = @Cvjetnica THEN 'CVJETNICA'
        WHEN Dat = @VelikiCetvrtak THEN 'VELIKI ČETVRTAK'
        WHEN Dat = @VelikiPetak THEN 'VELIKI PETAK'
        WHEN Dat = @VelikaSubota THEN 'VELIKA SUBOTA'
        WHEN Dat = @Uskrs THEN 'USKRS'
        WHEN DATENAME(weekday, Dat) = 'nedjelja' THEN 'NEDJELJA'
        ELSE 'običan dan korizme'
    END as TipDana
    , racunaSE=CASE 
        WHEN Dat=@Uskrs THEN 'USKRS'
        WHEN Dat IN (@VelikiCetvrtak, @VelikiPetak, @VelikaSubota) THEN 'računa se'
        WHEN DATENAME(weekday, Dat) = 'nedjelja' THEN 'NE računa se'
        ELSE 'računa se'
    END
FROM (
    SELECT TOP (DATEDIFF(day, @start, @end) + 1) Dat=DATEADD(day, ROW_NUMBER() OVER (ORDER BY a.object_id) - 1, @start)
    FROM sys.all_objects a
    CROSS JOIN sys.all_objects b
) d;

SELECT
    Datum=CONVERT(varchar, Dat, 104) + '.'
   -- , [Broj dana]
    , [Dan u tjednu]
    --, [Radni dan]
	--, ObracunskiDan
    , [Tip dana]=[TipDana]
    , [Broj korizmenog dana]=
        CASE
            WHEN racunaSe='Uskrs' THEN 'USKRS'
        	WHEN racunaSe ='računa se' 
                THEN CONVERT(nvarchar, ROW_NUMBER() OVER (PARTITION BY racunaSe ORDER BY Dat))
        	ELSE 'ne računa se'
        END 
    ,  [Dana do Uskrsa] = 
            CASE 
            WHEN Dat = @Uskrs THEN 'USKRS'
            ELSE CONVERT(nvarchar, DATEDIFF(day, Dat, @Uskrs)) 
        END
FROM @datumi
WHERE Dat BETWEEN @CistaSrijeda AND @Uskrs
ORDER BY Dat;
