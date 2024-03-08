--Zadanie 1--
CREATE TABLE test (Id INT  IDENTITY,  Zawartosc INT, Zawartosc2 INT)
GO

DECLARE @a INT
SET @a = 1
    WHILE @a < 100000 BEGIN
        INSERT INTO test (Zawartosc, Zawartosc2)
VALUES  (CONVERT(INT,RAND()  * 100000), CONVERT(INT,RAND()  * 100000))
        SET @a = @a + 1
END
GO
--Zadanie 2--
SELECT * FROM test WHERE Zawartosc = 12345
--EstimatedTotalSubtreeCost = 0.314762;
