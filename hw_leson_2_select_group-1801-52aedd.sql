/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.
Занятие "02 - Оператор SELECT и простые фильтры, GROUP BY, HAVING".

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
1. Все товары, в названии которых есть "urgent" или название начинается с "Animal".
Вывести: ИД товара (StockItemID), наименование товара (StockItemName).
Таблицы: Warehouse.StockItems.
*/

TODO: 
SELECT 
	StockItemID,
	StockItemName
FROM Warehouse.StockItems
WHERE StockItemName LIKE '%urgent%' OR StockItemName LIKE 'Animal%'


/*
2. Поставщиков (Suppliers), у которых не было сделано ни одного заказа (PurchaseOrders).
Сделать через JOIN, с подзапросом задание принято не будет.
Вывести: ИД поставщика (SupplierID), наименование поставщика (SupplierName).
Таблицы: Purchasing.Suppliers, Purchasing.PurchaseOrders.
По каким колонкам делать JOIN подумайте самостоятельно.
*/

TODO:
SELECT DISTINCT 
	sp.SupplierID,
	sp.SupplierName
FROM Purchasing.Suppliers sp
LEFT JOIN Purchasing.PurchaseOrders p on p.SupplierID=sp.SupplierID 
WHERE p.SupplierID IS NULL

--SELECT * FROM Purchasing.Suppliers
--SELECT * FROM Purchasing.PurchaseOrders


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
* имя заказчика (Customer)
Добавьте вариант этого запроса с постраничной выборкой,
пропустив первую 1000 и отобразив следующие 100 записей.

Сортировка должна быть по номеру квартала, трети года, дате заказа (везде по возрастанию).

Таблицы: Sales.Orders, Sales.OrderLines, Sales.Customers.
*/

TODO: 
DECLARE 
	@pagesize BIGINT = 1000, -- Размер страницы
	@pagenum  BIGINT = 100;  -- Номер страницы

SELECT --TOP 100
	ordl.OrderID,
	CONVERT(varchar, ord.OrderDate, 104) as [OrderDate], --FORMAT(ord.OrderDate, 'dd.MM.yyyy')
	MONTH(ord.OrderDate) as [Month],
	DATEPART(quarter, ord.OrderDate ) as [Quarter],
	CEILING( MONTH(ord.OrderDate) * 1.0 / 12.0 * 3.0 ) as [PartYear3],
	c.CustomerName
FROM  Sales.OrderLines ordl
LEFT JOIN Sales.Orders ord on ord.OrderID=ordl.OrderID
LEFT JOIN Sales.Customers c on c.CustomerID=ord.CustomerID
WHERE ordl.UnitPrice > 100
	AND ordl.Quantity > 20
	AND ordl.PickingCompletedWhen IS NOT NULL
ORDER BY [Quarter], [PartYear3], ord.OrderDate
	OFFSET @pagesize ROWS FETCH NEXT @pagenum ROWS ONLY; 


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

TODO: 
SELECT 
	DeliveryMethodName,
	ExpectedDeliveryDate,
	SupplierName,
	FullName
FROM Purchasing.Suppliers p
LEFT JOIN Purchasing.PurchaseOrders po on po.SupplierID=p.SupplierID
LEFT JOIN Application.DeliveryMethods d on d.DeliveryMethodID=po.DeliveryMethodID
LEFT JOIN Application.People pp on pp.PersonID=po.ContactPersonID
WHERE po.ExpectedDeliveryDate BETWEEN N'2013-01-01' AND N'2013-01-31'
	AND d.DeliveryMethodName IN ('Air Freight', 'Refrigerated Air Freight')
	AND po.IsOrderFinalized = 1



/*
5. Десять последних продаж (по дате продажи) с именем клиента и именем сотрудника,
который оформил заказ (SalespersonPerson).
Сделать без подзапросов.
*/

TODO: 
SELECT TOP 10
	o.OrderDate,
	p.FullName,
	c.CustomerName
FROM Sales.Orders o 
LEFT JOIN Application.People p on p.PersonID=o.SalespersonPersonID
LEFT JOIN Sales.Customers c on c.CustomerID=o.CustomerID
ORDER BY o.OrderDate DESC


--SELECT TOP 100 * FROM Sales.Orders
--SELECT TOP 100 * FROM Sales.OrderLines
--SELECT TOP 100 * FROM Sales.Customers
--SELECT TOP 100 * FROM Application.People


--SELECT * FROM INFORMATION_SCHEMA.COLUMNS
--WHERE COLUMN_NAME  LIKE '%CustomerID%'



/*
6. Все ид и имена клиентов и их контактные телефоны,
которые покупали товар "Chocolate frogs 250g".
Имя товара смотреть в таблице Warehouse.StockItems.
*/

TODO: 
SELECT DISTINCT
	p.PersonID,
	p.FullName,
	p.PhoneNumber
FROM Sales.OrderLines ol
JOIN Warehouse.StockItems w on w.StockItemID=ol.StockItemID AND w.StockItemName = 'Chocolate frogs 250g'
LEFT JOIN Sales.Orders o on o.OrderID=ol.OrderID
LEFT JOIN Application.People p on p.PersonID=o.SalespersonPersonID


