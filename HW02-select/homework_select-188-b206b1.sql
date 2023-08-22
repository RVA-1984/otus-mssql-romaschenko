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

Select StockItemID as 'Ид.товара'
,StockItemName as 'наименование товара'
From Warehouse.StockItems
Where StockItemName Like 'Animal%' OR StockItemName Like '%urgent%';  


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
o.OrderID 'Ид.заказа'
,convert(varchar, o.OrderDate, 104) as 'Дата заказа'
,datename(M, o.OrderDate) as 'Название месяца'            
,datepart(Q, o.OrderDate) as 'Номер квартала' 
,case
when datepart(M, o.OrderDate) in (1,2,3,4) then 1
when datepart(M, o.OrderDate) in (5,6,7,8) then 2
else 3
end  as 'Треть года'
,c.CustomerName as 'Имя заказчика'
from sales.Orders as o
	join sales.OrderLines s on o.OrderID = s.OrderID
	left join sales.Customers c on o.CustomerID = c.CustomerID
where (s.UnitPrice > 100 or s.Quantity > 20)
	and s.PickingCompletedWhen is not null
order by 
	datepart(Q, o.OrderDate),
	case
		when datepart(M, o.OrderDate) in (1,2,3,4) then 1
		when datepart(M, o.OrderDate) in (5,6,7,8) then 2
		else 3
	end,
	convert(varchar, o.OrderDate, 104) 

	---пропускаем первую 1000 и отображаем следующие 100 записей
	select
o.OrderID 'Ид.заказа'
,convert(varchar, o.OrderDate, 104) as 'Дата заказа'
,datename(M, o.OrderDate) as 'Название месяца'            
,datepart(Q, o.OrderDate) as 'Номер квартала' 
,case
when datepart(M, o.OrderDate) in (1,2,3,4) then 1
when datepart(M, o.OrderDate) in (5,6,7,8) then 2
else 3
end  as 'Треть года'
,c.CustomerName as 'Имя заказчика'
from sales.Orders as o
	join sales.OrderLines s on o.OrderID = s.OrderID
	left join sales.Customers c on o.CustomerID = c.CustomerID
where (s.UnitPrice > 100 or s.Quantity > 20)
	and s.PickingCompletedWhen is not null
order by 
	datepart(Q, o.OrderDate),
	case
		when datepart(M, o.OrderDate) in (1,2,3,4) then 1
		when datepart(M, o.OrderDate) in (5,6,7,8) then 2
		else 3
	end,
	convert(varchar, o.OrderDate, 104)
	offset 1000 rows fetch first 100 rows only

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

	 select
	 ad.DeliveryMethodName      as 'Cпособ доставки'
	,ppo.ExpectedDeliveryDate   as 'Дата доставки'
	,ps.SupplierName            as 'Имя поставщика'
	,ap.FullName                as 'Имя контактного лица, принимавшего заказ'
from Purchasing.Suppliers as ps
	join Purchasing.PurchaseOrders     as ppo on ps.SupplierID = ppo.SupplierID
	join Application.DeliveryMethods   as ad on ppo.DeliveryMethodID = ad.DeliveryMethodID
	join Application.People            as ap on ppo.ContactPersonID = ap.PersonID
where ppo.ExpectedDeliveryDate like '2013-01%'
	and (ad.DeliveryMethodName like 'Air Freight' or ad.DeliveryMethodName like 'Refrigerated Air Freight')
	and ppo.IsOrderFinalized = 1


/*
5. Десять последних продаж (по дате продажи) с именем клиента и именем сотрудника,
который оформил заказ (SalespersonPerson).
Сделать без подзапросов.
*/

select top 10 c.CustomerName, p.FullName, i.*
from sales.Invoices as i
join Sales.Customers as c on i.CustomerID = c.CustomerID
join Application.People as p on i.SalespersonPersonID = p.PersonID
order by InvoiceDate desc, InvoiceID desc
/*
6. Все ид и имена клиентов и их контактные телефоны,
которые покупали товар "Chocolate frogs 250g".
Имя товара смотреть в таблице Warehouse.StockItems.
*/

SELECT
     st.CustomerID as 'Ид клиента',
	 c.CustomerName 'Имя клиента',
	 c.PhoneNumber as 'Контактный телефон'
FROM Warehouse.StockItemTransactions as st 
JOIN Warehouse.StockItems as s ON st.StockItemID = s.StockItemID
JOIN sales.Customers as c on st.CustomerID = c.CustomerID
where s.StockItemName like 'Chocolate frogs 250g'



 


