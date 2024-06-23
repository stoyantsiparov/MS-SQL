USE SoftUni

--01. Employee Address
   SELECT TOP 5
		EmployeeID,
		JobTitle,
		e.AddressID,
		AddressText
	FROM Employees AS e 
	JOIN Addresses AS a ON e.AddressID = a.AddressID
ORDER BY AddressID

--02. Addresses with Towns
   SELECT TOP 50
		FirstName,
		LastName,
		t.[Name],
		AddressText
	FROM Employees AS e 
	JOIN Addresses AS a ON e.AddressID = a.AddressID
	JOIN Towns AS t ON a.TownID = t.TownID
ORDER BY FirstName, LastName

--03. Sales Employees
   SELECT
		EmployeeID,
		FirstName,
		LastName,
		d.[Name] AS DepartmentName
	FROM Employees AS e 
	JOIN Departments AS d ON e.DepartmentID = d.DepartmentID
   WHERE d.[Name] IN ('Sales')
ORDER BY EmployeeID

--04. Employee Departments
   SELECT TOP 5
		EmployeeID,
		FirstName,
		Salary,
		d.[Name] AS DepartmentName
	FROM Employees AS e 
	JOIN Departments AS d ON e.DepartmentID = d.DepartmentID
   WHERE Salary > 15000
ORDER BY e.DepartmentID

--05. Employees Without Projects
   SELECT TOP 3 
		e.EmployeeID,
		FirstName
	 FROM Employees AS e
LEFT JOIN EmployeesProjects AS ep ON e.EmployeeID = ep.EmployeeID
	WHERE ep.EmployeeID IS NULL

--06. Employees Hired After
   SELECT
		FirstName,
		LastName,
		HireDate,
		d.[Name] AS DeptName
	FROM Employees AS e 
	JOIN Departments AS d ON e.DepartmentID = d.DepartmentID
   WHERE HireDate > '1.1.1999' AND d.[Name] IN ('Sales', 'Finance')
ORDER BY HireDate

--07. Employees With Project
  SELECT TOP 5
		e.EmployeeID,
		FirstName,
		p.[Name] AS ProjectName
    FROM Employees AS e
    JOIN EmployeesProjects AS ep ON e.EmployeeID = ep.EmployeeID
    JOIN Projects AS p ON ep.ProjectID = p.ProjectID
   WHERE StartDate > '2002.08.13' AND EndDate IS NULL
ORDER BY e.EmployeeID

--08. Employee 24
SELECT TOP 5
	e.EmployeeID,
	FirstName,
  CASE 
	WHEN p.StartDate >= '2005.01.01' THEN NULL 
	ELSE p.[Name]
END AS ProjectName
  FROM Employees AS e
  JOIN EmployeesProjects AS ep ON e.EmployeeID = ep.EmployeeID
  JOIN Projects AS p ON ep.ProjectID = p.ProjectID
 WHERE e.EmployeeID = 24

 --09. Employee Manager
  SELECT 
	  e.EmployeeID,
	  e.FirstName,
	  e.ManagerID,
	  m.FirstName AS ManagerName
    FROM Employees AS e
    JOIN Employees AS m ON e.ManagerID = m.EmployeeID
   WHERE e.ManagerID IN (3, 7)
ORDER BY e.EmployeeID

--10. Employees Summary
  SELECT TOP 50
	  e.EmployeeID,
	  CONCAT_WS(' ', e.FirstName, e.LastName) AS EmployeeName,
	  CONCAT_WS(' ', m.FirstName, m.LastName) AS ManagerName,
	  d.[Name] AS DepartmentName
    FROM Employees AS e
    JOIN Employees AS m ON e.ManagerID = m.EmployeeID
	JOIN Departments AS d ON e.DepartmentID = d.DepartmentID
ORDER BY e.EmployeeID

--11. Min Average Salary
SELECT MIN(AvrSalary) AS MinAverageSalary
  FROM 
  (
    SELECT AVG(Salary) AS AvrSalary
      FROM Employees
  GROUP BY DepartmentID
  ) AS DeptAvgSalaries