--SELECT TOP 100 * FROM Sales.Orders
--SELECT TOP 100 * FROM Sales.OrderLines
--SELECT TOP 100 * FROM Application.People
--SELECT TOP 100 * FROM Warehouse.StockItems

/*
7. Посчитать среднюю цену товара, общую сумму продажи по месяцам
Вывести:
* Год продажи (например, 2015)
* Месяц продажи (например, 4)
* Средняя цена за месяц по всем товарам
* Общая сумма продаж за месяц

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/

TODO: 
SELECT 
	YEAR(i.InvoiceDate) as [Year],
	MONTH(i.InvoiceDate) as [Month],
	AVG(ol.UnitPrice) as [AvgPrice],
	SUM(ol.UnitPrice) as [Revenue]
FROM Sales.Invoices i
LEFT JOIN Sales.OrderLines ol on ol.OrderID=i.OrderID
GROUP BY YEAR(i.InvoiceDate), MONTH(i.InvoiceDate)
ORDER BY YEAR(i.InvoiceDate), MONTH(i.InvoiceDate)


--SELECT COUNT(*), COUNT(DISTINCT OrderID) FROM Sales.Invoices
--SELECT TOP 100 * FROM Sales.Invoices
--SELECT TOP 100 * FROM Sales.OrderLines

/*
8. Отобразить все месяцы, где общая сумма продаж превысила 10 000

Вывести:
* Год продажи (например, 2015)
* Месяц продажи (например, 4)
* Общая сумма продаж

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/

TODO: 

SELECT 
	YEAR(i.InvoiceDate) as [Year],
	MONTH(i.InvoiceDate) as [Month],
	SUM(ol.UnitPrice) as [Revenue]
FROM Sales.Invoices i
LEFT JOIN Sales.OrderLines ol on ol.OrderID=i.OrderID
GROUP BY YEAR(i.InvoiceDate), MONTH(i.InvoiceDate)
HAVING SUM(ol.UnitPrice) > 10000
ORDER BY YEAR(i.InvoiceDate), MONTH(i.InvoiceDate)



/*
9. Вывести сумму продаж, дату первой продажи
и количество проданного по месяцам, по товарам,
продажи которых менее 50 ед в месяц.
Группировка должна быть по году,  месяцу, товару.

Вывести:
* Год продажи
* Месяц продажи
* Наименование товара
* Сумма продаж
* Дата первой продажи
* Количество проданного

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/

TODO: 
SELECT 
	YEAR(i.InvoiceDate) as [Year],
	MONTH(i.InvoiceDate) as [Month],
	w.StockItemName,
	SUM(ol.UnitPrice) as [Revenue],
	MIN(i.InvoiceDate) as [FirsttDate],
	COUNT(*) as [Qty]
FROM Sales.Invoices i
LEFT JOIN Sales.OrderLines ol on ol.OrderID=i.OrderID
LEFT JOIN Warehouse.StockItems w on w.StockItemID=ol.StockItemID
GROUP BY YEAR(i.InvoiceDate), MONTH(i.InvoiceDate), w.StockItemName
HAVING COUNT(*) < 50
ORDER BY YEAR(i.InvoiceDate), MONTH(i.InvoiceDate)



--SELECT TOP 100 * FROM Sales.Invoices
--SELECT TOP 100 * FROM Sales.Orders
--SELECT TOP 100 * FROM Sales.OrderLines
--SELECT TOP 100 * FROM Warehouse.StockItems

-- ---------------------------------------------------------------------------
-- Опционально
-- ---------------------------------------------------------------------------
/*
Написать запросы 8-9 так, чтобы если в каком-то месяце не было продаж,
то этот месяц также отображался бы в результатах, но там были нули.
*/

-- Не одназначно понял задание
SELECT 
	YEAR(i.InvoiceDate) as [Year],
	MONTH(i.InvoiceDate) as [Month],
	SUM(ol.UnitPrice) as [Revenue]
FROM Sales.Invoices i
LEFT JOIN Sales.OrderLines ol on ol.OrderID=i.OrderID
GROUP BY GROUPING SETS (YEAR(i.InvoiceDate), MONTH(i.InvoiceDate))  --GROUP BY YEAR(i.InvoiceDate), MONTH(i.InvoiceDate)
HAVING SUM(ol.UnitPrice) > 10000
ORDER BY YEAR(i.InvoiceDate), MONTH(i.InvoiceDate)


TODO: 
SELECT 
	YEAR(i.InvoiceDate) as [Year],
	MONTH(i.InvoiceDate) as [Month],
	w.StockItemName,
	SUM(ol.UnitPrice) as [Revenue],
	MIN(i.InvoiceDate) as [FirsttDate],
	COUNT(*) as [Qty]
FROM Sales.Invoices i
LEFT JOIN Sales.OrderLines ol on ol.OrderID=i.OrderID
LEFT JOIN Warehouse.StockItems w on w.StockItemID=ol.StockItemID
GROUP BY GROUPING SETS (YEAR(i.InvoiceDate), MONTH(i.InvoiceDate), w.StockItemName) -- GROUP BY YEAR(i.InvoiceDate), MONTH(i.InvoiceDate), w.StockItemName
HAVING COUNT(*) < 50
ORDER BY YEAR(i.InvoiceDate), MONTH(i.InvoiceDate)



