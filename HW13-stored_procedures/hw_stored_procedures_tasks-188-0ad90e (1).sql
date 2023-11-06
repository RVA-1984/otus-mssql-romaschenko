/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "12 - Хранимые процедуры, функции, триггеры, курсоры".

Задания выполняются с использованием базы данных WideWorldImporters.

Бэкап БД можно скачать отсюда:
https://github.com/Microsoft/sql-server-samples/releases/tag/wide-world-importers-v1.0
Нужен WideWorldImporters-Full.bak

Описание WideWorldImporters от Microsoft:
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
*/

USE WideWorldImporters

/*
Во всех заданиях написать хранимую процедуру / функцию и продемонстрировать ее использование.
*/

/*
1) Написать функцию возвращающую Клиента с наибольшей суммой покупки.
*/

USE WideWorldImporters;

IF OBJECT_ID (N'Sales.CT', N'SCT') IS NOT NULL
    DROP FUNCTION Sales.CT;
GO
CREATE FUNCTION Sales.CT (@CustomerID int)
RETURNS TABLE
AS
RETURN
(
    SELECT S.CustomerID, Max (S.TransactionAmount) AS 'Total'
    FROM Sales.CustomerTransactions AS S
	GROUP BY S.CustomerID);

/*
2) Написать хранимую процедуру с входящим параметром СustomerID, выводящую сумму покупки по этому клиенту.
Использовать таблицы :
Sales.Customers: CustomerID
Sales.Invoices: Customer ID, InvoiceID
Sales.InvoiceLines: InvoiceID, LineProfit

*/

USE WideWorldImporters;

IF OBJECT_ID ( 'Sales.Cstm', 'S' ) IS NOT NULL
    DROP PROCEDURE Sales.Cstm;
GO
CREATE PROCEDURE Sales.Cstm @SalesCustomer VARCHAR(40)
    , @CustomerID MONEY
    , @LineProfit MONEY OUTPUT
	, @InvoiceID MONEY OUTPUT
    
AS
    SET NOCOUNT ON;
    SELECT SC.CustomerID AS CustomerID 
    FROM Sales.Customers AS SC
    JOIN Sales.Invoices AS SI
      ON SC.CustomerID = SI.CustomerID
    WHERE SI.CustomerID LIKE @CustomerID;
-- Populate the output variable @LineProfit.
SET @LineProfit = (SELECT SUM(SIL.LineProfit)
    FROM Sales.InvoiceLines AS SIL
    JOIN Sales.Invoices AS SI
      ON SIL.InvoiceID = SI.InvoiceID
    WHERE SI.InvoiceID LIKE @InvoiceID AND SIL.LineProfit=@LineProfit);
-- Populate the output variable @CustomerID.
SET @CustomerID = @LineProfit;
GO


/*
3) Создать одинаковую функцию и хранимую процедуру, посмотреть в чем разница в производительности и почему.
*/

--Создание табличной функции
--Количество проданного товара, с наименованием и ценой товара по счету

--входной параметр @InvoiceID
--Используемые таблицы и поля 
 -- Sales.InvoiceLines:InvoiceID, Description, Quantity, UnitPrice
 -- Sales.Invoices: InvoiceID

 USE WideWorldImporters;

IF OBJECT_ID (N'Sales_Inv', N'SI') IS NOT NULL
    DROP FUNCTION Sales_Inv;
GO
CREATE FUNCTION Sales_Inv (@InvoiceID int)
RETURNS TABLE
AS
RETURN
(
    SELECT SIL.InvoiceID, SIL.Description, SUM(Quantity) AS 'Total_Quantity', SUM (SIL.UnitPrice) AS 'Total_Sum'
    FROM Sales.InvoiceLines AS SIL
    JOIN Sales.Invoices AS SI ON SIL.InvoiceID = SI.InvoiceID
    WHERE SI.InvoiceID = @InvoiceID
    GROUP BY SIL.InvoiceID,SIL.Description,SIL.UnitPrice)

	--Выгрузим данные по InvoiceID = 28
	select * from Sales_Inv (28)


	--Создание хранимой процедуры
--Количество проданного товара, с наименованием и ценой товара по счету

--входной параметр @InvoiceID
--Используемые таблицы и поля 
 -- Sales.InvoiceLines:InvoiceID, Description, Quantity, UnitPrice
 -- Sales.Invoices: InvoiceID

 USE WideWorldImporters;

IF OBJECT_ID ( 'Sale_Invoice', 'SI' ) IS NOT NULL
    DROP PROCEDURE Sale_Invoice;
GO
CREATE PROCEDURE Sale_Invoice 
     @InvoiceID INT,
     @Description NVARCHAR(50),
	 @Quantity INT,
	 @UnitPrice DECIMAL (18,2)
	
    
AS
    SET NOCOUNT ON;
    SELECT SIL.InvoiceID AS InvoiceID, SIL.Description, SIL.Quantity AS 'Total_Quantity', SIL.UnitPrice AS 'Total_Sum'
    FROM Sales.InvoiceLines AS SIL
    JOIN Sales.Invoices AS SI
      ON SIL.InvoiceID = SI.InvoiceID
    WHERE SI.InvoiceID LIKE @InvoiceID;
-- Populate the output variable @Quantity.
SET @Quantity = (SELECT SUM(SIL.Quantity)
    FROM Sales.InvoiceLines AS SIL
    JOIN Sales.Invoices AS SI
      ON SIL.InvoiceID = SI.InvoiceID
    WHERE SI.InvoiceID LIKE @InvoiceID AND SIL.Quantity=@Quantity);
-- Populate the output variable @UnitPrice.
SET @UnitPrice = (SELECT SUM (SIL.UnitPrice)
    FROM Sales.InvoiceLines AS SIL
    JOIN Sales.Invoices AS SI
      ON SIL.InvoiceID = SI.InvoiceID
    WHERE SI.InvoiceID LIKE @InvoiceID AND SIL.UnitPrice=@UnitPrice);
-- Populate the output variable @InvoiceID.
SET @InvoiceID = @Quantity;
SET @InvoiceID = @UnitPrice;
GO

/*
4) Создайте табличную функцию покажите как ее можно вызвать для каждой строки result set'а без использования цикла. 
*/
--входной параметр @CustomerID

IF OBJECT_ID (N'Sales_Customers', N'SCT') IS NOT NULL
    DROP FUNCTION Sales_Customers;
GO
CREATE FUNCTION Sales_Customers (@CustomerID int)
RETURNS TABLE
AS
RETURN
(
    SELECT SCT.CustomerID, SUM(SCT.TransactionAmount) AS 'Total_Summ'
    FROM Sales.CustomerTransactions AS SCT
    JOIN Sales.Orders AS SO ON SCT.CustomerID = SO.CustomerID
    WHERE SO.CustomerID = @CustomerID
    GROUP BY SCT.CustomerID)

--В следующем примере функция вызывается с CustomerID=868.

SELECT * FROM Sales_Customers (868)


/*
5) Опционально. Во всех процедурах укажите какой уровень изоляции транзакций вы бы использовали и почему. 
*/







