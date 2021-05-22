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

IF OBJECT_ID(N'WideWorldImporters.dbo.ufn_Top1BuyClient') IS NOT NULL  DROP FUNCTION dbo.ufn_Top1BuyClient

CREATE FUNCTION dbo.ufn_Top1BuyClient (@StartDAte date, @EndDAte date)  
RETURNS varchar(100)
WITH EXECUTE AS CALLER  
AS  
BEGIN  
     DECLARE @ClientName varchar(100);  
     SET @ClientName= (
				SELECT 	CustomerName
				FROM (
					SELECT TOP 1
						inv.InvoiceID,
						c.CustomerName,
						sinv.InvoiceDate,
						SUM(inv.Quantity * inv.UnitPrice) as [SumSales]
					FROM [Sales].[InvoiceLines] inv
					LEFT JOIN [Sales].[Invoices] sinv on sinv.InvoiceID=inv.InvoiceID
					LEFT JOIN [Sales].[Customers] c on c.CustomerID=sinv.CustomerID
					WHERE sinv.InvoiceDate BETWEEN @StartDAte AND @EndDAte
					GROUP BY 
						inv.InvoiceID,
						c.CustomerName,
						sinv.InvoiceDate
					ORDER BY [SumSales] DESC	
					) c 
				)
     RETURN(@ClientName);  
END;  
GO  

SELECT dbo.ufn_Top1BuyClient ('20150101', '20150131')  
IF OBJECT_ID(N'WideWorldImporters.dbo.ufn_Top1BuyClient') IS NOT NULL  DROP FUNCTION dbo.ufn_Top1BuyClient


/*
2) Написать хранимую процедуру с входящим параметром СustomerID, выводящую сумму покупки по этому клиенту.
Использовать таблицы :
Sales.Customers
Sales.Invoices
Sales.InvoiceLines
*/

IF OBJECT_ID(N'WideWorldImporters.dbo.usp_CustomerBay') IS NOT NULL  DROP PROCEDURE dbo.usp_CustomerBay
CREATE PROCEDURE dbo.usp_CustomerBay 
	@CustomerID int

WITH EXECUTE AS CALLER --выполняются от имени вызывающей стороны родительской процедуры 
AS  
    SET NOCOUNT ON;  
	SELECT
		SUM(inv.Quantity * inv.UnitPrice) as [SumSales]
	FROM [Sales].[InvoiceLines] inv
	LEFT JOIN [Sales].[Invoices] sinv on sinv.InvoiceID=inv.InvoiceID
	LEFT JOIN [Sales].[Customers] c on c.CustomerID=sinv.CustomerID
	WHERE c.CustomerID = @CustomerID
	RETURN
GO     

EXEC dbo.uspCustomerBay '22'


/*


3) Создать одинаковую функцию и хранимую процедуру, посмотреть в чем разница в производительности и почему.
*/
IF OBJECT_ID(N'WideWorldImporters.dbo.usp_CustomerBayDate') IS NOT NULL  DROP FUNCTION dbo.usp_CustomerBayDate
ALTER PROCEDURE dbo.usp_CustomerBayDate 
	@StartDAte date, @EndDAte date

WITH EXECUTE AS CALLER --выполняются от имени вызывающей стороны родительской процедуры 
AS  
    SET NOCOUNT ON;  
     
	DECLARE @ClientName varchar(100);  
    SET @ClientName= (
			SELECT 	CustomerName
			FROM (
				SELECT TOP 1
					inv.InvoiceID,
					c.CustomerName,
					sinv.InvoiceDate,
					SUM(inv.Quantity * inv.UnitPrice) as [SumSales]
				FROM [Sales].[InvoiceLines] inv
				LEFT JOIN [Sales].[Invoices] sinv on sinv.InvoiceID=inv.InvoiceID
				LEFT JOIN [Sales].[Customers] c on c.CustomerID=sinv.CustomerID
				WHERE sinv.InvoiceDate BETWEEN @StartDAte AND @EndDAte
				GROUP BY 
					inv.InvoiceID,
					c.CustomerName,
					sinv.InvoiceDate
				ORDER BY [SumSales] DESC	
				) c 
			)
	SELECT @ClientName as ClientName 
