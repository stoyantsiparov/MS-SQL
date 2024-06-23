USE SoftUni

--01. Find Names of All Employees by First Name
SELECT 
	FirstName, LastName
  FROM Employees
 WHERE FirstName LIKE 'Sa%'

--02. Find Names of All Employees by Last Name
SELECT 
	FirstName, LastName
  FROM Employees
 WHERE LastName LIKE '%ei%'

--03. Find First Names of All Employees
SELECT 
	FirstName
  FROM Employees
 WHERE DepartmentID IN (3, 10) AND YEAR(HireDate) BETWEEN 1995 AND 2005

--04. Find All Employees Except Engineers
SELECT 
	FirstName, LastName
  FROM Employees
 WHERE JobTitle NOT LIKE '%engineer%'

--05. Find Towns with Name Length
   SELECT
	"Name"
	 FROM Towns
	WHERE LEN("Name") = 5 OR LEN("Name") = 6
 ORDER BY "Name" ASC

--06. Find Towns Starting With
   SELECT
	TownID, "Name"
	 FROM Towns
	WHERE  LEFT("Name", 1) IN ('M', 'K', 'B', 'E')
 ORDER BY "Name" ASC

--07. Find Towns Not Starting With
   SELECT
	TownID, "Name"
	 FROM Towns
	WHERE  LEFT("Name", 1) NOT IN ('R', 'B', 'D') 
 ORDER BY "Name" ASC

--08. Create View Employees Hired After 2000 Year
CREATE VIEW V_EmployeesHiredAfter2000 AS
	 SELECT
		FirstName, LastName
	  FROM Employees
	 WHERE YEAR(HireDate) > 2000

--09. Length of Last Name
SELECT 
	FirstName, LastName
  FROM Employees
 WHERE LEN(LastName) = 5

--10. Rank Employees by Salary
  SELECT
		EmployeeID, FirstName, LastName, Salary,
		DENSE_RANK() OVER (PARTITION BY Salary ORDER BY EmployeeID) AS "Rank"
	FROM Employees
   WHERE Salary BETWEEN 10000 AND 50000
ORDER BY Salary DESC

--11. Find All Employees with Rank 2
	 WITH RankedEmployees AS 
(
   SELECT
		EmployeeID, FirstName, LastName, Salary,
		DENSE_RANK() OVER (PARTITION BY Salary ORDER BY EmployeeID) AS "Rank"
	 FROM Employees
	WHERE Salary BETWEEN 10000 AND 50000
)
  SELECT EmployeeID, FirstName, LastName, Salary, "Rank"
	FROM RankedEmployees
   WHERE "Rank" = 2
ORDER BY Salary DESC

USE Geography
--12. Countries Holding 'A' 3 or More Times
  SELECT 
	CountryName, ISOCode
	FROM Countries
   WHERE LOWER(CountryName) LIKE '%a%a%a%'
ORDER BY ISOCode

--13. Mix of Peak and River Names
  SELECT 
	PeakName, RiverName,
    LOWER(CONCAT(SUBSTRING(PeakName, 1, LEN(PeakName)-1), RiverName)) AS Mix
	FROM 
    Peaks, Rivers
   WHERE RIGHT(PeakName, 1) = LEFT(RiverName, 1)
ORDER BY Mix

USE Diablo
--14. Games From 2011 and 2012 Year
SELECT TOP 50
	"Name",
	FORMAT("Start", 'yyyy-MM-dd') AS "Start"
  FROM Games
 WHERE YEAR("Start") IN (2011, 2012)
 ORDER BY "Start", "Name"

--15. User Email Providers
  SELECT 
	Username, 
	SUBSTRING(Email, CHARINDEX('@', Email) + 1, LEN(Email)) AS EmailProvider
    FROM Users
ORDER BY EmailProvider, Username

--16. Get Users with IP Address Like Pattern
  SELECT 
	Username, IpAddress
	FROM Users
   WHERE IpAddress LIKE '___.1_%._%.___'
ORDER BY Username

--17. Show All Games with Duration & Part of the Day
   SELECT 
		"Name" AS Game,
		CASE 
			WHEN DATEPART(HOUR, "Start") >= 0 AND DATEPART(HOUR, "Start") < 12 THEN 'Morning'
			WHEN DATEPART(HOUR, "Start") >= 12 AND DATEPART(HOUR, "Start") < 18 THEN 'Afternoon'
			WHEN DATEPART(HOUR, "Start") >= 18 AND DATEPART(HOUR, "Start") < 24 THEN 'Evening'
		END AS "Part of the Day",
		CASE 
			WHEN Duration <= 3 THEN 'Extra Short'
			WHEN Duration BETWEEN 4 AND 6 THEN 'Short'
			WHEN Duration > 6 THEN 'Long'
			ELSE 'Extra Long'
		END AS Duration
	FROM Games
ORDER BY "Name" ASC, Duration ASC, "Part of the Day" ASC

--18. Orders Table
CREATE TABLE Orders
(
	Id INT PRIMARY KEY IDENTITY,
	ProductName VARCHAR(60),
	OrderDate DATETIME2
)

INSERT INTO Orders VALUES 
('Butter', GETDATE()),
('Milk', GETDATE()),
('Honey', GETDATE())

SELECT ProductName, OrderDate,
	DATEADD(DAY, 3, OrderDate) AS "Pay Due",
	DATEADD(MONTH, 1, OrderDate) AS "Delivery Due"
  FROM Orders