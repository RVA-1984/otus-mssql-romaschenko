/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "06 - Оконные функции".

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
1. Сделать расчет суммы продаж нарастающим итогом по месяцам с 2015 года 
(в рамках одного месяца он будет одинаковый, нарастать будет в течение времени выборки).
Выведите: id продажи, название клиента, дату продажи, сумму продажи, сумму нарастающим итогом

Пример:
-------------+----------------------------
Дата продажи | Нарастающий итог по месяцу
-------------+----------------------------
 2015-01-29   | 4801725.31
 2015-01-30	 | 4801725.31
 2015-01-31	 | 4801725.31
 2015-02-01	 | 9626342.98
 2015-02-02	 | 9626342.98
 2015-02-03	 | 9626342.98
Продажи можно взять из таблицы Invoices.
Нарастающий итог должен быть без оконной функции.
*/

	set statistics time, io on

	;with CTE as (
select 
left(i.InvoiceDate,7) as d,
sum(ct.TransactionAmount) as s
from Sales.Invoices as i
join Sales.CustomerTransactions as ct on ct.InvoiceID = i.InvoiceID
where i.InvoiceDate >= '2015-01-01'
group by 
left (i.InvoiceDate,7))

select
 i.InvoiceID				as 'Id продажи'
,c.CustomerName			    as 'Название клиента'
,i.InvoiceDate				as 'Дата продажи'
,ct.TransactionAmount		as 'Сумма продажи'
,FROM_CTE.PROGRESSIVE_TOTAL as 'Нарастающий итог по месяцу'
from Sales.Invoices as i
	join Sales.CustomerTransactions as ct on ct.InvoiceID = i.InvoiceID
	join Sales.Customers as c on c.CustomerID = ct.CustomerID
	join (select T1.*, (select coalesce(sum(T2.S),0)
						from CTE as T2 where T2.D<=T1.D) as PROGRESSIVE_TOTAL
		  from CTE as T1) as FROM_CTE on FROM_CTE.D = left(i.InvoiceDate,7)
order by [id продажи]

--SQL Server parse and compile time: 
   --CPU time = 94 ms, elapsed time = 418 ms.

/*
2. Сделайте расчет суммы нарастающим итогом в предыдущем запросе с помощью оконной функции.
   Сравните производительность запросов 1 и 2 с помощью set statistics time, io on
*/

select
 i.InvoiceID				as 'Id продажи'
,c.CustomerName			as 'Название клиента'
,i.InvoiceDate				as 'Дата продажи'
,ct.TransactionAmount		as 'Сумма продажи'
,sum(ct.TransactionAmount) over (order by datepart(YEAR, i.InvoiceDate), datepart(MONTH, i.InvoiceDate)) as 'Нарастающий итог по месяцу'
from Sales.Invoices as i
	join Sales.CustomerTransactions as ct on ct.InvoiceID = i.InvoiceID
	join Sales.Customers as c on c.CustomerID = ct.CustomerID
where i.InvoiceDate >= '2015-01-01'
order by [id продажи]	

--SQL Server parse and compile time: 
   --CPU time = 31 ms, elapsed time = 153 ms.
   -- Вывод: оконная функция выдает результат в разы быстрее, чем использование CTE
/*
3. Вывести список 2х самых популярных продуктов (по количеству проданных) 
в каждом месяце за 2016 год (по 2 самых популярных продукта в каждом месяце).
*/
select YEAR_MONTH, StockItemID, TOTAL from (
	select *, ROW_NUMBER() OVER (PARTITION BY YEAR_MONTH ORDER BY TOTAL desc) as ID_ROW from (
		select distinct left(i.InvoiceDate,7) as YEAR_MONTH, si.StockItemID, sum(Quantity) OVER (PARTITION BY month(i.InvoiceDate), si.StockItemID) as TOTAL from Sales.Invoices as i
			join Sales.InvoiceLines as si on si.InvoiceID = i.InvoiceID
		where i.InvoiceDate like '2016%'
	) t1
) t2
where ID_ROW <= 2
order by YEAR_MONTH, TOTAL

/*
4. Функции одним запросом
Посчитайте по таблице товаров (в вывод также должен попасть ид товара, название, брэнд и цена):
* пронумеруйте записи по названию товара, так чтобы при изменении буквы алфавита нумерация начиналась заново
* посчитайте общее количество товаров и выведете полем в этом же запросе
* посчитайте общее количество товаров в зависимости от первой буквы названия товара
* отобразите следующий id товара исходя из того, что порядок отображения товаров по имени 
* предыдущий ид товара с тем же порядком отображения (по имени)
* названия товара 2 строки назад, в случае если предыдущей строки нет нужно вывести "No items"
* сформируйте 30 групп товаров по полю вес товара на 1 шт

Для этой задачи НЕ нужно писать аналог без аналитических функций.
*/
-- пронумеруйте записи по названию товара, так чтобы при изменении буквы алфавита нумерация начиналась заново
select StockItemID, StockItemName, Brand, UnitPrice, 
ROW_NUMBER () OVER (PARTITION BY left(StockItemName,1) order by StockItemName) as 'Нумерация' 
from Warehouse.StockItems

