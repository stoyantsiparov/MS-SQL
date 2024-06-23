CREATE DATABASE Accounting
USE Accounting

--01. DDL
CREATE TABLE Countries
(
	Id INT PRIMARY KEY IDENTITY,
    [Name] NVARCHAR(10) NOT NULL
)

CREATE TABLE Addresses
(
	Id INT PRIMARY KEY IDENTITY,
	StreetName NVARCHAR(20) NOT NULL,
	StreetNumber INT,
	PostCode INT NOT NULL,
	City NVARCHAR(25) NOT NULL,
	CountryId INT NOT NULL,
	FOREIGN KEY (CountryId) REFERENCES Countries(Id)
)

CREATE TABLE Vendors
(
	Id INT PRIMARY KEY IDENTITY,
    [Name] NVARCHAR(25) NOT NULL,
	NumberVAT NVARCHAR(15) NOT NULL,
	AddressId INT NOT NULL,
	FOREIGN KEY (AddressId) REFERENCES Addresses(Id)
)

CREATE TABLE Clients
(
	Id INT PRIMARY KEY IDENTITY,
    [Name] NVARCHAR(25) NOT NULL,
	NumberVAT NVARCHAR(15) NOT NULL,
	AddressId INT NOT NULL,
	FOREIGN KEY (AddressId) REFERENCES Addresses(Id)
)

CREATE TABLE Categories
(
	Id INT PRIMARY KEY IDENTITY,
    [Name] NVARCHAR(10) NOT NULL
)

CREATE TABLE Products
(
	Id INT PRIMARY KEY IDENTITY,
    [Name] NVARCHAR(35) NOT NULL,
	Price DECIMAL(18,2) NOT NULL,
	CategoryId INT NOT NULL,
	VendorId INT NOT NULL,
	FOREIGN KEY (CategoryId) REFERENCES Categories(Id),
	FOREIGN KEY (VendorId) REFERENCES Vendors(Id)
)

CREATE TABLE Invoices
(
	Id INT PRIMARY KEY IDENTITY,
	Number INT NOT NULL,
	IssueDate DATETIME2 NOT NULL,
	DueDate DATETIME2 NOT NULL,
	Amount DECIMAL(18,2) NOT NULL,
	Currency NVARCHAR(5) NOT NULL,
	ClientId INT NOT NULL,
	FOREIGN KEY (ClientId) REFERENCES Clients(Id)
)

CREATE TABLE ProductsClients
(
	ProductId INT NOT NULL,
	ClientId INT NOT NULL,
	PRIMARY KEY (ProductId, ClientId),
	FOREIGN KEY (ProductId) REFERENCES Products(Id),
    FOREIGN KEY (ClientId) REFERENCES Clients(Id)
)

--02. Insert
INSERT INTO Products ([Name], Price, CategoryId, VendorId)
VALUES 
('SCANIA Oil Filter XD01', 78.69, 1, 1),
('MAN Air Filter XD01', 97.38, 1, 5),
('DAF Light Bulb 05FG87', 55.00, 2, 13),
('ADR Shoes 47-47.5', 49.85, 3, 5),
('Anti-slip pads S', 5.87, 5, 7)

INSERT INTO Invoices (Number, IssueDate, DueDate, Amount, Currency, ClientId)
VALUES 
(1219992181, '2023-03-01', '2023-04-30', 180.96, 'BGN', 3),
(1729252340, '2022-11-06', '2023-01-04', 158.18, 'EUR', 13),
(1950101013, '2023-02-17', '2023-04-18', 615.15, 'USD', 19)

--03. Update
UPDATE Invoices
   SET DueDate = '2023-04-01'
 WHERE YEAR(IssueDate) = 2022 AND MONTH(IssueDate) = 11

UPDATE Clients
   SET AddressId = 3
 WHERE [Name] LIKE '%CO%'

 --04. Delete
CREATE TABLE #ClientsToDelete (Id INT)

INSERT INTO #ClientsToDelete (Id)
SELECT Id
  FROM Clients
 WHERE NumberVAT LIKE 'IT%'

