/*
    Procedura Albumy_Uzytkownika ma za zadanie wyświetlić nazwy playlist,
    które należą do użytkownika o podanym adresie email.
    Parametry:
    v_mailUzytkownika - adres email użytkownika, dla którego chcemy zobaczyć playlisty.
    Działanie procedury:
    Procedura sprawdza, czy istnieje użytkownik o podanym adresie email w tabeli UZYTKOWNICY.
    Jeśli nie, podnoszony jest błąd i procedura kończy działanie.
    Następnie sprawdzane jest, czy użytkownik ma jakieś playlisty w tabeli PLAYLISTY.
    Jeśli nie, podnoszony jest błąd z komunikatem o braku playlist i procedura kończy działanie.
    Procedura Wyświetla id i nazwy playlisty dla każdego wiersza z kursora.
    Procedura kończy działanie.
*/
ALTER TABLE UZYTKOWNICY ADD CONSTRAINT EMAIL_UNIQE UNIQUE (EMAIL);

create or replace procedure Albumy_Uzytkownika(v_mailUzytkownika UZYTKOWNICY.EMAIL%type)
is
    cursor usr_playlists is
    select ID_PLAYLISTY, NAZWA
    from PLAYLISTY
    where ID_UZYTKOWNIKA = (select ID_UZYTKOWNIKA
                            from UZYTKOWNICY
                            where EMAIL = v_mailUzytkownika);
    v_UserName UZYTKOWNICY.IMIE%type;
    v_UserSurname UZYTKOWNICY.NAZWISKO%type;
begin
    begin
        select IMIE, NAZWISKO
        into v_UserName, v_UserSurname
        from UZYTKOWNICY
        where EMAIL = v_mailUzytkownika;
        exception
            when no_data_found then
                raise_application_error(-20001,'Użytkownik o podanym mail ' || v_mailUzytkownika || ' nie istnieje.');
    end;

    declare
        v_tmpID integer;
    begin
        select ID_UZYTKOWNIKA
        into v_tmpID
        from PLAYLISTY
        where ID_UZYTKOWNIKA = (select ID_UZYTKOWNIKA
                            from UZYTKOWNICY
                            where EMAIL = v_mailUzytkownika)
        fetch first 1 row only;
        exception
            when no_data_found then
                raise_application_error(-20001,v_UserName || ' ' || v_UserSurname || ' nie posiada żadnych playlist.');
    end;
    DBMS_OUTPUT.PUT_LINE('Playlisty użytkownika ' || v_UserName || ' ' || v_UserSurname);
    for v_row in usr_playlists loop
        DBMS_OUTPUT.PUT_LINE('ID = ' || v_row.ID_PLAYLISTY || ', nazwa: ' || v_row.NAZWA);
    end loop;
end;

--Wywołujemy procedurę Albumy_Uzytkownika dla użytkownika o adresie email 'example@example.com'
--Oczeiwany wynik: Użytkownik o podanym mail example@example.com nie istnieje.
call Albumy_Uzytkownika('example@example.com');
--Dodajemy użytkownika o adresie email 'example@example.com'
insert into UZYTKOWNICY
values ((select max(ID_UZYTKOWNIKA) from UZYTKOWNICY) + 1, 'Nowy', 'Użytkownik', 'example@example.com', current_date);
--Wywołujemy procedurę Albumy_Uzytkownika dla użytkownika o adresie email 'example@example.com'
--Oczekiwany wynik: Nowy Użytkownik nie posiada żadnych playlist.
call Albumy_Uzytkownika('example@example.com');
--Wywołujemy procedurę Albumy_Uzytkownika dla użytkownika o adresie email 'magdalena.wlodarczyk@example.com'
--Oczekiwany wynik: Playlisty użytkownika Magdalena Włodarczyk
-- ID = 26, nazwa: Country Favorites
-- ID = 27, nazwa: Smooth Jazz
-- ID = 28, nazwa: Reggae Mix
-- ID = 29, nazwa: Epic Soundtracks
-- ID = 30, nazwa: Party Hits
call Albumy_Uzytkownika('magdalena.wlodarczyk@example.com');

