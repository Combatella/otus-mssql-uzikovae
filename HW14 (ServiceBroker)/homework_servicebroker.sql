--Создайте очередь для формирования отчетов для клиентов по таблице Invoices. 
--При вызове процедуры для создания отчета в очередь должна отправляться заявка.
--При обработке очереди создавайте отчет по количеству заказов (Orders) 
--по клиенту за заданный период времени и складывайте готовый отчет в новую таблицу.
--Проверьте, что вы корректно открываете и закрываете диалоги 
--и у нас они не копятся.

create table Sales.OrdersStat
(
CustomerID int,
OrderDateFrom date,
OrderDateTo date,
OrdersCount int
)

go

alter database [WideWorldImporters] set enable_broker with no_wait
alter database [WideWorldImporters] set trustworthy on
alter authorization on database::WideWorldImporters to [sa]

go

create message type [WideWorldImporters/ServiceBroker/RequestMessage]
validation = well_formed_xml

go

create message type [WideWorldImporters/ServiceBroker/ReplyMessage]
validation = well_formed_xml

go

create contract [WideWorldImporters/ServiceBroker/Contract]
(
[WideWorldImporters/ServiceBroker/RequestMessage] sent by initiator,
[WideWorldImporters/ServiceBroker/ReplyMessage] sent by target
)

go

create queue TargetQueueWideWorldImporters
create service [WideWorldImporters/ServiceBroker/TargetService]
on queue TargetQueueWideWorldImporters([WideWorldImporters/ServiceBroker/Contract])

go

create queue InitiatorWideWorldImporters
create service [WideWorldImporters/ServiceBroker/InitiatorService]
on queue InitiatorWideWorldImporters([WideWorldImporters/ServiceBroker/Contract])

go

create procedure Sales.SendRequestByCustomerAndDate
(
@CustomerID int,
@OrderDateFrom date,
@OrderDateTo date
)
as
begin
	set nocount on
	declare @InitDlgHandle uniqueidentifier
	declare @RequestMessage nvarchar(4000)

	begin transaction
		select @RequestMessage =
		(
			select 
			CustomerID, 
			@OrderDateFrom as OrderDateFrom, 
			@OrderDateTo as OrderDateTo, 
			Count(OrderID) as OrdersCount
			from Sales.Orders 
			where CustomerID = @CustomerID 
			and OrderDate between @OrderDateFrom and @OrderDateTo
			group by CustomerID
			for xml auto, root('RequestMessage')
		);

		begin dialog @InitDlgHandle
		from service [WideWorldImporters/ServiceBroker/InitiatorService]
		to service 'WideWorldImporters/ServiceBroker/TargetService'
		on contract [WideWorldImporters/ServiceBroker/Contract]
		with encryption=off;

		send on conversation @InitDlgHandle
		message type 
		[WideWorldImporters/ServiceBroker/RequestMessage]
		(@RequestMessage);
		
	commit transaction
end

go

create procedure Sales.GetReport
as
begin
	declare @TargetDlgHandle uniqueidentifier
	declare @Message nvarchar(4000)
	declare @MessageType Sysname
	declare @ReplyMessage nvarchar(4000)
	declare @ReplyMessageName Sysname
	declare @CustomerID int
	declare @OrderDateFrom date
	declare @OrderDateTo date
	declare @xml xml

	begin transaction;

		receive top(1)
			@TargetDlgHandle = Conversation_Handle,
			@Message = Message_Body,
			@MessageType = Message_Type_Name
		from dbo.TargetQueueWideWorldImporters; 

		set @xml = cast(@Message as xml);

		select @CustomerID = R.Iv.value('@CustomerID', 'int')
		from @xml.nodes('/RequestMessage/Sales.Orders') as R(Iv);

		select @OrderDateFrom = R.Iv.value('@OrderDateFrom', 'date')
		from @xml.nodes('/RequestMessage/Sales.Orders') as R(Iv);
		
		select @OrderDateTo = R.Iv.value('@OrderDateTo', 'date')
		from @xml.nodes('/RequestMessage/Sales.Orders') as R(Iv);

		select @xml as xml, @CustomerID as CustomerID, @OrderDateFrom as OrderDateFrom, @OrderDateTo as OrderDateTo; -- убрать  

		if exists (
			select CustomerID, OrderDate 
			from Sales.Orders 
			where CustomerID = @CustomerID 
			and OrderDate between @OrderDateFrom and @OrderDateTo
			)
		begin
			declare @count int;
			select @count = count(OrderID) from Sales.Orders 
			where CustomerID = @CustomerID 
			and OrderDate between @OrderDateFrom and @OrderDateTo

			insert Sales.OrdersStat values
			(
			@CustomerID,
			@OrderDateFrom,
			@OrderDateTo,
			@count
			)
		end;

		if @MessageType=N'WideWorldImporters/ServiceBroker/RequestMessage'
		begin
			set @ReplyMessage = N'<ReplyMessage> Message received</ReplyMessage>';

			send on conversation @TargetDlgHandle
			message type [WideWorldImporters/ServiceBroker/ReplyMessage]
			(@ReplyMessage);
			end conversation @TargetDlgHandle;
		end
		
	commit transaction
end

go

create procedure Sales.ConfirmOrder
as
begin
	declare @InitiatorReplyDlgHandle uniqueidentifier
	declare @ReplyReceivedMessage nvarchar(1000)

	begin transaction;

		receive top(1)
			@InitiatorReplyDlgHandle = Conversation_Handle,
			@ReplyReceivedMessage = Message_Body
		from dbo.InitiatorWideWorldImporters;

		end conversation @InitiatorReplyDlgHandle;

	commit transaction
end


exec Sales.SendRequestByCustomerAndDate @CustomerID = 173, @OrderDateFrom = '2012-01-01', @OrderDateTo = '2013-07-17';

select cast(message_body as xml), * from dbo.TargetQueueWideWorldImporters;
select cast(message_body as xml), * from dbo.InitiatorWideWorldImporters;

exec Sales.GetReport;
exec Sales.ConfirmOrder;

select * from Sales.OrdersStat;

--select Conversation_Handle, is_initiator, s.name as 'local service', far_service, sc.name 'contract', ce.state_desc
--from sys.conversation_endpoints ce
--left join sys.services s on ce.service_id=s.service_id
--left join sys.service_contracts sc on ce.service_contract_id=sc.service_contract_id
--order by conversation_handle