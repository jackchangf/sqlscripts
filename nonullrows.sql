--NO NULLS from any row in a table

--create Stored procedure-----
create procedure HideNullRows
	@tablename nvarchar(max)
as
begin
	declare @search nvarchar(500)
	set @search = (
		select STRING_AGG(Name, ' is not null and ') from 
		(
			select name from sys.columns where object_name(object_id) = @tablename
		) as t1
	)
	set @search = @search + ' is not null'
	set @search = 'select * from ' + @tablename +' where ' + @search
	exec (@search)
end

--to use SP----
EXEC HideNullRows @tablename = tblPerson;