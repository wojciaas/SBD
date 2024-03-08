--Zadanie I.1
declare
    v_OsobaCount integer;
begin
    select count(*) into v_OsobaCount from osoba1;
    DBMS_OUTPUT.PUT_LINE('W tabeli jest ' || v_OsobaCount || ' rekordów');
end;

--Zadanie I.2
declare
    v_liczbaDyd integer;
    v_id integer;
begin
    select count(*) into v_liczbaDyd from dydaktyk1;
    if v_liczbaDyd < 16 then
        select max(nvl(idosoba, 0)) + 1 into v_id from osoba1;
        insert into osoba1 (idosoba, imie, nazwisko, plec)
    end if;
end;