DELETE FROM Invoices
 WHERE ClientId IN (SELECT Id FROM #ClientsToDelete)

DELETE FROM ProductsClients
 WHERE ClientId IN (SELECT Id FROM #ClientsToDelete)

DELETE FROM Clients
 WHERE Id IN (SELECT Id FROM #ClientsToDelete)

DROP TABLE #ClientsToDelete

--05. Invoices by Amount and Date
  SELECT 
		Number,
		Currency
	FROM Invoices
ORDER BY Amount DESC, DueDate ASC

--06. Products by Category
  SELECT 
		p.Id,
		p.[Name],
		Price,
		c.[Name] AS CategoryName
	FROM Products AS p
	JOIN Categories AS c ON p.CategoryId = c.Id
   WHERE c.[Name] IN ('ADR', 'Others')
ORDER BY p.Price DESC

--07. Clients without Products
  SELECT 
		c.Id,
		c.[Name] AS Client,
		CONCAT(A.StreetName, ' ', A.StreetNumber, ', ', A.City, ', ', A.PostCode, ', ', cc.[Name]) AS Address
	FROM Clients AS c
	LEFT JOIN ProductsClients AS pc ON c.Id = pc.ClientId
	JOIN Addresses AS a ON c.AddressId = a.Id
	JOIN Countries AS cc ON a.CountryId = cc.Id
   WHERE pc.ClientId IS NULL
ORDER BY c.[Name]

--08. First 7 Invoices
  SELECT TOP 7
		i.Number,
		i.Amount,
		(SELECT [Name] FROM Clients WHERE Id = i.ClientId) AS Client
    FROM Invoices AS i
   WHERE (i.IssueDate < '2023-01-01' AND i.Currency = 'EUR') OR 
	     (i.Amount > 500.00 AND EXISTS (SELECT 1 FROM Clients WHERE Id = i.ClientId AND NumberVAT LIKE 'DE%'))
ORDER BY i.Number ASC, i.Amount DESC

--09. Clients with VAT
  SELECT
		c.[Name] AS Client,
		MAX(p.Price) AS Price,
		c.NumberVAT AS [VAT Number]
	FROM ProductsClients AS pc
	JOIN Clients AS c ON pc.ClientId = c.Id
	JOIN Products AS p ON pc.ProductId = p.Id
   WHERE c.[Name] NOT LIKE '%KG%'
GROUP BY c.[Name], c.NumberVAT
ORDER BY MAX(p.Price) DESC

--10. Clients by Price
  SELECT
		c.[Name] AS Client,
		FLOOR(AVG(p.Price)) AS [Average Price]
	FROM Clients AS c
	JOIN ProductsClients AS pc ON c.Id = pc.ClientId
	JOIN Products AS p ON pc.ProductId = p.Id
	JOIN Vendors AS v ON p.VendorId = v.Id
   WHERE pc.ClientId IS NOT NULL AND v.NumberVAT LIKE '%FR%'
GROUP BY c.[Name]
ORDER BY AVG(p.Price) ASC, c.[Name] DESC

--11. Product with Clients
CREATE FUNCTION udf_ProductWithClients(@name NVARCHAR(30))
RETURNS INT
AS
BEGIN
	DECLARE @totalProductClient INT = 
	(
		SELECT
			COUNT(pc.ClientId)
		FROM Products AS p
		INNER JOIN ProductsClients AS pc ON p.Id = pc.ProductId
		WHERE p.[Name] = @name
	)
	RETURN @totalProductClient
END

--12. Search for Vendors from a Specific Country
CREATE OR ALTER PROC usp_SearchByCountry(@country VARCHAR(10))
AS
	SELECT 
	    v.[Name] AS Vendor,
		v.NumberVAT AS VAT, 
		CONCAT(a.StreetName, ' ', a.StreetNumber) AS [Street Info], 
		CONCAT(a.City, ' ', a.PostCode) AS [City Info]
	FROM Vendors AS v
	JOIN Addresses AS a ON v.AddressId = a.Id
	JOIN Countries AS c ON c.Id = a.CountryId
	WHERE c.[Name] = @country
	ORDER BY v.[Name], a.City