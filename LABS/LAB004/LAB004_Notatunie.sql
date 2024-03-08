USE [2019SBD]

DECLARE @NaszaZmienna int = 3;
--SET @NaszaZmienna = 5;

IF @NaszaZmienna > 0
BEGIN --jako klamry
PRINT 'Liczba wieksza niz zero';
PRINT 'Cos jeszcze';
END; --koniec klamr
ELSE
PRINT 'Liczba mniejsza niz zero';

--SELECT @NaszaZmienna = id FROM T_Osoba WHERE nazwisko = 'Paches';

--PRINT 'Id osoby = ' + CAST(@NaszaZmienna AS Varchar(5));

ALTER PROCEDURE MojaProcedura @Liczba1 int, @Liczba2 int = 999, @Info Varchar(50) OUTPUT
AS
BEGIN
SET @Info =  'Liczba 1 = ' + CAST(@Liczba1 AS Varchar(5)) + ', ' + 'Liczba 2 = ' + CAST(@Liczba2 AS Varchar(5));
SELECT id FROM T_Zakup;
END;

DECLARE @Informacja VARCHAR(50);
EXEC MojaProcedura 88, DEFAULT, @Informacja OUTPUT;
PRINT @Informacja;

--@@ROWCOUNT

SET NOCOUNT ON;
UPDATE T_Produkt
SET cena = cena + 0.01;

PRINT 'Liczba zmodyfikowanych rekordów: ' + CAST(@@ROWCOUNT AS Varchar(5));

--@@IDENTITY

SELECT id FROM T_ZAKUP;
INSERT INTO T_Zakup("Data", klient) VALUES (GETDATE(), 1);

DELETE FROM T_zakup WHERE id > 11;

PRINT @@IDENTITY;