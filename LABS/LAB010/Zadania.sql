/*Zadanie 01*/
begin
    declare v_ile integer;
    begin
        select count(*) into v_ile from T_OSOBA;
        DBMS_OUTPUT.PUT_LINE('W tabeli jest ' || v_ile || ' osób');
    end;
end;

/*Zadanie 02*/
begin
    declare v_ile integer;
    begin
        select count(*) into v_ile from T_OSOBA;
        if v_ile < 11 then
            insert into T_OSOBA VALUES (v_ile + 1, 'Henry', 'Hippias');
            DBMS_OUTPUT.PUT_LINE('Wstawiono osobę: Henry Hippias');
            commit;
        else
            DBMS_OUTPUT.PUT_LINE('Nie wstawiono danych');
        end if;
    end;
end;

/*Zadanie 03*/
begin
    declare v_nazwa varchar2(50);
    begin
        --select nazwa into v_nazwa from T_PRODUKT where ID = 15;
        --select nazwa into v_nazwa from T_PRODUKT where ID in (1,2,3);
        --insert into T_PRODUKT VALUES (1, 'a', 1.83, 1);
        v_nazwa := 10/0;
        exception
        when no_data_found then
            DBMS_OUTPUT.PUT_LINE('Nie znaleziono rekordu');
        when too_many_rows then
            DBMS_OUTPUT.PUT_LINE('Znaleziono więcej niż jeden rekord');
        when dup_val_on_index then
            DBMS_OUTPUT.PUT_LINE('Naruszenie więzów unikalności');
        when others then
            DBMS_OUTPUT.PUT_LINE('Inny błąd');
    end;
end;

/*Zadanie 04*/
create or replace procedure AktualizacjaCeny(v_war T_PRODUKT.cena%type default 0.01)
as
begin
    update T_PRODUKT set
    cena = cena + v_war;
    DBMS_OUTPUT.PUT_LINE('Ilość zaktualizowanych rekordów: ' || sql%rowcount);
end;
begin
    AktualizacjaCeny();
end;

/*Zadanie 05*/
create or replace procedure DanePracownika
    (v_idPracownika T_PRACOWNIK.ID%type,
    v_imie OUT T_OSOBA.IMIE%type,
    v_nazwisko OUT T_OSOBA.NAZWISKO%type)
as
begin
    select imie, nazwisko into v_imie, v_nazwisko
    from T_PRACOWNIK join T_OSOBA on T_PRACOWNIK.ID = T_OSOBA.ID
    where T_PRACOWNIK.ID = v_idPracownika;
    exception
        when no_data_found then
            DBMS_OUTPUT.PUT_LINE('Pracownik o podanym id nie istnieje');
end;
begin
    declare v_imie T_OSOBA.IMIE%type; v_nazwisko T_OSOBA.NAZWISKO%type;
    begin
        DanePracownika(6, v_imie, v_nazwisko);
        DBMS_OUTPUT.PUT_LINE(v_imie || ' ' || v_nazwisko);
    end;
end;

/*Zadanie 06*/
create or replace procedure NowyZakup
    (v_idKlient T_ZAKUP.KLIENT%type,
    v_idNowyZakup OUT T_ZAKUP.ID%type)
AS
begin
    insert into T_ZAKUP (DATA, KLIENT)
    values (sysdate, v_idKlient)
    returning id into v_idNowyZakup;
    commit;
    DBMS_OUTPUT.PUT_LINE('Zarejestrowano nowy zakup o id: ' || v_idNowyZakup);
end;
declare
    v_idKlient T_ZAKUP.KLIENT%type := 11;
    v_idNowyZakup T_ZAKUP.ID%type;
    v_info T_ZAKUP%rowtype;
begin
    NowyZakup(v_idKlient, v_idNowyZakup);
    select id, data, klient into v_info.ID, v_info.DATA, v_info.KLIENT from T_ZAKUP where ID = v_idNowyZakup;
    DBMS_OUTPUT.PUT_LINE(v_info.ID || ' ' || v_info.KLIENT || ' ' || v_info.DATA);
end;

/*Zadanie 07*/
create or replace procedure DodajProduktDoZakupu
    (v_idProdukt T_PRODUKT.ID%type,
    v_ilosc T_LISTAPRODUKTOW.ILOSC%type,
    v_idZakup T_ZAKUP.ID%type)
