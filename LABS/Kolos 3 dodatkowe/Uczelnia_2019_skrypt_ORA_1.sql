
	ALTER TABLE Dydaktyk1
	DROP CONSTRAINT Katedra_Dydaktyk_FK1;
DROP TABLE Dydaktyk1;
DROP TABLE Student1;
DROP TABLE Osoba1;
DROP TABLE Miasto1;
DROP TABLE Panstwo1;
------------------------------------
DROP TABLE PrzedmiotPoprzedzajacy;
DROP TABLE Program;
DROP TABLE Ocena;
DROP TABLE Egzamin;
DROP TABLE Srednia;
DROP TABLE Przedmiot;
	-- ALTER TABLE Dydaktyk
	-- DROP CONSTRAINT Katedra_Dydaktyk_FK1;
DROP TABLE Katedra;
DROP TABLE Wydzial;
DROP TABLE Dydaktyk;
DROP TABLE Siatkaplac;
DROP TABLE StopnieTytuly;
DROP TABLE StudentGrupa;
DROP TABLE Grupa;
DROP TABLE RokAkademicki;
--DROP TABLE Student;
--DROP TABLE Osoba;
--DROP TABLE Miasto;
--DROP TABLE Panstwo;
ALTER SESSION SET NLS_LANGUAGE = 'AMERICAN';
ALTER SESSION SET NLS_TERRITORY = 'AMERICA';
ALTER SESSION SET NLS_DATE_FORMAT = 'RRRR-MM-DD';

-- Create new TABLE ROKAKADEMICKI. 
CREATE TABLE ROKAKADEMICKI (
	IDROKAKADEMICKI CHAR(7) not null,
	DATA_ROZP DATE not null,
	DATA_ZAK DATE not null, constraint ROKAKADEMICKI_PK primary key (IDROKAKADEMICKI) ); 

-- Create new table STUDENTGRUPA. 
CREATE TABLE STUDENTGRUPA (
	IDOSOBA NUMBER(38,0) not null,
	IdGrupa NUMBER(38, 0) not null,
	constraint STUDENTGRUPA_PK primary key (IdGrupa, IDOSOBA) ); 

-- Create new TABLE GRUPA.
CREATE TABLE GRUPA (
	IdGrupa NUMBER(38, 0),
	NRGRUPY CHAR(10) not null,
	IDROKAKADEMICKI CHAR(7) not null,
	SEMESTRNAUKI NUMBER(1,0) not null, constraint GRUPA_PK primary key (IdGrupa ) ); 

-- Create new TABLE PRZEDMIOTPOPRZEDZAJACY.
CREATE TABLE PRZEDMIOTPOPRZEDZAJACY (
	IDPOPRZEDNIK NUMBER(38,0) not null,
	IDPRZEDMIOT NUMBER(38,0) not null, constraint PRZEDMIOTPOPRZEDZAJACY_PK primary key (IDPOPRZEDNIK, IDPRZEDMIOT) ); 

-- Create new TABLE PRZEDMIOT.
CREATE TABLE PRZEDMIOT (
	IDPRZEDMIOT NUMBER(38,0) not null,
	PRZEDMIOT VARCHAR2(128) not null,
	SYMBOL CHAR(3) not null,
	IDKATEDRA NUMBER(38,0) null, constraint PRZEDMIOT_PK primary key (IDPRZEDMIOT) ); 

-- Create new TABLE STOPNIETYTULY.
CREATE TABLE STOPNIETYTULY (
	IDSTOPIEN NUMBER(38,0) not null,
	STOPIEN VARCHAR2(32) not null,
	SKROT VARCHAR2(16) not null, constraint STOPNIETYTULY_PK primary key (IDSTOPIEN) ); 

-- Create new TABLE OCENA.
CREATE TABLE OCENA (
	IDSTUDENT NUMBER(38,0) not null,
	IDPRZEDMIOT NUMBER(38,0) not null,
	DATAWYSTAWIENIA DATE not null,
	IDDYDAKTYK NUMBER(38,0) not null,
	OCENA NUMBER(38,0) not null, constraint OCENA_PK primary key (IDSTUDENT, DATAWYSTAWIENIA, IDPRZEDMIOT) ); 

-- Create new TABLE PANSTWO1.
CREATE TABLE PANSTWO1 (
	IDPANSTWO NUMBER(38,0) not null,
	PANSTWO VARCHAR2(64) not null, constraint PANSTWO_PK primary key (IDPANSTWO) ); 

-- Create new TABLE OSOBA1.
CREATE TABLE OSOBA1 (
	IDOSOBA NUMBER(38,0) not null,
	NAZWISKO VARCHAR2(62) not null,
	IMIE VARCHAR2(32) not null,
	DATAURODZENIA DATE null,
	IDPANSTWO NUMBER(38,0) null, constraint OSOBA_PK primary key (IDOSOBA) ); 

