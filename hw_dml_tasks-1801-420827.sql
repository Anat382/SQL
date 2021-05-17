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

--SELECT  * FROM  [Purchasing].[Suppliers]


DROP TABLE IF EXISTS [Purchasing].[SuppliersPractic] 

SELECT  * INTO [Purchasing].[SuppliersPractic] FROM  [Purchasing].[Suppliers]

INSERT INTO [Purchasing].[SuppliersPractic] (SupplierID, SupplierName, SupplierCategoryID, PrimaryContactPersonID, AlternateContactPersonID, DeliveryMethodID, DeliveryCityID, PostalCityID, SupplierReference, BankAccountName, BankAccountBranch, BankAccountCode, BankAccountNumber, BankInternationalCode, PaymentDays, InternalComments, PhoneNumber, FaxNumber, WebsiteURL, DeliveryAddressLine1, DeliveryAddressLine2, DeliveryPostalCode, DeliveryLocation, PostalAddressLine1, PostalAddressLine2, PostalPostalCode, LastEditedBy, ValidFrom, ValidTo)
SELECT TOP 5  0, SupplierName, SupplierCategoryID, PrimaryContactPersonID, AlternateContactPersonID, DeliveryMethodID, DeliveryCityID, PostalCityID, SupplierReference, BankAccountName, BankAccountBranch, BankAccountCode, BankAccountNumber, BankInternationalCode, PaymentDays, InternalComments, PhoneNumber, FaxNumber, WebsiteURL, DeliveryAddressLine1, DeliveryAddressLine2, DeliveryPostalCode, DeliveryLocation, PostalAddressLine1, PostalAddressLine2, PostalPostalCode, LastEditedBy, ValidFrom, ValidTo
FROM [Purchasing].[Suppliers]

SELECT * FROM [Purchasing].[SuppliersPractic]

--DROP TABLE IF EXISTS [Purchasing].[SuppliersPractic] 

--SELECT  CONCAT('target.',COLUMN_NAME,' = source.',COLUMN_NAME,',') FROM INFORMATION_SCHEMA.COLUMNS -- STRING_AGG(COLUMN_NAME, ', ') 
--WHERE TABLE_NAME = 'Suppliers'
--	AND TABLE_SCHEMA = 'Purchasing'


/*
2. Удалите одну запись из Customers, которая была вами добавлена
*/

DELETE  FROM [Purchasing].[SuppliersPractic]
WHERE SupplierID = 0
	AND SupplierName = 'Graphic Design Institute' 

SELECT * FROM [Purchasing].[SuppliersPractic]

/*
3. Изменить одну запись, из добавленных через UPDATE
*/

UPDATE [Purchasing].[SuppliersPractic] set SupplierID = 100
WHERE SupplierName = 'Fabrikam, Inc.' 
	AND SupplierID = 0

SELECT * FROM [Purchasing].[SuppliersPractic]

/*
4. Написать MERGE, который вставит вставит запись в клиенты, если ее там нет, и изменит если она уже есть
*/

