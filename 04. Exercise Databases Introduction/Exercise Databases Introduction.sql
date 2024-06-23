--01. Create Database
CREATE DATABASE Minions

--02. Create Tables
CREATE TABLE Minions
(
	Id INT PRIMARY KEY,
	[Name] VARCHAR(50),
	Age INT,
)

CREATE TABLE Towns
(
	Id INT PRIMARY KEY,
	[Name] VARCHAR(50),
)

--03. Alter Minions Table
ALTER TABLE Minions
ADD TownId INT

ALTER TABLE Minions
ADD FOREIGN KEY (TownId) REFERENCES Towns(Id)

--04. Insert Records in Both Tables
INSERT INTO Towns VALUES 
(1, 'Sofia'),
(2, 'Plovdiv'),
(3, 'Varna')

INSERT INTO Minions(Id,[Name], Age, TownId) VALUES
(1, 'Kevin', 22, 1),
(2, 'Bob', 15, 3),
(3, 'Steward', NULL, 2)

--05. Truncate Table Minions
TRUNCATE TABLE Minions

--06. Drop All Tables
DROP TABLE Minions
DROP TABLE Towns

--07. Create Table People
CREATE TABLE People
(
	-- IDENTITY - прави програмата сама да си оправя числата на (Id) графата (почва от 1 до ...)
	Id INT PRIMARY KEY IDENTITY,
	[Name] NVARCHAR(200) NOT NULL,
	Picture VARBINARY(MAX),
	-- DECIMAL(3,2) - 3 символа, от който 2 са прецизноста
	Height DECIMAL(3,2),
	[Weight] DECIMAL(5,2),
	Gender CHAR(1) NOT NULL,
	-- CHECK(Gender in('m', 'f')) - правя ограничение, в което може стойноста да е или жена('f') или мъж('m')
		CHECK(Gender in('m', 'f')),
	Birthdate DATETIME2 NOT NULL,
	Biography VARCHAR(MAX),
)

INSERT INTO People([Name], Gender, Birthdate) VALUES
('Pesho', 'm', '2003-01-14'),
('Tosho', 'm', '1989-12-03'),
('Pesho', 'm', '2000-07-02'),
('Pesho', 'm', '1993-09-25'),
('Pesho', 'm', '1999-10-19')

--08. Create Table Users
CREATE TABLE Users
(
	-- IDENTITY - прави програмата сама да си оправя числата на (Id) графата (почва от 1 до ...)
	Id BIGINT PRIMARY KEY IDENTITY,
	Username VARCHAR(30) NOT NULL,
    [Password] VARCHAR(26) NOT NULL,
    ProfilePicture VARBINARY(MAX),
    LastLoginTime DATETIME,
	-- BIT = BOLLEAN
    IsDeleted BIT
)

INSERT INTO Users (Username, [Password]) VALUES
('user1', 'password1'),
('user2', 'password2'),
('user3', 'password3'),
('user4', 'password4'),
('user5', 'password5')

--09. Change Primary Key
-- Името на (PRIMARY KEY)-а -> PK__Users__3214EC071826209D
ALTER TABLE Users 
DROP CONSTRAINT PK__Users__3214EC071826209D

ALTER TABLE Users 
ADD PRIMARY KEY (Id, Username)

--010. Add Check Constraint
ALTER TABLE Users 
-- Създавам парола и е проверявам дали е дълга поне 5 символа
ADD CONSTRAINT CHK_PasswordIsAtLeastFiveSymbols
	CHECK(LEN(Password) >= 5)

--11. Set Default Value of a Field
ALTER TABLE Users
ADD CONSTRAINT DF_LastLoginTime DEFAULT GETDATE() FOR LastLoginTime;

--12. Set Unique Field
-- Махам (Username)-а от първичния ключ
ALTER TABLE Users 
DROP CONSTRAINT PK__Users__77222459BFA7FDB6;

-- Правя (Id)-то като единствен първичния ключ
ALTER TABLE Users 
ADD PRIMARY KEY (Id);

-- Добавям уникално условие за (Username)-а, което гарантира че ще дължината на името ще е поне 3 символа
ALTER TABLE Users
ADD CONSTRAINT UQ_Username UNIQUE (Username);