as
    no_product_found exception;
    no_purchase_found exception;
    less_or_equal exception;
    v_product_exists integer;
    v_purchase_exists integer;
    v_product_in_purchase_exists integer;
begin
    select count(id) into v_product_exists from T_PRODUKT where ID = v_idProdukt;
    select count(id) into v_purchase_exists from T_ZAKUP where ID = v_idZakup;
    select count(PRODUKT) into v_product_in_purchase_exists from T_LISTAPRODUKTOW where PRODUKT = v_idProdukt and ZAKUP = v_idZakup;

    if v_product_exists = 0 then
        raise no_product_found;
    elsif v_purchase_exists = 0 then
        raise no_purchase_found;
    elsif v_ilosc <= 0 then
        raise less_or_equal;
    elsif v_product_in_purchase_exists > 0 then
        update T_LISTAPRODUKTOW
        set ILOSC = ILOSC + v_ilosc
        where ZAKUP = v_idZakup and PRODUKT = v_idProdukt;
        commit;
    else
        insert into T_LISTAPRODUKTOW
        VALUES (v_idZakup, v_idProdukt, v_ilosc);
        DBMS_OUTPUT.PUT_LINE('Do zakupu ' || v_idZakup || ' dodano produkt ' || v_idProdukt || ', w ilości: ' || v_ilosc);
        commit;
    end if;

    exception
        when no_product_found then
            DBMS_OUTPUT.PUT_LINE('Nie znaleziono produktu o id: ' || v_idProdukt);
        when no_purchase_found then
            DBMS_OUTPUT.PUT_LINE('Nie znaleziono zakupu o id: ' || v_idZakup);
        when less_or_equal then
            DBMS_OUTPUT.PUT_LINE('Ilość niepoprawna. Ilość ' || v_ilosc || ' <= 0');
end;
declare v_idZakup T_LISTAPRODUKTOW.ZAKUP%type;
begin
    NowyZakup(1, v_idZakup);
    DodajProduktDoZakupu(1, 1, 75);
    DodajProduktDoZakupu(1, 1, 75);
end;

/*Zadanie 08*/
create or replace procedure AktualizacjaStanowiska
    (v_IdPracownika T_PRACOWNIK.ID%type,
    v_IdStanowiska T_STANOWISKO.ID%type)
as
    v_ctnPracownik int;
    v_ctnStanowisko int;
    v_ctnPracownikStanowisko int;
    v_ctnStanowiskoPracownik int;
begin
    select count(*) into v_ctnPracownik from T_PRACOWNIK where ID = v_IdPracownika;
    if v_ctnPracownik = 0 then
        DBMS_OUTPUT.PUT_LINE('Pracownik o id: ' || v_IdPracownika || ' nie istnieje');
        return;
    end if;

    select count(*) into v_ctnStanowisko from T_STANOWISKO where ID = v_IdStanowiska;
    if v_ctnStanowisko = 0 then
        DBMS_OUTPUT.PUT_LINE('Stanowisko o id: ' || v_IdStanowiska || ' nie istnieje');
        return;
    end if;

    select count(*) into v_ctnPracownikStanowisko
    from T_ZATRUDNIENIE
    where PRACOWNIK = v_IdPracownika and STANOWISKO = v_IdStanowiska and do is null;
    if v_ctnPracownikStanowisko > 0 then
        DBMS_OUTPUT.PUT_LINE('Pracownik jest już przypisany na to stanowisko');
        return;
    end if;

    select count(*) into v_ctnStanowiskoPracownik
    from T_ZATRUDNIENIE
    where PRACOWNIK = v_IdPracownika and do = to_char(sysdate, 'YYYY-MM-DD');
    if v_ctnStanowiskoPracownik > 0 then
        DBMS_OUTPUT.PUT_LINE('Zmiany nie zostały zapisane, stanowisko można aktualizować tylko raz dziennie');
        return;
    end if;

    update T_ZATRUDNIENIE
    set do = to_char(sysdate, 'YYYY-MM-DD')
    where PRACOWNIK = v_IdPracownika and do is null;

    insert into T_ZATRUDNIENIE
    VALUES (v_IdPracownika, v_IdStanowiska, to_char(sysdate, 'YYYY-MM-DD'), null);
    commit;
end;