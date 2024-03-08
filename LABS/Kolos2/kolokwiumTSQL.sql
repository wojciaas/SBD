--zadanie 1

CREATE PROCEDURE DodajZawodnika1 @imie varchar(30), @nazwaZawodow varchar(40)
AS
BEGIN
    IF @imie NOT IN (SELECT imie FROM K9_Zawodnik WHERE imie = @imie)
        INSERT INTO K9_Zawodnik VALUES (@imie);
    DECLARE @runda int;
    SELECT @runda = MIN(runda) FROM K9_Udzial u
    INNER JOIN K9_Zawody z ON u.zawody = z.id
    WHERE z.nazwa = @nazwaZawodow GROUP BY u.zawody;
    IF @runda IS NULL
        SET @runda = 1;
    INSERT INTO K9_Udzial VALUES
    ((SELECT id FROM K9_Zawodnik WHERE imie = @imie),
    (SELECT id FROM K9_Zawody WHERE nazwa = @nazwaZawodow),
     @runda, null);
END;

exec DodajZawodnika1 'Myronides', 'Nemean Games';
exec DodajZawodnika1 'Iphicrates', 'Olympic Games';

--zadanie 2

CREATE PROCEDURE PrzepiszDalej @nazwaZawodow varchar(40)
AS
BEGIN
    DECLARE @idZawodow int, @runda int;
    SELECT @idZawodow = id FROM K9_Zawody WHERE nazwa = @nazwaZawodow;
    SELECT @runda = MAX(runda) FROM K9_Udzial WHERE zawody = @idZawodow GROUP BY zawody;

    IF EXISTS (SELECT 1 FROM K9_Udzial WHERE punkty IS NULL AND runda = @runda AND zawody = @idZawodow)
        PRINT 'Aktualna runda jeszcze sie nie zakonczyla'
    ELSE
    BEGIN
        DECLARE K9_cursor CURSOR FOR
        SELECT zawodnik FROM K9_Udzial
        WHERE zawody = @idZawodow AND runda = @runda
        AND punkty <> (SELECT MIN(punkty) FROM K9_Udzial WHERE zawody = @idZawodow AND runda = @runda);

        OPEN K9_cursor;
        DECLARE @idZawodnika int;
        FETCH NEXT FROM K9_cursor INTO @idZawodnika;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            INSERT INTO K9_Udzial VALUES (@idZawodnika, @idZawodow, @runda + 1, null);
            FETCH NEXT FROM K9_cursor INTO @idZawodnika;
        END;

        CLOSE K9_cursor;
        DEALLOCATE K9_cursor;
    END;
END;


--zadanie 3

CREATE TRIGGER UdzialTrigger
ON K9_Udzial
INSTEAD OF INSERT
AS
BEGIN
    --pkt 1
    IF (SELECT punkty FROM inserted) IS NOT NULL
        RAISERROR('Punkty mozna przypisywac tylko poprzez UPDATE.', 16, 1);
    --pkt 2
    ELSE IF NOT EXISTS
        (SELECT 1 FROM K9_Udzial WHERE runda = (SELECT runda FROM inserted) AND punkty IS NULL)
    RAISERROR('Nie mozna dodac zawodnika do rundy, ktora juz sie zakonczyla.', 16, 2);
    --pkt 3
    ELSE IF NOT EXISTS (SELECT 1 FROM K9_Udzial
        WHERE runda = (SELECT runda-1 FROM inserted) AND zawodnik = (SELECT zawodnik FROM inserted))
    RAISERROR('Zawodnik nie uczestniczyl w poprzedniej rundzie.', 16, 3);
    ELSE
    --pkt 4
    BEGIN TRY
        DECLARE @idZawodnika int, @idZawodow int, @runda int;
        SELECT @idZawodnika = Zawodnik, @idZawodow = Zawody, @runda = runda FROM inserted;
        INSERT INTO K9_Udzial VALUES (@idZawodnika, @idZawodow, @runda, null);
    END TRY
    BEGIN CATCH
        RAISERROR('Zawodnik jest juz przypisany do podanej rundy w tych zawodach.', 16, 3);
    END CATCH;
END;