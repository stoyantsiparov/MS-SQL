CREATE DATABASE LibraryDb
USE LibraryDb

--01. DDL
CREATE TABLE Contacts 
(
    Id INT PRIMARY KEY IDENTITY,
    Email NVARCHAR(100) NULL,
    PhoneNumber NVARCHAR(20) NULL,
    PostAddress NVARCHAR(200) NULL,
    Website NVARCHAR(50) NULL
)

CREATE TABLE Authors 
(
    Id INT PRIMARY KEY IDENTITY,
    [Name] NVARCHAR(100) NOT NULL,
    ContactId INT NOT NULL,
    FOREIGN KEY (ContactId) REFERENCES Contacts(Id)
)

CREATE TABLE Genres 
(
    Id INT PRIMARY KEY IDENTITY,
    [Name] NVARCHAR(30) NOT NULL
)

CREATE TABLE Libraries 
(
    Id INT PRIMARY KEY IDENTITY,
    [Name] NVARCHAR(50) NOT NULL,
    ContactId INT NOT NULL,
    FOREIGN KEY (ContactId) REFERENCES Contacts(Id)
)

CREATE TABLE Books 
(
    Id INT PRIMARY KEY IDENTITY,
    Title NVARCHAR(100) NOT NULL,
    YearPublished INT NOT NULL,
    ISBN NVARCHAR(13) NOT NULL UNIQUE,
    AuthorId INT NOT NULL,
    GenreId INT NOT NULL,
    FOREIGN KEY (AuthorId) REFERENCES Authors(Id),
    FOREIGN KEY (GenreId) REFERENCES Genres(Id)
)

CREATE TABLE LibrariesBooks 
(
    LibraryId INT NOT NULL,
    BookId INT NOT NULL,
    PRIMARY KEY (LibraryId, BookId),
    FOREIGN KEY (LibraryId) REFERENCES Libraries(Id),
    FOREIGN KEY (BookId) REFERENCES Books(Id)
)

--02. Insert
INSERT INTO Contacts (Email, PhoneNumber, PostAddress, Website) VALUES
('stoyan.king@example.com', '+4445556646', '29 Fiction Ave, Bangor, ME', 'www.stoyan.com'),
('daris.collins@example.com', '+7773289999', '99 Mockingbird Ln, NY, NY', 'www.daris.com'),
('stephen.king@example.com', '+4445556666', '15 Fiction Ave, Bangor, ME', 'www.stephenking.com'),
('suzanne.collins@example.com', '+7778889999', '10 Mockingbird Ln, NY, NY', 'www.suzannecollins.com')

INSERT INTO Authors ([Name], ContactId) VALUES
('George Orwell', 21),
('Aldous Huxley', 22),
('Stephen King', 23),
('Suzanne Collins', 24)

INSERT INTO Books (Title, YearPublished, ISBN, AuthorId, GenreId) VALUES
('1984', 1949, '9780451524935', 16, 2),
('Animal Farm', 1945, '9780451526342', 16, 2),
('Brave New World', 1932, '9780060850524', 17, 2),
('The Doors of Perception', 1954, '9780060850531', 17, 2),
('The Shining', 1977, '9780307743657', 18, 9),
('It', 1986, '9781501142970', 18, 9),
('The Hunger Games', 2008, '9780439023481', 19, 7),
('Catching Fire', 2009, '9780439023498', 19, 7),
('Mockingjay', 2010, '9780439023511', 19, 7)

INSERT INTO LibrariesBooks (LibraryId, BookId) VALUES
(1, 36), (1, 37), (2, 38), (2, 39), (3, 40), (3, 41), (4, 42), (4, 43), (5, 44)

--03. Update
UPDATE Contacts
   SET Website = 'www.' + REPLACE(LOWER(a.[Name]), ' ', '') + '.com'
  FROM Contacts AS c
  JOIN Authors AS a ON c.Id = a.ContactId
 WHERE c.Website IS NULL

--04. Delete
DECLARE @AuthorIdToDelete INT

 SELECT @AuthorIdToDelete = Id 
   FROM Authors 
  WHERE [Name] = 'Alex Michaelides'

