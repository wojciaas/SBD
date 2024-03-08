/*Zadanie 01*/
declare
    cursor AktualizacjaCen
    is
    select *
    from T_PRODUKT where CENA not between 1 and 2;
    v_produkt T_PRODUKT%rowtype;
    v_nowaCena T_PRODUKT.CENA%type;
begin
    for v_produkt in AktualizacjaCen
    loop
        if v_produkt.CENA > 2 then
            update T_PRODUKT
            set CENA = round(v_produkt.CENA * 0.9, 2)
            where ID = v_produkt.ID;
        else
            update T_PRODUKT
            set CENA = round(v_produkt.CENA * 1.05, 2)
            where ID = v_produkt.ID;
        end if;
        select CENA into v_nowaCena from T_PRODUKT where ID = v_produkt.ID;
        DBMS_OUTPUT.PUT_LINE('Cena ' || v_produkt.NAZWA ||  ' została zmieniona na: ' || v_nowaCena ||'$');
    end loop;
end;

/*Zadanie 02*/
create or replace procedure ZmianaCen
    (v_wartoscDolna T_PRODUKT.CENA%type,
    v_wartoscGorna T_PRODUKT.CENA%type)
AS
    cursor AktualizujCen is
    select nazwa,
        case
            when cena < v_wartoscDolna then round(CENA * 1.05,  2)
            when CENA > v_wartoscGorna then round(CENA * 0.9,  2)
            else cena
        end
    from T_PRODUKT
    where cena not between v_wartoscDolna and v_wartoscGorna;
    v_nazwa T_PRODUKT.nazwa%type;
    v_cena T_PRODUKT.CENA%type;
begin
    open AktualizujCen;
    loop
        fetch AktualizujCen into v_nazwa, v_cena;
        exit when AktualizujCen%notFound;
        update T_PRODUKT
        set CENA = v_cena
        where NAZWA = v_nazwa;
        DBMS_OUTPUT.PUT_LINE('Cena ' || v_nazwa ||  ' została zmieniona na: ' || v_cena ||'$');
    end loop;
end;
begin
    ZmianaCen(1, 2);
end;

/*Zadanie 03*/
declare
    cursor NoweZaopatrzenie is
    select PRODUKT, sum(ILOSC) * 2
    from T_LISTAPRODUKTOW TLP
    join T_ZAKUP TZ on TZ.ID = TLP.ZAKUP
    where extract(year from data) = 2022 and extract(month from data) = 12
    group by PRODUKT
    having sum(ILOSC) > 10;
    v_produkt T_PRODUKT.id%type;
    v_ilosc T_LISTAPRODUKTOW.ILOSC%type;
    v_id integer;
begin
    insert into T_ZAOPATRZENIE (DATA)
    values (to_date(current_date, 'YYYY-MM-DD'))
    returning id into v_id;

    open NoweZaopatrzenie;
    loop
        fetch NoweZaopatrzenie into v_produkt, v_ilosc;
        exit when NoweZaopatrzenie%notFound;
        insert into T_ZAOPATRZENIEPRODUKT
        values (v_id, v_produkt, v_ilosc);
        DBMS_OUTPUT.PUT_LINE('Zamówiono produkt o ID= ' || v_produkt || ' w ilości= ' || v_ilosc);
    end loop;
    close NoweZaopatrzenie;
end;

/*Zadanie 04*/
alter table T_PRACOWNIK
add Bonus number(8, 2) null;

create view StazPracownika(Pracownik, staz) as
select pracownik, abs(trunc(months_between(min(od), current_date)))
from T_ZATRUDNIENIE
where PRACOWNIK in (select PRACOWNIK
                    from T_ZATRUDNIENIE
                    where DO is null)
group by pracownik;

declare
    cursor Premia is
    select PRACOWNIK,
        case
            when staz < 6 then null
            when staz > 30 then 30
            else staz
        end as staz
    from StazPracownika;
    v_pracownik StazPracownika%rowtype;
begin
    for v_pracownik in Premia loop
        if v_pracownik.staz is not null then
            update T_PRACOWNIK
            set bonus = (select PENSJA from T_PRACOWNIK where ID = v_pracownik.Pracownik) * round((v_pracownik.staz/100), 2)
            where ID = v_pracownik.Pracownik;
            DBMS_OUTPUT.PUT_LINE('Pracownik od id= ' || v_pracownik.Pracownik || ' ma przypisany bonus w wysokości= ' || v_pracownik.staz ||' % pensji');
        end if;
    end loop;
end;

/*Zadanie 05*/
alter table T_OSOBA
add Ulubiony_produkt integer null;

alter table T_OSOBA
add constraint FK_Osoba_Produkt foreign key (Ulubiony_produkt)
references T_PRODUKT (id);

declare
    cursor c_UlubionyProdukt is
    select o.id, p.id
    from T_OSOBA o
    join T_ZAKUP z on o.id = z.klient
    join T_LISTAPRODUKTOW l on z.id = l.zakup
    join T_PRODUKT p on l.produkt = p.id
    where p.id = (select l2.produkt
                  from T_ZAKUP z2
                  join T_LISTAPRODUKTOW l2 on z2.id = l2.zakup
                  where o.id = z2.klient
                  group by l2.produkt
                  order by sum(l2.ilosc) desc
                  fetch first 1 row only)
    group by o.id, p.id;
    v_idOsoba integer;
    v_idUlubProd integer;
begin
    open c_UlubionyProdukt;
    loop
        fetch c_UlubionyProdukt into v_idOsoba, v_idUlubProd;
        exit when c_UlubionyProdukt%notFound;
        update T_OSOBA
        set Ulubiony_produkt = v_idUlubProd
        where ID = v_idOsoba;
        DBMS_OUTPUT.PUT_LINE('Dodano ulubiony produkt o id= ' || v_idUlubProd || ' dla osoby o id= ' || v_idOsoba);
    end loop;
    close c_UlubionyProdukt;
end;

SELECT o.nazwisko, p.nazwa AS "ulubiony produkt"
FROM T_Osoba o LEFT JOIN T_Produkt p ON o.ulubiony_produkt = p.id;