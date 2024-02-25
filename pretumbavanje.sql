CREATE OR ALTER PROCEDURE [shema].[barcodeUpdate] @paket nvarchar(255) AS BEGIN 
DROP TABLE IF EXISTS #dijelovi;
SELECT 
  paket, 
  doc, 
  barkod, 
  dio1, 
  dio2, 
  dio3, 
  dio4, 
  dio5, 
  dio6, 
  dio7, 
  dio8 INTO #dijelovi
FROM 
  (
    SELECT 
      paket, 
      doc, 
      barkod, 
      'dio' + CAST(
        ROW_NUMBER() OVER (
          PARTITION BY doc 
          ORDER by 
            paket, 
            DOC
        ) AS varchar
      ) AS dio, 
      VALUE 
    FROM 
      imeTabliceObrade CROSS APPLY string_split(barkod, ';') as split 
    WHERE 
      paket = @paket
  ) AS tablica PIVOT (
    MAX(value) for dio in (
      [dio1], [dio2], [dio3], [dio4], [dio5], 
      [dio6], [dio7], [dio8]
    )
  ) as pivotica --SELECT * FROM #dijelovi
  BEGIN 
UPDATE 
  imeTabliceObrade 
SET 
  NazivNarudzbe = d.dio1, 
  RbrNarudzbe = dio2, 
  NazivTvrtke = dio3, 
  OibTvrtke = dio4, 
  MbTvrtke = dio5, 
  ImePrezimeOsobe = dio6 + ' ' + dio7, 
  OibOsobe = dio8 
FROM 
  #dijelovi d
  INNER JOIN imeTabliceObrade o ON o.paket = d.paket 
  and o.doc = d.doc 
WHERE 
  dio1 IN ('vrstax', ‘vrstay’) END BEGIN 
UPDATE 
  imeTabliceObrade 
SET 
  NazivNarudzbe = d.dio1, 
  RbrNarudzbe = dio2, 
  ImePrezimeOsobe = dio3 + ' ' + dio4, 
  OibOsobe = dio5, 
  osobnaVrijediDo = dio6 
FROM 
  #dijelovi d
  INNER JOIN imeTabliceObrade o ON o.paket = d.paket 
  and o.doc = d.doc 
WHERE 
  dio1 IN ('vrstaz', ‘vrstaa’) END BEGIN 
UPDATE 
  imeTabliceObrade 
SET 
  NazivNarudzbe = d.dio1, 
  RbrNarudzbe = dio2, 
  nazivTvrtke = dio3, 
  oibTvrtke = dio4, 
  mbTvrtke = dio5 
FROM 
  #dijelovi d
  INNER JOIN imeTabliceObrade o ON o.paket = d.paket 
  and o.doc = d.doc 
WHERE 
  dio1 IN ('vrstac', ‘vrstad’) END BEGIN 
UPDATE 
  imeTabliceObrade 
SET 
  NazivNarudzbe = d.dio1, 
  ImePrezimeOsobe = dio2 + ' ' + dio3, 
  OibOsobe = dio4 --
  provjeriti kada nađemo tu dokumentaciju 
FROM 
  #dijelovi d
  INNER JOIN imeTabliceObrade o ON o.paket = d.paket 
  and o.doc = d.doc 
WHERE 
  dio1 IN ('vrstae', ‘vrstaf’) END BEGIN 
UPDATE 
  imeTabliceObrade 
SET 
  NazivNarudzbe = d.dio1, 
  RbrNarudzbe = dio2 
FROM 
  #dijelovi d
  INNER JOIN imeTabliceObrade o ON o.paket = d.paket 
  and o.doc = d.doc 
WHERE 
  dio1 IN ('vrstag', ‘vrstah’) END BEGIN 
UPDATE 
  imeTabliceObrade 
SET 
  NazivNarudzbe = d.dio1, 
  RbrNarudzbe = dio2, 
  ImePrezimeOsobe = dio3 + ' ' + dio4, 
  oibOsobe = dio5, 
  mbTvrtke = dio6 
FROM 
  #dijelovi d
  INNER JOIN imeTabliceObrade o ON o.paket = d.paket 
  and o.doc = d.doc 
WHERE 
  dio1 IN ('vrstai') END BEGIN 
UPDATE 
  imeTabliceObrade 
SET 
  NazivNarudzbe = d.dio1, 
  RbrNarudzbe = dio2, 
  ImePrezimeOsobe = dio3 + ' ' + dio4, 
  oibOsobe = dio5 
FROM 
  #dijelovi d
  INNER JOIN imeTabliceObrade o ON o.paket = d.paket 
  and o.doc = d.doc 
WHERE 
  dio1 IN (
    'vrstaj', ‘vrstak’, ‘vrstal’, 
    ‘vestam’
  ) END 
END