-- Create new TABLE STUDENT1.
CREATE TABLE STUDENT1 (
	IDOSOBA NUMBER(38,0) not null,
	NRINDEKSU CHAR(10) not null,
	DATAREKRUTACJI DATE not null, constraint STUDENT_PK primary key (IDOSOBA) ); 

-- Create new TABLE DYDAKTYK1.
CREATE TABLE DYDAKTYK1 (
	IDOSOBA NUMBER(38,0) not null,
	IDSTOPIEN NUMBER(38,0) null,
	PODLEGA NUMBER(38,0) null, constraint DYDAKTYK_PK primary key (IDOSOBA) ); 

-- Add foreign key constraints to TABLE STUDENTGRUPA.
ALTER TABLE STUDENTGRUPA
	add constraint STUDENT_STUDENTGRUPA_FK1 foreign key (
		IDOSOBA)
	 references STUDENT1 (
		IDOSOBA); 

ALTER TABLE STUDENTGRUPA
	add constraint GRUPASTUD_STUDENTGRUPA_FK1 foreign key (
		IdGrupa)
	 references GRUPA (
		IdGrupa); 

-- Add foreign key constraints to TABLE GRUPA.
ALTER TABLE GRUPA
	add constraint ROKAKAD_GRUPASTUD_FK1 foreign key (
		IDROKAKADEMICKI)
	 references ROKAKADEMICKI (
		IDROKAKADEMICKI); 

-- Add foreign key constraints to TABLE PRZEDMIOTPOPRZEDZAJACY.
ALTER TABLE PRZEDMIOTPOPRZEDZAJACY
	add constraint PRZEDMIOT_PRZEDMIOTPOP_FK1 foreign key (
		IDPOPRZEDNIK)
	 references PRZEDMIOT (
		IDPRZEDMIOT); 

ALTER TABLE PRZEDMIOTPOPRZEDZAJACY
	add constraint PRZEDMIOT_PRZEDMIOTPOP_FK2 foreign key (
		IDPRZEDMIOT)
	 references PRZEDMIOT (
		IDPRZEDMIOT); 

-- Add foreign key constraints to TABLE OCENA.
ALTER TABLE OCENA
	add constraint DYDAKTYK_OCENA_FK1 foreign key (
		IDDYDAKTYK)
	 references DYDAKTYK1 (
		IDOSOBA); 

ALTER TABLE OCENA
	add constraint STUDENT_OCENA_FK1 foreign key (
		IDSTUDENT)
	 references STUDENT1 (
		IDOSOBA); 

ALTER TABLE OCENA
	add constraint PRZEDMIOT_OCENA_FK1 foreign key (
		IDPRZEDMIOT)
	 references PRZEDMIOT (
		IDPRZEDMIOT); 

-- Add foreign key constraints to TABLE STUDENT.
ALTER TABLE STUDENT1
	add constraint OSOBA_STUDENT_FK1 foreign key (
		IDOSOBA)
	 references OSOBA1 (
		IDOSOBA); 

-- Add foreign key constraints to TABLE DYDAKTYK.
ALTER TABLE DYDAKTYK1
	add constraint OSOBA_DYDAKTYK_FK1 foreign key (
		IDOSOBA)
	 references OSOBA1 (
		IDOSOBA); 

ALTER TABLE DYDAKTYK1
	add constraint STOPNIETYTULY_DYDAKTYK_FK1 foreign key (
		IDSTOPIEN)
	 references STOPNIETYTULY (
		IDSTOPIEN); 

ALTER TABLE DYDAKTYK1
	add constraint DYDAKTYK_DYDAKTYK_FK1 foreign key (
		PODLEGA)
	 references DYDAKTYK1 (
		IDOSOBA); 

ALTER TABLE OSOBA1
	add constraint PANSTWO_OSOBA_FK1 foreign key (
		IDPANSTWO)
	 references PANSTWO1 (
		IDPANSTWO); 

-----------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------
-- This is the end of the Microsoft Visual Studio generated SQL DDL script.
-----------------------------------------------------------------------------------------------------------------
INSERT ALL
INTO RokAkademicki (IdRokAkademicki, Data_rozp, Data_zak) VALUES ('2011_12', '2011-10-01', '2012-08-31')
INTO RokAkademicki (IdRokAkademicki, Data_rozp, Data_zak) VALUES ('2012_13', '2012-10-01', '2013-08-31')
INTO RokAkademicki (IdRokAkademicki, Data_rozp, Data_zak) VALUES ('2013_14', '2013-10-01', '2014-08-31')
INTO RokAkademicki (IdRokAkademicki, Data_rozp, Data_zak) VALUES ('2014_15', '2014-10-01', '2015-08-31')
SELECT * FROM dual;
-----------------------------------------------------------------------------------------------------------------