ALTER TABLE Users
ADD CONSTRAINT CHK_UsernameIsAtLeastThreeSymbols
    CHECK (LEN(Username) >= 3);

--13. Movies Database
CREATE DATABASE Movies
USE Movies

CREATE TABLE Directors (
    Id INT PRIMARY KEY IDENTITY,
    DirectorName VARCHAR(100) NOT NULL,
    Notes VARCHAR(MAX)
)

CREATE TABLE Genres (
    Id INT PRIMARY KEY IDENTITY,
    GenreName VARCHAR(50) NOT NULL,
    Notes VARCHAR(MAX)
)

CREATE TABLE Categories (
    Id INT PRIMARY KEY IDENTITY,
    CategoryName VARCHAR(50) NOT NULL,
    Notes VARCHAR(MAX)
)

CREATE TABLE Movies (
    Id INT PRIMARY KEY IDENTITY,
    Title VARCHAR(200) NOT NULL,
    DirectorId INT NOT NULL,
    CopyrightYear INT NOT NULL,
    [Length] INT NOT NULL,
    GenreId INT NOT NULL,
    CategoryId INT NOT NULL,
    Rating DECIMAL(3, 1),
    Notes VARCHAR(MAX),
    FOREIGN KEY (DirectorId) REFERENCES Directors(Id),
    FOREIGN KEY (GenreId) REFERENCES Genres(Id),
    FOREIGN KEY (CategoryId) REFERENCES Categories(Id)
)

-- Populate Directors Table
INSERT INTO Directors (DirectorName, Notes) VALUES
('Christopher Nolan', 'Famous for directing The Dark Knight trilogy'),
('Steven Spielberg', 'Renowned director known for his works like Jurassic Park'),
('Quentin Tarantino', 'Known for his unique storytelling style'),
('Martin Scorsese', 'Famous for directing classics like Goodfellas'),
('Alfred Hitchcock', 'Master of suspense and thriller films');

-- Populate Genres Table
INSERT INTO Genres (GenreName, Notes) VALUES
('Action', 'Movies with high levels of physical action or suspense'),
('Drama', 'Movies that focus on character development and interpersonal relationships'),
('Thriller', 'Movies designed to evoke excitement and tension'),
('Sci-Fi', 'Movies set in futuristic or speculative worlds'),
('Comedy', 'Movies intended to make the audience laugh');

-- Populate Categories Table
INSERT INTO Categories (CategoryName, Notes) VALUES
('Adventure', 'Movies with exciting and often dangerous journeys or exploits'),
('Crime', 'Movies centered around criminal activities and investigations'),
('Horror', 'Movies designed to evoke fear and terror in the audience'),
('Romance', 'Movies focusing on romantic relationships and love stories'),
('Fantasy', 'Movies with imaginative and fantastical elements');

-- Populate Movies Table
INSERT INTO Movies (Title, DirectorId, CopyrightYear, [Length], GenreId, CategoryId, Rating, Notes) VALUES
('Inception', 1, 2010, 148, 1, 3, 8.8, 'Mind-bending thriller directed by Christopher Nolan'),
('Jurassic Park', 2, 1993, 127, 1, 1, 8.1, 'Classic adventure film directed by Steven Spielberg'),
('Pulp Fiction', 3, 1994, 154, 3, 2, 8.9, 'Cult classic crime film directed by Quentin Tarantino'),
('Goodfellas', 4, 1990, 146, 2, 2, 8.7, 'Iconic crime drama directed by Martin Scorsese'),
('Psycho', 5, 1960, 109, 3, 3, 8.5, 'Legendary horror film directed by Alfred Hitchcock');

--14. Car Rental Database
CREATE DATABASE CarRental
USE CarRental

CREATE TABLE Categories (
    Id INT PRIMARY KEY IDENTITY,
    CategoryName VARCHAR(50) NOT NULL,
    DailyRate DECIMAL(10, 2) NOT NULL,
    WeeklyRate DECIMAL(10, 2) NOT NULL,
    MonthlyRate DECIMAL(10, 2) NOT NULL,
    WeekendRate DECIMAL(10, 2) NOT NULL
)

