/****************************************************/
/* Created by: SQL Profiler                         */
/* Date: 04/02/2009  14:31:16         */
/****************************************************/


-- Create a Queue
declare @rc int
declare @TraceID int
declare @maxfilesize bigint
set @maxfilesize = 5 

-- Please replace the text InsertFileNameHere, with an appropriate
-- filename prefixed by a path, e.g., c:\MyFolder\MyTrace. The .trc extension
-- will be appended to the filename automatically. If you are writing from
-- remote server to local drive, please use UNC path and make sure server has
-- write access to your network share

exec @rc = sp_trace_create @TraceID output, 0, N'InsertFileNameHere', @maxfilesize, NULL 
if (@rc != 0) goto error

-- Client side File and Table cannot be scripted

-- Writing to a table is not supported through the SP's

-- Set the events
declare @on bit
set @on = 1
exec sp_trace_setevent @TraceID, 42, 1, @on
exec sp_trace_setevent @TraceID, 42, 6, @on
exec sp_trace_setevent @TraceID, 42, 9, @on
exec sp_trace_setevent @TraceID, 42, 10, @on
exec sp_trace_setevent @TraceID, 42, 11, @on
exec sp_trace_setevent @TraceID, 42, 12, @on
exec sp_trace_setevent @TraceID, 42, 13, @on
exec sp_trace_setevent @TraceID, 42, 14, @on
exec sp_trace_setevent @TraceID, 42, 16, @on
exec sp_trace_setevent @TraceID, 42, 17, @on
exec sp_trace_setevent @TraceID, 42, 18, @on
exec sp_trace_setevent @TraceID, 43, 1, @on
exec sp_trace_setevent @TraceID, 43, 6, @on
exec sp_trace_setevent @TraceID, 43, 9, @on
exec sp_trace_setevent @TraceID, 43, 10, @on
exec sp_trace_setevent @TraceID, 43, 11, @on
exec sp_trace_setevent @TraceID, 43, 12, @on
exec sp_trace_setevent @TraceID, 43, 13, @on
exec sp_trace_setevent @TraceID, 43, 14, @on
exec sp_trace_setevent @TraceID, 43, 16, @on
exec sp_trace_setevent @TraceID, 43, 17, @on
exec sp_trace_setevent @TraceID, 43, 18, @on


-- Set the Filters
declare @intfilter int
declare @bigintfilter bigint

exec sp_trace_setfilter @TraceID, 10, 0, 7, N'SQL Profiler'
exec sp_trace_setfilter @TraceID, 10, 0, 7, N'SQLAgent - Alert Engine'
exec sp_trace_setfilter @TraceID, 10, 0, 7, N'SQLAgent - Job Manager'


-- Set the trace status to start
exec sp_trace_setstatus @TraceID, 1

-- display trace id for future references
select TraceID=@TraceID
goto finish

error: 
select ErrorCode=@rc

finish: 
go