INSERT ALL
INTO Grupa (IdGrupa, NrGrupy, SemestrNauki, IdRokAkademicki) VALUES (1,'WIs I.1', 1, '2011_12')
INTO Grupa (IdGrupa, NrGrupy, SemestrNauki, IdRokAkademicki) VALUES (2,'WIs I.2', 1, '2011_12')
INTO Grupa (IdGrupa, NrGrupy, SemestrNauki, IdRokAkademicki) VALUES (3,'WIs II.1', 2, '2011_12')
INTO Grupa (IdGrupa, NrGrupy, SemestrNauki, IdRokAkademicki) VALUES (4,'WIs II.2', 2, '2011_12')
INTO Grupa (IdGrupa, NrGrupy, SemestrNauki, IdRokAkademicki) VALUES (5,'WIs I.1', 1, '2012_13')
INTO Grupa (IdGrupa, NrGrupy, SemestrNauki, IdRokAkademicki) VALUES (6,'WIs I.2', 1, '2012_13')
INTO Grupa (IdGrupa, NrGrupy, SemestrNauki, IdRokAkademicki) VALUES (7,'WIs II.1', 2, '2012_13')
INTO Grupa (IdGrupa, NrGrupy, SemestrNauki, IdRokAkademicki) VALUES (8,'WIs II.2', 2, '2012_13')
INTO Grupa (IdGrupa, NrGrupy, SemestrNauki, IdRokAkademicki) VALUES (9,'WIs III.1', 3, '2012_13')
INTO Grupa (IdGrupa, NrGrupy, SemestrNauki, IdRokAkademicki) VALUES (10,'WIs III.2', 3, '2012_13')
INTO Grupa (IdGrupa, NrGrupy, SemestrNauki, IdRokAkademicki) VALUES (11,'WIs IV.1', 4, '2012_13')
INTO Grupa (IdGrupa, NrGrupy, SemestrNauki, IdRokAkademicki) VALUES (12,'WIs IV.2', 4, '2012_13')
INTO Grupa (IdGrupa, NrGrupy, SemestrNauki, IdRokAkademicki) VALUES (13,'WIs I.1', 1, '2013_14')
INTO Grupa (IdGrupa, NrGrupy, SemestrNauki, IdRokAkademicki) VALUES (14,'WIs I.2', 1, '2013_14')
INTO Grupa (IdGrupa, NrGrupy, SemestrNauki, IdRokAkademicki) VALUES (15,'WIs II.1', 2, '2013_14')
INTO Grupa (IdGrupa, NrGrupy, SemestrNauki, IdRokAkademicki) VALUES (16,'WIs II.2', 2, '2013_14')
INTO Grupa (IdGrupa, NrGrupy, SemestrNauki, IdRokAkademicki) VALUES (17,'WIs III.1', 3, '2013_14')
INTO Grupa (IdGrupa, NrGrupy, SemestrNauki, IdRokAkademicki) VALUES (18,'WIs III.2', 3, '2013_14')
INTO Grupa (IdGrupa, NrGrupy, SemestrNauki, IdRokAkademicki) VALUES (19,'WIs IV.1', 4, '2013_14')
INTO Grupa (IdGrupa, NrGrupy, SemestrNauki, IdRokAkademicki) VALUES (20,'WIs IV.2', 4, '2013_14')
INTO Grupa (IdGrupa, NrGrupy, SemestrNauki, IdRokAkademicki) VALUES (21,'WIs V.1', 5, '2013_14')
INTO Grupa (IdGrupa, NrGrupy, SemestrNauki, IdRokAkademicki) VALUES (22,'WIs VI.1', 6, '2013_14')
INTO Grupa (IdGrupa, NrGrupy, SemestrNauki, IdRokAkademicki) VALUES (23,'WIs I.1', 1, '2014_15')
INTO Grupa (IdGrupa, NrGrupy, SemestrNauki, IdRokAkademicki) VALUES (24,'WIs I.2', 1, '2014_15')
INTO Grupa (IdGrupa, NrGrupy, SemestrNauki, IdRokAkademicki) VALUES (25,'WIs II.1', 2, '2014_15')
INTO Grupa (IdGrupa, NrGrupy, SemestrNauki, IdRokAkademicki) VALUES (26,'WIs II.2', 2, '2014_15')
SELECT * FROM dual;

-----------------------------------------------------------------------------------------------------------------
INSERT ALL
INTO Przedmiot (IdPrzedmiot, Przedmiot, Symbol) VALUES	(1,'Systemy baz danych', 'SBD')
INTO Przedmiot (IdPrzedmiot, Przedmiot, Symbol) VALUES	(2,'Relacyjne bazy danych', 'RBD')
INTO Przedmiot (IdPrzedmiot, Przedmiot, Symbol) VALUES	(3,'Algebra liniowa i geometria', 'ALG')
INTO Przedmiot (IdPrzedmiot, Przedmiot, Symbol) VALUES	(4,'Matematyka dyskretna', 'MAD')
INTO Przedmiot (IdPrzedmiot, Przedmiot, Symbol) VALUES	(5,'Systemy operacyjne', 'SOP')
INTO Przedmiot (IdPrzedmiot, Przedmiot, Symbol) VALUES	(6,'Analiza matematyczna I', 'AM1')
INTO Przedmiot (IdPrzedmiot, Przedmiot, Symbol) VALUES	(7,'Inżynieria oprogramowania', 'INO')
INTO Przedmiot (IdPrzedmiot, Przedmiot, Symbol) VALUES	(8,'Projektowanie baz danych', 'BDA')
INTO Przedmiot (IdPrzedmiot, Przedmiot, Symbol) VALUES	(9,'Administrowanie bazami danych', 'ADM')
INTO Przedmiot (IdPrzedmiot, Przedmiot, Symbol) VALUES	(10,'Analiza matematyczna II', 'AM2')
INTO Przedmiot (IdPrzedmiot, Przedmiot, Symbol) VALUES	(11,'Algorytmy i struktury danych', 'ASD')
INTO Przedmiot (IdPrzedmiot, Przedmiot, Symbol) VALUES	(12,'Administracja systemów operacyjnych', 'ASO')
SELECT * FROM dual;

