--Zadanie 02--
create procedure dataSmierci
as
begin
    set nocount on
    declare kurs cursor for select General, Bitwa from K7_Bitwa where CzyZginal = 1;
    declare @generalId int, @bitwaId int;
    open kurs;
    fetch next from kurs into @generalId, @bitwaId;
    while @@fetch_status = 0
    begin
        update K7_General set DataSmierci = (Select data from k7_bitwa where id = @bitwaId)
        where id = @generalId;
    end;
end;

exec dataSmierci;