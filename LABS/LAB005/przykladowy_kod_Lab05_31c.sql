

--Kursor
DECLARE moj_kursor CURSOR FOR
SELECT nazwisko FROM T_Osoba;

OPEN moj_kursor;
FETCH NEXT FROM moj_kursor;
CLOSE moj_kursor;
DEALLOCATE moj_kursor;


--Przypisanie wartosci zmiennej poprzez Kursor 

DECLARE moj_kursor CURSOR FOR
SELECT nazwisko FROM T_Osoba;

OPEN moj_kursor;
DECLARE @Nazwisko Varchar(30);
FETCH NEXT FROM moj_kursor INTO @Nazwisko;
PRINT (@Nazwisko)
CLOSE moj_kursor;
DEALLOCATE moj_kursor;


--Kursor z pętlą while
DECLARE moj_kursor CURSOR FOR
SELECT nazwisko FROM T_Osoba;

OPEN moj_kursor;
DECLARE @Nazwisko Varchar(30);

FETCH NEXT FROM moj_kursor INTO @Nazwisko;
WHILE @@Fetch_status = 0 
BEGIN
	PRINT(@Nazwisko)
	FETCH NEXT FROM moj_kursor INTO @Nazwisko;
END;
CLOSE moj_kursor;
DEALLOCATE moj_kursor;

--Kursor dla instrukcji DML
INSERT INTO T_Zaopatrzenie ("Data") VALUES (GETDATE());

DECLARE @IdZaopatrzenia int = @@Identity;

INSERT INTO T_ZaopatrzenieProdukt(zaopatrzenie, produkt, ilosc) VALUES ( @IdZaopatrzenia, 1, 100)
INSERT INTO T_ZaopatrzenieProdukt(zaopatrzenie, produkt, ilosc) VALUES ( @IdZaopatrzenia, 2, 100)
INSERT INTO T_ZaopatrzenieProdukt(zaopatrzenie, produkt, ilosc) VALUES ( @IdZaopatrzenia, 3, 100)
INSERT INTO T_ZaopatrzenieProdukt(zaopatrzenie, produkt, ilosc) VALUES ( @IdZaopatrzenia, 4, 100)
INSERT INTO T_ZaopatrzenieProdukt(zaopatrzenie, produkt, ilosc) VALUES ( @IdZaopatrzenia, 5, 100)
INSERT INTO T_ZaopatrzenieProdukt(zaopatrzenie, produkt, ilosc) VALUES ( @IdZaopatrzenia, 6, 100)
INSERT INTO T_ZaopatrzenieProdukt(zaopatrzenie, produkt, ilosc) VALUES ( @IdZaopatrzenia, 7, 100)
INSERT INTO T_ZaopatrzenieProdukt(zaopatrzenie, produkt, ilosc) VALUES ( @IdZaopatrzenia, 8, 100)
INSERT INTO T_ZaopatrzenieProdukt(zaopatrzenie, produkt, ilosc) VALUES ( @IdZaopatrzenia, 9, 100)
INSERT INTO T_ZaopatrzenieProdukt(zaopatrzenie, produkt, ilosc) VALUES ( @IdZaopatrzenia, 10, 100)


DECLARE zaopatrzenie CURSOR FOR
SELECT id FROM T_Produkt;

OPEN zaopatrzenie;
INSERT INTO T_Zaopatrzenie ("Data") VALUES (GETDATE());
DECLARE @IdProdukt int, @IdZaopatrzenia int = @@Identity;
FETCH NEXT FROM zaopatrzenie INTO @IdProdukt;
WHILE @@Fetch_status = 0
BEGIN
	INSERT INTO T_ZaopatrzenieProdukt(zaopatrzenie, produkt, ilosc) VALUES (@IdZaopatrzenia, @IdProdukt, 100)
	FETCH NEXT FROM zaopatrzenie INTO @IdProdukt;
END
CLOSE zaopatrzenie;
DEALLOCATE zaopatrzenie;

SELECT * FROM T_ZaopatrzenieProdukt;

SELECT id FROM T_Zaopatrzenie 
WHERE "Data" = CAST(GETDATE() AS Date);


--CASE

SELECT nazwisko, 
CASE
WHEN pensja < 3000 THEN 'Malo'
WHEN pensja < 8000 THEN 'Duzo'
ELSE 'Inna'
END AS "Pensja słownie"
FROM T_Osoba o JOIN T_Pracownik p ON o.id = p.id;


--DATEDIFF()
DECLARE @Data1 date = CONVERT(DATE, '01-12-2020', 103), 
@Data2 date = CONVERT(DATE, '01-12-2021', 103);

SELECT DATEDIFF(YEAR, @Data1, @Data2)
