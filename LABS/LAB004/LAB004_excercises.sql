--Zadanie 01
declare @ile integer;

select @ile = count(1) from T_Osoba;
print 'W tabeli jest ' + cast(@ile as varchar) + ' osób';
go

declare @ile integer;
select id from T_Osoba;
set @ile = @@rowcount;
print 'W tabeli jest ' + cast(@ile as varchar) + ' osób';
go

declare @ile integer = (select count(1) from T_Osoba);
print 'W tabeli jest ' + cast(@ile as varchar) + ' osób';
go

--Zadanie 02
declare @ile integer = (select count(id) from T_Osoba);
if @ile < 7
begin
    set nocount on;
    insert into T_Osoba
    values (
            (select max(id) + 1 from T_Osoba),
            'Thomas',
            'Theramenes'
           )
    print 'Dodano nową osobę o id ' + cast(@@identity as varchar);
end
else
begin
    print 'Nie wstawiono żadnych danych'
end
go

--Zadanie 03
create procedure ProduktyTanszeNiz
    @cena money
as
begin
    set nocount on;
    select nazwa, cena from T_Produkt where Cena < @cena;
end
go

exec ProduktyTanszeNiz 1;
--Zadanie 04
alter procedure AktualizacjaCeny
    @cena money = 0.01
as
begin
    set nocount on;
    declare @ile integer;
    update T_Produkt
    set Cena = Cena + @cena;
    set @ile = @@rowcount;
    print 'Ilość zaktualizowanych rekordów: ' + cast(@ile as varchar);
end
go

exec AktualizacjaCeny;
exec AktualizacjaCeny 0.02;

--Zadanie 05
alter procedure NowyZakup
    @klinetId int,
    @stworzonyZakupId int OUTPUT
as
begin
    insert into T_Zakup (Data, Klient)
    values (getdate(), @klinetId);
    set @stworzonyZakupId = @@identity;
    print 'Zarejestrowano nowy zakup o id: ' + cast(@stworzonyZakupId as varchar);
end
go

declare @id int;
exec NowyZakup 7, @id output;
print 'Id zakupu: ' + cast(@id as varchar);

--Zadanie 06
alter procedure DodajProduktDoZakupu
    @idProdukt integer,
    @ilosc integer,
    @idZakup integer
as
begin
    set nocount on;
    if @idProdukt not in (select id from T_Produkt)
        print 'Produkt o podanym id ' + cast(@idProdukt as varchar) + ' nie istnieje.';
    else if @idZakup not in (select id from T_Zakup)
        print 'Zakup o podanym id ' + cast(@idZakup as varchar) + ' nie istnieje.';
    else if @ilosc <= 0
        print 'Ilość musi być większa od 0';
    else
    begin
        insert into T_ListaProduktow
        values (@idZakup, @idProdukt, @ilosc);
        print 'Do zakupu o id = ' + cast(@idZakup as varchar) +
              ' dodano produkt o id = ' + cast(@idProdukt as varchar) +
              ', w ilości: ' + cast(@ilosc as varchar);
    end
end;
go

declare @idZakup integer;
execute NowyZakup 3, @idZakup output;
execute DodajProduktDoZakupu 3, 13, @idZakup;
execute DodajProduktDoZakupu 1, 6, @idZakup;

--Zadanie 07
alter procedure DanePracownika
    @Pracownik int,
    @Imie varchar(50) output,
    @Nazwisko varchar(50) output
as
begin
    set nocount on;
    if @Pracownik not in (select id from T_Osoba)
        print 'Pracownik o podanym id = ' + cast(@Pracownik as varchar) + ' nie istnieje';
    else
    begin
        select @Imie = Imie, @Nazwisko = Nazwisko
        from T_Osoba
        where Id = @Pracownik;
    end
end
go

declare @imie varchar(50), @nazwisko varchar(50);
execute DanePracownika 1, @imie output, @nazwisko output;
print @imie + ' ' + @nazwisko;

--Zadanie 08
alter procedure WstawProdukt
    @nazwa varchar(50),
    @cena money,
    @kategoria varchar(50)
as
begin
    set nocount on;
    if @nazwa in (select Nazwa from T_Produkt)
    begin
        print 'Produkt o nazwie ' + @nazwa + ' już istnieje';
    end;
    else if @kategoria not in (select nazwa from T_Kategoria)
    begin
        print 'Podana kategoria nie istnieje, produkt nie został dodany'
    end;
    else
    begin
        insert into T_Produkt
        values (
                (select isnull(max(id), 0) + 1 from T_Produkt),
                @nazwa,
                @cena,
                (select id from T_Kategoria where Nazwa = @kategoria)
               );
        print 'Dodano produkt o nazwie ' + @nazwa;
    end;
end;
go

exec WstawProdukt 'dory', 8.09, 'fish';

--Zadanie 09
create procedure AktualizujStanowisko
    @Id_pracownika integer,
    @Id_stanowiska integer
as
begin
    set nocount on;
    if @Id_pracownika not in (select id from T_Pracownik)
    begin
        print 'Pracownik o podanym id nie istnieje';
        return;
    end;
    else if @Id_stanowiska not in (select id from T_Stanowisko)
    begin
        print 'Stanowisko o podanym id nie istnieje';
        return;
    end;

    if exists (select pracownik
                from T_Zatrudnienie
                where Stanowisko = @Id_stanowiska and Pracownik = @Id_pracownika and Do is null)
    begin
        print 'Pracownik jest już przypisany na to stanowisko';
        return;
    end;
    else if exists (select pracownik from T_Zatrudnienie where Pracownik = @Id_pracownika and Do = getdate())
    begin
        print 'Zmiany nie zostały zapisane, stanowisko można aktualizować tylko raz dziennie';
    end;
    else
    begin
        update T_Zatrudnienie
        set Do = getdate()
        where Pracownik = @Id_pracownika and do is null;
        insert into T_Zatrudnienie
        values (@Id_pracownika, @Id_stanowiska, getdate(), null);
        print 'Pracownik został przypisany na nowe stanowisko';
    end;
end;
go

exec AktualizujStanowisko 1, 3;