GO  
EXEC dbo.usp_CustomerBayDate  '20150101', '20150131'
--SET STATISTICS IO, TIME OFF;
SET SHOWPLAN_TEXT OFF;
SET SHOWPLAN_ALL OFF;
SET STATISTICS PROFILE OFF;




IF OBJECT_ID(N'WideWorldImporters.dbo.ufn_Top1BuyClient') IS NOT NULL  DROP FUNCTION dbo.ufn_Top1BuyClient

CREATE FUNCTION dbo.ufn_Top1BuyClient (@StartDAte date, @EndDAte date)  
RETURNS varchar(100)
WITH EXECUTE AS CALLER  
AS  
BEGIN  
     DECLARE @ClientName varchar(100);  
     SET @ClientName= (
			SELECT 	CustomerName
			FROM (
				SELECT TOP 1
					inv.InvoiceID,
					c.CustomerName,
					sinv.InvoiceDate,
					SUM(inv.Quantity * inv.UnitPrice) as [SumSales]
				FROM [Sales].[InvoiceLines] inv
				LEFT JOIN [Sales].[Invoices] sinv on sinv.InvoiceID=inv.InvoiceID
				LEFT JOIN [Sales].[Customers] c on c.CustomerID=sinv.CustomerID
				WHERE sinv.InvoiceDate BETWEEN @StartDAte AND @EndDAte
				GROUP BY 
					inv.InvoiceID,
					c.CustomerName,
					sinv.InvoiceDate
				ORDER BY [SumSales] DESC	
				) c 
			)
     RETURN(@ClientName);  
END;  
GO  

SELECT dbo.ufn_Top1BuyClient ('20150101', '20150131')  as ClientName  

