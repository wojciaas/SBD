USE [2019SBD]

--RAISERROR
PRINT 'Przed błędem'
SELECT 10/0;
PRINT 'Po błędzie'

RAISERROR ('Mój błąd', 16, 1)

--TRY CATCH

BEGIN TRY
PRINT 'Przed błędem'
SELECT 10/0;
PRINT 'Po błędzie'
END TRY
BEGIN CATCH
RAISERROR ('Mój błąd', 16, 1)
END CATCH;

--Wyzwalacze

ALTER TRIGGER wyzwalacz
ON T_Osoba
FOR INSERT
AS
PRINT 'Coś zostało dodane';

INSERT INTO T_Osoba(Id, Imie, Nazwisko) VALUES (11, 'Mike', 'Mindarus')

--Wyzwalacz INSTEAD OF
ALTER TRIGGER wyzwalacz
ON T_Osoba
INSTEAD OF INSERT
AS
PRINT 'Coś zostało dodane';

INSERT INTO T_Osoba(Id, Imie, Nazwisko) VALUES (12, 'Mike', 'Meleager')

--Wyzwalacz AFTER
ALTER TRIGGER wyzwalacz
ON T_Osoba
AFTER INSERT
AS
PRINT 'Coś zostało dodane';

INSERT INTO T_Osoba(Id, Imie, Nazwisko) VALUES (12, 'Mike', 'Meleager')

SELECT * FROM T_Osoba;

--Tabele Inserted i Deleted
ALTER TRIGGER wyzwalacz
ON T_Osoba
INSTEAD OF INSERT
AS
BEGIN
DECLARE @Nazwisko Varchar(50)
SELECT @Nazwisko = nazwisko FROM Inserted;
PRINT 'Checmy dodać osobę o nazwisku ' + @Nazwisko
END;

INSERT INTO T_Osoba(Id, Imie, Nazwisko) VALUES (13, 'Mike', 'Attalus')

--Nie pozwalamy dodać nowej osoby o nazwisku które już istnieje przy użyciu wyzwalacz INSTEAD OF
ALTER TRIGGER wyzwalacz
ON T_Osoba
INSTEAD OF INSERT
AS
BEGIN
DECLARE @Id int, @Imie Varchar(50), @Nazwisko Varchar(50)
SELECT @id = id, @Imie = imie, @Nazwisko = nazwisko FROM Inserted;
IF @Nazwisko IN (SELECT nazwisko FROM T_Osoba)
	RAISERROR('Osoba o takim nazwisku już istnieje' , 16, 1)
ELSE
	INSERT INTO T_Osoba(Id, Imie, Nazwisko) VALUES (@Id, @Imie, @Nazwisko)
END;

INSERT INTO T_Osoba(Id, Imie, Nazwisko) VALUES (13, 'Mike', 'Thrasyllus')

SELECT * FROM T_Osoba;

--Nie pozwalamy dodać nowej osoby o nazwisku które już istnieje przy użyciu wyzwalacz AFTER
ALTER TRIGGER wyzwalacz
ON T_Osoba
AFTER INSERT
AS
BEGIN
DECLARE @Id int, @Nazwisko Varchar(50)
SELECT @id = id, @Nazwisko = nazwisko FROM Inserted;
IF @Nazwisko IN (SELECT nazwisko FROM T_Osoba WHERE id <> @Id)
BEGIN
	RAISERROR('Osoba o takim nazwisku już istnieje' , 16, 1)
	ROLLBACK;
END;
END;

INSERT INTO T_Osoba(Id, Imie, Nazwisko) VALUES (14, 'Mike', 'Coenus')

SELECT * FROM T_Osoba;

--UPDATE()
ALTER TRIGGER wyzwalacz
ON T_Osoba
AFTER UPDATE
AS
BEGIN
IF UPDATE(nazwisko)
BEGIN
	RAISERROR('Nie można edytować nazwiska', 16,1)
	ROLLBACK;
END;
END;

UPDATE T_Osoba
SET imie = 'Nowe'
WHERE id = 1;