-----------------------------------------------------------------------------------------------------------------
INSERT ALL
INTO PrzedmiotPoprzedzajacy (IdPoprzednik, IdPrzedmiot) VALUES (2,1)
INTO PrzedmiotPoprzedzajacy (IdPoprzednik, IdPrzedmiot) VALUES (3,4)
INTO PrzedmiotPoprzedzajacy (IdPoprzednik, IdPrzedmiot) VALUES (6, 10)
INTO PrzedmiotPoprzedzajacy (IdPoprzednik, IdPrzedmiot) VALUES (4, 11)
INTO PrzedmiotPoprzedzajacy (IdPoprzednik, IdPrzedmiot) VALUES (5,12)
SELECT * FROM dual;

-----------------------------------------------------------------------------------------------------------------
INSERT ALL
INTO StopnieTytuly (IdStopien, Skrot, Stopien) VALUES	(1, 'Prof. Dr hab.', 'Profesor Doktor habilitowany')
INTO StopnieTytuly (IdStopien, Skrot, Stopien) VALUES	(2, 'Dr hab.', 'Doktor habilitowany')
INTO StopnieTytuly (IdStopien, Skrot, Stopien) VALUES	(3, 'Dr', 'Doktor')
INTO StopnieTytuly (IdStopien, Skrot, Stopien) VALUES	(4, 'Mgr', 'Magister')
INTO StopnieTytuly (IdStopien, Skrot, Stopien) VALUES	(5, 'Inż', 'Inżynier')
SELECT * FROM dual;

-----------------------------------------------------------------------------------------------------------------
INSERT ALL
INTO Panstwo1 (IdPanstwo, Panstwo) VALUES (14, 'Białoruś')
INTO Panstwo1 (IdPanstwo, Panstwo) VALUES (4, 'Czechy')
INTO Panstwo1 (IdPanstwo, Panstwo) VALUES (15, 'Francja')
INTO Panstwo1 (IdPanstwo, Panstwo) VALUES (10, 'Niemcy')
INTO Panstwo1 (IdPanstwo, Panstwo) VALUES (3,	'Polska')
INTO Panstwo1 (IdPanstwo, Panstwo) VALUES (12, 'Rosja')
INTO Panstwo1 (IdPanstwo, Panstwo) VALUES (18, 'Rumunia')
INTO Panstwo1 (IdPanstwo, Panstwo) VALUES (11, 'Słowacja')
INTO Panstwo1 (IdPanstwo, Panstwo) VALUES (16, 'Słowenia')
INTO Panstwo1 (IdPanstwo, Panstwo) VALUES (13, 'Ukraina')
INTO Panstwo1 (IdPanstwo, Panstwo) VALUES (2, 'USA')
SELECT * FROM dual;

