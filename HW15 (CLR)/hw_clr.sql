﻿-- используя https://sqlsharp.com
-- воспользоваться функцией регулярного выражения
-- для формирования таблицы по координатам заказа

declare @expressionlat nvarchar(max)
declare @expressionlon nvarchar(max)
declare @InvoiceID int
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
(
@InvoiceID,
SQL#.RegEx_CaptureGroup(@json, @expressionlat, 3, 'Undefined', 1, -1, 'IgnoreCase'),
SQL#.RegEx_CaptureGroup(@json, @expressionlon, 3, 'Undefined', 1, -1, 'IgnoreCase')
)

fetch next from mycursor into @InvoiceID, @json