/*
    Procedura Ulubieni_Wykonawcy ma za zadanie wyświetlić nazwy i liczbę odtworzeń ulubionych wykonawców użytkownika
    o podanym adresie email.
    Parametry:
    v_mailUzytkownika - adres email użytkownika, dla którego chcemy zobaczyć ulubionych wykonawców
    v_iluWykonawcow - liczba wykonawców, którą chcemy wyświetlić z domyślną wartością 5.
    Opis działania procedury:
    Procedura najpierw sprawdza, czy istnieje użytkownik o podanym adresie email w tabeli UZYTKOWNICY.
    Jeśli nie, zgłasza błąd i kończy działanie.
    Następnie procedura sprawdza, czy użytkownik ma jakieś odtworzenia w tabeli HISTORIA_ODTWARZANIA.
    Jeśli nie, zgłasza błąd i kończy działanie.
    Następnie procedura wyświetla informację o użytkowniku i liczbie wykonawców, którą chce wyświetlić.
    Wreszcie procedura otwiera kursor usr_fav_artists i iteruje po wszystkich wierszach, które zwraca.
    Dla każdego wiersza wyświetla nazwę i liczbę odtworzeń wykonawcy dla danego użytkownika.
    (Założyłem, że jest to pokroju podsumowania roku jak 'Spotify Wrapped' i uzytkownicy sa aktywnymi sluchaczami, pomimp
    ze nie mam tylu rekordow w bazie danych)
*/
create or replace procedure Ulubieni_Wykonawcy
    (v_mailUzytkownika UZYTKOWNICY.EMAIL%type,
    v_iluWykonawcow integer default 5)
is
    cursor usr_fav_artists is
    select w.NAZWA, count(*) as LICZBA_UTWOROW
    from HISTORIA_ODTWARZANIA ho
    join UTWORY u on ho.ID_UTWORU = u.ID_UTWORU
    join ALBUMY a on u.ID_ALBUMU = a.ID_ALBUMU
    join WYKONAWCY w on a.ID_WYKONAWCY = w.ID_WYKONAWCY
    where ho.ID_UZYTKOWNIKA = (select ID_UZYTKOWNIKA
                            from UZYTKOWNICY
                            where EMAIL = v_mailUzytkownika)
    group by w.NAZWA
    order by LICZBA_UTWOROW desc
    fetch first v_iluWykonawcow rows only;

    v_UserName UZYTKOWNICY.IMIE%type;
    v_UserSurname UZYTKOWNICY.NAZWISKO%type;
begin
    begin
        select IMIE, NAZWISKO
        into v_UserName, v_UserSurname
        from UZYTKOWNICY
        where EMAIL = v_mailUzytkownika;
        exception
            when no_data_found then
                raise_application_error(-20001,'Użytkownik o podanym mail ' || v_mailUzytkownika || ' nie istnieje.');
    end;

    declare
        v_tmpID integer;
    begin
        select ID_UZYTKOWNIKA
        into v_tmpID
        from HISTORIA_ODTWARZANIA
        where ID_UZYTKOWNIKA = (select ID_UZYTKOWNIKA
                            from UZYTKOWNICY
                            where EMAIL = v_mailUzytkownika)
        fetch first 1 row only;
        exception
            when no_data_found then
                raise_application_error(-20001,v_UserName || ' ' || v_UserSurname || ' nie posiada żadnych odtworzeń.');
    end;

    DBMS_OUTPUT.PUT_LINE('TOP ' || v_iluWykonawcow || ' ulubionych wykonawców użytkownika ' || v_UserName || ' ' || v_UserSurname);
    for v_row in usr_fav_artists loop
        DBMS_OUTPUT.PUT_LINE('Wykonawca: ' || v_row.NAZWA || ', liczba odtworzeń: ' || v_row.LICZBA_UTWOROW);
    end loop;
end;

--Wywołujemy procedurę Ulubieni_Wykonawcy dla użytkownika o adresie email 'ex@ex.com'
--Oczekiwany wynik: Użytkownik o podanym mail ex@ex.com nie istnieje.
call Ulubieni_Wykonawcy('ex@ex');
--Wywołujemy procedurę Ulubieni_Wykonawcy dla użytkownika o adresie email 'example@example.com'
--Oczekiwany wynik: Nowy Użytkownik nie posiada żadnych odtworzeń.
call Ulubieni_Wykonawcy('example@example.com');
--Wywołujemy procedurę Ulubieni_Wykonawcy dla użytkownika o adresie email 'magdalena.wlodarczyk@example.com' i domyślną liczbą wykonawców
--Oczekiwany wynik: TOP 5 ulubionych wykonawców użytkownika Magdalena Włodarczyk
-- Wykonawca: Greta Van Fleet, liczba odtworzeń: 4
-- Wykonawca: The Rolling Stones, liczba odtworzeń: 2
-- Wykonawca: Charlotte de Witte, liczba odtworzeń: 2
-- Wykonawca: The Beatles, liczba odtworzeń: 1
-- Wykonawca: Pink Floyd, liczba odtworzeń: 1
call Ulubieni_Wykonawcy('magdalena.wlodarczyk@example.com');
--Wywołujemy procedurę Ulubieni_Wykonawcy dla użytkownika o adresie email 'magdalena.wlodarczyk@example.com' i 3 wykonawców
--Oczekiwany wynik: TOP 3 ulubionych wykonawców użytkownika Magdalena Włodarczyk
-- Wykonawca: Greta Van Fleet, liczba odtworzeń: 4
-- Wykonawca: Charlotte de Witte, liczba odtworzeń: 2
-- Wykonawca: The Rolling Stones, liczba odtworzeń: 2
call Ulubieni_Wykonawcy('magdalena.wlodarczyk@example.com', 3);

