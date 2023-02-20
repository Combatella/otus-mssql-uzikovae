-- используя https://sqlsharp.com
-- воспользоваться функцией регулярного выражения
-- для формирования таблицы по координатам заказа

declare @expressionlat nvarchar(max)
declare @expressionlon nvarchar(max)
declare @InvoiceID int
declare @json nvarchar(max)

set @expressionlat = N'(latitude)(\D[^-])(-?\d{2,3}[.]\d+)'
set @expressionlon = N'(Longitude)(\D[^-])(-?\d{2,3}[.]\d+)'

drop table if exists #tmptable
create table #tmptable
(
InvoiceID int,
Latitude nvarchaR(128),
Longitude nvarchaR(128)
)

declare mycursor cursor
for select InvoiceId, ReturnedDeliveryData from Sales.Invoices
open mycursor
fetch next from mycursor into @InvoiceID, @json
while @@FETCH_STATUS = 0
begin

insert into #tmptable values 
(
@InvoiceID,
SQL#.RegEx_CaptureGroup(@json, @expressionlat, 3, 'Undefined', 1, -1, 'IgnoreCase'),
SQL#.RegEx_CaptureGroup(@json, @expressionlon, 3, 'Undefined', 1, -1, 'IgnoreCase')
)

fetch next from mycursor into @InvoiceID, @json
end
close mycursor
deallocate mycursor

select * from #tmptable