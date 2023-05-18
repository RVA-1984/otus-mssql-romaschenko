/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.
Занятие "02 - Оператор SELECT и простые фильтры, JOIN".

Задания выполняются с использованием базы данных WideWorldImporters.

Бэкап БД WideWorldImporters можно скачать отсюда:
https://github.com/Microsoft/sql-server-samples/releases/download/wide-world-importers-v1.0/WideWorldImporters-Full.bak

Описание WideWorldImporters от Microsoft:
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
*/

-- ---------------------------------------------------------------------------
-- Задание - написать выборки для получения указанных ниже данных.
-- ---------------------------------------------------------------------------

USE WideWorldImporters

/*
1. Все товары, в названии которых есть "urgent" или название начинается с "Animal".
Вывести: ИД товара (StockItemID), наименование товара (StockItemName).
Таблицы: Warehouse.StockItems.
*/

Select StockItemID,StockItemName
From Warehouse.StockItems
Where StockItemName Like 'Animal%';  

Select StockItemID,StockItemName
From Warehouse.StockItems
Where StockItemName Like '%urgent%';
/*
2. Поставщиков (Suppliers), у которых не было сделано ни одного заказа (PurchaseOrders).
Сделать через JOIN, с подзапросом задание принято не будет.
Вывести: ИД поставщика (SupplierID), наименование поставщика (SupplierName).
Таблицы: Purchasing.Suppliers, Purchasing.PurchaseOrders.
По каким колонкам делать JOIN подумайте самостоятельно.
*/

SELECT
  s.SupplierID,
  s.SupplierName,
  o.PurchaseOrderID,
  o.SupplierID
FROM Purchasing.Suppliers s
LEFT JOIN Purchasing.PurchaseOrders o
	ON s.SupplierID = o.SupplierID 
WHERE o.PurchaseOrderID IS NULL
ORDER BY s.SupplierID;
/*
3. Заказы (Orders) с ценой товара (UnitPrice) более 100$ 
либо количеством единиц (Quantity) товара более 20 штук
и присутствующей датой комплектации всего заказа (PickingCompletedWhen).
Вывести:
* OrderID
* дату заказа (OrderDate) в формате ДД.ММ.ГГГГ
* название месяца, в котором был сделан заказ
* номер квартала, в котором был сделан заказ
* треть года, к которой относится дата заказа (каждая треть по 4 месяца)
* имя заказчика (CustomerName) table Sales.Customers
Добавьте вариант этого запроса с постраничной выборкой,
пропустив первую 1000 и отобразив следующие 100 записей.

Сортировка должна быть по номеру квартала, трети года, дате заказа (везде по возрастанию).

Таблицы: Sales.Orders, Sales.OrderLines, Sales.Customers.
*/
select
s.UnitPrice,
s.Quantity,
o.OrderID,
c.CustomerName,
FORMAT (OrderDate,'dd.MM.yyyy') AS OrderDate, 
DATENAME (month,o.PickingCompletedWhen) AS PickingCompletedWhen,
DATEPART (quarter,o.PickingCompletedWhen) AS NumberQuarter
FROM Sales.Orders o
JOIN Sales.OrderLines s ON s.UnitPrice>100 AND Quantity>20
JOIN Sales.Customers c ON c.CustomerName=c.CustomerName
Order by NumberQuarter, OrderDate ASC
OFFSET 1000 ROWS FETCH FIRST 100 ROWS ONLY
/*
4. Заказы поставщикам (Purchasing.Suppliers),
которые должны быть исполнены (ExpectedDeliveryDate) в январе 2013 года
с доставкой "Air Freight" или "Refrigerated Air Freight" (DeliveryMethodName)
и которые исполнены (IsOrderFinalized).
Вывести:
* способ доставки (DeliveryMethodName)
* дата доставки (ExpectedDeliveryDate)
* имя поставщика
* имя контактного лица принимавшего заказ (ContactPerson)

Таблицы: Purchasing.Suppliers, Purchasing.PurchaseOrders, Application.DeliveryMethods, Application.People.
*/
Select 
d.DeliveryMethodName,
p.ExpectedDeliveryDate,
s.SupplierName,
p.ContactPersonID,
p.IsOrderFinalized
FROM Purchasing.Suppliers s
JOIN Application.DeliveryMethods d ON d.DeliveryMethodName = 'Air Freight' OR d.DeliveryMethodName = 'Refrigerated Air Freight'
JOIN Purchasing.PurchaseOrders p ON p.ExpectedDeliveryDate BETWEEN '2013-01-01' AND '2013-01-31'



/*
5. Десять последних продаж (по дате продажи) с именем клиента и именем сотрудника,
который оформил заказ (SalespersonPerson).
Сделать без подзапросов.
*/

Select top 10
t.TransactionDate,
c.CustomerName,
i.SalespersonPersonID
FROM Sales.CustomerTransactions t
JOIN Sales.Customers c ON c.CustomerName = c.CustomerName
JOIN Sales.Invoices i ON i.SalespersonPersonID = i.SalespersonPersonID

/*
6. Все ид и имена клиентов и их контактные телефоны,
которые покупали товар "Chocolate frogs 250g".
Имя товара смотреть в таблице Warehouse.StockItems.
*/

SELECT
     c.CustomerID,
	 c.CustomerName,
	 c.PhoneNumber,
	 s.StockItemName 
FROM Sales.Customers c 
JOIN Warehouse.StockItems s ON s.StockItemName = 'Chocolate frogs 250g';


 