CREATE TABLE Cars (
    Id INT PRIMARY KEY IDENTITY,
    PlateNumber VARCHAR(20) NOT NULL,
    Manufacturer VARCHAR(50) NOT NULL,
    Model VARCHAR(50) NOT NULL,
    CarYear INT NOT NULL,
    CategoryId INT NOT NULL,
    Doors INT NOT NULL,
    Picture VARBINARY(MAX),
    Condition VARCHAR(50) NOT NULL,
    Available BIT NOT NULL,
    FOREIGN KEY (CategoryId) REFERENCES Categories(Id)
)

CREATE TABLE Employees (
    Id INT PRIMARY KEY IDENTITY,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Title VARCHAR(50) NOT NULL,
    Notes VARCHAR(MAX)
)

CREATE TABLE Customers (
    Id INT PRIMARY KEY IDENTITY,
    DriverLicenceNumber VARCHAR(50) NOT NULL,
    FullName VARCHAR(100) NOT NULL,
    Address VARCHAR(200) NOT NULL,
    City VARCHAR(50) NOT NULL,
    ZIPCode VARCHAR(10) NOT NULL,
    Notes VARCHAR(MAX)
);

CREATE TABLE RentalOrders (
    Id INT PRIMARY KEY IDENTITY,
    EmployeeId INT NOT NULL,
    CustomerId INT NOT NULL,
    CarId INT NOT NULL,
    TankLevel DECIMAL(3, 1) NOT NULL,
    KilometrageStart INT NOT NULL,
    KilometrageEnd INT NOT NULL,
    TotalKilometrage AS (KilometrageEnd - KilometrageStart) PERSISTED,
    StartDate DATE NOT NULL,
    EndDate DATE NOT NULL,
    TotalDays AS (DATEDIFF(DAY, StartDate, EndDate) + 1) PERSISTED,
    RateApplied DECIMAL(10, 2) NOT NULL,
    TaxRate DECIMAL(5, 2) NOT NULL,
    OrderStatus VARCHAR(50) NOT NULL,
    Notes VARCHAR(MAX),
    FOREIGN KEY (EmployeeId) REFERENCES Employees(Id),
    FOREIGN KEY (CustomerId) REFERENCES Customers(Id),
    FOREIGN KEY (CarId) REFERENCES Cars(Id)
)

-- Populate Categories Table
INSERT INTO Categories (CategoryName, DailyRate, WeeklyRate, MonthlyRate, WeekendRate) VALUES
('Economy', 30.00, 180.00, 700.00, 100.00),
('SUV', 50.00, 300.00, 1200.00, 150.00),
('Luxury', 100.00, 600.00, 2400.00, 300.00);

-- Populate Cars Table
INSERT INTO Cars (PlateNumber, Manufacturer, Model, CarYear, CategoryId, Doors, Picture, Condition, Available) VALUES
('ABC123', 'Toyota', 'Corolla', 2020, 1, 4, NULL, 'Excellent', 1),
('XYZ789', 'Ford', 'Explorer', 2019, 2, 4, NULL, 'Good', 1),
('LMN456', 'BMW', '5 Series', 2021, 3, 4, NULL, 'Excellent', 1);

-- Populate Employees Table
INSERT INTO Employees (FirstName, LastName, Title, Notes) VALUES
('John', 'Doe', 'Manager', 'Oversees operations'),
('Jane', 'Smith', 'Assistant Manager', 'Assists with daily tasks'),
('Jim', 'Brown', 'Clerk', 'Handles customer queries');

-- Populate Customers Table
INSERT INTO Customers (DriverLicenceNumber, FullName, Address, City, ZIPCode, Notes) VALUES
('DL12345', 'Alice Johnson', '123 Maple St', 'Springfield', '12345', 'Frequent renter'),
('DL67890', 'Bob Williams', '456 Oak St', 'Shelbyville', '67890', 'Prefers SUVs'),
('DL11223', 'Charlie Davis', '789 Pine St', 'Capital City', '11223', 'Likes luxury cars');

