CREATE DATABASE RailwaysDb
USE RailwaysDb

--01. DDL
CREATE TABLE Passengers
(
	Id INT PRIMARY KEY IDENTITY,
    [Name] NVARCHAR(80) NOT NULL
)

CREATE TABLE Towns
(
	Id INT PRIMARY KEY IDENTITY,
    [Name] NVARCHAR(30) NOT NULL
)

CREATE TABLE RailwayStations
(
	Id INT PRIMARY KEY IDENTITY,
    [Name] NVARCHAR(50) NOT NULL,
	TownId INT NOT NULL,
	FOREIGN KEY (TownId) REFERENCES Towns(Id)
)

CREATE TABLE Trains
(
	Id INT PRIMARY KEY IDENTITY,
    HourOfDeparture NVARCHAR(5) NOT NULL,
	HourOfArrival NVARCHAR(5) NOT NULL,
	DepartureTownId INT NOT NULL,
	ArrivalTownId INT NOT NULL,
	FOREIGN KEY (DepartureTownId) REFERENCES Towns(Id),
	FOREIGN KEY (ArrivalTownId) REFERENCES Towns(Id)
)

CREATE TABLE TrainsRailwayStations
(
	TrainId INT NOT NULL,
    RailwayStationId INT NOT NULL,
	PRIMARY KEY (TrainId, RailwayStationId),
	FOREIGN KEY (TrainId) REFERENCES Trains(Id),
    FOREIGN KEY (RailwayStationId) REFERENCES RailwayStations(Id)
)

CREATE TABLE MaintenanceRecords
(
	Id INT PRIMARY KEY IDENTITY,
    DateOfMaintenance DATE NOT NULL,
	Details NVARCHAR(2000) NOT NULL,
	TrainId INT NOT NULL,
	FOREIGN KEY (TrainId) REFERENCES Trains(Id)
)

CREATE TABLE Tickets
(
	Id INT PRIMARY KEY IDENTITY,
    Price DECIMAL (10, 2) NOT NULL,
	DateOfDeparture DATE NOT NULL,
	DateOfArrival DATE NOT NULL,
	TrainId INT NOT NULL,
	PassengerId INT NOT NULL,
	FOREIGN KEY (TrainId) REFERENCES Trains(Id),
	FOREIGN KEY (PassengerId) REFERENCES Passengers(Id)
)

--02. Insert
INSERT INTO Trains (HourOfDeparture, HourOfArrival, DepartureTownId, ArrivalTownId)
VALUES
('07:00', '19:00', 1, 3),
('08:30', '20:30', 5, 6),
('09:00', '21:00', 4, 8),
('06:45', '03:55', 27, 7),
('10:15', '12:15', 15, 5)

INSERT INTO TrainsRailwayStations (TrainId, RailwayStationId)
VALUES
(36, 1), (36, 4), (36, 31), (36, 57), (36, 7),
(37, 60), (37, 16), (37, 13), (37, 54),
(38, 10), (38, 50), (38, 52), (38, 22),
(39, 3), (39, 31), (39, 19), (39, 68),
(40, 41), (40, 7), (40, 52), (40, 13)

INSERT INTO Tickets (Price, DateOfDeparture, DateOfArrival, TrainId, PassengerId)
VALUES
(90.00, '2023-12-01', '2023-12-01', 36, 1),
(115.00, '2023-08-02', '2023-08-02', 37, 2),
(160.00, '2023-08-03', '2023-08-03', 38, 3),
(255.00, '2023-09-01', '2023-09-02', 39, 21),
(95.00, '2023-09-02', '2023-09-03', 40, 22)

--03. Update
UPDATE Tickets
   SET DateOfDeparture = DATEADD(DAY, 7, DateOfDeparture), DateOfArrival = DATEADD(DAY, 7, DateOfArrival)
 WHERE DateOfDeparture > '2023-10-31'

--04. Delete
DECLARE @BerlinTownId INT

 SELECT @BerlinTownId = Id
   FROM Towns
  WHERE [Name] = 'Berlin'

DECLARE @BerlinTrainId INT

 SELECT @BerlinTrainId = Id
   FROM Trains
  WHERE DepartureTownId = @BerlinTownId

