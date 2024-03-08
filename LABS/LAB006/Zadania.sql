--Zadanie 01--
DELETE FROM T_ListaProduktow
       WHERE zakup = 55 AND produkt = 10;

CREATE TRIGGER INSTEAD_OF_DELETE
    ON T_ListaProduktow
    INSTEAD OF DELETE
AS
BEGIN
    RAISERROR('Nie można usuwać rekordów z tabeli T_ListaProduktow', 16, 1);
END;

DELETE FROM T_ListaProduktow
    WHERE zakup = 55 AND produkt = 5;

--Zadanie 02--
ALTER TRIGGER INSTEAD_OF_DELETE
    ON T_ListaProduktow
    INSTEAD OF DELETE
AS
    BEGIN
        DECLARE @ZAKUP int, @PRODUKT int, @ERR VARCHAR(200);
        SELECT @ZAKUP = Zakup, @PRODUKT = Produkt FROM DELETED;
        SET @ERR = ('Nie można usuwać rekordów z tabeli T_ListaProduktow. ' +
                   'Usuwanie rekordu dla zakupu = ' + CAST(@ZAKUP AS VARCHAR(8)) +
                   ' i produktu = ' + CAST(@PRODUKT AS VARCHAR(8)) + ' nie powiodło się.');
        RAISERROR(@ERR, 16, 1);
END;

DELETE FROM T_ListaProduktow
       WHERE zakup = 55 AND produkt = 5;

--Zadanie 03--
