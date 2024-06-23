CREATE DATABASE TouristAgency
USE TouristAgency

--01. DDL
CREATE TABLE Countries 
(
    Id INT PRIMARY KEY IDENTITY,
    [Name] NVARCHAR(50) NOT NULL
)

CREATE TABLE Destinations  
(
    Id INT PRIMARY KEY IDENTITY,
    [Name] NVARCHAR(50) NOT NULL,
    CountryId INT NOT NULL,
    FOREIGN KEY (CountryId) REFERENCES Countries(Id)
)

CREATE TABLE Tourists   
(
    Id INT PRIMARY KEY IDENTITY,
    [Name] NVARCHAR(80) NOT NULL,
	PhoneNumber VARCHAR(20) NOT NULL,
	Email VARCHAR(80),
    CountryId INT NOT NULL,
    FOREIGN KEY (CountryId) REFERENCES Countries(Id)
)

CREATE TABLE Hotels   
(
    Id INT PRIMARY KEY IDENTITY,
    [Name] NVARCHAR(50) NOT NULL,
    DestinationId INT NOT NULL,
    FOREIGN KEY (DestinationId) REFERENCES Destinations(Id)
)

CREATE TABLE Rooms 
(
    Id INT PRIMARY KEY IDENTITY,
    [Type] NVARCHAR(40) NOT NULL,
    Price DECIMAL(18, 2) NOT NULL,
    BedCount INT NOT NULL CHECK (BedCount BETWEEN 0 AND 10)
)

CREATE TABLE HotelsRooms 
(
    HotelId INT NOT NULL,
    RoomId INT NOT NULL,
    PRIMARY KEY (HotelId, RoomId),
    FOREIGN KEY (HotelId) REFERENCES Hotels(Id),
    FOREIGN KEY (RoomId) REFERENCES Rooms(Id)
)

CREATE TABLE Bookings 
(
    Id INT PRIMARY KEY IDENTITY,
    ArrivalDate DATETIME2 NOT NULL,
    DepartureDate DATETIME2 NOT NULL,
    AdultsCount INT NOT NULL CHECK (AdultsCount BETWEEN 1 AND 10),
    ChildrenCount INT NOT NULL CHECK (ChildrenCount BETWEEN 0 AND 9),
    TouristId INT NOT NULL,
    HotelId INT NOT NULL,
    RoomId INT NOT NULL,
    FOREIGN KEY (TouristId) REFERENCES Tourists(Id),
    FOREIGN KEY (HotelId) REFERENCES Hotels(Id),
    FOREIGN KEY (RoomId) REFERENCES Rooms(Id)
)

--02. Insert
INSERT INTO Tourists ([Name], PhoneNumber, Email, CountryId) VALUES
('John Rivers', '653-551-1555', 'john.rivers@example.com', 6),
('Adeline Aglaé', '122-654-8726', 'adeline.aglae@example.com', 2),
('Sergio Ramirez', '233-465-2876', 's.ramirez@example.com', 3),
('Johan Müller', '322-876-9826', 'j.muller@example.com', 7),
('Eden Smith', '551-874-2234', 'eden.smith@example.com', 6)

INSERT INTO Bookings (ArrivalDate, DepartureDate, AdultsCount, ChildrenCount, TouristId, HotelId, RoomId) VALUES
('2024-03-01', '2024-03-11', 1, 0, 21, 3, 5),
('2023-12-28', '2024-01-06', 2, 1, 22, 13, 3),
('2023-11-15', '2023-11-20', 1, 2, 23, 19, 7),
('2023-12-05', '2023-12-09', 4, 0, 24, 6, 4),
('2024-05-01', '2024-05-07', 6, 0, 25, 14, 6)

--03. Update
UPDATE Bookings
   SET DepartureDate = DATEADD(DAY, 1, DepartureDate)
 WHERE ArrivalDate >= '2023-12-01' AND ArrivalDate < '2024-01-01'

UPDATE Tourists
   SET Email = NULL
 WHERE UPPER(Name) LIKE '%MA%'