-- Populate RentalOrders Table
INSERT INTO RentalOrders (EmployeeId, CustomerId, CarId, TankLevel, KilometrageStart, KilometrageEnd, StartDate, EndDate, RateApplied, TaxRate, OrderStatus, Notes) VALUES
(1, 1, 1, 0.9, 10000, 10200, '2024-05-01', '2024-05-10', 30.00, 10.00, 'Completed', 'No issues'),
(2, 2, 2, 0.8, 20000, 20250, '2024-05-05', '2024-05-12', 50.00, 10.00, 'Completed', 'Customer reported minor issues'),
(3, 3, 3, 1.0, 5000, 5200, '2024-05-08', '2024-05-15', 100.00, 10.00, 'Ongoing', 'Rental in progress');

--15. Hotel Database
CREATE DATABASE Hotel
USE Hotel

CREATE TABLE Employees (
    Id INT PRIMARY KEY IDENTITY,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Title VARCHAR(50) NOT NULL,
    Notes VARCHAR(MAX)
)

CREATE TABLE Customers (
    AccountNumber INT PRIMARY KEY IDENTITY,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    PhoneNumber VARCHAR(15) NOT NULL,
    EmergencyName VARCHAR(50),
    EmergencyNumber VARCHAR(15),
    Notes VARCHAR(MAX)
)

CREATE TABLE RoomStatus (
    RoomStatus VARCHAR(50) PRIMARY KEY,
    Notes VARCHAR(MAX)
)

CREATE TABLE RoomTypes (
    RoomType VARCHAR(50) PRIMARY KEY,
    Notes VARCHAR(MAX)
)

CREATE TABLE BedTypes (
    BedType VARCHAR(50) PRIMARY KEY,
    Notes VARCHAR(MAX)
)

CREATE TABLE Rooms (
    RoomNumber INT PRIMARY KEY,
    RoomType VARCHAR(50) NOT NULL,
    BedType VARCHAR(50) NOT NULL,
    Rate DECIMAL(10, 2) NOT NULL,
    RoomStatus VARCHAR(50) NOT NULL,
    Notes VARCHAR(MAX),
    FOREIGN KEY (RoomType) REFERENCES RoomTypes(RoomType),
    FOREIGN KEY (BedType) REFERENCES BedTypes(BedType),
    FOREIGN KEY (RoomStatus) REFERENCES RoomStatus(RoomStatus)
)

CREATE TABLE Payments (
    Id INT PRIMARY KEY IDENTITY,
    EmployeeId INT NOT NULL,
    PaymentDate DATE NOT NULL,
    AccountNumber INT NOT NULL,
    FirstDateOccupied DATE NOT NULL,
    LastDateOccupied DATE NOT NULL,
    TotalDays AS (DATEDIFF(DAY, FirstDateOccupied, LastDateOccupied) + 1),
    AmountCharged DECIMAL(10, 2) NOT NULL,
    TaxRate DECIMAL(5, 2) NOT NULL,
    TaxAmount AS (AmountCharged * TaxRate / 100),
    PaymentTotal AS (AmountCharged + (AmountCharged * TaxRate / 100)),
    Notes VARCHAR(MAX),
    FOREIGN KEY (EmployeeId) REFERENCES Employees(Id),
    FOREIGN KEY (AccountNumber) REFERENCES Customers(AccountNumber)
)

CREATE TABLE Occupancies (
    Id INT PRIMARY KEY IDENTITY,
    EmployeeId INT NOT NULL,
    DateOccupied DATE NOT NULL,
    AccountNumber INT NOT NULL,
    RoomNumber INT NOT NULL,
    RateApplied DECIMAL(10, 2) NOT NULL,
    PhoneCharge DECIMAL(10, 2),
    Notes VARCHAR(MAX),
    FOREIGN KEY (EmployeeId) REFERENCES Employees(Id),
    FOREIGN KEY (AccountNumber) REFERENCES Customers(AccountNumber),
    FOREIGN KEY (RoomNumber) REFERENCES Rooms(RoomNumber)
)

-- Populate Employees Table
INSERT INTO Employees (FirstName, LastName, Title, Notes) VALUES
('John', 'Doe', 'Manager', 'Oversees operations'),
('Jane', 'Smith', 'Assistant Manager', 'Assists with daily tasks'),
('Jim', 'Brown', 'Clerk', 'Handles customer queries');

