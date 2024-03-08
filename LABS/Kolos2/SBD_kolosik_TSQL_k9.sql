

DROP TABLE IF EXISTS K9_Udzial;
DROP TABLE IF EXISTS K9_Zawody;
DROP TABLE IF EXISTS K9_Zawodnik; 

-- tables
-- Table: K9_Udzial
CREATE TABLE K9_Udzial (
    Zawodnik int  NOT NULL,
    Zawody int  NOT NULL,
    Runda int  NOT NULL,
    Punkty int  NULL,
    CONSTRAINT K9_Udzial_pk PRIMARY KEY  (Runda,Zawodnik,Zawody)
);

-- Table: K9_Zawodnik
CREATE TABLE K9_Zawodnik (
    Id int  NOT NULL IDENTITY(1, 1),
    Imie varchar(30)  NOT NULL
    CONSTRAINT K9_Zawodnik_pk PRIMARY KEY  (Id)
);

-- Table: K9_Zawody
CREATE TABLE K9_Zawody (
    Id int  NOT NULL IDENTITY(1, 1),
    Nazwa varchar(40)  NOT NULL,
    CONSTRAINT K9_Zawody_pk PRIMARY KEY  (Id)
);

-- foreign keys
-- Reference: K9_Udzial_K9_Zawodnik (table: K9_Udzial)
ALTER TABLE K9_Udzial ADD CONSTRAINT K9_Udzial_K9_Zawodnik
    FOREIGN KEY (Zawodnik)
    REFERENCES K9_Zawodnik (Id);

-- Reference: K9_Udzial_K9_Zawody (table: K9_Udzial)
ALTER TABLE K9_Udzial ADD CONSTRAINT K9_Udzial_K9_Zawody
    FOREIGN KEY (Zawody)
    REFERENCES K9_Zawody (Id);

INSERT INTO K9_Zawodnik (Imie) 
VALUES
('Theramenes'),
('Thrasybulus'),
('Thrasyllus'),
('Phrynichus'),
('Myronides'),
('Tolmides');

INSERT INTO K9_Zawody (Nazwa) 
VALUES
('Pythian Games'),
('Nemean Games'),
('Isthmian Games'),
('Olympic Games');


INSERT INTO K9_Udzial (Zawodnik, Zawody, Runda, Punkty) 
VALUES
(1,1,1,5),
(2,1,1,4),
(3,1,1,4),
(4,1,1,2),
(5,1,1,6),
(6,1,1,3),
(1,1,2,3),
(2,1,2,4),
(3,1,2,6),
(5,1,2,1),
(6,1,2,2),
(1,1,3,3),
(2,1,3,2),
(3,1,3,1),
(6,1,3,4),
(1,2,1,5),
(2,2,1,4),
(3,2,1,NULL),
(4,2,1,NULL),
(1,3,1,3),
(2,3,1,2),
(3,3,1,4),
(4,3,1,1),
(5,3,1,3);

-- End of file.