--04. Delete
DECLARE @TouristIds TABLE (Id INT)

INSERT INTO @TouristIds (Id)
SELECT Id
  FROM Tourists
 WHERE [Name] LIKE '%Smith%'

DELETE FROM Bookings
 WHERE TouristId IN (SELECT Id FROM @TouristIds)

DELETE FROM Tourists
 WHERE Id IN (SELECT Id FROM @TouristIds)

--05. Bookings by Price of Room and Arrival Date
SELECT 
	FORMAT(ArrivalDate, 'yyyy-MM-dd') AS ArrivalDate,
	AdultsCount,
	ChildrenCount
  FROM Rooms AS r 
  JOIN Bookings AS b ON r.Id = b.RoomId
ORDER BY Price DESC, ArrivalDate ASC

--06. Hotels by Count of Bookings
  SELECT 
		h.Id,
		h.[Name]
	FROM Hotels AS h
	JOIN HotelsRooms AS hr ON hr.HotelId = h.Id
	JOIN Rooms AS r ON r.Id = hr.RoomId
	JOIN Bookings AS b ON b.HotelId = h.Id
   WHERE r.[Type] = 'VIP Apartment'
GROUP BY h.Id, h.[Name]
ORDER BY COUNT(*) DESC

--07. Tourists without Bookings
  SELECT 
		Id,
		[Name],
		PhoneNumber
	FROM Tourists
   WHERE Id NOT IN (SELECT TouristId FROM Bookings)
ORDER BY [Name] ASC

--08. First 10 Bookings
  SELECT TOP 10
		h.[Name] AS HotelName,
		d.[Name] AS DestinationName,
		c.[Name] AS CountryName
	FROM Bookings AS b
	JOIN Hotels AS h ON b.HotelId = h.Id AND h.Id % 2 <> 0
	JOIN Destinations AS d ON h.DestinationId = d.Id
	JOIN Countries AS c ON d.CountryId = c.Id
   WHERE b.ArrivalDate < '2023-12-31'
ORDER BY c.[Name], b.ArrivalDate

--09. Tourists booked in Hotels
  SELECT 
		h.[Name] AS HotelName,
		Price AS RoomPrice
	FROM Tourists AS t
	JOIN Bookings AS b ON t.Id = b.TouristId
	JOIN Hotels AS h ON b.HotelId = h.Id
	JOIN Rooms AS r ON b.RoomId = r.Id
   WHERE t.[Name] NOT LIKE '%EZ'
ORDER BY r.Price DESC

--10. Hotels Revenue
   SELECT
		h.[Name] AS HotelName,
		SUM(DATEDIFF(DAY, ArrivalDate, DepartureDate) * Price) AS TotalRevenue
	FROM Bookings b
	JOIN Hotels h ON b.HotelId = h.Id
	JOIN Rooms r ON b.RoomId = r.Id
GROUP BY h.[Name]
ORDER BY TotalRevenue DESC

--11. Rooms with Tourists
CREATE FUNCTION udf_RoomsWithTourists(@name NVARCHAR(40))
RETURNS INT
AS
BEGIN
    DECLARE @TotalTourists INT

    SELECT @TotalTourists = SUM(AdultsCount + ChildrenCount)
      FROM Bookings b
      JOIN Rooms r ON b.RoomId = r.Id
     WHERE r.[Type] = @name

    RETURN ISNULL(@TotalTourists, 0)
END

--12. Search for Tourists from a Specific Country
CREATE OR ALTER PROCEDURE usp_SearchByCountry(@country NVARCHAR(50))
	   AS 
   SELECT 
		t.[Name],
		t.PhoneNumber,
		t.Email,
		COUNT(b.Id) AS CountOfBookings
	FROM Tourists AS t
	JOIN Bookings AS b ON t.Id = b.TouristId
	JOIN Countries AS c ON t.CountryId = c.Id
   WHERE c.[Name] = @country
GROUP BY t.[Name], t.PhoneNumber, t.Email
ORDER BY t.[Name] ASC, COUNT(b.Id) DESC