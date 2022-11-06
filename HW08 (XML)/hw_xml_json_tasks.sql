/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "08 - Выборки из XML и JSON полей".

Задания выполняются с использованием базы данных WideWorldImporters.

Бэкап БД можно скачать отсюда:
https://github.com/Microsoft/sql-server-samples/releases/tag/wide-world-importers-v1.0
Нужен WideWorldImporters-Full.bak

Описание WideWorldImporters от Microsoft:
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
*/

-- ---------------------------------------------------------------------------
-- Задание - написать выборки для получения указанных ниже данных.
-- ---------------------------------------------------------------------------

USE WideWorldImporters

/*
Примечания к заданиям 1, 2:
* Если с выгрузкой в файл будут проблемы, то можно сделать просто SELECT c результатом в виде XML. 
* Если у вас в проекте предусмотрен экспорт/импорт в XML, то можете взять свой XML и свои таблицы.
* Если с этим XML вам будет скучно, то можете взять любые открытые данные и импортировать их в таблицы (например, с https://data.gov.ru).
* Пример экспорта/импорта в файл https://docs.microsoft.com/en-us/sql/relational-databases/import-export/examples-of-bulk-import-and-export-of-xml-documents-sql-server
*/


/*
1. В личном кабинете есть файл StockItems.xml.
Это данные из таблицы Warehouse.StockItems.
Преобразовать эти данные в плоскую таблицу с полями, аналогичными Warehouse.StockItems.
Поля: StockItemName, SupplierID, UnitPackageID, OuterPackageID, QuantityPerOuter, TypicalWeightPerUnit, LeadTimeDays, IsChillerStock, TaxRate, UnitPrice 

Загрузить эти данные в таблицу Warehouse.StockItems: 
существующие записи в таблице обновить, отсутствующие добавить (сопоставлять записи по полю StockItemName). 

Сделать два варианта: с помощью OPENXML и через XQuery.
*/


-- Реализация с помощью OpenXML

declare @xmlDocument xml
select @xmlDocument = BulkColumn
from openrowset(bulk 'c:\OTUS_SQL\HW08 (XML)\StockItems.xml', single_clob) as data

declare @xmlDocHandle int
exec sp_xml_preparedocument @xmlDocHandle output, @xmlDocument

drop table if exists #TempItems
create table #TempItems
(
	StockItemName nvarchar(1000) collate Latin1_General_100_CI_AS, 
	SupplierID int,
	UnitPackageID int,
	OuterPackageID int,
	QuantityPerOuter int,
	TypicalWeightPerUnit decimal(18, 3),
	LeadTimeDays int,
	IsChillerStock int,
	TaxRate decimal(18, 3),
	UnitPrice decimal(18, 3)
)

insert into #TempItems
select *
from openxml (@xmlDocHandle,'/StockItems/Item', 2)
with (
	StockItemName nvarchar(100) '@Name',
	SupplierID int 'SupplierID',
	UnitPackageID int 'Package/UnitPackageID',
	OuterPackageID int 'Package/OuterPackageID',
	QuantityPerOuter int 'Package/QuantityPerOuter',
	TypicalWeightPerUnit decimal(18, 3) 'Package/TypicalWeightPerUnit',
	LeadTimeDays int 'LeadTimeDays',
	IsChillerStock int 'IsChillerStock',
	TaxRate decimal(18, 3) 'TaxRate',
	UnitPrice decimal(18, 2) 'UnitPrice'
)

exec sp_xml_removedocument @xmlDocHandle

update Warehouse.StockItems 
set
    Warehouse.StockItems.SupplierID = ti.SupplierID,
    Warehouse.StockItems.UnitPackageID = ti.UnitPackageID,
	Warehouse.StockItems.OuterPackageID = ti.OuterPackageID,
	Warehouse.StockItems.QuantityPerOuter = ti.QuantityPerOuter,
	Warehouse.StockItems.TypicalWeightPerUnit = ti.TypicalWeightPerUnit,
	Warehouse.StockItems.LeadTimeDays = ti.LeadTimeDays,
	Warehouse.StockItems.IsChillerStock = ti.IsChillerStock,
	Warehouse.StockItems.TaxRate = ti.TaxRate,
	Warehouse.StockItems.UnitPrice = ti.UnitPrice
