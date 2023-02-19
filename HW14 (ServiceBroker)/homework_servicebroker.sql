--Создайте очередь для формирования отчетов для клиентов по таблице Invoices. 
--При вызове процедуры для создания отчета в очередь должна отправляться заявка.
--При обработке очереди создавайте отчет по количеству заказов (Orders) 
--по клиенту за заданный период времени и складывайте готовый отчет в новую таблицу.
--Проверьте, что вы корректно открываете и закрываете диалоги 
--и у нас они не копятся.

alter table Sales.Orders add OrderConfirmedProcessing datetime;

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
@OrderDate date
)
as
begin
	set nocount on
	declare @InitDlgHandle uniqueidentifier
	declare @RequestMessage nvarchar(4000)

	begin transaction
		select @RequestMessage =
		(select CustomerID, @OrderDate as OrderDate
		from Sales.Customers as sc 
		where sc.CustomerID = @CustomerID
		for xml auto, root('RequestMessage'));

		begin dialog @InitDlgHandle
		from service [WideWorldImporters/ServiceBroker/InitiatorService]
		to service 'WideWorldImporters/ServiceBroker/TargetService'
		on contract [WideWorldImporters/ServiceBroker/Contract]
		with encryption=off;

		send on conversation @InitDlgHandle
		message type 
		[WideWorldImporters/ServiceBroker/RequestMessage]
		(@RequestMessage);
		select @RequestMessage as SentRequestMessage;		
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
	declare @OrderDate date
	declare @xml xml

	begin transaction;

		receive top(1)
			@TargetDlgHandle = Conversation_Handle,
			@Message = Message_Body,
			@MessageType = Message_Type_Name
		from dbo.TargetQueueWideWorldImporters; 
		
		select @Message; -- убрать

		set @xml = cast(@Message as xml);

		select @CustomerID = R.Iv.value('@CustomerID', 'int')
		from @xml.nodes('/RequestMessage/Inv') as R(Iv);

		select @OrderDate = R.Iv.value('@OrderDate', 'date')
		from @xml.nodes('/RequestMessage/Inv') as R(Iv);

		if exists (select CustomerID from Sales.Customers where CustomerID = @CustomerID)
		begin
			update Sales.Orders
			set OrderConfirmedProcessing = getutcdate()
			where CustomerID = @CustomerID and OrderDate = @OrderDate;
		end;

		select @Message as ReceivedRequestMessage, @MessageType; -- убрать  

		if @MessageType=N'//WideWorldImporters/ServiceBroker/RequestMessage'
		begin
			set @ReplyMessage = N'<ReplyMessage> Message received</ReplyMessage>';

			send on conversation @TargetDlgHandle
			message type [WideWorldImporters/ServiceBroker/ReplyMessage]
			(@ReplyMessage);
			end conversation @TargetDlgHandle;
		end

		select @ReplyMessage as SendReplyMessage;

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
			@InitiatorReplyDlgHandle = conversation_handle,
			@ReplyReceivedMessage = Message_Body
		from dbo.InitiatorWideWorldImporters;

		end conversation @InitiatorReplyDlgHandle;

		select @ReplyReceivedMessage as ReceivedRepliedMessage;

	commit transaction
end

select CustomerID, OrderConfirmedProcessing, * 
from Sales.Orders
where CustomerID = 173 and OrderDate = '2013-07-17';

exec Sales.SendRequestByCustomerAndDate @CustomerID = 173, @OrderDate = '2013-07-17';

select cast(message_body as xml), * from dbo.TargetQueueWideWorldImporters
select cast(message_body as xml), * from dbo.InitiatorWideWorldImporters

exec Sales.GetReport 
exec Sales.ConfirmOrder