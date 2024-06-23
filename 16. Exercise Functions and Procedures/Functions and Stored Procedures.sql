USE SoftUni

--01. Employees with Salary Above 35000
CREATE PROCEDURE usp_GetEmployeesSalaryAbove35000 
	AS
SELECT 
	FirstName,
	LastName
  FROM Employees
 WHERE Salary > 35000

--02. Employees with Salary Above Number
CREATE PROCEDURE usp_GetEmployeesSalaryAboveNumber(@salaryAvoveNumber DECIMAL (18, 4))
	AS 
SELECT 
	FirstName,
	LastName
  FROM Employees
 WHERE Salary >= @salaryAvoveNumber

--03. Town Names Starting With
CREATE OR ALTER PROCEDURE usp_GetTownsStartingWith(@townNamesStarting NVARCHAR(50))
	AS
SELECT [Name]
  FROM Towns
 WHERE [Name] LIKE @townNamesStarting + '%'

--04. Employees from Town
CREATE OR ALTER PROCEDURE usp_GetEmployeesFromTown(
	@townNames NVARCHAR(50))
	AS
SELECT 
	FirstName,
	LastName
  FROM Employees AS e
  JOIN Addresses AS a ON e.AddressID = a.AddressID
  JOIN Towns AS t ON a.TownID = t.TownID
 WHERE t.[Name] = @townNames

--05. Salary Level Function
 CREATE OR ALTER FUNCTION  dbo.ufn_GetSalaryLevel(@salary DECIMAL(18,4))
RETURNS NVARCHAR(10)
	 AS
  BEGIN
	DECLARE @SalaryLevel NVARCHAR(10)
	SET @SalaryLevel = 
		CASE
			WHEN @salary < 30000 THEN 'Low'
			WHEN @salary BETWEEN 30000 AND 50000 THEN 'Average'
			WHEN @salary > 50000 THEN 'High'
		END
	RETURN @SalaryLevel
	END

--06. Employees by Salary Level
CREATE OR ALTER PROCEDURE usp_EmployeesBySalaryLevel(@salaryLevel NVARCHAR(10))
	AS
SELECT 
	FirstName,
	LastName
  FROM Employees
 WHERE dbo.ufn_GetSalaryLevel(Salary) = @salaryLevel

--07. Define Function
 CREATE OR ALTER FUNCTION  dbo.ufn_IsWordComprised
(
    @setOfLetters NVARCHAR(100),
    @word NVARCHAR(100)
)
RETURNS BIT
	 AS
  BEGIN
    DECLARE @result BIT = 1 --Инициализирам резултата като вярно (1)

    DECLARE @len INT = LEN(@word)
    DECLARE @i INT = 1;

		WHILE @i <= @len
		BEGIN
			DECLARE @char NVARCHAR(1) = LOWER(SUBSTRING(@word, @i, 1)) --Конвертирам символа в малки букви за безразлично към главни и малки букви сравнение
			IF CHARINDEX(@char, @setOfLetters) = 0
			BEGIN
				SET @result = 0 --Задавам резултата като грешно (0), ако символът не се намира в множеството от букви
				BREAK
			END
			SET @i = @i + 1
		END

		RETURN @result
    END

--08. *Delete Employees and Departments
CREATE OR ALTER PROCEDURE usp_DeleteEmployeesFromDepartment(@departmentId INT) 
    AS
		DECLARE @employeesToDelete TABLE ([Id] INT)
		--1. Запазвам данните за изтритите работници
		INSERT INTO @employeesToDelete
			SELECT EmployeeID
			  FROM Employees
			 WHERE [DepartmentID] = @departmentId
		
		--2. Премахвам работниците от EmployeesProjects
			DELETE FROM EmployeesProjects
			 WHERE EmployeeID IN (SELECT * FROM @employeesToDelete)

		--3. Правя ManagerID и Departments nullable
			ALTER TABLE Departments
			ALTER COLUMN [ManagerID] INT

		--4. Правя стойноста на ManagerID в Departments да е равна на NULL
			UPDATE Departments
			   SET ManagerID = NULL
			 WHERE ManagerID IN (SELECT * FROM @employeesToDelete)

		--5. Слагам ManagerID-то на работниците да е равно на NULL
			UPDATE Employees
			   SET ManagerID = NULL
			 WHERE ManagerID IN (SELECT * FROM @employeesToDelete)
			
			DELETE FROM Employees
			 WHERE DepartmentID = @departmentId
			
			DELETE FROM Departments
			 WHERE DepartmentID = @departmentId
			
			SELECT COUNT(*)
			  FROM Employees
			 WHERE DepartmentID = @departmentId
USE Bank

--09. Find Full Name
CREATE OR ALTER PROCEDURE usp_GetHoldersFullName
	AS
    SELECT 
		CONCAT(FirstName, ' ', LastName) AS FullName
      FROM AccountHolders

--10. People with Balance Higher Than
CREATE OR ALTER PROCEDURE usp_GetHoldersWithBalanceHigherThan(@balanceHigherThan DECIMAL (18, 4))
	AS
    SELECT 
		FirstName,
		LastName
      FROM AccountHolders AS ah
	  JOIN Accounts AS a ON ah.Id = a.AccountHolderId
  GROUP BY ah.Id, FirstName, LastName
    HAVING SUM(a.Balance) > @balanceHigherThan
  ORDER BY FirstName, LastName

--11. Future Value Function
CREATE OR ALTER FUNCTION dbo.ufn_CalculateFutureValue
(
    @initialSum DECIMAL(18, 4),
    @yearlyInterestRate FLOAT,
    @numberOfYears INT
)
RETURNS DECIMAL(18, 4)
	 AS
  BEGIN
		DECLARE @futureValue DECIMAL(18, 4);

		--FV = I × (1 + R)^T
		SET @futureValue = @initialSum * POWER((1 + @yearlyInterestRate), @numberOfYears);
		SET @futureValue = ROUND(@futureValue, 4);

		RETURN @futureValue
    END

--12. Calculating Interest
CREATE OR ALTER PROCEDURE usp_CalculateFutureValueForAccount
    @AccountId INT,
    @interestRate FLOAT
   AS
	  DECLARE @FirstName NVARCHAR(50)
      DECLARE @LastName NVARCHAR(50)
      DECLARE @CurrentBalance DECIMAL(18, 4)

       SELECT @FirstName = FirstName,
           @LastName = LastName,
           @CurrentBalance = Balance
        FROM AccountHolders ah
        JOIN Accounts a ON ah.Id = a.AccountHolderId
       WHERE a.Id = @AccountId

     DECLARE @FutureValue DECIMAL(18, 4)
         SET @FutureValue = dbo.ufn_CalculateFutureValue(@CurrentBalance, @interestRate, 5)

      SELECT @AccountId AS AccountId,
             @FirstName AS FirstName,
             @LastName AS LastName,
             @CurrentBalance AS CurrentBalance,
             @FutureValue AS FutureBalance

USE Diablo

--13. *Cash in User Games Odd Rows
CREATE OR ALTER FUNCTION ufn_CashInUsersGames(@gameName NVARCHAR(100))
RETURNS TABLE
AS
RETURN
(
    SELECT SUM(Cash) AS SumCash
    FROM (
        SELECT Cash, ROW_NUMBER() OVER (ORDER BY Cash DESC) AS RowNum
          FROM Games AS g
		  JOIN UsersGames AS ug ON ug.GameId = g.Id
         WHERE g.[Name] = @gameName
    ) AS RankedData
    WHERE RowNum % 2 <> 0
)