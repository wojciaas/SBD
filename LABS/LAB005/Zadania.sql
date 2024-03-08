--Zadanie 01
set nocount on;
declare ModyfikujCeny cursor for
    select nazwa, cena
    from T_Produkt
    where cena not between 1 and 2;
declare @nazwa varchar(50), @cena money;
open ModyfikujCeny;
fetch next from ModyfikujCeny into @nazwa, @cena;
while @@fetch_status = 0
begin
    if @cena > 2
    begin
        set @cena = round(@cena * 0.9, 2);
    end;
    else
    begin
        set @cena = round(@cena * 1.05, 2);
    end;
    update T_Produkt
    set cena = @cena
    where Nazwa = @nazwa;
    print 'Cena ' + @nazwa + ' została zmieniona na ' + cast(@cena as varchar) + '$';
    fetch next from ModyfikujCeny into @nazwa, @cena;
end;
close ModyfikujCeny;
deallocate ModyfikujCeny;
go;

--Zadanie 02
create procedure ZmianaCen
    @gornaWartosc money,
    @dolnaWartosc money
as
begin
    set nocount on;
    declare ModyfikujCeny cursor for
        select nazwa,
        case
        when Cena < @dolnaWartosc then round(Cena * 0.9, 2)
        when Cena > @gornaWartosc then round(Cena * 1.05, 2)
        else Cena
        end
        from T_Produkt
        where Cena not between @dolnaWartosc and @gornaWartosc;
    declare @nazwa varchar(50), @cena money;
    open ModyfikujCeny;
    fetch next from ModyfikujCeny into @nazwa, @cena;
    while @@fetch_status = 0
    begin
        update T_Produkt
        set cena = @cena
        where Nazwa = @nazwa;
        print 'Cena ' + @nazwa + ' została zmieniona na ' + cast(@cena as varchar);
        fetch next from ModyfikujCeny into @nazwa, @cena;
    end;
    close ModyfikujCeny;
    deallocate ModyfikujCeny;
end;
go;

exec ZmianaCen 1, 2;

--Zadanie 03
set nocount on;
declare PrzypiszProdukty cursor for
    select lp.Produkt, sum(lp.Ilosc)
    from T_ListaProduktow lp
    join T_Zakup z on lp.Zakup = z.Id
    where month(z.Data) = 12 and year(z.Data) = 2022
    group by lp.Produkt
    having sum(lp.Ilosc) > 10;

insert into T_Zaopatrzenie (Data)
values (getdate());

declare @idProdukt integer, @ilosc integer, @idZaopatrzenie integer = @@identity;
open PrzypiszProdukty;
fetch next from PrzypiszProdukty into @idProdukt, @ilosc;
while @@fetch_status = 0
begin
    insert into T_ZaopatrzenieProdukt
    values (@idZaopatrzenie, @idProdukt, @ilosc * 2);
    print 'Zamówiono produkt o ID= ' + cast(@idProdukt as varchar) + ' w ilości= ' + cast(@ilosc * 2 as varchar);
    fetch next from PrzypiszProdukty into @idProdukt, @ilosc;
end;
close PrzypiszProdukty;
deallocate PrzypiszProdukty;
go;

--Zadanie 04
alter table T_Pracownik
add Bonus money null;

create view StazPracownika(Pracownik, Staz)
as
select Pracownik, datediff(month, min(od), getdate())
from T_Zatrudnienie
where Pracownik in (
    select Pracownik
    from T_Zatrudnienie
    where Do is null
    )
group by Pracownik;

set nocount on;
declare bonus_pracownika cursor for
    select Pracownik,
    case
    when staz < 5 then null
    when staz > 30 then 30
    else staz
    end as bonus
    from StazPracownika;
declare @pracownik integer, @bonus integer;
open bonus_pracownika;
fetch next from bonus_pracownika into @pracownik, @bonus;
while @@fetch_status = 0
begin
    update T_Pracownik
    set Bonus = Pensja * @bonus/100
    where Id = @pracownik and @bonus is not null;
    print 'Pracownik od id= ' + cast(@pracownik as varchar) +
          ' ma przypisanybonus w wysokości= ' + cast(@bonus as varchar) + '% pensji';
    fetch next from bonus_pracownika into @pracownik, @bonus;
end;
close bonus_pracownika;
deallocate bonus_pracownika;
go;
