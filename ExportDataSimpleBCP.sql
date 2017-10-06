/* PART 1 - EXPORT OF YOUR DATA */


--Don't change the parameters at the end of the BCP statement
--Change the Table/View Name, and the WF / Filename parameters only.

--Declare the statement as a string
DECLARE @BCP1 AS VARCHAR(1000)

--Create the string using the TABLE or VIEW you wish to output
--View example
--SET @BCP1 = 'bcp "SELECT * FROM Database.dbo.ViewName"  queryout \\ukvfs019\mi$\01_Work_Requests\WFxxx\Scripts\FileNameXXXX.txt -S REGAPP053\ukrc_prod -T -t^| -c'

--Table example
SET @BCP1 = 'bcp "Database.dbo.ViewName"  out \\ukvfs019\mi$\01_Work_Requests\WFxxx\Scripts\FileNameXXXX.txt -S REGAPP053\ukrc_prod -T -t^| -c'

--Execute the OUTPUT of the table
EXECUTE sys.xp_cmdshell @BCP1



/* PART 2 - RE-IMPORT OF YOUR DATA */

--Create the table to reimport the data
CREATE TABLE [dbo].Database.dbo.ViewName(
	[Field1] [varchar](50) COLLATE Latin1_General_CI_AS NULL,
	[Field2] [varchar](15) COLLATE Latin1_General_CI_AS NULL
)

--Declare the new statement as a string
DECLARE @BCP2 AS VARCHAR(1000)

--Create the string declaring the table you want to import into and the filename of the data
SET @BCP2 = 'bcp "Database.dbo.ViewName"  in \\ukvfs019\mi$\01_Work_Requests\WFxxx\Scripts\FileNameXXXX.txt -S REGAPP053\ukrc_prod -T -t^| -c'

--Execute the import
EXECUTE sys.xp_cmdshell @BCP2