/*
    Wyzwalacz check_playlist_name ma za zadanie sprawdzić,
    czy nazwa playlisty jest unikalna dla danego użytkownika przed dodaniem nowej playlisty do tabeli PLAYLISTY.
    Opis działania wyzwalacza:
    Wyzwalacz jest uruchamiany przed dodaniem nowego wiersza do tabeli PLAYLISTY dla każdego wiersza.
    Wyzwalacz najpierw sprawdza, czy istnieje użytkownik o podanym id w tabeli UZYTKOWNICY.
    Jeśli nie, zgłasza błąd i kończy działanie.
    Następnie wyzwalacz sprawdza, czy istnieje już playlista o tej samej nazwie dla danego użytkownika w tabeli PLAYLISTY.
    Jeśli tak, zgłasza błąd i kończy działanie.
    Jeśli nie, przypisuje do zmiennej v_info informację o dodaniu playlisty.
    Na koniec wyzwalacz wyświetla wartość zmiennej v_info.
*/
create or replace trigger check_playlist_name
before insert
on PLAYLISTY
for each row
declare
    v_ctnNazwa integer;
    v_UserName UZYTKOWNICY.IMIE%type;
    v_UserSurname UZYTKOWNICY.NAZWISKO%type;
    v_info varchar2(100);
begin
    declare
        v_tmpUser integer;
    begin
        select ID_UZYTKOWNIKA
        into v_tmpUser
        from UZYTKOWNICY
        where ID_UZYTKOWNIKA = :new.ID_UZYTKOWNIKA;
        exception
            when no_data_found then
                raise_application_error(-20001,'Użytkownik o podanym ID ' || :new.ID_UZYTKOWNIKA || ' nie istnieje.');
    end;

    select count(*)
    into v_ctnNazwa
    from PLAYLISTY
    where NAZWA = :new.NAZWA
    and ID_UZYTKOWNIKA = :new.ID_UZYTKOWNIKA;

    select IMIE, NAZWISKO
    into v_UserName, v_UserSurname
    from UZYTKOWNICY
    where ID_UZYTKOWNIKA = :new.ID_UZYTKOWNIKA;


    if v_ctnNazwa > 0 then
    raise_application_error(-20001, 'Playlista o nazwie ' || :new.NAZWA || ' już istnieje w bibliotece użytkownika '
                                    || v_UserName || ' ' || v_UserSurname || '.');
    else
        v_info := 'Dodano playlistę o nazwie ' || :new.NAZWA || ' do biblioteki użytkownika ' || v_UserName
                      || ' ' || v_UserSurname;
    end if;
    DBMS_OUTPUT.PUT_LINE(v_info);
end;

--Dodajemy do tabeli PLAYLISTY nową playlistę o nazwie 'Chill Vibes' dla użytkownika o ID 12
--Oczekiwany wynik: Użytkownik o podanym ID 12 nie istnieje.
insert into PLAYLISTY
values ((select max(ID_PLAYLISTY) from PLAYLISTY) + 1, 'Chill Vibes', 12);
--Dodajemy do tabeli PLAYLISTY nową playlistę o nazwie 'Chill Vibes' dla użytkownika o ID 1
--Oczekiwany wynik: Playlista o nazwie Chill Vibes już istnieje w bibliotece użytkownika Jan Kowalski.
insert into PLAYLISTY
values ((select max(ID_PLAYLISTY) from PLAYLISTY) + 1, 'Chill Vibes', 1);
--Dodajemy do tabeli PLAYLISTY nową playlistę o nazwie 'Przykładowa nazwa' dla użytkownika o ID 11
--Oczekiwany wynik: Dodano playlistę o nazwie Przykładowa nazwa do biblioteki użytkownika Nowy Użytkownik.
insert into PLAYLISTY
values ((select max(ID_PLAYLISTY) from PLAYLISTY) + 1, 'Przykładowa nazwa', 11);

