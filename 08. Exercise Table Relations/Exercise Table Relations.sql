CREATE DATABASE Demo
USE Demo

--01. One-To-One Relationship (слага се {UNIQUE FOREIGN KEY}, когато е 1 към МНОГО връзка)
CREATE TABLE Passports
(
	PassportID INT PRIMARY KEY IDENTITY(101, 1),
	PassportNumber VARCHAR(32) NOT NULL
)

CREATE TABLE Persons
(
	PersonID INT PRIMARY KEY IDENTITY(1, 1),
	FirstName VARCHAR(32) NOT NULL,
	Salary DECIMAL(10,2),
	PassportID INT UNIQUE FOREIGN KEY REFERENCES Passports(PassportID)
)

INSERT INTO Passports
	 VALUES 
		('N34FG21B'), ('K65LO4R7'), ('ZE657QP2')

INSERT INTO Persons
	 VALUES 
			('Roberto', 43300, 102),
			('Tom', 56100, 103),
			('Yana', 60200, 101)

--02. One-To-Many Relationship
CREATE TABLE Manufacturers
(
	ManufacturerID INT PRIMARY KEY IDENTITY(1, 1),
	[Name] VARCHAR(32) NOT NULL,
	EstablishedOn DATE NOT NULL
)

CREATE TABLE Models 
(
    ModelID INT PRIMARY KEY IDENTITY(101, 1),
    [Name] VARCHAR(32) NOT NULL,
    ManufacturerID INT FOREIGN KEY REFERENCES Manufacturers(ManufacturerID)
)

INSERT INTO Manufacturers ([Name], EstablishedOn) 
	 VALUES
		('BMW', '07/03/1916'),
		('Tesla', '01/01/2003'),
		('Lada', '01/05/1966')

INSERT INTO Models ([Name], ManufacturerID) 
	 VALUES
		('X1', 1),
		('i6', 1),
		('Model S', 2),
		('Model X', 2),
		('Model 3', 2),
		('Nova', 3)

--03. Many-To-Many Relationship
CREATE TABLE Students 
(
    StudentID INT PRIMARY KEY IDENTITY(1, 1),
    [Name] VARCHAR(32) NOT NULL
)

CREATE TABLE Exams 
(
    ExamID INT PRIMARY KEY IDENTITY(101, 1),
    [Name] VARCHAR(32) NOT NULL
)

CREATE TABLE StudentsExams 
(
    StudentID INT NOT NULL,
    ExamID INT NOT NULL,
  --CONSTRAINT PK_StudentsExams PRIMARY KEY(StudentID, ExamID) -> ако искам аз да сложа име на композитния ключ
    PRIMARY KEY (StudentID, ExamID),						-- композитен ключ
    FOREIGN KEY (StudentID) REFERENCES Students(StudentID), -- FOREIGN KEY(StudentID) от едната таблица Students
    FOREIGN KEY (ExamID) REFERENCES Exams(ExamID)			-- FOREIGN KEY(ExamID) от едната таблица Exams
)

INSERT INTO Students ([Name]) 
	 VALUES
		('Mila'),
		('Toni'),
		('Ron')

INSERT INTO Exams ([Name]) 
	 VALUES
		('SpringMVC'),
		('Neo4j'),
		('Oracle 11g')

INSERT INTO StudentsExams (StudentID, ExamID) 
	 VALUES
		(1, 101),
		(1, 102),
		(2, 101),
		(3, 103),
		(2, 102),
		(2, 103)

--04. Self-Referencing
CREATE TABLE Teachers 
(
    TeacherID INT PRIMARY KEY IDENTITY(101, 1),
    [Name] VARCHAR(32) NOT NULL,
    ManagerID INT,
    FOREIGN KEY (ManagerID) REFERENCES Teachers(TeacherID)
)

-- Step 2: Insert data into Teachers table
INSERT INTO Teachers ([Name], ManagerID) 
	 VALUES
		('John', NULL),
		('Maya', 106),
		('Silvia', 106),
		('Ted', 105),
		('Mark', 101),
		('Greta', 101)

--05. Online Store Database
CREATE DATABASE OnlineStore
USE OnlineStore

CREATE TABLE ItemTypes
(
	ItemTypeID INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(32) NOT NULL
)

CREATE TABLE Items
(
	ItemID INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(128) NOT NULL,
	ItemTypeID INT FOREIGN KEY REFERENCES ItemTypes(ItemTypeID)
)

CREATE TABLE Cities
(
	CityID INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(64) NOT NULL
)

CREATE TABLE Customers
(
	CustomerID INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(64) NOT NULL,
	Birthday DATETIME2,
	CityID INT FOREIGN KEY REFERENCES Cities(CityID)
)

CREATE TABLE Orders
(
	OrderID INT PRIMARY KEY IDENTITY,
	CustomerID INT FOREIGN KEY REFERENCES Customers(CustomerID)
)

-- Първи начин
CREATE TABLE OrderItems 
(
    OrderID INT NOT NULL,
    ItemID INT NOT NULL,
    PRIMARY KEY (OrderID, ItemID),
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    FOREIGN KEY (ItemID) REFERENCES Items(ItemID)
)

-- Втори начин (по-кратък вариант)
CREATE TABLE OrderItems
(
	OrderID INT FOREIGN KEY REFERENCES Orders(OrderID),
	ItemID INT FOREIGN KEY REFERENCES Items(ItemID),
	CONSTRAINT pk_orderitems PRIMARY KEY(OrderID, ItemID)
)

--06. University Database
CREATE  DATABASE Uni
USE Uni

CREATE TABLE Majors
(
	MajorID INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(64) NOT NULL
)

CREATE TABLE Students
(
	StudentID INT PRIMARY KEY IDENTITY,
	StudentNumber VARCHAR(64) NOT NULL,
	StudentName VARCHAR(64) NOT NULL,
	MajorID INT FOREIGN KEY REFERENCES Majors(MajorID)
)

CREATE TABLE Subjects
(
	SubjectID INT PRIMARY KEY IDENTITY,
	SubjectName VARCHAR(64) NOT NULL
)

CREATE TABLE Agenda
(
	StudentID INT FOREIGN KEY REFERENCES Students(StudentID),
	SubjectID INT FOREIGN KEY REFERENCES Subjects(SubjectID),
	PRIMARY KEY (StudentID, SubjectID)
)

CREATE TABLE Payments
(
	PaymentID INT PRIMARY KEY IDENTITY,
	PaymentDate DATETIME2 NOT NULL,
	PaymentAmount DECIMAL(10, 2) NOT NULL,
	StudentID INT FOREIGN KEY REFERENCES Students(StudentID)
)

--09. *Peaks in Rila
USE Geography

SELECT MountainRange, PeakName, Elevation FROM Peaks
JOIN Mountains ON Peaks.MountainId = Mountains.Id
WHERE MountainRange = 'Rila'
ORDER BY Elevation DESC