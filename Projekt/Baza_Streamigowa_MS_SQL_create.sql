-- Created by Vertabelo (http://vertabelo.com)
-- Last modification date: 2024-01-14 01:30:58.801

-- tables
-- Table: Albumy
CREATE TABLE Albumy (
    ID_Albumu int IDENTITY(1,1) NOT NULL,
    Nazwa varchar(100)  NOT NULL,
    Data_Wydania date  NOT NULL,
    ID_Wykonawcy int  NOT NULL,
    CONSTRAINT Albumy_pk PRIMARY KEY (ID_Albumu)
) ;

-- Table: Gatunki
CREATE TABLE Gatunki (
    ID_Gatunku int IDENTITY(1,1) NOT NULL,
    Nazwa_Gatunku varchar(100)  NOT NULL,
    CONSTRAINT Gatunki_pk PRIMARY KEY (ID_Gatunku)
) ;

-- Table: Historia_Odtwarzania
CREATE TABLE Historia_Odtwarzania (
    ID_Utworu int  NOT NULL,
    ID_Uzytkownika int  NOT NULL,
    Data_Odtworzenia datetime  NOT NULL,
    CONSTRAINT Historia_Odtwarzania_pk PRIMARY KEY (ID_Utworu,ID_Uzytkownika)
) ;

-- Table: Obserwowani_wykonawcy
CREATE TABLE Obserwowani_wykonawcy (
    ID_Uzytkownika int  NOT NULL,
    ID_Wykonawcy int  NOT NULL,
    CONSTRAINT Obserwowani_wykonawcy_pk PRIMARY KEY (ID_Uzytkownika,ID_Wykonawcy)
) ;

-- Table: Playlisty
CREATE TABLE Playlisty (
    ID_Playlisty int IDENTITY(1,1) NOT NULL,
    Nazwa nvarchar(255)  NOT NULL,
    ID_Uzytkownika int  NOT NULL,
    CONSTRAINT Playlisty_pk PRIMARY KEY (ID_Playlisty)
) ;

-- Table: Utwory
CREATE TABLE Utwory (
    ID_Utworu int IDENTITY(1,1) NOT NULL,
    Tytul varchar(100)  NOT NULL,
    Czas_trwania varchar(8)  NOT NULL,
    ID_Albumu int  NOT NULL,
    ID_Gatunku int  NOT NULL,
    CONSTRAINT Utwory_pk PRIMARY KEY (ID_Utworu)
) ;

-- Table: Utwory_w_playliscie
CREATE TABLE Utwory_w_playliscie (
    ID_Playlisty int  NOT NULL,
    ID_Utworu int  NOT NULL,
    CONSTRAINT Utwory_w_playliscie_pk PRIMARY KEY (ID_Playlisty, ID_Utworu)
) ;

-- Table: Uzytkownicy
CREATE TABLE Uzytkownicy (
    ID_Uzytkownika int IDENTITY(1,1) NOT NULL,
    Imie varchar(50)  NOT NULL,
    Nazwisko varchar(50)  NOT NULL,
    Email varchar(100)  NOT NULL,
    Data_rejestracji date  NOT NULL,
    CONSTRAINT Uzytkownicy_pk PRIMARY KEY (ID_Uzytkownika)
) ;

-- Table: Wykonawcy
CREATE TABLE Wykonawcy (
    ID_Wykonawcy int IDENTITY(1,1) NOT NULL,
    Nazwa varchar(100)  NOT NULL,
    Data_rozpoczecia_kariery date  NOT NULL,
    CONSTRAINT Wykonawcy_pk PRIMARY KEY (ID_Wykonawcy)
) ;

-- foreign keys
-- Reference: Albumy_Wykonawcy (table: Albumy)
ALTER TABLE Albumy ADD CONSTRAINT Albumy_Wykonawcy
    FOREIGN KEY (ID_Wykonawcy)
    REFERENCES Wykonawcy (ID_Wykonawcy);

-- Reference: Odtwarzania_Utwory (table: Historia_Odtwarzania)
ALTER TABLE Historia_Odtwarzania ADD CONSTRAINT Odtwarzania_Utwory
    FOREIGN KEY (ID_Utworu)
    REFERENCES Utwory (ID_Utworu);

-- Reference: Odtwarzania_Uzytkownicy (table: Historia_Odtwarzania)
ALTER TABLE Historia_Odtwarzania ADD CONSTRAINT Odtwarzania_Uzytkownicy
    FOREIGN KEY (ID_Uzytkownika)
    REFERENCES Uzytkownicy (ID_Uzytkownika);

-- Reference: Playlisty_Uzytkownicy (table: Playlisty)
ALTER TABLE Playlisty ADD CONSTRAINT Playlisty_Uzytkownicy
    FOREIGN KEY (ID_Uzytkownika)
    REFERENCES Uzytkownicy (ID_Uzytkownika);

-- Reference: Utwory_Albumy (table: Utwory)
ALTER TABLE Utwory ADD CONSTRAINT Utwory_Albumy
    FOREIGN KEY (ID_Albumu)
    REFERENCES Albumy (ID_Albumu);

-- Reference: Utwory_Gatunki (table: Utwory)
ALTER TABLE Utwory ADD CONSTRAINT Utwory_Gatunki
    FOREIGN KEY (ID_Gatunku)
    REFERENCES Gatunki (ID_Gatunku);

-- Reference: Utwory_Playlisty (table: Utwory_w_playliscie)
ALTER TABLE Utwory_w_playliscie ADD CONSTRAINT Utwory_Playlisty
    FOREIGN KEY (ID_Playlisty)
    REFERENCES Playlisty (ID_Playlisty);

-- Reference: Utwory_Utwory (table: Utwory_w_playliscie)
ALTER TABLE Utwory_w_playliscie ADD CONSTRAINT Utwory_Utwory
    FOREIGN KEY (ID_Utworu)
    REFERENCES Utwory (ID_Utworu);

-- Reference: Wykonawcy_Uzytkownicy (table: Obserwowani_wykonawcy)
ALTER TABLE Obserwowani_wykonawcy ADD CONSTRAINT Wykonawcy_Uzytkownicy
    FOREIGN KEY (ID_Uzytkownika)
    REFERENCES Uzytkownicy (ID_Uzytkownika);

-- Reference: Wykonawcy_Wykonawcy (table: Obserwowani_wykonawcy)
ALTER TABLE Obserwowani_wykonawcy ADD CONSTRAINT Wykonawcy_Wykonawcy
    FOREIGN KEY (ID_Wykonawcy)
    REFERENCES Wykonawcy (ID_Wykonawcy);

-- End of file.