USE Geography
--12. Highest Peaks in Bulgaria
   SELECT 
	CountryCode,
	MountainRange,
	PeakName,
	Elevation
	FROM Peaks AS p
	JOIN Mountains AS m ON p.MountainId = m.Id
	JOIN MountainsCountries AS c ON m.Id = c.MountainId
   WHERE c.CountryCode = 'BG' AND Elevation > 2835
ORDER BY Elevation DESC

--13. Count Mountain Ranges
   SELECT 
	CountryCode,
	COUNT(m.Id) AS MountainRanges
    FROM Mountains AS m
    JOIN MountainsCountries AS c ON m.Id = c.MountainId
   WHERE CountryCode IN ('US', 'RU', 'BG')
GROUP BY CountryCode

--14. Countries With or Without Rivers
   SELECT TOP 5
	CountryName,
	RiverName
     FROM CountriesRivers AS cr
     JOIN Rivers AS r ON cr.RiverId = r.Id
FULL JOIN Countries AS c ON c.CountryCode = cr.CountryCode
    WHERE c.ContinentCode = 'AF'
ORDER BY c.CountryName

--15. Continents and Currencies
WITH CurrencyCounts AS (
   SELECT 
        c.ContinentCode, 
        c.CurrencyCode, 
        COUNT(*) AS CurrencyUsage
    FROM Countries AS c
GROUP BY c.ContinentCode, c.CurrencyCode
),
RankedCurrencies AS (
  SELECT 
        cc.ContinentCode,
        cc.CurrencyCode,
        cc.CurrencyUsage,
        DENSE_RANK() OVER (PARTITION BY cc.ContinentCode ORDER BY cc.CurrencyUsage DESC) AS Rank
   FROM CurrencyCounts AS cc
  WHERE cc.CurrencyUsage > 1  -- Filter out currencies used in only one country
)
  SELECT 
    rc.ContinentCode,
    rc.CurrencyCode,
    rc.CurrencyUsage
	FROM RankedCurrencies AS rc
   WHERE rc.Rank = 1
ORDER BY rc.ContinentCode

--16. Countries Without any Mountains
   SELECT 
	COUNT(*) 
	 FROM Countries AS c
LEFT JOIN MountainsCountries AS m ON c.CountryCode = m.CountryCode
	WHERE m.CountryCode IS NULL

--17. Highest Peak and Longest River by Country
    SELECT TOP 5
		CountryName,
		MAX(Elevation) AS HighestPeakElevation,
		MAX([Length]) AS LongestRiverLength
	 FROM Countries AS c
LEFT JOIN MountainsCountries AS mc ON c.CountryCode = mc.CountryCode
LEFT JOIN Mountains AS m ON mc.MountainId = m.Id
LEFT JOIN Peaks AS p ON m.Id = p.MountainId
LEFT JOIN CountriesRivers AS rc ON c.CountryCode = rc.CountryCode
LEFT JOIN Rivers AS r ON rc.RiverId = r.Id
 GROUP BY CountryName
 ORDER BY HighestPeakElevation DESC, LongestRiverLength DESC, CountryName

--18. Highest Peak Name and Elevation by Country
WITH PeaksRankedByElevation AS 
(
    SELECT
		c.CountryName,
		p.PeakName,
		p.Elevation,
		m.MountainRange,
DENSE_RANK() OVER 
			(PARTITION BY c.CountryName ORDER BY Elevation DESC) AS PeakRank
	  FROM Countries AS c
 LEFT JOIN MountainsCountries AS mc ON c.CountryCode = mc.CountryCode
 LEFT JOIN Mountains AS m ON mc.MountainId = m.Id
 LEFT JOIN Peaks AS p ON m.Id = p.MountainId
)

  SELECT TOP 5
		CountryName AS Country,
		ISNULL(PeakName, '(no highest peak)') AS [Highest Peak Name],
		ISNULL(Elevation, 0) AS [Highest Peak Elevation],
		ISNULL(MountainRange, '(no mountain)') AS Mountain
	FROM PeaksRankedByElevation
   WHERE PeakRank = 1
ORDER BY CountryName, [Highest Peak Name]