------- В производительности отличия нет, при отражения действительного плана запроса у функции скрывается ход выполнения. План запроса отражается при выключении SET SHOWPLAN_TEXT ON;
/*
--------------------- /// PROCEDURE dbo.usp_CustomerBayDate 

       |--Compute Scalar(DEFINE:([Expr1012]=CONVERT_IMPLICIT(varchar(100),[WideWorldImporters].[Sales].[Customers].[CustomerName] as [c].[CustomerName],0)))
            |--Nested Loops(Left Outer Join)
                 |--Constant Scan
                 |--Sort(TOP 1, ORDER BY:([Expr1010] DESC))
                      |--Compute Scalar(DEFINE:([Expr1010]=CASE WHEN [Expr1029]=(0) THEN NULL ELSE [Expr1030] END))
                           |--Stream Aggregate(GROUP BY:([c].[CustomerName], [inv].[InvoiceID]) DEFINE:([Expr1029]=COUNT_BIG([Expr1016]), [Expr1030]=SUM([Expr1016])))
                                |--Sort(ORDER BY:([c].[CustomerName] ASC, [inv].[InvoiceID] ASC))
                                     |--Hash Match(Right Outer Join, HASH:([c].[CustomerID])=([sinv].[CustomerID]))
                                          |--Nested Loops(Left Semi Join, OUTER REFERENCES:([c].[DeliveryCityID]))
                                          |    |--Clustered Index Scan(OBJECT:([WideWorldImporters].[Sales].[Customers].[PK_Sales_Customers] AS [c]))
                                          |    |--Concatenation
                                          |         |--Filter(WHERE:(STARTUP EXPR(is_rolemember(N'db_owner')<>(0))))
                                          |         |    |--Constant Scan
                                          |         |--Filter(WHERE:(is_rolemember([Expr1015]+N' Sales')<>(0)))
                                          |         |    |--Nested Loops(Left Outer Join)
                                          |         |         |--Constant Scan
                                          |         |         |--Assert(WHERE:(CASE WHEN [Expr1014]>(1) THEN (0) ELSE NULL END))
                                          |         |              |--Stream Aggregate(DEFINE:([Expr1014]=Count(*), [Expr1015]=ANY([WideWorldImporters].[Application].[StateProvinces].[SalesTerritory] as [sp].[SalesTerritory])))
                                          |         |                   |--Nested Loops(Inner Join, OUTER REFERENCES:([c].[StateProvinceID]))
                                          |         |                        |--Clustered Index Seek(OBJECT:([WideWorldImporters].[Application].[Cities].[PK_Application_Cities] AS [c]), SEEK:([c].[CityID]=[WideWorldImporters].[Sales].[Customers].[DeliveryCityID] as [c].[DeliveryCityID]) ORDERED FORWARD)
                                          |         |                        |--Clustered Index Seek(OBJECT:([WideWorldImporters].[Application].[StateProvinces].[PK_Application_StateProvinces] AS [sp]), SEEK:([sp].[StateProvinceID]=[WideWorldImporters].[Application].[Cities].[StateProvinceID] as [c].[StateProvinceID]) ORDERED FORWARD)
                                          |         |--Nested Loops(Inner Join, OUTER REFERENCES:([sp].[StateProvinceID]))
                                          |              |--Filter(WHERE:([Expr1017]=session_context(N'SalesTerritory')))
                                          |              |    |--Compute Scalar(DEFINE:([Expr1017]=CONVERT_IMPLICIT(sql_variant,[WideWorldImporters].[Application].[StateProvinces].[SalesTerritory] as [sp].[SalesTerritory],0)))
                                          |              |         |--Clustered Index Scan(OBJECT:([WideWorldImporters].[Application].[StateProvinces].[PK_Application_StateProvinces] AS [sp]))
                                          |              |--Filter(WHERE:(STARTUP EXPR(original_login()=N'Website')))
                                          |                   |--Index Seek(OBJECT:([WideWorldImporters].[Application].[Cities].[FK_Application_Cities_StateProvinceID] AS [c]), SEEK:([c].[StateProvinceID]=[WideWorldImporters].[Application].[StateProvinces].[StateProvinceID] as [sp].[StateProvinceID] AND [c].[CityID]=[WideWorldImporters].[Sales].[Customers].[DeliveryCityID] as [c].[DeliveryCityID]) ORDERED FORWARD)
                                          |--Hash Match(Inner Join, HASH:([sinv].[InvoiceID])=([inv].[InvoiceID])DEFINE:([Opt_Bitmap1018]))
                                               |--Clustered Index Scan(OBJECT:([WideWorldImporters].[Sales].[Invoices].[PK_Sales_Invoices] AS [sinv]), WHERE:([WideWorldImporters].[Sales].[Invoices].[InvoiceDate] as [sinv].[InvoiceDate]>=[@StartDAte] AND [WideWorldImporters].[Sales].[Invoices].[InvoiceDate] as [sinv].[InvoiceDate]<=[@EndDAte]))
                                               |--Compute Scalar(DEFINE:([Expr1016]=CONVERT_IMPLICIT(decimal(10,0),[WideWorldImporters].[Sales].[InvoiceLines].[Quantity] as [inv].[Quantity],0)*[WideWorldImporters].[Sales].[InvoiceLines].[UnitPrice] as [inv].[UnitPrice]))
                                                    |--Index Scan(OBJECT:([WideWorldImporters].[Sales].[InvoiceLines].[NCCX_Sales_InvoiceLines] AS [inv]),  WHERE:(PROBE([Opt_Bitmap1018],[WideWorldImporters].[Sales].[InvoiceLines].[InvoiceID] as [inv].[InvoiceID])))

--------------------- ///  FUNCTION dbo.ufn_Top1BuyClient

            |--Compute Scalar(DEFINE:([Expr1012]=CONVERT_IMPLICIT(varchar(100),[WideWorldImporters].[Sales].[Customers].[CustomerName] as [c].[CustomerName],0)))
                 |--Nested Loops(Left Outer Join)
                      |--Constant Scan
                      |--Sort(TOP 1, ORDER BY:([Expr1010] DESC))
                           |--Compute Scalar(DEFINE:([Expr1010]=CASE WHEN [Expr1029]=(0) THEN NULL ELSE [Expr1030] END))
                                |--Stream Aggregate(GROUP BY:([c].[CustomerName], [inv].[InvoiceID]) DEFINE:([Expr1029]=COUNT_BIG([Expr1016]), [Expr1030]=SUM([Expr1016])))
                                     |--Sort(ORDER BY:([c].[CustomerName] ASC, [inv].[InvoiceID] ASC))
                                          |--Hash Match(Right Outer Join, HASH:([c].[CustomerID])=([sinv].[CustomerID]))
                                               |--Nested Loops(Left Semi Join, OUTER REFERENCES:([c].[DeliveryCityID]))
                                               |    |--Clustered Index Scan(OBJECT:([WideWorldImporters].[Sales].[Customers].[PK_Sales_Customers] AS [c]))
                                               |    |--Concatenation
                                               |         |--Filter(WHERE:(STARTUP EXPR(is_rolemember(N'db_owner')<>(0))))
                                               |         |    |--Constant Scan
                                               |         |--Filter(WHERE:(is_rolemember([Expr1015]+N' Sales')<>(0)))
                                               |         |    |--Nested Loops(Left Outer Join)
                                               |         |         |--Constant Scan
                                               |         |         |--Assert(WHERE:(CASE WHEN [Expr1014]>(1) THEN (0) ELSE NULL END))
                                               |         |              |--Stream Aggregate(DEFINE:([Expr1014]=Count(*), [Expr1015]=ANY([WideWorldImporters].[Application].[StateProvinces].[SalesTerritory] as [sp].[SalesTerritory])))
                                               |         |                   |--Nested Loops(Inner Join, OUTER REFERENCES:([c].[StateProvinceID]))
                                               |         |                        |--Clustered Index Seek(OBJECT:([WideWorldImporters].[Application].[Cities].[PK_Application_Cities] AS [c]), SEEK:([c].[CityID]=[WideWorldImporters].[Sales].[Customers].[DeliveryCityID] as [c].[DeliveryCityID]) ORDERED FORWARD)
                                               |         |                        |--Clustered Index Seek(OBJECT:([WideWorldImporters].[Application].[StateProvinces].[PK_Application_StateProvinces] AS [sp]), SEEK:([sp].[StateProvinceID]=[WideWorldImporters].[Application].[Cities].[StateProvinceID] as [c].[StateProvinceID]) ORDERED FORWARD)
                                               |         |--Nested Loops(Inner Join, OUTER REFERENCES:([sp].[StateProvinceID]))
                                               |              |--Filter(WHERE:([Expr1017]=session_context(N'SalesTerritory')))
                                               |              |    |--Compute Scalar(DEFINE:([Expr1017]=CONVERT_IMPLICIT(sql_variant,[WideWorldImporters].[Application].[StateProvinces].[SalesTerritory] as [sp].[SalesTerritory],0)))
                                               |              |         |--Clustered Index Scan(OBJECT:([WideWorldImporters].[Application].[StateProvinces].[PK_Application_StateProvinces] AS [sp]))
                                               |              |--Filter(WHERE:(STARTUP EXPR(original_login()=N'Website')))
                                               |                   |--Index Seek(OBJECT:([WideWorldImporters].[Application].[Cities].[FK_Application_Cities_StateProvinceID] AS [c]), SEEK:([c].[StateProvinceID]=[WideWorldImporters].[Application].[StateProvinces].[StateProvinceID] as [sp].[StateProvinceID] AND [c].[CityID]=[WideWorldImporters].[Sales].[Customers].[DeliveryCityID] as [c].[DeliveryCityID]) ORDERED FORWARD)
                                               |--Hash Match(Inner Join, HASH:([sinv].[InvoiceID])=([inv].[InvoiceID])DEFINE:([Opt_Bitmap1018]))
                                                    |--Clustered Index Scan(OBJECT:([WideWorldImporters].[Sales].[Invoices].[PK_Sales_Invoices] AS [sinv]), WHERE:([WideWorldImporters].[Sales].[Invoices].[InvoiceDate] as [sinv].[InvoiceDate]>=[@StartDAte] AND [WideWorldImporters].[Sales].[Invoices].[InvoiceDate] as [sinv].[InvoiceDate]<=[@EndDAte]))
                                                    |--Compute Scalar(DEFINE:([Expr1016]=CONVERT_IMPLICIT(decimal(10,0),[WideWorldImporters].[Sales].[InvoiceLines].[Quantity] as [inv].[Quantity],0)*[WideWorldImporters].[Sales].[InvoiceLines].[UnitPrice] as [inv].[UnitPrice]))
                                                         |--Index Scan(OBJECT:([WideWorldImporters].[Sales].[InvoiceLines].[NCCX_Sales_InvoiceLines] AS [inv]),  WHERE:(PROBE([Opt_Bitmap1018],[WideWorldImporters].[Sales].[InvoiceLines].[InvoiceID] as [inv].[InvoiceID])))

*/