-----------------------------------------------------------------------------------------------------------------
--Dydaktycy------------------------
INSERT	INTO osoba1 (IdOsoba, Imie, Nazwisko, DataUrodzenia) VALUES (1, 'Apolinary', 'Anyżek','1960-12-01');
INSERT	INTO osoba1 (IdOsoba, Imie, Nazwisko, DataUrodzenia) VALUES (2, 'Balbina', 'Bakłażan', '1991-02-03');
INSERT	INTO osoba1 (IdOsoba, Imie, Nazwisko, DataUrodzenia) VALUES (3, 'Baltazar', 'Bigos','1995-09-04');
INSERT	INTO osoba1 (IdOsoba, Imie, Nazwisko, DataUrodzenia) VALUES (4, 'Cezary', 'Czosnek', '1958-11-11');
INSERT	INTO osoba1 (IdOsoba, Imie, Nazwisko, DataUrodzenia) VALUES (5, 'Domicella', 'Dynia', '1982-06-30');
INSERT	INTO osoba1 (IdOsoba, Imie, Nazwisko, DataUrodzenia) VALUES (6, 'Bazyli', 'Brokuł', '1971-03-08');
INSERT	INTO osoba1 (IdOsoba, Imie, Nazwisko, DataUrodzenia) VALUES (7, 'Kajetan', 'Kalafior', '1989-05-03');
INSERT	INTO osoba1 (IdOsoba, Imie, Nazwisko, DataUrodzenia) VALUES (8, 'Kunegunda', 'Karp', '1995-10-21');
INSERT	INTO osoba1 (IdOsoba, Imie, Nazwisko, DataUrodzenia) VALUES (9, 'January', 'Jajecznica', '1965-05-22');
INSERT	INTO osoba1 (IdOsoba, Imie, Nazwisko, DataUrodzenia) VALUES (10, 'Archibald', 'Agrest', '1978-09-05');
INSERT	INTO osoba1 (IdOsoba, Imie, Nazwisko, DataUrodzenia) VALUES (11, 'Kleofas', 'Klops', '1977-11-11');
INSERT	INTO osoba1 (IdOsoba, Imie, Nazwisko) VALUES (23, 'Winicjusz', 'Wężymord');
INSERT	INTO Dydaktyk1 (IdOsoba, IdStopien) VALUES	(1 ,1);
INSERT	INTO Dydaktyk1 (IdOsoba, IdStopien) VALUES	(2,4);
INSERT	INTO Dydaktyk1 (IdOsoba, IdStopien) VALUES	(3,5);
INSERT	INTO Dydaktyk1 (IdOsoba, IdStopien) VALUES	(4, 1);
INSERT	INTO Dydaktyk1 (IdOsoba, IdStopien) VALUES	(5 ,3);
INSERT	INTO Dydaktyk1 (IdOsoba, IdStopien) VALUES	(6,2);
INSERT	INTO Dydaktyk1 (IdOsoba, IdStopien) VALUES	(7,4);
INSERT	INTO Dydaktyk1 (IdOsoba, IdStopien) VALUES	(8,5);
INSERT	INTO Dydaktyk1 (IdOsoba, IdStopien) VALUES	(9,2);
INSERT	INTO Dydaktyk1 (IdOsoba, IdStopien) VALUES	(10,3);
INSERT	INTO Dydaktyk1 (IdOsoba, IdStopien) VALUES	(11, 4);
INSERT	INTO Dydaktyk1 (IdOsoba, IdStopien) VALUES	(23, NULL);
UPDATE Dydaktyk1 SET Podlega = 1 WHERE IdOsoba IN (6,10,2,3);
UPDATE Dydaktyk1 SET Podlega = 4 WHERE IdOsoba IN (5, 9);
UPDATE Dydaktyk1 SET Podlega = 9 WHERE IdOsoba IN (7, 11);
UPDATE Dydaktyk1 SET Podlega = 5 WHERE IdOsoba IN (8, 23);

