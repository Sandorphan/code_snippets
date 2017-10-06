declare @dbsize decimal(15,0)
declare @logsize decimal(15,0)
declare @bytesperpage decimal(15,0)
declare @pagesperMB decimal(15,0)
	
select @dbsize = sum(convert(dec(15),size))
		from dbo.sysfiles
		where (status & 64 = 0)

select @logsize = sum(convert(dec(15),size))
		from dbo.sysfiles
		where (status & 64 <> 0)

select @bytesperpage = low
		from master.dbo.spt_values
		where number = 1
			and type = 'E'
select @pagesperMB = 1048576 / @bytesperpage
drop table #databasesizes
create table #databasesizes (
DBName VARCHAR(50) NULL,
DataFileSize_MB decimal(18,2) NULL,
LogFileSize_MB decimal(18,2) NULL,
ReservedSpace_MB decimal(18,2) NULL)

INSERT INTO #databasesizes 
select  db_name(),
	cast(ltrim(str((@dbsize) / @pagesperMB,15,2)) as decimal(18,2)),
	cast(ltrim(str((@logsize) / @pagesperMB,15,2)) as decimal(18,2)),
	cast(ltrim(str((@dbsize -
				(select sum(convert(dec(15),reserved))
					from sysindexes
						where indid in (0, 1, 255)
				)) / @pagesperMB,15,2)) as decimal(18,2))
	