-- Populate Customers Table
INSERT INTO Customers (FirstName, LastName, PhoneNumber, EmergencyName, EmergencyNumber, Notes) VALUES
('Alice', 'Johnson', '123-456-7890', 'Bob Johnson', '098-765-4321', 'Frequent guest'),
('Bob', 'Williams', '234-567-8901', 'Alice Williams', '876-543-2109', 'Prefers quiet rooms'),
('Charlie', 'Davis', '345-678-9012', 'David Davis', '765-432-1098', 'Likes ocean view');

-- Populate RoomStatus Table
INSERT INTO RoomStatus (RoomStatus, Notes) VALUES
('Available', 'Room is available for booking'),
('Occupied', 'Room is currently occupied'),
('Maintenance', 'Room is under maintenance');

-- Populate RoomTypes Table
INSERT INTO RoomTypes (RoomType, Notes) VALUES
('Single', 'Single room with one bed'),
('Double', 'Double room with two beds'),
('Suite', 'Suite with multiple rooms and amenities');

-- Populate BedTypes Table
INSERT INTO BedTypes (BedType, Notes) VALUES
('Twin', 'Two small single beds'),
('Queen', 'One queen-size bed'),
('King', 'One king-size bed');

-- Populate Rooms Table
INSERT INTO Rooms (RoomNumber, RoomType, BedType, Rate, RoomStatus, Notes) VALUES
(101, 'Single', 'Queen', 100.00, 'Available', 'Nice view'),
(102, 'Double', 'Twin', 150.00, 'Occupied', 'Near elevator'),
(103, 'Suite', 'King', 300.00, 'Maintenance', 'Requires cleaning');

-- Populate Payments Table
INSERT INTO Payments (EmployeeId, PaymentDate, AccountNumber, FirstDateOccupied, LastDateOccupied, AmountCharged, TaxRate, Notes) VALUES
(1, '2024-05-01', 1, '2024-04-25', '2024-04-30', 500.00, 10.00, 'Paid in full'),
(2, '2024-05-05', 2, '2024-04-26', '2024-05-01', 750.00, 10.00, 'Discount applied'),
(3, '2024-05-10', 3, '2024-05-01', '2024-05-07', 2100.00, 10.00, 'Late checkout fee included');

-- Populate Occupancies Table
INSERT INTO Occupancies (EmployeeId, DateOccupied, AccountNumber, RoomNumber, RateApplied, PhoneCharge, Notes) VALUES
(1, '2024-04-25', 1, 101, 100.00, 10.00, 'Checked in late'),
(2, '2024-04-26', 2, 102, 150.00, 20.00, 'Requested early check-in'),
(3, '2024-05-01', 3, 103, 300.00, 0.00, 'Special request for maintenance');


--16. Create SoftUni Database
CREATE DATABASE SoftUni
USE SoftUni

CREATE TABLE Towns (
    Id INT PRIMARY KEY IDENTITY(1,1),
    [Name] VARCHAR(100) NOT NULL
)

CREATE TABLE Addresses (
    Id INT PRIMARY KEY IDENTITY(1,1),
    AddressText VARCHAR(200) NOT NULL,
    TownId INT NOT NULL,
    FOREIGN KEY (TownId) REFERENCES Towns(Id)
)

CREATE TABLE Departments (
    Id INT PRIMARY KEY IDENTITY(1,1),
    [Name] VARCHAR(100) NOT NULL
)

CREATE TABLE Employees (
    Id INT PRIMARY KEY IDENTITY(1,1),
    FirstName VARCHAR(50) NOT NULL,
    MiddleName VARCHAR(50),
    LastName VARCHAR(50) NOT NULL,
    JobTitle VARCHAR(100) NOT NULL,
    DepartmentId INT NOT NULL,
    HireDate DATE NOT NULL,
    Salary DECIMAL(10, 2) NOT NULL,
    AddressId INT,
    FOREIGN KEY (DepartmentId) REFERENCES Departments(Id),
    FOREIGN KEY (AddressId) REFERENCES Addresses(Id)
)