-----------------------------------------------------------------------------------------------------------------
--Studenci
-----------------------------------------------------------------------------------------------------------------
INSERT	INTO osoba1 (IdOsoba, Imie, Nazwisko, DataUrodzenia) VALUES (12,'Alberta', 'Ananas', '1991-03-05');
INSERT	INTO Student1 (IdOsoba, DataRekrutacji, NrIndeksu)	VALUES	(12, '2011-09-12','s2121');
INSERT	INTO Dydaktyk1 (IdOsoba, IdStopien) VALUES	(12, 5);
INSERT	INTO osoba1 (IdOsoba, Imie, Nazwisko, DataUrodzenia) VALUES (13, 'Salomea', 'Śliwka', '1992-05-15');
INSERT	INTO Student1 (IdOsoba, DataRekrutacji, NrIndeksu) VALUES	(13, '2011-09-13','s2126');
INSERT	INTO osoba1 (IdOsoba, Imie, Nazwisko, DataUrodzenia) VALUES (14, 'Pulchernia', 'Pączek', '1993-08-14');
INSERT	INTO Student1 (IdOsoba, DataRekrutacji, NrIndeksu) VALUES	(14, '2011-08-19','s2101');
INSERT	INTO osoba1 (IdOsoba, Imie, Nazwisko, DataUrodzenia) VALUES (15, 'Gryzelda', 'Gruszka', '1990-12-24');
INSERT	INTO Student1 (IdOsoba, DataRekrutacji, NrIndeksu) VALUES	(15, '2011-10-01','s2135');
INSERT	INTO osoba1 (IdOsoba, Imie, Nazwisko, DataUrodzenia) VALUES (16, 'Tymoteusz', 'Tymianek', '1993-11-21');
INSERT	INTO Student1 (IdOsoba, DataRekrutacji, NrIndeksu) VALUES	(16, '2012-08-12','s3162');
INSERT	INTO osoba1 (IdOsoba, Imie, Nazwisko, DataUrodzenia) VALUES (17, 'Klara', 'Koperek', '1994-03-22');
INSERT	INTO Student1 (IdOsoba, DataRekrutacji, NrIndeksu) VALUES	(17, '2012-09-23','s3177');
INSERT	INTO osoba1 (IdOsoba, Imie, Nazwisko, DataUrodzenia) VALUES (18, 'Melchior', 'Melon', '1995-08-09');
INSERT	INTO Student1 (IdOsoba, DataRekrutacji, NrIndeksu) VALUES	(18, '2012-07-22','s3045');
INSERT	INTO osoba1 (IdOsoba, Imie, Nazwisko, DataUrodzenia) VALUES (19, 'Hieronim', 'Kapusta', '1994-08-09');
INSERT	INTO Student1 (IdOsoba, DataRekrutacji, NrIndeksu) VALUES	(19, '2013-08-05','s4120');
INSERT	INTO osoba1 (IdOsoba, Imie, Nazwisko, DataUrodzenia) VALUES (20, 'Brunchilda', 'Banan', '1995-07-07');
INSERT	INTO Student1 (IdOsoba, DataRekrutacji, NrIndeksu) VALUES	(20, '2013-07-16','s4022');
INSERT	INTO osoba1 (IdOsoba, Imie, Nazwisko, DataUrodzenia) VALUES (21, 'Salomon', 'Seler', '1994-11-05');
INSERT	INTO Student1 (IdOsoba, DataRekrutacji, NrIndeksu) VALUES	(21, '2013-07-06','s4004');
INSERT	INTO osoba1 (IdOsoba, Imie, Nazwisko, DataUrodzenia) VALUES (22, 'Bonifacy', 'Bób', '1996-03-09');
INSERT	INTO Student1 (IdOsoba, DataRekrutacji, NrIndeksu) VALUES	(22, '2013-09-22','s4321');
INSERT	INTO osoba1 (IdOsoba, Imie, Nazwisko, DataUrodzenia) VALUES (24, 'Pafnucy', 'Papryka', '1997-02-19');
INSERT	INTO Student1 (IdOsoba, DataRekrutacji, NrIndeksu) VALUES	(24, '2013-09-22','s4322');
INSERT	INTO osoba1 (IdOsoba, Imie, Nazwisko, DataUrodzenia) VALUES (25, 'Pankracy', 'Por', '1995-07-09');
INSERT	INTO Student1 (IdOsoba, DataRekrutacji, NrIndeksu) VALUES	(25, '2013-09-22','s4323');
INSERT INTO Osoba1 (IdOsoba, Imie, Nazwisko, DataUrodzenia) VALUES (26, 'Cecylia', 'Cebula', '1997-12-02');
INSERT INTO Student1 (Idosoba, NrIndeksu, DataRekrutacji) VALUES (26, 5122, '2014-06-11');
INSERT INTO Osoba1 (IdOsoba, Imie, Nazwisko, DataUrodzenia) VALUES (27, 'Dezydery', 'Dąb', '1998-01-22');
INSERT INTO Student1 (Idosoba, NrIndeksu, DataRekrutacji) VALUES (27, 5131, '2014-07-17');
INSERT INTO Osoba1 (IdOsoba, Imie, Nazwisko, DataUrodzenia) VALUES (28, 'Konstancja', 'Koperek', '1996-02-02');
INSERT INTO Student1 (Idosoba, NrIndeksu, DataRekrutacji) VALUES (28, 5138, '2014-07-22');
INSERT INTO Osoba1 (IdOsoba, Imie, Nazwisko, DataUrodzenia) VALUES (29, 'Judyta', 'Jarmuż', '1997-08-28');
INSERT INTO Student1 (Idosoba, NrIndeksu, DataRekrutacji) VALUES (29, 5141, '2014-08-12');
INSERT INTO Osoba1 (IdOsoba, Imie, Nazwisko, DataUrodzenia) VALUES (30, 'Klaudiusz', 'Karczoch', '1996-09-06');
INSERT INTO Student1 (Idosoba, NrIndeksu, DataRekrutacji) VALUES (30, 5144, '2014-08-22');
INSERT INTO Osoba1 (IdOsoba, Imie, Nazwisko, DataUrodzenia) VALUES (31, 'Sykstus', 'Szczaw', '1997-10-05');
INSERT INTO Student1 (Idosoba, NrIndeksu, DataRekrutacji) VALUES (31, 5149, '2014-09-01');
COMMIT;

