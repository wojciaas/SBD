/*Zadanie 01*/
DELETE FROM T_ListaProduktow
WHERE zakup = 55 AND produkt = 4;
create or replace trigger t_zabronUsuniecia
    before delete
on T_LISTAPRODUKTOW
begin
    raise_application_error(-20001, 'Nie można usuwać rekordów z tabeli T_ListaProduktow');
end;

DELETE FROM T_ListaProduktow
WHERE zakup = 55 AND produkt = 5;

/*Zadanie 02*/
create or replace trigger t_zabronUsuniecia
    before delete
on T_LISTAPRODUKTOW
for each row
begin
    raise_application_error(-20001, 'Nie można usuwać rekordów z tabeli T_ListaProduktow.' ||
                                    ' Usuwanie rekordu dla zakupu= ' || :old.ZAKUP || ' produktu= ' || :old.PRODUKT || ' nie powiodło  się');
end;
DELETE FROM T_ListaProduktow
WHERE zakup = 55 AND produkt = 5;

/*Zadanie 03*/
DELETE FROM T_Zakup WHERE id = 1;
create or replace trigger T_Zakup_ADR
    after delete
    on T_ZAKUP
    for each row
begin
    delete from T_LISTAPRODUKTOW where ZAKUP = :old.id;
    DBMS_OUTPUT.PUT_LINE('Usunięto zakup o id = ' || :old.id);
end;
DELETE FROM T_Zakup WHERE id = 1;

/*Zadanie 04*/
create or replace trigger T_PRACOWNIK_BIUR
    before insert or update
    on T_PRACOWNIK
    for each row
    when (new.pensja >= 10000)
begin
    raise_application_error(-20001, 'Pensja za duża, operacja DML nie powiodła się');
end;
UPDATE T_Pracownik
SET pensja = 40000
WHERE id =2;

/*Zadanie 05*/
create or replace trigger T_PRODUKT_BUR
    before update of cena
    on T_PRODUKT
    for each row
    when (new.cena < old.cena)
begin
    raise_application_error(-20001, 'Nie można zmniejszać ceny');
end;
UPDATE T_Produkt
SET cena= 0.01
WHERE id = 2;

/*Zadanie 06*/
create or replace trigger T_OSOBA_BIUD
    before insert or update or delete
    on T_PRODUKT
    for each row
begin
    if inserting then
        if :new.cena > 100 then
            raise_application_error(-20001, 'Nie można dodać produktu z ceną większą niż 100');
        end if;
    elsif updating then
        if :new.cena > :old.cena then
            raise_application_error(-20001, 'Nowa cena nie może być większa niż stara');
        end if;
    else
        delete from T_LISTAPRODUKTOW
        where PRODUKT = :old.id;
        DBMS_OUTPUT.PUT_LINE('Usunięto wszystkie rekordy dla produktu z id = ' || :old.id || ' z tabeli T_LISTAPRODUKTOW');
    end if;
end;

/*Zadanie 07*/
create or replace trigger T_OSOBA_BIR
before insert
on T_OSOBA
for each row
declare
    v_ctnOsoba integer;
begin
    select count(*) into v_ctnOsoba from T_OSOBA where NAZWISKO = :new.nazwisko;
    if v_ctnOsoba > 0 then
        raise_application_error(-20001, 'Osoba o podanym nazwisku już istnieje');
    else
        DBMS_OUTPUT.PUT_LINE(:new.NAZWISKO || ' został pomyślnie dodany');
    end if;
end;
INSERT INTO T_Osoba (id, imie, nazwisko) VALUES (11, 'Tim', 'Theramenes');
INSERT INTO T_Osoba (id, imie, nazwisko) VALUES (11, 'Tim', 'Thrasybulus');
INSERT ALL
    INTO T_Osoba (id, imie, nazwisko) VALUES (12, 'Liam', 'Thrasyllus')
    INTO T_Osoba (id, imie, nazwisko) VALUES (13, 'Keith', 'Conon')
    INTO T_Osoba (id, imie, nazwisko) VALUES (14, 'Reece', 'Callicratidas')
SELECT 1 FROM DUAL;

/*Zadanie 08*/
alter session set nls_date_format = 'YYYY-MM-DD';
create or replace trigger T_ZATRUDNIENIE_BUR
before update
on T_ZATRUDNIENIE
for each row
begin
    if updating('pracownik') or updating('stanowisko') or updating('od') then
        raise_application_error(-20001, 'Można aktualizować tylko kolumnę Do');
    else
        if :old.do is not null then
            raise_application_error(-20001, 'Można aktualizować datę Do tylko gdy jest Nullem');
        elsif :old.od > :new.do then
            raise_application_error(-20001, 'Data Do nie może być wcześniejsza od daty Od');
        else
            DBMS_OUTPUT.PUT_LINE('Tabela T_Zatrudnienie została zaktualizowana');
        end if;
    end if;