/*
4) Создайте табличную функцию покажите как ее можно вызвать для каждой строки result set'а без использования цикла. --- Пологаю что сдесь опечатка и надо создать процедуру
*/
--- https://sqlstudies.com/2016/01/14/what-is-result-sets/

--IF OBJECT_ID(N'WideWorldImporters.dbo.ufn_Top1BuyClientTable') IS NOT NULL  DROP FUNCTION dbo.ufn_Top1BuyClientTable

--CREATE FUNCTION dbo.ufn_Top1BuyClientTable (@StartDAte date, @EndDAte date)  
--RETURNS TABLE 
--AS  
--RETURN  (  
--	SELECT 
--		inv.InvoiceID,
--		c.CustomerName,
--		sinv.InvoiceDate,
--		SUM(inv.Quantity * inv.UnitPrice) as [SumSales]
--	FROM [Sales].[InvoiceLines] inv
--	LEFT JOIN [Sales].[Invoices] sinv on sinv.InvoiceID=inv.InvoiceID
--	LEFT JOIN [Sales].[Customers] c on c.CustomerID=sinv.CustomerID
--	WHERE sinv.InvoiceDate BETWEEN @StartDAte AND @EndDAte
--	GROUP BY 
--		inv.InvoiceID,
--		c.CustomerName,
--		sinv.InvoiceDate	
--)
--GO  