-- посчитайте общее количество товаров и выведете полем в этом же запросе
select StockItemID, StockItemName, Brand, UnitPrice, 
ROW_NUMBER () OVER (PARTITION BY left(StockItemName,1) order by StockItemName), 
sum (QuantityPerOuter) over () as 'Общее количество товаров' from Warehouse.StockItems

-- посчитайте общее количество товаров в зависимости от первой буквы названия товара
select StockItemID, StockItemName, Brand, UnitPrice, 
ROW_NUMBER () OVER (PARTITION BY left(StockItemName,1) order by StockItemName), 
sum (QuantityPerOuter) over () as 'Общее количество товаров', 
sum (QuantityPerOuter) over (PARTITION BY left(StockItemName,1) 
order by left(StockItemName,1)) as 'Общее количество товаров по первой букве' from Warehouse.StockItems


-- отобразите следующий id товара исходя из того, что порядок отображения товаров по имени
select StockItemID, StockItemName, Brand, UnitPrice, 
lead(StockItemID) OVER (order by StockItemName) as 'Следующий id товара' from Warehouse.StockItems


-- предыдущий ид товара с тем же порядком отображения (по имени)
select StockItemID, StockItemName, Brand, UnitPrice, 
lag(StockItemID) OVER (order by StockItemName) as 'Предыдыщий ид товара' from Warehouse.StockItems


-- названия товара 2 строки назад, в случае если предыдущей строки нет нужно вывести "No items"
select StockItemID, StockItemName, Brand, UnitPrice, 
isnull(lag(StockItemName,2) OVER (order by StockItemName),'No items') as 'Название товара 2 строки назад'
from Warehouse.StockItems


-- сформируйте 30 групп товаров по полю вес товара на 1 шт
select StockItemID, StockItemName, Brand, UnitPrice, TypicalWeightPerUnit, 
ntile(30) OVER (PARTITION BY TypicalWeightPerUnit order by TypicalWeightPerUnit) as 'Группа товаров по полю вес'
from Warehouse.StockItems
order by ntile(30) OVER (PARTITION BY TypicalWeightPerUnit order by TypicalWeightPerUnit)


/*
5. По каждому сотруднику выведите последнего клиента, которому сотрудник что-то продал.
   В результатах должны быть ид и фамилия сотрудника, ид и название клиента, дата продажи, сумму сделки.
*/

; with CTE as (
				select distinct
				 SalespersonPersonID
				,max (InvoiceID) OVER (PARTITION BY SalespersonPersonID) as 'Вывод последнего клиента по каждому сотруднику'
				from Sales.Invoices)

select 
 CTE.SalespersonPersonID
,a.FullName
,ct.CustomerID
,с.CustomerName
,ct.TransactionDate
,ct.TransactionAmount
from CTE
	join Sales.CustomerTransactions as ct on ct.InvoiceID = CTE.[Вывод последнего клиента по каждому сотруднику]
	join Sales.Customers as с on с.CustomerID = ct.CustomerID
	join Application.People as a on a.PersonID = CTE.SalespersonPersonID
order by 1, 3   


/*
6. Выберите по каждому клиенту два самых дорогих товара, которые он покупал.
В результатах должно быть ид клиета, его название, ид товара, цена, дата покупки.
*/

; with CTE as (
				select distinct
				 s.CustomerID
				,o.UnitPrice
				,o.StockItemID
				,max(s.OrderDate) OVER (PARTITION BY s.CustomerID, o.UnitPrice, o.StockItemID order by o.UnitPrice desc) as 'Дата покупки товара'
				,DENSE_RANK() OVER (PARTITION BY s.CustomerID order by o.UnitPrice desc) as SORT
				from Sales.OrderLines as o
					join Sales.Orders as s on s.OrderID = o.OrderID)
select 
 CTE.CustomerID
,c.CustomerName
,CTE.StockItemID
,CTE.UnitPrice
,CTE.[Дата покупки товара]
from CTE
	join Sales.Customers as c on c.CustomerID = CTE.CustomerID
where CTE.SORT <= 2
order by 1 asc, 4 desc

---Опционально можете для каждого запроса без оконных функций сделать вариант запросов с оконными функциями и сравнить их производительность. 