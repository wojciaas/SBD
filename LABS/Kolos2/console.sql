--Zadanie 01
alter procedure DodajZawodnika
    @zawodnik varchar(50),
    @zawody varchar(100)
as
begin
    set nocount on;
    if @zawodnik not in (select imie from K9_Zawodnik)
    begin
        insert into K9_Zawodnik (Imie) values (@zawodnik);
        print 'Dodano zawodnika do tabeli Zawodnik, id = ' + cast(@@identity as varchar) + ', imie ' + @zawodnik;
    end;
    declare @runda int;
    select @runda = isnull(max(u.runda), 1)
    from K9_Udzial u
    join K9_Zawody z on u.Zawody = z.Id
    where z.Nazwa = @zawody;
    if @runda > 1
    begin
        print 'Zawody już się rozpoczęły';
    end;
    else
    begin
        insert into K9_Udzial
        values (
                (select id from K9_Zawodnik where Imie = @zawodnik),
                (select id from K9_Zawody where Nazwa = @zawody),
                @runda,
                null
               )
        print 'Dodano zawodnika ' + @zawodnik + ' do pierwszej rundy zawodów ' + @zawody;
    end;
end;
go;

exec DodajZawodnika 'Myronides', 'Nemean Games';
exec DodajZawodnika 'Myronides', 'Pythian Games';
exec DodajZawodnika 'Iphicrates', 'Olympic Games';

--Zadanie 02
alter procedure NastepnaRunda
    @zawody varchar(50)
as
begin
    if exists(select u.Zawodnik
              from K9_Udzial u
              join K9_Zawody z on u.Zawody = z.Id
              where Runda = (select max(runda) from K9_Udzial u1 join K9_Zawody z1 on u1.Zawody = z1.Id where z1.Nazwa = @zawody)
              and Zawody = (select id from K9_Zawody where Nazwa = @zawody)
              and Punkty is null)
    begin
        print 'Aktualnarunda jeszcze się nie zakończyła';
    end;
    else
    begin
        declare next_round scroll cursor for
            select Zawodnik, Zawody, Runda + 1
            from K9_Udzial u
            join K9_Zawody z on u.Zawody = z.Id
            where z.Nazwa = @zawody
            and runda in (select max(runda) from K9_Udzial u1 join K9_Zawody z1 on u1.Zawody = z1.Id where z1.Nazwa = @zawody)
            order by Punkty;
        declare @zawodnik int, @idZawody int, @runda int;
        open next_round;
        fetch relative 1 from next_round;
        while @@fetch_status = 0
        begin
            print 'Przepisano zawodnika o id = ' + cast(@zawodnik as varchar) + ' do rundy ' + cast(@runda as varchar);
            fetch next from next_round into @zawodnik, @idZawody, @runda;
        end;
        close next_round;
        deallocate next_round;
    end;
end;
go;

exec NastepnaRunda 'Pythian Games';
exec NastepnaRunda 'Isthmian Games';
exec NastepnaRunda 'Nemean Games'

--Zadanie 03
create trigger UdzialIOI
    on K9_Udzial
    instead of insert
as
begin
    if (select punkty from inserted) is not null
    begin
        RAISERROR('Punkty mozna przypisywac tylko poprzez UPDATE.', 16, 1);
    end;
    else if not exists
        (select 1 from K9_Udzial where runda = (select runda from inserted) and punkty is null)
        raiserror('Nie mozna dodac zawodnika do rundy, ktora juz sie zakonczyla.', 16, 2);
    else if (select runda from inserted) > 1
            and not exists(select 1 from K9_Udzial where Runda = (select runda - 1 from inserted) and Zawodnik = (select Zawodnik from inserted))
    begin
        raiserror('Nie mozna dodac zawodnika do rundy, ktora juz sie zakonczyla.', 16, 3);
    end;
    else
    begin
        begin try
            if exists
                (select 1 from K9_Udzial where Zawodnik = (select Zawodnik from inserted) and Runda = (select runda from inserted))
                throw 50001, 'Zawodnik jest już przypisany do podanej rundy w tych zawodach', 1
        end try
        begin catch
            throw
        end catch;
    end;
end;

insert into K9_Udzial
values (3, 2, 1, null)