--SELECT * FROM dbo.ufn_Top1BuyClientTable ('20150101', '20150131') ORDER BY [SumSales] DESC

USE tempdb
IF OBJECT_ID(N'tempdb.dbo.#usp_BuyClientTable') IS NOT NULL  DROP PROC dbo.#usp_BuyClientTable
CREATE PROC #usp_BuyClientTable @StartDAte date, @EndDAte date 
AS  
	SELECT 
		inv.InvoiceID,
		c.CustomerName,
		sinv.InvoiceDate,
		SUM(inv.Quantity * inv.UnitPrice) as [SumSales]
	FROM [Sales].[InvoiceLines] inv
	LEFT JOIN [Sales].[Invoices] sinv on sinv.InvoiceID=inv.InvoiceID
	LEFT JOIN [Sales].[Customers] c on c.CustomerID=sinv.CustomerID
	WHERE sinv.InvoiceDate BETWEEN @StartDAte AND @EndDAte
	GROUP BY 
		inv.InvoiceID,
		c.CustomerName,
		sinv.InvoiceDate	
GO  

EXEC tempdb.dbo.#usp_BuyClientTable '20150101', '20150131'
WITH RESULT SETS
( 
	(	
		[Invoice] int,
		[Name]  VARCHAR(50),
		[Date] date,
		[Sales] Money
	)
)


/*
5) Опционально. Во всех процедурах укажите какой уровень изоляции транзакций вы бы использовали и почему. 
*/
-- ========================== 
-- Для SP dbo.uspCustomerBay  -- Read Uncommitted - так как в процедуре выполняеется обычный запрос без DML