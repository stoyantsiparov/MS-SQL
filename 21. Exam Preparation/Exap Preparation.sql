CREATE DATABASE Boardgames
USE Boardgames

--01. DDL
CREATE TABLE Categories
(
	Id INT PRIMARY KEY IDENTITY,
    [Name] NVARCHAR(50) NOT NULL
)

CREATE TABLE Addresses
(
	Id INT PRIMARY KEY IDENTITY,
    StreetName NVARCHAR(100) NOT NULL,
	StreetNumber INT NOT NULL,
	Town NVARCHAR(30) NOT NULL,
	Country NVARCHAR(50) NOT NULL,
	ZIP INT NOT NULL
)

CREATE TABLE Publishers
(
	Id INT PRIMARY KEY IDENTITY,
    [Name] NVARCHAR(30) NOT NULL,
	AddressId INT NOT NULL,
	FOREIGN KEY (AddressId) REFERENCES Addresses(Id),
	Website NVARCHAR(40),
	Phone NVARCHAR(20)
)

CREATE TABLE PlayersRanges
(
	Id INT PRIMARY KEY IDENTITY,
	PlayersMin INT NOT NULL,
	PlayersMax INT NOT NULL
)

CREATE TABLE Boardgames
(
	Id INT PRIMARY KEY IDENTITY,
    [Name] NVARCHAR(30) NOT NULL,
	YearPublished INT NOT NULL,
	Rating DECIMAL(18,2) NOT NULL,
	CategoryId INT NOT NULL,
	PublisherId INT NOT NULL,
	PlayersRangeId INT NOT NULL,
	FOREIGN KEY (CategoryId) REFERENCES Categories(Id),
	FOREIGN KEY (PublisherId) REFERENCES Publishers(Id),
	FOREIGN KEY (PlayersRangeId) REFERENCES PlayersRanges(Id)
)

CREATE TABLE Creators
(
	Id INT PRIMARY KEY IDENTITY,
	FirstName NVARCHAR(30) NOT NULL,
	LastName NVARCHAR(30) NOT NULL,
	Email NVARCHAR(30) NOT NULL
)

CREATE TABLE CreatorsBoardgames
(
	CreatorId INT NOT NULL,
	BoardgameId INT NOT NULL,
	PRIMARY KEY (CreatorId, BoardgameId),
	FOREIGN KEY (CreatorId) REFERENCES Creators(Id),
	FOREIGN KEY (BoardgameId) REFERENCES Boardgames(Id)
)

--02. Insert
INSERT INTO Categories ([Name])
VALUES 
('Strategy'), ('Family'), ('Party'), ('Abstract'), ('Thematic'), ('Children'), ('Adventure')

INSERT INTO Addresses (StreetName, StreetNumber, Town, Country, ZIP)
VALUES
('Main St', 123, 'New York', 'USA', 10001),
('Broadway', 456, 'New York', 'USA', 10002),
('Sunset Blvd', 789, 'Los Angeles', 'USA', 90001),
('Hollywood Blvd', 101, 'Los Angeles', 'USA', 90002),
('Market St', 202, 'San Francisco', 'USA', 94102),
('Mission St', 303, 'San Francisco', 'USA', 94103),
('Baker St', 404, 'San Francisco', 'USA', 94104),
('Rodeo Dr', 505, 'Beverly Hills', 'USA', 90210),
('Elm St', 606, 'Chicago', 'USA', 60601),
('Lake Shore Dr', 707, 'Chicago', 'USA', 60602),
('Michigan Ave', 808, 'Chicago', 'USA', 60603),
('Peachtree St', 909, 'Atlanta', 'USA', 30303),
('Bourbon St', 1010, 'New Orleans', 'USA', 70116)

INSERT INTO PlayersRanges (PlayersMin, PlayersMax)
VALUES 
(2, 4), (2, 5), (3, 6), (1, 4), (1, 2), (2, 8), (2, 6)

INSERT INTO Publishers ([Name], AddressId, Website, Phone)
VALUES
('Agman Games', 5, 'www.agmangames.com', '+16546135542'),
('Amethyst Games', 7, 'www.amethystgames.com', '+15558889992'),
('BattleBooks', 13, 'www.battlebooks.com', '+12345678907')

INSERT INTO Boardgames ([Name], YearPublished, Rating, CategoryId, PublisherId, PlayersRangeId)
VALUES
('Deep Blue', 2019, 5.67, 1, 15, 7),
('Paris', 2016, 9.78, 7, 1, 5),
('Catan: Starfarers', 2021, 9.87, 7, 13, 6),
('Bleeding Kansas', 2020, 3.25, 3, 7, 4),
('One Small Step', 2019, 5.75, 5, 9, 2)