-----------------------------------------------------------------------------------------------------------------
--Oceny
-----------------------------------------------------------------------------------------------------------------
INSERT ALL
INTO Ocena (IdStudent, IdPrzedmiot, DataWystawienia, Ocena, IdDydaktyk) VALUES (12, 6, '2012-01-20', 4.0, 1)
INTO Ocena (IdStudent, IdPrzedmiot, DataWystawienia, Ocena, IdDydaktyk) VALUES (13, 6, '2012-01-20', 4.5, 1)
INTO Ocena (IdStudent, IdPrzedmiot, DataWystawienia, Ocena, IdDydaktyk) VALUES (14, 6, '2012-01-20', 3.0, 1)
INTO Ocena (IdStudent, IdPrzedmiot, DataWystawienia, Ocena, IdDydaktyk) VALUES (15, 6, '2012-01-20', 5.0, 1)
INTO Ocena (IdStudent, IdPrzedmiot, DataWystawienia, Ocena, IdDydaktyk) VALUES (16, 6, '2013-01-25', 2.0, 1)
INTO Ocena (IdStudent, IdPrzedmiot, DataWystawienia, Ocena, IdDydaktyk) VALUES (17, 6, '2013-01-25', 4.5, 1)
INTO Ocena (IdStudent, IdPrzedmiot, DataWystawienia, Ocena, IdDydaktyk) VALUES (18, 6, '2013-01-25', 3.0, 1)
INTO Ocena (IdStudent, IdPrzedmiot, DataWystawienia, Ocena, IdDydaktyk) VALUES (16, 6, '2013-02-02', 3.0, 1)
INTO Ocena (IdStudent, IdPrzedmiot, DataWystawienia, Ocena, IdDydaktyk) VALUES (19, 6, '2014-01-18', 5.0, 1)
INTO Ocena (IdStudent, IdPrzedmiot, DataWystawienia, Ocena, IdDydaktyk) VALUES (20, 6, '2014-01-18', 4.0, 1)
INTO Ocena (IdStudent, IdPrzedmiot, DataWystawienia, Ocena, IdDydaktyk) VALUES (21, 6, '2014-01-18', 4.5, 1)
INTO Ocena (IdStudent, IdPrzedmiot, DataWystawienia, Ocena, IdDydaktyk) VALUES (22, 6, '2014-01-18', 2.0, 1)
INTO Ocena (IdStudent, IdPrzedmiot, DataWystawienia, Ocena, IdDydaktyk) VALUES (22, 6, '2014-01-30', 4.0, 1)
INTO Ocena (IdStudent, IdPrzedmiot, DataWystawienia, Ocena, IdDydaktyk) VALUES (12, 2, '2012-01-22', 5.0, 9)
INTO Ocena (IdStudent, IdPrzedmiot, DataWystawienia, Ocena, IdDydaktyk) VALUES (13, 2, '2012-01-22', 4.5, 9)
INTO Ocena (IdStudent, IdPrzedmiot, DataWystawienia, Ocena, IdDydaktyk) VALUES (14, 2, '2012-01-22', 4.0, 9)
INTO Ocena (IdStudent, IdPrzedmiot, DataWystawienia, Ocena, IdDydaktyk) VALUES (15, 2, '2012-01-22', 5.0, 9)
INTO Ocena (IdStudent, IdPrzedmiot, DataWystawienia, Ocena, IdDydaktyk) VALUES (16, 2, '2013-01-23', 5.0, 9)
INTO Ocena (IdStudent, IdPrzedmiot, DataWystawienia, Ocena, IdDydaktyk) VALUES (17, 2, '2013-01-23', 4.5, 9)
INTO Ocena (IdStudent, IdPrzedmiot, DataWystawienia, Ocena, IdDydaktyk) VALUES (18, 2, '2013-01-23', 2.0, 9)
INTO Ocena (IdStudent, IdPrzedmiot, DataWystawienia, Ocena, IdDydaktyk) VALUES (18, 2, '2013-02-01', 3.0, 9)
INTO Ocena (IdStudent, IdPrzedmiot, DataWystawienia, Ocena, IdDydaktyk) VALUES (19, 2, '2014-01-18', 3.0, 9)
INTO Ocena (IdStudent, IdPrzedmiot, DataWystawienia, Ocena, IdDydaktyk) VALUES (20, 2, '2014-01-18', 4.0, 9)
INTO Ocena (IdStudent, IdPrzedmiot, DataWystawienia, Ocena, IdDydaktyk) VALUES (21, 2, '2014-01-18', 3.5, 9)
INTO Ocena (IdStudent, IdPrzedmiot, DataWystawienia, Ocena, IdDydaktyk) VALUES (22, 2, '2014-01-18', 5.0, 9)
INTO Ocena (IdStudent, IdPrzedmiot, DataWystawienia, Ocena, IdDydaktyk) VALUES (12, 12, '2014-01-18', 4.0, 8)
INTO Ocena (IdStudent, IdPrzedmiot, DataWystawienia, Ocena, IdDydaktyk) VALUES (13, 12, '2014-01-18', 4.5, 8)
INTO Ocena (IdStudent, IdPrzedmiot, DataWystawienia, Ocena, IdDydaktyk) VALUES (14, 12, '2014-01-18', 4.0, 8)
INTO Ocena (IdStudent, IdPrzedmiot, DataWystawienia, Ocena, IdDydaktyk) VALUES (15, 12, '2014-01-18', 3.0, 8)
SELECT * FROM dual;