/*
    Wyzwalacz UTWORY_TIIUD ma za zadanie umożliwić dodawanie,
    aktualizowanie i usuwanie danych z widoku Informacje_o_Utworze, który zawiera informacje o
    utworach, wykonawcach, albumach i gatunkach.
    Opis działania wyzwalacza:
    Wyzwalacz jest uruchamiany zamiast dodania, aktualizacji lub usunięcia wiersza z widoku Informacje_o_Utworze
    dla każdego wiersza.
    Wyzwalacz najpierw sprawdza, czy operacja jest dodawaniem. Jeśli tak, wykonuje następujące kroki:
    Sprawdza, czy istnieje wykonawca o podanej nazwie w tabeli WYKONAWCY.
    Jeśli nie, dodaje nowy rekord do tej tabeli z nowym id, nazwą i aktualną datą.
    Sprawdza, czy istnieje album o podanej nazwie i wykonawcy w tabeli ALBUMY.
    Jeśli nie, dodaje nowy rekord do tej tabeli z nowym id, nazwą, aktualną datą i id wykonawcy.
    Sprawdza, czy istnieje gatunek o podanej nazwie w tabeli GATUNKI.
    Jeśli nie, dodaje nowy rekord do tej tabeli z nowym id i nazwą.
    Sprawdza, czy istnieje utwór o podanym tytule i albumie w tabeli UTWORY.
    Jeśli nie, dodaje nowy rekord do tej tabeli z nowym id, tytułem, czasem trwania, id albumu i id gatunku.
    Następnie wyzwalacz sprawdza, czy operacja jest aktualizacją. Jeśli tak, wykonuje następujące kroki:
    Sprawdza, czy aktualizowana jest kolumna TYTUL.
    Jeśli tak, zmienia tytuł utworu w tabeli UTWORY na nową wartość i wyświetla informację o zmianie.
    Sprawdza, czy aktualizowana jest kolumna WYKONAWCA, GATUNEK, ALBUM, DATA_WYDANIA lub CZAS_TRWANIA.
    Jeśli tak, zgłasza błąd i kończy działanie. Tych kolumn nie można aktualizować przez widok Informacje_o_Utworze.
    Wreszcie wyzwalacz sprawdza, czy operacja jest usuwaniem. Jeśli tak, wykonuje następujący krok:
    Zmienia id albumu utworu w tabeli UTWORY na null, aby usunąć powiązanie z albumem.
    Nie usuwa całego rekordu z tabeli UTWORY, ponieważ utwór może być nadal używany w innych tabelach, takich jak
    HISTORIA_ODTWARZANIA czy PLAYLISTY.
*/
ALTER TABLE UTWORY
MODIFY (ID_ALBUMU NULL);
create or replace view Informacje_o_Utworze as
    select u.TYTUL, w.NAZWA as WYKONAWCA, a.NAZWA as ALBUM, g.NAZWA_GATUNKU as GATUNEK, a.DATA_WYDANIA, u.CZAS_TRWANIA
    from UTWORY u
    join ALBUMY a on u.ID_ALBUMU = a.ID_ALBUMU
    join WYKONAWCY w on a.ID_WYKONAWCY = w.ID_WYKONAWCY
    join GATUNKI g on u.ID_GATUNKU = g.ID_GATUNKU
    where u.ID_ALBUMU is not null
    order by a.DATA_WYDANIA desc;

create or replace trigger UTWORY_TIIUD
instead of insert or update or delete
on Informacje_o_Utworze
for each row
declare
    v_ctnWykonawca integer;
    v_ctnAlbum integer;
    v_ctnUtwor integer;
    v_ctnGatunek integer;
    v_currDate date := to_date(to_char(current_date, 'yyyy-mm-dd'));