end;
update T_ZATRUDNIENIE
set do = to_char(current_date, 'dd-mm-yyyy')
where PRACOWNIK = 6 and STANOWISKO = 2;

/*Zadanie 09*/
CREATE TABLE T_SprzedaneProdukty(Wartosc number(8,2) not null);
DECLARE
v_wartosc number(8,2);
BEGIN
    SELECT SUM(cena * ilosc) INTO v_wartosc FROM T_ListaProduktow lp
    JOIN T_Produkt p ON lp.produkt = p.id;
    INSERT INTO T_SprzedaneProdukty VALUES (v_wartosc);
END;
create or replace trigger T_SPRZEDANEPRODUKTY_BIUD
before insert or update or delete
on T_SPRZEDANEPRODUKTY
declare
    v_wartosc T_SprzedaneProdukty.Wartosc%type;
begin
    select sum(cena * ilosc) into v_wartosc from T_LISTAPRODUKTOW lp
    join T_PRODUKT p on lp.PRODUKT = p.ID;
    update T_SPRZEDANEPRODUKTY
    set Wartosc = v_wartosc
    where null is null;
end;

/*Zadanie 10*/
create view V_Pracownik(Imie, Nazwisko, Pensja, Stanowisko)
as
select o.imie, o.nazwisko, p.pensja, s.nazwa
from T_OSOBA o join T_PRACOWNIK p on o.ID = p.ID
join T_ZATRUDNIENIE z on p.ID = z.PRACOWNIK
join T_STANOWISKO s on z.STANOWISKO = s.ID
where z.do is null;

create or replace trigger V_Pracownik_IOI
instead of insert
on V_Pracownik
for each row
declare
    v_idOsoby integer;
    v_IdStanowiska integer;
    v_ctnPracownicy integer;
    v_ctnZatrudnienie integer;
    v_dzisiejszaData date := to_date(current_date, 'YYYY-MM-DD');
begin
    begin
        select ID into v_idOsoby from T_OSOBA where IMIE = :new.imie and NAZWISKO = :new.nazwisko;
        exception
            when no_data_found then
                v_idOsoby := null;
    end;

    if v_idOsoby is null then
        select max(id) + 1 into v_idOsoby from T_OSOBA;
        insert into T_OSOBA
        VALUES (v_idOsoby, :new.imie, :new.nazwisko, null);
        DBMS_OUTPUT.PUT_LINE('Dodano nową osobę o id = ' || v_idOsoby);
    end if;

    select count(*) into v_ctnPracownicy from T_PRACOWNIK where ID = v_idOsoby;
    if v_ctnPracownicy < 1 then
        insert into T_PRACOWNIK
        VALUES (v_idOsoby, :new.pensja, null, null);
        DBMS_OUTPUT.PUT_LINE('Dodano nowego pracownika o id = ' || v_idOsoby);
    else
        update T_PRACOWNIK
        set PENSJA = :new.pensja
        where id = v_idOsoby;
        DBMS_OUTPUT.PUT_LINE('Zaktualizowano pensję pracownikowi o id = ' || v_idOsoby);
    end if;

    begin
        select id into v_IdStanowiska from T_STANOWISKO where NAZWA = :new.stanowisko;
        exception
            when no_data_found then
                v_IdStanowiska := null;
    end;

    if v_IdStanowiska is null then
        select max(id) + 1 into v_IdStanowiska from T_STANOWISKO;
        insert into T_STANOWISKO
        VALUES (v_IdStanowiska, :new.stanowisko);
        DBMS_OUTPUT.PUT_LINE('Dodano nowe stanowisko o nazwie = ' || :new.stanowisko);
    end if;

    select count(*) into v_ctnZatrudnienie from T_ZATRUDNIENIE where PRACOWNIK = v_idOsoby and do is null and stanowisko = v_IdStanowiska;
    if v_ctnZatrudnienie < 1 then
        update T_ZATRUDNIENIE
        set do = v_dzisiejszaData
        where PRACOWNIK = v_idOsoby and do is null;

        insert into T_ZATRUDNIENIE
        VALUES (v_idOsoby, v_IdStanowiska, v_dzisiejszaData, null);
        DBMS_OUTPUT.PUT_LINE('Zaktualizowano historię zatrudnienia pracownikowi o id = ' || v_idOsoby);
    else
        DBMS_OUTPUT.PUT_LINE('Dany pracownik jest już zatrudniony na tym stanowisku');
    end if;
end;

INSERT INTO V_PRACOWNIK VALUES ('Mark', 'Clearchus', 9999, 'cashier');
INSERT INTO V_PRACOWNIK VALUES ('Mark', 'Clearchus', 9999, 'boss');
INSERT INTO V_PRACOWNIK VALUES ('Matthew', 'Mindarus', 8675, 'janitor');
INSERT INTO V_PRACOWNIK VALUES ('Matthew', 'Mindarus', 8675, 'security');
INSERT INTO V_PRACOWNIK VALUES ('Matthew', 'Mindarus', 9999, 'security');
select * from T_ZATRUDNIENIE;