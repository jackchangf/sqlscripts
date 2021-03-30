
declare @counter int = 0
declare @maxRow int = 0
declare @hackeridtocheck int = 0
declare @freq int = 0
declare @day int = 1
declare @maxdays int = 0
declare @numberofuniques int = 0
declare @uniquenumberidentifier nvarchar(max) = ''
declare @result nvarchar(max) = ''
declare @hacker nvarchar(max) = ''

--calc max days
;with t1 as (
select m=max(submission_date) from submissions group by submission_date)
select @maxdays = count(*) from t1

while (@day <= @maxdays)
begin
	set @numberofuniques = 0
	set @uniquenumberidentifier = ''
	set @result = ''

	; with t1 as (select rn1=row_number() over (order by submission_date),
						rn2=dense_rank() over (order by submission_date asc) from submissions)
	select @maxRow = max(rn1), @counter = min(rn1) from t1 where (rn2 = @day)
	--print 'day' + cast(@day as nvarchar(max)) + 'maxrow' + cast(@maxrow as nvarchar(max))

	; with t2 as
	(select submission_date, rn3=row_number() over (order by submission_date asc) from submissions)
	select @result=submission_date from t2 where rn3=@maxrow
	
	declare @i int =0
	declare @j nvarchar(max) = ''
	;with t2 as (
		select t1.hacker_id, h.name from (
			select top 1 submission_date, hacker_id,times=count(hacker_id) from submissions group by submission_date,hacker_id
			having submission_date = @result
			order by times desc, hacker_id asc) t1 
		inner join hackers h on t1.hacker_id = h.hacker_id)
	select @i=hacker_id, @j=name from t2
	set @hacker = cast(@i as nvarchar(max)) +' '+ @j

	while (@counter <= @maxrow)
	begin
		; with t1 as (select s.*,rn=row_number() over (order by submission_date) from submissions s)
		select @hackeridtocheck = hacker_id from t1 where rn = @counter
	
		; with t2 as (SELECT max(CASE WHEN hacker_id = @hackeridtocheck THEN 1 ELSE 0 END) OVER(PARTITION BY submission_date) as consecutive
		FROM (select top (@maxrow) * from submissions)s) select @freq = sum(consecutive) from t2

		if(@freq = @maxrow)
		begin
			if CHARINDEX(cast(@hackeridtocheck as nvarchar(max)) + ',', @uniquenumberidentifier) =0
			--begin --exists already
			--	print 'exists'
			--end
			--else --doesn't exists, so add
			begin
			set @uniquenumberidentifier += cast(@hackeridtocheck as nvarchar(max)) + ','
			set @numberofuniques += 1
			end
			--print @uniquenumberidentifier
			--print 'number of unqiues ' + cast(@numberofuniques as nvarchar(max))
		end
		--print @numberofuniques
		--print 'the freq ' + cast(@freq as nvarchar(max)) + 'the day ' + cast(@day as nvarchar(max))
		set @counter += 1
	end

		set @result += ' ' + cast(@numberofuniques as nvarchar(max)) + ' ' + @hacker
		print @result
		--finding max hacker submission

		
set @day += 1
end