begin
    if inserting then
        select count(*)
        into v_ctnWykonawca
        from WYKONAWCY
        where NAZWA = :new.WYKONAWCA;
        if v_ctnWykonawca = 0 then
            insert into WYKONAWCY
            values ((select max(ID_WYKONAWCY) from WYKONAWCY) + 1, :new.WYKONAWCA, v_currDate);
        end if;

        select count(*)
        into v_ctnAlbum
        from ALBUMY
        where NAZWA = :new.ALBUM
        and ID_WYKONAWCY = (select ID_WYKONAWCY from WYKONAWCY where NAZWA = :new.WYKONAWCA);
        if v_ctnAlbum = 0 then
            insert into ALBUMY
            values ((select max(ID_ALBUMU) from ALBUMY) + 1,
                    :new.ALBUM,
                    v_currDate,
                   (select ID_WYKONAWCY from WYKONAWCY where NAZWA = :new.WYKONAWCA));
        end if;

        select count(*)
        into v_ctnGatunek
        from GATUNKI
        where NAZWA_GATUNKU = :new.GATUNEK;
        if v_ctnGatunek = 0 then
            insert into GATUNKI
            values ((select max(ID_GATUNKU) from GATUNKI) + 1, :new.GATUNEK);
        end if;

        select count(*)
        into v_ctnUtwor
        from UTWORY
        where TYTUL = :new.TYTUL
        and ID_ALBUMU = (select ID_ALBUMU from ALBUMY where NAZWA = :new.ALBUM);
        if v_ctnUtwor = 0 then
            insert into UTWORY
            values ((select max(ID_UTWORU) from UTWORY) + 1,
                    :new.TYTUL,
                    :new.CZAS_TRWANIA,
                    (select ID_ALBUMU from ALBUMY where NAZWA = :new.ALBUM),
                    (select ID_GATUNKU from GATUNKI where NAZWA_GATUNKU = :new.GATUNEK));
        end if;
        DBMS_OUTPUT.PUT_LINE('Dodano utwór ' || :new.TYTUL || ' do albumu ' || :new.ALBUM ||
                             ' wykonawcy ' || :new.WYKONAWCA || '.');

    elsif updating('TYTUL') then
        update UTWORY
        set TYTUL = :new.TYTUL
        where ID_UTWORU = (select ID_UTWORU from UTWORY where TYTUL = :old.TYTUL)
        and ID_ALBUMU = (select ID_ALBUMU from ALBUMY where NAZWA = :old.ALBUM and ID_WYKONAWCY = (
            select ID_WYKONAWCY from WYKONAWCY where NAZWA = :old.WYKONAWCA
            ));
        DBMS_OUTPUT.PUT_LINE('Zmieniono tytuł utworu ' || :old.TYTUL || ' z albumu ' || :old.ALBUM ||
                             ' wykonawcy ' || :old.WYKONAWCA || ' na ' || :new.TYTUL);

    elsif deleting then
        update UTWORY
        set ID_ALBUMU = null
        where ID_UTWORU = (select ID_UTWORU from UTWORY where TYTUL = :old.TYTUL)
        and ID_ALBUMU = (select ID_ALBUMU from ALBUMY where NAZWA = :old.ALBUM and ID_WYKONAWCY = (
            select ID_WYKONAWCY from WYKONAWCY where NAZWA = :old.WYKONAWCA
            ));
        DBMS_OUTPUT.PUT_LINE('Usunięto utwór ' || :old.TYTUL || ' z albumu ' || :old.ALBUM ||
                             ' wykonawcy ' || :old.WYKONAWCA || '.');

    else
        raise_application_error(-20001, 'Dozwolone jest aktualizowanie tylko kolumny TYTUL.');
    end if;
end;

--Dodajemy nowy utwór do widoku Informacje_o_Utworze
--Oczekiwany wynik: Dodano utwór 'The Chain' do albumu Rumours wykonawcy Fleetwood Mac.
insert into Informacje_o_Utworze
values ('The Chain', 'Fleetwood Mac', 'Rumours', 'Rock', '1977-02-04', '00:04:30');

--Aktualizujemy tytuł utworu w widoku Informacje_o_Utworze
--Oczekiwany wynik: Zmieniono tytuł utworu The Chain z albumu Rumours wykonawcy Fleetwood Mac na The Chain (2004 Remaster)
update Informacje_o_Utworze
set TYTUL = 'The Chain (2004 Remaster)'
where TYTUL = 'The Chain';

--Aktualizujemy wykonawcę utworu w widoku Informacje_o_Utworze
--Oczekiwany wynik: Dozwolone jest aktualizowanie tylko kolumny TYTUL.
update Informacje_o_Utworze
set WYKONAWCA = 'Fleetwood Mac'
where TYTUL = 'The Chain (2004 Remaster)';

--Usuwanie utworu z widoku Informacje_o_Utworze
--Oczekiwany wynik: Usunięto utwór 'The Chain (2004 Remaster)' z albumu Rumours wykonawcy Fleetwood Mac.
delete from Informacje_o_Utworze
where TYTUL = 'The Chain (2004 Remaster)';