MERGE [Purchasing].[SuppliersPractic] AS target 
	USING (
		SELECT SupplierID, SupplierName, SupplierCategoryID, PrimaryContactPersonID, AlternateContactPersonID, DeliveryMethodID, DeliveryCityID, PostalCityID, SupplierReference, BankAccountName, BankAccountBranch, BankAccountCode, BankAccountNumber, BankInternationalCode, PaymentDays, InternalComments, PhoneNumber, FaxNumber, WebsiteURL, DeliveryAddressLine1, DeliveryAddressLine2, DeliveryPostalCode, DeliveryLocation, PostalAddressLine1, PostalAddressLine2, PostalPostalCode, LastEditedBy, ValidFrom, ValidTo
		FROM [Purchasing].[Suppliers] 
		) 
		AS source (SupplierID, SupplierName, SupplierCategoryID, PrimaryContactPersonID, AlternateContactPersonID, DeliveryMethodID, DeliveryCityID, PostalCityID, SupplierReference, BankAccountName, BankAccountBranch, BankAccountCode, BankAccountNumber, BankInternationalCode, PaymentDays, InternalComments, PhoneNumber, FaxNumber, WebsiteURL, DeliveryAddressLine1, DeliveryAddressLine2, DeliveryPostalCode, DeliveryLocation, PostalAddressLine1, PostalAddressLine2, PostalPostalCode, LastEditedBy, ValidFrom, ValidTo) 
		ON
	 (target.SupplierID = source.SupplierID
		AND target.SupplierName= source.SupplierName
		) 
	WHEN MATCHED 
		THEN UPDATE SET target.SupplierID = source.SupplierID,
						target.SupplierName = source.SupplierName,
						target.SupplierCategoryID = source.SupplierCategoryID,
						target.PrimaryContactPersonID = source.PrimaryContactPersonID,
						target.AlternateContactPersonID = source.AlternateContactPersonID,
						target.DeliveryMethodID = source.DeliveryMethodID,
						target.DeliveryCityID = source.DeliveryCityID,
						target.PostalCityID = source.PostalCityID,
						target.SupplierReference = source.SupplierReference,
						target.BankAccountName = source.BankAccountName,
						target.BankAccountBranch = source.BankAccountBranch,
						target.BankAccountCode = source.BankAccountCode,
						target.BankAccountNumber = source.BankAccountNumber,
						target.BankInternationalCode = source.BankInternationalCode,
						target.PaymentDays = source.PaymentDays,
						target.InternalComments = source.InternalComments,
						target.PhoneNumber = source.PhoneNumber,
						target.FaxNumber = source.FaxNumber,
						target.WebsiteURL = source.WebsiteURL,
						target.DeliveryAddressLine1 = source.DeliveryAddressLine1,
						target.DeliveryAddressLine2 = source.DeliveryAddressLine2,
						target.DeliveryPostalCode = source.DeliveryPostalCode,
						target.DeliveryLocation = source.DeliveryLocation,
						target.PostalAddressLine1 = source.PostalAddressLine1,
						target.PostalAddressLine2 = source.PostalAddressLine2,
						target.PostalPostalCode = source.PostalPostalCode,
						target.LastEditedBy = source.LastEditedBy,
						target.ValidFrom = source.ValidFrom,
						target.ValidTo = source.ValidTo
	WHEN NOT MATCHED THEN 
		INSERT (SupplierID, SupplierName, SupplierCategoryID, PrimaryContactPersonID, AlternateContactPersonID, DeliveryMethodID, DeliveryCityID, PostalCityID, SupplierReference, BankAccountName, BankAccountBranch, BankAccountCode, BankAccountNumber, BankInternationalCode, PaymentDays, InternalComments, PhoneNumber, FaxNumber, WebsiteURL, DeliveryAddressLine1, DeliveryAddressLine2, DeliveryPostalCode, DeliveryLocation, PostalAddressLine1, PostalAddressLine2, PostalPostalCode, LastEditedBy, ValidFrom, ValidTo) 
		VALUES (SupplierID, SupplierName, SupplierCategoryID, PrimaryContactPersonID, AlternateContactPersonID, DeliveryMethodID, DeliveryCityID, PostalCityID, SupplierReference, BankAccountName, BankAccountBranch, BankAccountCode, BankAccountNumber, BankInternationalCode, PaymentDays, InternalComments, PhoneNumber, FaxNumber, WebsiteURL, DeliveryAddressLine1, DeliveryAddressLine2, DeliveryPostalCode, DeliveryLocation, PostalAddressLine1, PostalAddressLine2, PostalPostalCode, LastEditedBy, ValidFrom, ValidTo) 
	OUTPUT deleted.*, $action, inserted.*;

/*
5. Напишите запрос, который выгрузит данные через bcp out и загрузить через bulk insert
*/

-- To allow advanced options to be changed.  
EXEC sp_configure 'show advanced options', 1;  
GO  
-- To update the currently configured value for advanced options.  
RECONFIGURE;  
GO  
-- To enable the feature.  
EXEC sp_configure 'xp_cmdshell', 1;  
GO  
-- To update the currently configured value for this feature.  
RECONFIGURE;  
GO  


DROP TABLE IF EXISTS [Purchasing].[SuppliersPractic] 

SELECT  * INTO [Purchasing].[SuppliersPractic] FROM  [Purchasing].[Suppliers]

DECLARE @sname nvarchar(250) = (SELECT CONCAT('bcp "[WideWorldImporters].[Purchasing].[SuppliersPractic]" out  "E:\SQL_Developer\SuppliersPractic.txt" -T -w -t"@eu&$1&" -S','DESKTOP-NU9LQBU\SQL2017') )

exec master..xp_cmdshell @sname



TRUNCATE TABLE [Purchasing].[SuppliersPractic] 

BULK INSERT [WideWorldImporters].[Purchasing].[SuppliersPractic] 
				FROM "E:\SQL_Developer\SuppliersPractic.txt"
				WITH 
					(
					BATCHSIZE = 1000, 
					DATAFILETYPE = 'widechar',
					FIELDTERMINATOR = '@eu&$1&',
					ROWTERMINATOR ='\n',
					KEEPNULLS,
					TABLOCK        
					);

SELECT * FROM [Purchasing].[SuppliersPractic]

DROP TABLE IF EXISTS [Purchasing].[SuppliersPractic] 
