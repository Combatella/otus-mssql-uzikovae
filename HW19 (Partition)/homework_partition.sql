-- ПОДГОТОВКА
use [WideWorldImporters]
SELECT * FROM [Sales].[OrderLines]

SELECT distinct year(PickingCompletedWhen) FROM [Sales].[OrderLines]

select distinct t.name from sys.partitions p
inner join sys.tables t on t.object_id = p.object_id
where p.partition_number <> 1

alter database [WideWorldImporters] 
add filegroup [YearData]

alter database [WideWorldImporters] 
add file (name = N'years', filename = N'C:\Repos\otus-mssql-uzikovae\HW19 (Partition)\yeardata.ndf',
size = 1097152KB, filegrowth = 65536KB) to filegroup [YearData]

create partition function [FnYearPartition](datetime2) 
as range right for values ('2013-01-01 00:00:00.0000000','2014-01-01 00:00:00.0000000','2015-01-01 00:00:00.0000000','2016-01-01 00:00:00.0000000')

create partition scheme [ShmYearPartition] 
as partition [FnYearPartition]
all to([YearData])

drop table if exists [Sales].[OrderLinesPartitioned]
create table [Sales].[OrderLinesPartitioned](
	[OrderLineID] [int] NOT NULL,
	[OrderID] [int] NOT NULL,
	[StockItemID] [int] NOT NULL,
	[Description] [nvarchar](100) NOT NULL,
	[PackageTypeID] [int] NOT NULL,
	[Quantity] [int] NOT NULL,
	[UnitPrice] [decimal](18, 2) NULL,
	[TaxRate] [decimal](18, 3) NOT NULL,
	[PickedQuantity] [int] NOT NULL,
	[PickingCompletedWhen] [datetime2](7) NULL,
	[LastEditedBy] [int] NOT NULL,
	[LastEditedWhen] [datetime2](7) NOT NULL
) on [ShmYearPartition]([LastEditedWhen])

alter table [Sales].[OrderLinesPartitioned] 
add constraint PK_Sales_OrderLinesPartitioned
primary key clustered ([LastEditedWhen], [OrderID], [OrderLineID])
on [ShmYearPartition]([LastEditedWhen])

-- ЭКСПОРТ ДАННЫХ
exec sp_configure 'show advanced options', 1;
reconfigure;
exec sp_configure 'xp_cmdshell', 1;
reconfigure;
select @@SERVERNAME;
exec master..xp_cmdshell 'bcp "select [OrderLineID], [OrderID], [StockItemID], [Description], [PackageTypeID], [Quantity], [UnitPrice], [TaxRate], [PickedQuantity], [PickingCompletedWhen], [LastEditedBy], [LastEditedWhen] from [WideWorldImporters].[Sales].[OrderLines]" queryout "C:\Repos\otus-mssql-uzikovae\HW19 (Partition)\orders.txt" -T -w -t "&$t^@" -S DESKTOP-HGS0BIC'

-- ИМПОРТ ДАННЫХ
declare @fileName varchar(128)
declare @onlyScript bit
declare @query nvarchar(max)
declare @dbName varchar(256)
declare @batchSize int

select @dbName = db_name()
set @batchSize = 1000
set @onlyScript = 0

set @fileName = 'C:\Repos\otus-mssql-uzikovae\HW19 (Partition)\orders.txt'

begin try
	
	if @fileName is not null
	begin

		set @query = 'bulk insert ['+@dbName+'].[Sales].[OrderLinesPartitioned] from "'+@fileName+'"
		with (
		batchsize = '+cast(@batchSize as varchar(255))+',
		datafiletype = ''widechar'',
		fieldterminator = ''&$t^@'',
		rowterminator = ''\n'',
		keepnulls,
		tablock
		);';

		if @onlyScript = 0 exec sp_executesql @query;
	end;

end try
begin catch

	select error_number() as errorNumber, error_message() as errorMessage

end catch