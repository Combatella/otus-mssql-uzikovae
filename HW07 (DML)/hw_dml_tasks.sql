/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "10 - Операторы изменения данных".

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
1. Довставлять в базу пять записей используя insert в таблицу Customers или Suppliers 
*/

insert into Purchasing.Suppliers (
    SupplierName
    ,SupplierCategoryID
    ,PrimaryContactPersonID
    ,AlternateContactPersonID
    ,DeliveryMethodID
    ,DeliveryCityID
    ,PostalCityID
    ,SupplierReference
    ,BankAccountName
    ,BankAccountBranch
    ,BankAccountCode
    ,BankAccountNumber
    ,BankInternationalCode
    ,PaymentDays
    ,InternalComments
    ,PhoneNumber
    ,FaxNumber
    ,WebsiteURL
    ,DeliveryAddressLine1
    ,DeliveryAddressLine2
    ,DeliveryPostalCode
    ,DeliveryLocation
    ,PostalAddressLine1
    ,PostalAddressLine2
    ,PostalPostalCode
    ,LastEditedBy
) values 
    ('Supplier reserve name 1' ,7 ,45 ,46 ,1 ,1 ,1 ,'' ,'' ,'' ,'', '' ,'' ,0, 'insert test record 1' ,'(000) 000-0000' ,'(000) 000-0000' ,'http://www.otus.ru' ,'' ,'' ,'' ,null ,'' ,'' ,'' ,1),
    ('Supplier reserve name 2' ,7 ,45 ,46 ,1 ,1 ,1 ,'' ,'' ,'' ,'', '' ,'' ,0, 'insert test record 2' ,'(000) 000-0000' ,'(000) 000-0000' ,'http://www.otus.ru' ,'' ,'' ,'' ,null ,'' ,'' ,'' ,1),
    ('Supplier reserve name 3' ,7 ,45 ,46 ,1 ,1 ,1 ,'' ,'' ,'' ,'', '' ,'' ,0, 'insert test record 3' ,'(000) 000-0000' ,'(000) 000-0000' ,'http://www.otus.ru' ,'' ,'' ,'' ,null ,'' ,'' ,'' ,1),
    ('Supplier reserve name 4' ,7 ,45 ,46 ,1 ,1 ,1 ,'' ,'' ,'' ,'', '' ,'' ,0, 'insert test record 4' ,'(000) 000-0000' ,'(000) 000-0000' ,'http://www.otus.ru' ,'' ,'' ,'' ,null ,'' ,'' ,'' ,1),
    ('Supplier reserve name 5' ,7 ,45 ,46 ,1 ,1 ,1 ,'' ,'' ,'' ,'', '' ,'' ,0, 'insert test record 5' ,'(000) 000-0000' ,'(000) 000-0000' ,'http://www.otus.ru' ,'' ,'' ,'' ,null ,'' ,'' ,'' ,1)

/*
2. Удалите одну запись из Customers, которая была вами добавлена
*/

delete from Purchasing.Suppliers 
where SupplierName = 'Supplier reserve name 5'


/*
3. Изменить одну запись, из добавленных через UPDATE
*/

update Purchasing.Suppliers 
set 
    SupplierName = 'Supplier reserve name 0'
where SupplierName = 'Supplier reserve name 4'

/*
4. Написать MERGE, который вставит вставит запись в клиенты, если ее там нет, и изменит если она уже есть
*/

declare @s table (
	[SupplierName] nvarchar(100),
	[SupplierCategoryID] int,
	[PrimaryContactPersonID] int,
	[AlternateContactPersonID] int,
	[DeliveryMethodID] int,
	[DeliveryCityID] int,
	[PostalCityID] int,
	[SupplierReference] nvarchar(20),
	[BankAccountName] nvarchar(50),
	[BankAccountBranch] nvarchar(50),
	[BankAccountCode] nvarchar(20),
	[BankAccountNumber] nvarchar(20),
	[BankInternationalCode] nvarchar(20),
	[PaymentDays] int,
	[InternalComments] nvarchar(max),
	[PhoneNumber] nvarchar(20),
	[FaxNumber] nvarchar(20),
	[WebsiteURL] nvarchar(256),
	[DeliveryAddressLine1] nvarchar(60),
	[DeliveryAddressLine2] nvarchar(60),
	[DeliveryPostalCode] nvarchar(10),
	[DeliveryLocation] geography,
	[PostalAddressLine1] nvarchar(60),
	[PostalAddressLine2] nvarchar(60),
	[PostalPostalCode] nvarchar(10),
	[LastEditedBy] int);
insert into @s values ('Supplier reserve name 0', 7, 45, 46, 1, 1, 1, '', '', '', '', '', '', 0, 'insert test record 0' ,'(111) 111-1111' ,'(111) 111-1111' ,'http://www.otus.ru' ,'' ,'' ,'' ,null ,'' ,'' ,'' ,1);

