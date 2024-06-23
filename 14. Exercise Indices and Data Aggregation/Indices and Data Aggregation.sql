USE Gringotts

--01. Records’ Count
SELECT COUNT(*) FROM WizzardDeposits

--02. Longest Magic Wand
SELECT MAX(MagicWandSize) AS LongestMagicWand FROM WizzardDeposits

--03. Longest Magic Wand per Deposit Groups
SELECT
	DepositGroup,
	MAX(MagicWandSize) AS LongestMagicWand
  FROM WizzardDeposits
GROUP BY DepositGroup

--04. Smallest Deposit Group Per Magic Wand Size
  SELECT TOP 2
		DepositGroup
	FROM WizzardDeposits
GROUP BY DepositGroup
ORDER BY AVG(MagicWandSize)

--05. Deposits Sum
  SELECT
	DepositGroup,
	SUM(DepositAmount) AS TotalSum
	FROM WizzardDeposits
GROUP BY DepositGroup

--06. Deposits Sum for Ollivander Family
  SELECT
	DepositGroup,
	SUM(DepositAmount) AS TotalSum
	FROM WizzardDeposits
   WHERE MagicWandCreator IN ('Ollivander Family')
GROUP BY DepositGroup

--07. Deposits Filter
  SELECT
	DepositGroup,
	SUM(DepositAmount) AS TotalSum
	FROM WizzardDeposits
   WHERE MagicWandCreator IN ('Ollivander Family')
GROUP BY DepositGroup
  HAVING SUM(DepositAmount) < 150000
ORDER BY TotalSum DESC

--08.  Deposit Charge
  SELECT
	DepositGroup,
	MagicWandCreator,
	MIN(DepositCharge) AS MinDepositCharge
	FROM WizzardDeposits
GROUP BY MagicWandCreator, DepositGroup
ORDER BY MagicWandCreator, DepositGroup

--09. Age Groups
  SELECT 
	AgeGroup, 
	COUNT(*) AS WizzardCount
	FROM 
    (SELECT 
		CASE
			WHEN Age BETWEEN 0 AND 10 THEN '[0-10]'
			WHEN Age BETWEEN 11 AND 20 THEN '[11-20]'
			WHEN Age BETWEEN 21 AND 30 THEN '[21-30]'
			WHEN Age BETWEEN 31 AND 40 THEN '[31-40]'
			WHEN Age BETWEEN 41 AND 50 THEN '[41-50]'
			WHEN Age BETWEEN 51 AND 60 THEN '[51-60]'
			ELSE '[61+]'  
		END AS AgeGroup
			FROM WizzardDeposits 
     ) AS NestedQuery
GROUP BY AgeGroup

--10. First Letter
  SELECT FirstLetter FROM 
   (
		SELECT 
			SUBSTRING(FirstName, 1, 1) AS FirstLetter
		FROM WizzardDeposits
		WHERE DepositGroup = 'Troll Chest'
    ) AS SubQuery
GROUP BY FirstLetter

--11. Average Interest
  SELECT
	DepositGroup,
	IsDepositExpired,
	AVG(DepositInterest) AS AverageInterest
	FROM WizzardDeposits
   WHERE DepositStartDate > '1985.01.01'
GROUP BY IsDepositExpired, DepositGroup
ORDER BY DepositGroup DESC, IsDepositExpired ASC

--12. *Rich Wizard, Poor Wizard
SELECT SUM("Difference") AS SumDifference
  FROM
(
SELECT 
	FirstName AS "Host Wizard",
	DepositAmount AS "Host Wizard Deposit",
	LEAD(FirstName) OVER (ORDER BY Id) AS "Guest Wizard",
	LEAD(DepositAmount) OVER (ORDER BY Id) AS "Guest Wizard Deposit",
	(DepositAmount - LEAD(DepositAmount) OVER (ORDER BY Id)) AS "Difference"
 FROM WizzardDeposits
)  AS SubQuery

USE SoftUni

--13. Departments Total Salaries
  SELECT 
	DepartmentID,
	SUM(Salary) AS TotalSalary
	FROM Employees
GROUP BY DepartmentID
ORDER BY DepartmentID

--14. Employees Minimum Salaries
  SELECT 
	DepartmentID,
	MIN(Salary) AS MinimumSalary
	FROM Employees
   WHERE DepartmentID IN (2, 5, 7) AND HireDate > '2000.01.01'
GROUP BY DepartmentID

--15. Employees Average Salaries
SELECT * INTO RichEmployees
  FROM Employees
 WHERE Salary > 30000

DELETE 
  FROM RichEmployees
 WHERE ManagerID = 42

UPDATE RichEmployees
   SET Salary = Salary + 5000
 WHERE DepartmentID = 1

  SELECT 
		DepartmentID, 
		AVG(Salary)
	FROM RichEmployees
GROUP BY DepartmentID

--16. Employees Maximum Salaries
  SELECT 
	DepartmentID,
	MAX(Salary) AS MaxSalary
	FROM Employees
GROUP BY DepartmentID
  HAVING MAX(Salary) NOT BETWEEN 30000 AND 70000

--17. Employees Count Salaries
SELECT 
	COUNT(*) AS "Count"
  FROM Employees
 WHERE ManagerID IS NULL

--18. *3rd Highest Salary
SELECT 
	DepartmentID,
	ThirRanking
  FROM
	( SELECT
		DepartmentID, 
		MAX(Salary) AS ThirRanking,
		DENSE_RANK() OVER (PARTITION BY DepartmentID ORDER BY Salary DESC) AS SalaryRanking
	    FROM Employees
	GROUP BY DepartmentID, Salary) AS SubQuery
WHERE SubQuery.SalaryRanking = 3

--19. **Salary Challenge
WITH DepartmentAvarageSalaries AS
(
	   SELECT 
			DepartmentID, 
			AVG(Salary) AS AvarageSalary
		FROM Employees
	GROUP BY DepartmentID
)
  SELECT TOP 10
		FirstName, 
		LastName, 
		e.DepartmentID
	FROM Employees AS e
	JOIN DepartmentAvarageSalaries AS das ON e.DepartmentID = das.DepartmentID
   WHERE e.Salary > das.AvarageSalary
ORDER BY e.DepartmentID