from #TempItems AS ti
where ti.StockItemName = Warehouse.StockItems.StockItemName

insert into Warehouse.StockItems
(
	StockItemName,
	SupplierID,
    UnitPackageID,
	OuterPackageID,
	QuantityPerOuter,
	TypicalWeightPerUnit,
	LeadTimeDays,
	IsChillerStock,
	TaxRate,
	UnitPrice,
    LastEditedBy
)
select *, 1 as LastEditedBy from #TempItems 
where StockItemName not in (select StockItemName from Warehouse.StockItems)


-- Реализация чтения XML файла через XQuery

declare @xmlDoc xml
set @xmlDoc = (
	select * from openrowset(bulk 'c:\OTUS_SQL\HW08 (XML)\StockItems.xml', single_clob) as data
)
select
	t.Item.value('(@Name)[1]', 'nvarchar(100)') as [Name],
  	t.Item.value('(SupplierID)[1]', 'int') as [SupplierID],
  	t.Item.value('(Package/UnitPackageID)[1]', 'int') as [UnitPackageID],
  	t.Item.value('(Package/OuterPackageID)[1]', 'int') as [OuterPackageID],
  	t.Item.value('(Package/QuantityPerOuter)[1]', 'int') as [QuantityPerOuter],
  	t.Item.value('(Package/TypicalWeightPerUnit)[1]', 'decimal(18, 3)') as [TypicalWeightPerUnit],
  	t.Item.value('(LeadTimeDays)[1]', 'int') as [LeadTimeDays],
  	t.Item.value('(IsChillerStock)[1]', 'int') as [IsChillerStock],
  	t.Item.value('(TaxRate)[1]', 'decimal(18, 3)') as [TaxRate],
  	t.Item.value('(UnitPrice)[1]', 'decimal(18, 3)') as [UnitPrice]
from @xmlDoc.nodes('/StockItems/Item') as t(Item)


/*
2. Выгрузить данные из таблицы StockItems в такой же xml-файл, как StockItems.xml
*/

-- для формирования выходных данных анологичных содержимому StockItems.xml 
-- воспользуемся ранее созданной временной таблицей #TempItems

select 
	StockItemName as [@Name],
	SupplierID as [SupplierID],
    UnitPackageID as [Package/UnitPackageID],
	OuterPackageID as [Package/OuterPackageID],
	QuantityPerOuter as [Package/QuantityPerOuter],
	TypicalWeightPerUnit as [Package/TypicalWeightPerUnit],
	LeadTimeDays as [LeadTimeDays],
	IsChillerStock as [IsChillerStock],
	TaxRate as [TaxRate],
	UnitPrice as [UnitPrice]
from Warehouse.StockItems as si
where si.StockItemName in (select ti.StockItemName from #TempItems as ti)
for xml path('Item'), root('StockItems')

/*
3. В таблице Warehouse.StockItems в колонке CustomFields есть данные в JSON.
Написать SELECT для вывода:
- StockItemID
- StockItemName
- CountryOfManufacture (из CustomFields)
- FirstTag (из поля CustomFields, первое значение из массива Tags)
*/

select 
	StockItemID, 
	StockItemName, 
	json_value(CustomFields, '$.CountryOfManufacture') as CountryOfManufacture,
	json_value(CustomFields, '$.Tags[0]') as [FirstTag]
from 
	Warehouse.StockItems as si

/*
4. Найти в StockItems строки, где есть тэг "Vintage".
Вывести: 
- StockItemID
- StockItemName
- (опционально) все теги (из CustomFields) через запятую в одном поле

Тэги искать в поле CustomFields, а не в Tags.
Запрос написать через функции работы с JSON.
Для поиска использовать равенство, использовать LIKE запрещено.

Должно быть в таком виде:
... where ... = 'Vintage'

Так принято не будет:
... where ... Tags like '%Vintage%'
... where ... CustomFields like '%Vintage%' 
*/

select 
	StockItemID, 
	StockItemName,
	string_agg(t2.value, ', ') as Tags
from 
	Warehouse.StockItems as si
cross apply 
	openjson(CustomFields, '$.Tags') t
cross apply 
	openjson(CustomFields, '$.Tags') t2
where t.value = 'Vintage'
group by StockItemID, StockItemName