merge Purchasing.Suppliers as trg
using (
	select SupplierName, SupplierCategoryID, PrimaryContactPersonID, AlternateContactPersonID, DeliveryMethodID, DeliveryCityID, PostalCityID, SupplierReference, BankAccountName, BankAccountBranch, BankAccountCode, BankAccountNumber, BankInternationalCode, PaymentDays, InternalComments, PhoneNumber, FaxNumber, WebsiteURL, DeliveryAddressLine1, DeliveryAddressLine2, DeliveryPostalCode, DeliveryLocation, PostalAddressLine1, PostalAddressLine2, PostalPostalCode, LastEditedBy
	from @s where SupplierName = 'Supplier reserve name 0'
) as src (
	SupplierName, SupplierCategoryID, PrimaryContactPersonID, AlternateContactPersonID, DeliveryMethodID, DeliveryCityID, PostalCityID, SupplierReference, BankAccountName, BankAccountBranch, BankAccountCode, BankAccountNumber, BankInternationalCode, PaymentDays, InternalComments, PhoneNumber, FaxNumber, WebsiteURL, DeliveryAddressLine1, DeliveryAddressLine2, DeliveryPostalCode, DeliveryLocation, PostalAddressLine1, PostalAddressLine2, PostalPostalCode, LastEditedBy
) on (
	trg.SupplierName = src.SupplierName
) 
when matched then 
   update set 
		PhoneNumber = src.PhoneNumber,
		FaxNumber = src.FaxNumber
when not matched by target then 
    insert (SupplierName, SupplierCategoryID, PrimaryContactPersonID, AlternateContactPersonID, DeliveryMethodID, DeliveryCityID, PostalCityID, SupplierReference, BankAccountName, BankAccountBranch, BankAccountCode, BankAccountNumber, BankInternationalCode, PaymentDays, InternalComments, PhoneNumber, FaxNumber, WebsiteURL, DeliveryAddressLine1, DeliveryAddressLine2, DeliveryPostalCode, DeliveryLocation, PostalAddressLine1, PostalAddressLine2, PostalPostalCode, LastEditedBy)
    values (src.SupplierName, src.SupplierCategoryID, src.PrimaryContactPersonID, src.AlternateContactPersonID, src.DeliveryMethodID, src.DeliveryCityID, src.PostalCityID, src.SupplierReference, src.BankAccountName, src.BankAccountBranch, src.BankAccountCode, src.BankAccountNumber, src.BankInternationalCode, src.PaymentDays, src.InternalComments, src.PhoneNumber, src.FaxNumber, src.WebsiteURL, src.DeliveryAddressLine1, src.DeliveryAddressLine2, src.DeliveryPostalCode, src.DeliveryLocation, src.PostalAddressLine1, src.PostalAddressLine2, src.PostalPostalCode, src.LastEditedBy);

select * from Purchasing.Suppliers


/*
5. Напишите запрос, который выгрузит данные через bcp out и загрузить через bulk insert
*/

EXEC sp_configure 'show advanced options', 1;  
GO  
RECONFIGURE;  
GO  
EXEC sp_configure 'xp_cmdshell', 1;  
GO  
RECONFIGURE;  
GO  

SELECT @@SERVERNAME

exec master..xp_cmdshell 'bcp "[WideWorldImporters].Purchasing.Suppliers" out  "c:\OTUS_SQL\HW07 (DML)\Purchasing.Suppliers.sql" -T -w -t"@ql$md^" -S DESKTOP-IDBHUNS'


drop table if exists Purchasing.Suppliers_back

CREATE TABLE Purchasing.Suppliers_back (
	[SupplierID] [int] NOT NULL,
	[SupplierName] [nvarchar](100) NOT NULL,
	[SupplierCategoryID] [int] NOT NULL,
	[PrimaryContactPersonID] [int] NOT NULL,
	[AlternateContactPersonID] [int] NOT NULL,
	[DeliveryMethodID] [int] NULL,
	[DeliveryCityID] [int] NOT NULL,
	[PostalCityID] [int] NOT NULL,
	[SupplierReference] [nvarchar](20) NULL,
	[BankAccountName] [nvarchar](50) NULL,
	[BankAccountBranch] [nvarchar](50) NULL,
	[BankAccountCode] [nvarchar](20) NULL,
	[BankAccountNumber] [nvarchar](20) NULL,
	[BankInternationalCode] [nvarchar](20) NULL,
	[PaymentDays] [int] NOT NULL,
	[InternalComments] [nvarchar](max) NULL,
	[PhoneNumber] [nvarchar](20) NOT NULL,
	[FaxNumber] [nvarchar](20) NOT NULL,
	[WebsiteURL] [nvarchar](256) NOT NULL,
	[DeliveryAddressLine1] [nvarchar](60) NOT NULL,
	[DeliveryAddressLine2] [nvarchar](60) NULL,
	[DeliveryPostalCode] [nvarchar](10) NOT NULL,
	[DeliveryLocation] [geography] NULL,
	[PostalAddressLine1] [nvarchar](60) NOT NULL,
	[PostalAddressLine2] [nvarchar](60) NULL,
	[PostalPostalCode] [nvarchar](10) NOT NULL,
	[LastEditedBy] [int] NOT NULL,
	[ValidFrom] [datetime2](7) NOT NULL,
	[ValidTo] [datetime2](7) NOT NULL)

bulk insert WideWorldImporters.Purchasing.Suppliers_back
				   FROM "c:\OTUS_SQL\HW07 (DML)\Purchasing.Suppliers.sql"
				   WITH 
					 (
						BATCHSIZE = 1000, 
						DATAFILETYPE = 'widechar',
						FIELDTERMINATOR = '@ql$md^',
						ROWTERMINATOR ='\n',
						KEEPNULLS,
						TABLOCK        
					  );

select * from Purchasing.Suppliers_back;
