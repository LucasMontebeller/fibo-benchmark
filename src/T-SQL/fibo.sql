/*
drop database if exists tests
go

create database tests
go

use tests
go
*/

drop function if exists dbo.fnc_fibonacci
go
drop function if exists dbo.fnc_fibonacci_cte
go
drop function if exists dbo.fnc_fibonacci_iteration
go
drop function if exists dbo.show_results
go


create function dbo.fnc_fibonacci(@number_of_sequence int)
returns int as
begin
    
    if @number_of_sequence <= 0
        return 0

    if @number_of_sequence in (1, 2)
        return 1

    return dbo.fnc_fibonacci(@number_of_sequence - 1) + dbo.fnc_fibonacci(@number_of_sequence - 2)
end
go

create function dbo.fnc_fibonacci_cte(@number_of_sequence int)
returns int as
begin
    
    declare @result int

    if @number_of_sequence <= 0
        return 0
    
    ;with cte_fibonacci as 
    (
        select 1 as [element], 1 as [index], 1 as [next_element]

        union all

        select [next_element] as [element], ([index] + 1) as [index], ([element] + [next_element]) as [next_element]
        from cte_fibonacci where [index] < @number_of_sequence
    )

    select @result = [element] from cte_fibonacci where [index] = @number_of_sequence
    return @result
end
go

create function dbo.fnc_fibonacci_iteration(@number_of_sequence int)
returns int as
begin
    
    declare @iterator int = 3,
            @result int,
            @last_but_one int = 1,
            @last int = 1

    if @number_of_sequence <= 0
        return 0

    if @number_of_sequence in (1, 2)
        return 1
    
    while @iterator <= @number_of_sequence
    begin
        set @result = @last_but_one + @last
        
        set @last_but_one = @last
        set @last = @result

        set @iterator += 1
    end

    return @result
end
go

create function dbo.show_results(@number_of_sequence int)
returns @result table (method varchar(25), method_result int, [time(s)] int)
as
begin
    declare @method varchar(25),
            @method_result int,
            @start datetime,
            @end datetime

    set @method = 'fnc_fibonacci'
    begin
        set @start = GETDATE()
        set @method_result = dbo.fnc_fibonacci(@number_of_sequence)
        set @end = GETDATE()

        insert into @result (method, method_result, [time(s)])
        values (@method, @method_result, datediff(second, @start,  @end))
    end

    set @method = 'fnc_fibonacci_cte'
    begin
        set @start = GETDATE()
        set @method_result = dbo.fnc_fibonacci_cte(@number_of_sequence)
        set @end = GETDATE()

        insert into @result (method, method_result, [time(s)])
        values (@method, @method_result, datediff(second, @start,  @end))
    end

    set @method = 'fnc_fibonacci_iteration'
    begin
        set @start = GETDATE()
        set @method_result = dbo.fnc_fibonacci_iteration(@number_of_sequence)
        set @end = GETDATE()

        insert into @result (method, method_result, [time(s)])
        values (@method, @method_result, datediff(second, @start,  @end))
    end

    return
end
go


declare @number_of_sequence int = 25
select * from dbo.show_results(@number_of_sequence)