-- Insert sample data into Towns Table
INSERT INTO Towns ([Name]) VALUES
('Sofia'),
('Plovdiv'),
('Varna'),
('Burgas'),
('Ruse');

-- Insert sample data into Addresses Table
INSERT INTO Addresses (AddressText, TownId) VALUES
('123 Main St', 1),
('456 Oak St', 2),
('789 Pine St', 3),
('101 Maple St', 4),
('202 Elm St', 5);

-- Insert sample data into Departments Table
INSERT INTO Departments ([Name]) VALUES
('Engineering'),
('HR'),
('Finance'),
('Marketing'),
('Sales');

-- Insert sample data into Employees Table
INSERT INTO Employees (FirstName, MiddleName, LastName, JobTitle, DepartmentId, HireDate, Salary, AddressId) VALUES
('John', 'A', 'Doe', 'Software Engineer', 1, '2022-01-01', 60000.00, 1),
('Jane', 'B', 'Smith', 'HR Manager', 2, '2021-02-01', 55000.00, 2),
('Jim', 'C', 'Brown', 'Accountant', 3, '2020-03-01', 52000.00, 3),
('Jill', 'D', 'Johnson', 'Marketing Specialist', 4, '2019-04-01', 48000.00, 4),
('Jack', 'E', 'Williams', 'Sales Representative', 5, '2018-05-01', 45000.00, 5);

--17. Backup Database
BACKUP DATABASE SoftUni 
TO DISK = 'C:\backups\softuni-backup.bak' 
WITH FORMAT, 
MEDIANAME = 'SoftUniBackup', 
NAME = 'Full Backup of SoftUni';

--18. Basic Insert

INSERT INTO Towns (Name) VALUES
('Sofia'),
('Plovdiv'),
('Varna'),
('Burgas');

INSERT INTO Departments (Name) VALUES
('Engineering'),
('Sales'),
('Marketing'),
('Software Development'),
('Quality Assurance');

INSERT INTO Employees (FirstName, MiddleName, LastName, JobTitle, DepartmentId, HireDate, Salary) VALUES
('Ivan', 'Ivanov', 'Ivanov', '.NET Developer', 1, '2013-02-01', 3500.00),
('Petar', 'Petrov', 'Petrov', 'Senior Engineer', 2, '2004-03-02', 4000.00),
('Maria', 'Petrova', 'Ivanova', 'Intern', 3, '2016-08-28', 525.25),
('Georgi', 'Teziev', 'Ivanov', 'CEO', 4, '2007-12-09', 3000.00),
('Peter', 'Pan', 'Pan', 'Intern', 5, '2016-08-28', 599.88);

--19. Basic Select All Fields
SELECT * FROM Towns

SELECT * FROM Departments

SELECT * FROM Employees

--20. Basic Select All Fields and Order Them
-- Подреждам имената им по азбучен ред
SELECT * FROM Towns ORDER BY [Name]

-- Подреждам отделите им по азбучен ред
SELECT * FROM Departments ORDER BY [Name]

-- Подреждам заплатите им по низходящ ред
SELECT * FROM Employees ORDER BY Salary DESC

--21. Basic Select Some Fields
-- Избирам колоната [Name] от таблицата с градове[Towns] и ги подреждам по азбучен ред
SELECT [Name] FROM Towns ORDER BY Name

-- Избирам колоната [Name] от таблицата отдели[Departments] и ги подреждам по азбучен ред
SELECT [Name] FROM Departments ORDER BY Name

-- Избирам колоните [FirstName], [LastName], [JobTitle] и [Salary] от таблицата служители[Employees] и ги подреждам в низходящ ред по заплата
SELECT FirstName, LastName, JobTitle, Salary FROM Employees ORDER BY Salary DESC

--22. Increase Employee Salaries
UPDATE Employees
SET Salary = Salary * 1.1
SELECT Salary FROM Employees

--23. Decrease Tax Rate
UPDATE Payments
SET TaxRate = TaxRate * 0.97
SELECT TaxRate FROM Payments

--24. Delete All Records
USE Hotel
TRUNCATE TABLE Occupancies