DELETE FROM LibrariesBooks
 WHERE BookId IN 
 (
    SELECT Id 
	  FROM Books 
	 WHERE AuthorId = @AuthorIdToDelete
 )

DELETE FROM Books 
 WHERE AuthorId = @AuthorIdToDelete

DELETE FROM Authors 
 WHERE Id = @AuthorIdToDelete

--05. Chronological Order
  SELECT 
		Title AS "Book Title",
		ISBN,
		YearPublished AS YearReleased
	FROM Books
ORDER BY YearPublished DESC, Title

--06. Books by Genre
  SELECT 
		b.Id,
		Title,
		ISBN,
		g.[Name] AS Genre
	FROM Books AS b
	JOIN Genres AS g ON b.GenreId = g.Id
   WHERE g.[Name] IN ('Biography', 'Historical Fiction')
ORDER BY Genre, Title

--07. Missing Genre
  SELECT 
		l.[Name] AS "Library", 
		c.Email
	FROM Libraries AS l
	JOIN Contacts AS c ON l.ContactId = c.Id
	LEFT JOIN (
		SELECT lb.LibraryId
		  FROM LibrariesBooks AS lb
		  JOIN Books AS b ON lb.BookId = b.Id
		 WHERE b.GenreId = (SELECT Id FROM Genres WHERE [Name] = 'Mystery')
	) AS LibrariesWithMystery ON l.Id = LibrariesWithMystery.LibraryId
   WHERE LibrariesWithMystery.LibraryId IS NULL
ORDER BY l.[Name] ASC

--08. First 3 Books
  SELECT TOP 3
		Title,
		YearPublished AS "Year",
		g.[Name] AS Genre
	FROM Books AS b
	JOIN Genres AS g ON b.GenreId = g.Id
   WHERE (YearPublished > 2000 AND Title LIKE '%a%') OR (YearPublished < 1950 AND g.[Name] LIKE '%Fantasy%')
ORDER BY Title ASC, YearPublished DESC

--09. Authors from UK
  SELECT 
		[Name] AS Author,
		Email,
		PostAddress AS "Address"
	FROM Authors AS a
	JOIN Contacts AS c ON a.ContactId = c.Id
   WHERE PostAddress LIKE '%UK%'
ORDER BY [Name]

--10. Fictions in Denver
  SELECT 
		a.[Name] AS Author,
		Title,
		l.[Name] AS "Library",
		PostAddress AS "Library Address"
	FROM Authors AS a
	JOIN Books AS b ON a.Id = b.AuthorId
	JOIN Genres AS g ON b.GenreId = g.Id
	JOIN LibrariesBooks AS lb ON b.Id = lb.BookId
	JOIN Libraries AS l ON lb.LibraryId = l.Id
	JOIN Contacts AS c ON l.ContactId = c.Id
   WHERE g.[Name] = 'Fiction' AND PostAddress LIKE '%Denver%'
ORDER BY Title

--11. Authors with Books
CREATE FUNCTION udf_AuthorsWithBooks(@name NVARCHAR(100))
RETURNS INT
AS
BEGIN
    DECLARE @bookCount INT

    SELECT @bookCount = COUNT(*)
      FROM Authors AS a
      JOIN Books AS b ON a.Id = b.AuthorId
      JOIN LibrariesBooks AS lb ON b.Id = lb.BookId
      JOIN Libraries AS l ON lb.LibraryId = l.Id
     WHERE a.[Name] = @name

    RETURN @bookCount
END

SELECT dbo.udf_AuthorsWithBooks('J.K. Rowling') AS "Output"

--12. Search by Genre
CREATE OR ALTER PROCEDURE usp_SearchByGenre (@genreName NVARCHAR(30))
AS
    SELECT
        Title,
        YearPublished AS "Year",
        ISBN,
        a.[Name] AS Author,
        g.[Name] AS Genre
     FROM Books AS b
     JOIN Authors AS a ON b.AuthorId = a.Id
     JOIN Genres AS g ON b.GenreId = g.Id
    WHERE g.[Name] = @genreName
 ORDER BY b.Title

EXEC usp_SearchByGenre 'Fantasy'