SET TEXTSIZE 0
-- Create variables for the character string and for the current 
-- position in the string.
DECLARE @position int, @string char(20)
-- Initialize the current position and the string variables.
SET @position = 1
SET @string = (SELECT TOP 1 fld20 FROM tblSCMTempImport WHERE fld1 = 'TariffItem')
WHILE @position <= DATALENGTH(@string)
   BEGIN
   SELECT ASCII(SUBSTRING(@string, @position, 1)), 
      CHAR(ASCII(SUBSTRING(@string, @position, 1)))
   SET @position = @position + 1
   END
GO