-----------------------------------------------------------------------------------------------------------------
--StudentGrupa
-----------------------------------------------------------------------------------------------------------------
INSERT ALL
INTO StudentGrupa (IdOsoba, IdGrupa) VALUES (12, 1)
INTO StudentGrupa (IdOsoba, IdGrupa) VALUES (12, 3)
INTO StudentGrupa (IdOsoba, IdGrupa) VALUES (12, 9)
INTO StudentGrupa (IdOsoba, IdGrupa) VALUES (12, 11)
INTO StudentGrupa (IdOsoba, IdGrupa) VALUES (12, 21)
INTO StudentGrupa (IdOsoba, IdGrupa) VALUES (12, 22)
INTO StudentGrupa (IdOsoba, IdGrupa) VALUES (13, 1)
INTO StudentGrupa (IdOsoba, IdGrupa) VALUES (13, 3)
INTO StudentGrupa (IdOsoba, IdGrupa) VALUES (13, 9)
INTO StudentGrupa (IdOsoba, IdGrupa) VALUES (13, 11)
INTO StudentGrupa (IdOsoba, IdGrupa) VALUES (13, 21)
INTO StudentGrupa (IdOsoba, IdGrupa) VALUES (13, 22)
INTO StudentGrupa (IdOsoba, IdGrupa) VALUES (14, 1)
INTO StudentGrupa (IdOsoba, IdGrupa) VALUES (14, 3)
INTO StudentGrupa (IdOsoba, IdGrupa) VALUES (14, 9)
INTO StudentGrupa (IdOsoba, IdGrupa) VALUES (14, 11)
INTO StudentGrupa (IdOsoba, IdGrupa) VALUES (14, 21)
INTO StudentGrupa (IdOsoba, IdGrupa) VALUES (14, 22)
INTO StudentGrupa (IdOsoba, IdGrupa) VALUES (15, 1)
INTO StudentGrupa (IdOsoba, IdGrupa) VALUES (15, 3)
INTO StudentGrupa (IdOsoba, IdGrupa) VALUES (15, 9)
INTO StudentGrupa (IdOsoba, IdGrupa) VALUES (15, 11)
INTO StudentGrupa (IdOsoba, IdGrupa) VALUES (15, 21)
INTO StudentGrupa (IdOsoba, IdGrupa) VALUES (15, 22)
INTO StudentGrupa (IdOsoba, IdGrupa) VALUES (16, 5)
INTO StudentGrupa (IdOsoba, IdGrupa) VALUES (17, 5)
INTO StudentGrupa (IdOsoba, IdGrupa) VALUES (18, 5)
INTO StudentGrupa (IdOsoba, IdGrupa) VALUES (16, 7)
INTO StudentGrupa (IdOsoba, IdGrupa) VALUES (17, 7)
INTO StudentGrupa (IdOsoba, IdGrupa) VALUES (18, 7)
INTO StudentGrupa (IdOsoba, IdGrupa) VALUES (16, 17)
INTO StudentGrupa (IdOsoba, IdGrupa) VALUES (17, 17)
INTO StudentGrupa (IdOsoba, IdGrupa) VALUES (18, 17)
INTO StudentGrupa (IdOsoba, IdGrupa) VALUES (16, 19)
INTO StudentGrupa (IdOsoba, IdGrupa) VALUES (17, 19)
INTO StudentGrupa (IdOsoba, IdGrupa) VALUES (18, 19)
INTO StudentGrupa (IdOsoba, IdGrupa) VALUES (19, 13)
INTO StudentGrupa (IdOsoba, IdGrupa) VALUES (20, 13)
INTO StudentGrupa (IdOsoba, IdGrupa) VALUES (21, 13)
INTO StudentGrupa (IdOsoba, IdGrupa) VALUES (22, 14)
INTO StudentGrupa (IdOsoba, IdGrupa) VALUES (24, 14)
INTO StudentGrupa (IdOsoba, IdGrupa) VALUES (25, 14)
INTO StudentGrupa (IdOsoba, IdGrupa) VALUES (19, 15)
INTO StudentGrupa (IdOsoba, IdGrupa) VALUES (20, 15)
INTO StudentGrupa (IdOsoba, IdGrupa) VALUES (21, 15)
INTO StudentGrupa (IdOsoba, IdGrupa) VALUES (22, 16)
INTO StudentGrupa (IdOsoba, IdGrupa) VALUES (24, 16)
INTO StudentGrupa (IdOsoba, IdGrupa) VALUES (25, 16)
INTO StudentGrupa (IdOsoba, IdGrupa) VALUES (26, 23)
INTO StudentGrupa (IdOsoba, IdGrupa) VALUES (27, 23)
INTO StudentGrupa (IdOsoba, IdGrupa) VALUES (28, 23)
INTO StudentGrupa (IdOsoba, IdGrupa) VALUES (29, 24)
INTO StudentGrupa (IdOsoba, IdGrupa) VALUES (30, 24)
INTO StudentGrupa (IdOsoba, IdGrupa) VALUES (31, 24)
INTO StudentGrupa (IdOsoba, IdGrupa) VALUES (26, 25)
INTO StudentGrupa (IdOsoba, IdGrupa) VALUES (27, 25)
INTO StudentGrupa (IdOsoba, IdGrupa) VALUES (28, 25)
INTO StudentGrupa (IdOsoba, IdGrupa) VALUES (29, 26)
INTO StudentGrupa (IdOsoba, IdGrupa) VALUES (30, 26)
INTO StudentGrupa (IdOsoba, IdGrupa) VALUES (31, 26)
SELECT * FROM dual;
Commit;