--03. Update
UPDATE PlayersRanges
   SET PlayersMax = PlayersMax + 1
 WHERE PlayersMin = 2 AND PlayersMax = 2

UPDATE Boardgames
   SET [Name] = [Name] + 'V2'
 WHERE YearPublished >= 2020

--04. Delete
DELETE FROM CreatorsBoardgames WHERE BoardgameId IN (1,16,31,47)
DELETE FROM Boardgames WHERE PublisherId IN (1,16)
DELETE FROM Publishers WHERE AddressId IN (5)
DELETE FROM Addresses WHERE SUBSTRING(Town, 1, 1) = 'L'

--05. Boardgames by Year of Publication
  SELECT 
		[Name],
		Rating
	FROM Boardgames
ORDER BY YearPublished, [Name] DESC

--06. Boardgames by Category
  SELECT 
		b.Id,
		b.[Name],
		YearPublished,
		c.[Name] AS CategoryName
	FROM Boardgames AS b
	JOIN Categories AS c ON b.CategoryId = c.Id
   WHERE c.[Name] IN ('Strategy Games', 'Wargames')
ORDER BY YearPublished DESC

--07. Creators without Boardgames
  SELECT 
		c.Id,
		CONCAT_WS(' ', c.FirstName, c.LastName) AS CreatorName,
		Email
	FROM Creators AS c
	LEFT JOIN CreatorsBoardgames AS cb ON c.Id = cb.CreatorId
   WHERE cb.CreatorId IS NULL
ORDER BY CreatorName

--08. First 5 Boardgames
  SELECT TOP 5
		b.[Name],
		Rating,
		c.[Name] AS CategoryName
	FROM Boardgames AS b
	LEFT JOIN Categories AS c ON b.CategoryId = c.Id
	LEFT JOIN PlayersRanges as r ON b.PlayersRangeId = r.Id
   WHERE Rating > 7 AND (b.[Name] LIKE '%a%' OR Rating > 7.50) AND PlayersMin >= 2 AND PlayersMax <= 5
ORDER BY [Name], CategoryName DESC

--09. Creators with Emails
  SELECT 
		CONCAT_WS(' ', c.FirstName, c.LastName) AS FullName,
		Email,
		MAX(b.Rating) AS Rating
	FROM Creators AS c
	JOIN CreatorsBoardgames AS cb ON c.Id = cb.CreatorId
	JOIN Boardgames AS b ON cb.BoardgameId = b.Id
   WHERE c.Email LIKE '%.com%'
GROUP BY CONCAT_WS(' ', c.FirstName, c.LastName), Email
ORDER BY FullName

--10. Creators by Rating
  SELECT 
		LastName,
		CEILING(AVG(b.Rating)) AS AverageRating,
		p.[Name] AS PublisherName
	FROM Creators AS c
	JOIN CreatorsBoardgames AS cb ON c.Id = cb.CreatorId
	JOIN Boardgames AS b ON cb.BoardgameId = b.Id
	JOIN Publishers AS p ON b.PublisherId = p.Id
   WHERE cb.CreatorId IS NOT NULL AND p.[Name] = 'Stonemaier Games'
GROUP BY LastName, p.[Name]
ORDER BY AVG(b.Rating) DESC

--11. Creator with Boardgames
CREATE FUNCTION dbo.udf_CreatorWithBoardgames(@name NVARCHAR(30))
RETURNS INT
AS
BEGIN
    DECLARE @totalBoardgames INT

    SELECT @totalBoardgames = COUNT(*)
      FROM CreatorsBoardgames
     WHERE CreatorId IN (
         SELECT Id
           FROM Creators
          WHERE FirstName = @name
     )

    RETURN @totalBoardgames
END

--12. Search for Boardgame with Specific Category
CREATE OR ALTER PROCEDURE usp_SearchByCategory (@category NVARCHAR(50))
AS
    SELECT 
        b.[Name] AS BoardgameName,
        YearPublished,
        Rating,
        c.[Name] AS CategoryName,
        ISNULL(p.[Name], 'Unknown') AS PublisherName,
        CAST(pr.PlayersMin AS NVARCHAR(10)) + ' people' AS MinPlayers,
        CAST(pr.PlayersMax AS NVARCHAR(10)) + ' people' AS MaxPlayers
      FROM Boardgames b
      LEFT JOIN Categories c ON b.CategoryId = c.Id
      LEFT JOIN Publishers p ON b.PublisherId = p.Id
      LEFT JOIN PlayersRanges pr ON b.PlayersRangeId = pr.Id
     WHERE c.[Name] = @category
  ORDER BY PublisherName ASC, b.YearPublished DESC