DELETE FROM TrainsRailwayStations
 WHERE TrainId = @BerlinTrainId

DELETE FROM MaintenanceRecords
 WHERE TrainId = @BerlinTrainId

DELETE FROM Tickets
 WHERE TrainId = @BerlinTrainId

DELETE FROM Trains
 WHERE Id = @BerlinTrainId

--05. Tickets by Price and Date Departure
  SELECT 
		DateOfDeparture,
		Price AS TicketPrice
	FROM Tickets
ORDER BY TicketPrice ASC, DateOfDeparture DESC

--06. Passengers with their Tickets
  SELECT 
		p.[Name] AS PassengerName,
		t.Price AS TicketPrice,
		t.DateOfDeparture,
		tr.[Id] AS TrainID
	FROM Passengers AS p
	JOIN Tickets AS t ON p.Id = t.PassengerId
	JOIN Trains AS tr ON t.TrainId = tr.Id
ORDER BY TicketPrice DESC, p.[Name]

--07. Railway Stations without Passing Trains
   SELECT 
		t.[Name] AS Town,
		r.[Name] AS RailwayStation
	 FROM RailwayStations AS r
LEFT JOIN TrainsRailwayStations AS trs ON r.Id = trs.RailwayStationId
LEFT JOIN Towns AS t ON r.TownId = t.Id
    WHERE trs.TrainId  IS NULL
 ORDER BY t.[Name], r.[Name]

--08. First 3 Trains Between 08:00 and 08:59
  SELECT TOP 3
		tr.Id AS TrainId,
		HourOfDeparture,
		Price AS TicketPrice,
		arr_town.[Name] AS Destination
	FROM Trains AS tr
	JOIN Tickets AS t ON tr.Id = t.TrainId
	JOIN Towns AS dep_town ON tr.DepartureTownId = dep_town.Id
	JOIN Towns AS arr_town ON tr.ArrivalTownId = arr_town.Id
   WHERE CAST(HourOfDeparture AS TIME) BETWEEN '08:00' AND '08:59'
     AND Price > 50.00
ORDER BY Price ASC

--09. Count of Passengers Paid More Than Average
  SELECT 
		t.[Name] AS TownName,
		COUNT(t.[Name]) AS PassengersCount
	FROM Tickets AS ti
	JOIN Trains AS tr ON ti.TrainId = tr.Id
	JOIN Towns AS t ON tr.ArrivalTownId = t.Id
   WHERE Price > 76.99
GROUP BY t.[Name]
ORDER BY t.[Name]

--10. Maintenance Inspection with Town and Station
  SELECT 
		tr.Id AS TrainID,
		t.[Name] AS DepartureTown,
		m.Details
	FROM MaintenanceRecords AS m
	JOIN Trains AS tr ON m.TrainId = tr.Id
	JOIN Towns AS t ON tr.DepartureTownId = t.Id
   WHERE m.Details LIKE '%inspection%'
ORDER BY tr.Id

--11. Towns with Trains
CREATE FUNCTION udf_TownsWithTrains(@name NVARCHAR(40))
RETURNS INT
AS
BEGIN
    DECLARE @TotalTrains INT

    SELECT @TotalTrains = COUNT(*)
      FROM Trains AS tr
      JOIN Towns AS dep_town ON tr.DepartureTownId = dep_town.Id
      JOIN Towns AS arr_town ON tr.ArrivalTownId = arr_town.Id
     WHERE dep_town.[Name] = @name OR arr_town.[Name] = @name

    RETURN @TotalTrains
END

--12. Search Passengers travelling to Specific Town
CREATE OR ALTER PROCEDURE usp_SearchByTown(@townName NVARCHAR(50))
	   AS 
   SELECT 
		p.[Name] AS PassengerName,
		DateOfDeparture,
		HourOfDeparture
	FROM Passengers AS p
	JOIN Tickets AS ti ON p.Id = ti.PassengerId
	JOIN Trains AS tr ON ti.TrainId = tr.Id
	JOIN Towns AS t ON tr.ArrivalTownId = t.Id
   WHERE t.[Name] = @townName
ORDER BY DateOfDeparture DESC, p.[Name]