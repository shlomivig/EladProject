

use EladInterViewProject
go

--drop procedure if exists  dbo.spLogin
--go
create or alter procedure spLogin	
	@token		uniqueidentifier = null,
	@params		nvarchar(max) = null
  as
begin
	/*
		exec dbo.spLogin @params='{ "username": "shalom", "password": "123456" }', @token='244A0FB6-BBC7-45D6-8655-05D2062DB26A'
	*/

	declare @userId int;
	declare @username varchar(32) = JSON_VALUE(@params,'$.username');
	declare @password varchar(32) = JSON_VALUE(@params,'$.password');

	if (@token is not null)
	begin
		set @userId = (select top 1 userId from UserToken where id = @token and isActive = 1) 
		if (isnull(@userId, 0) = 0)
		begin
			select 11 as code, 'The token you provided is invalid or has expired' as msg
			return;
		end
		select 0 as code, '' as msg
		select top 1 * from Users where id = @userId and isActive = 1
		return;  
	end


	set @userId = (select top 1 id from Users where username = @username and password = @password and isActive = 1) 
	if(isnull(@userId,0) = 0)
	begin
		select 12 as code,'Incorrect username or password. Please try again' as msg
		return;
	end

	update UserToken set lastLogin = getdate(), isActive = 1 where userId = @userId
	set @token = (select top 1 id from UserToken with (nolock) where userId = @userId) 
	
	select 0 as code, '' as msg
	select top 1 * from Users with (nolock) where id = @userId and isActive = 1
	select @token as token	

end
go	



--drop procedure if exists  dbo.spCheckTokens
--go
create or alter procedure spCheckTokens	
  as
begin
	/*
		exec dbo.spCheckTokens
	*/
	update UserToken set isActive = 0 where lastLogin < dateadd(minute, -10, getdate());
	select 0 as code, '' as msg
	end
go	


--drop procedure if exists  dbo.spGetCategories
--go
create or alter procedure spGetCategories	
	@token	uniqueidentifier = null
as
begin
	/*
		exec dbo.spGetCategories @token='244A0FB6-BBC7-45D6-8655-05D2062DB26A'
	*/

	declare @userId int = (select top 1 userId from UserToken where id = @token and isActive = 1) 
	if(isnull(@userId,0) = 0)
	begin
		select 90 as code,'user is not loged in' as msg
		return;
	end

	select 0 as code, '' as msg
    select * from Categories
end
go


--drop procedure if exists  dbo.spGetProducts
--go
create or alter procedure spGetProducts	
	@token			uniqueidentifier = null,
	@params		nvarchar(max) = null
as
begin
	/*
		exec dbo.spGetProducts @params='{ "categoryId" : "1" }', @token='B893414D-EE90-4D45-BC22-04CC8452307B'
	*/

	declare @userId int;
	set @userId = (select top 1 userId from UserToken where id = @token and isActive = 1) 
	if(isnull(@userId,0) = 0)
	begin
		select 90 as code,'user is not loged in' as msg
		return;
	end
	
	declare @categoryId int = JSON_VALUE(@params,'$.categoryId');

	select 0 as code, '' as msg
    select * from Products where categoryId = @categoryId
end
go



--drop procedure if exists  dbo.spAddProductToCart
--go
create or alter procedure spAddProductToCart	
	@token			uniqueidentifier = null,
	@params		nvarchar(max) = null
as
begin
	/*
		exec dbo.spAddProductToCart @params='{ "cartId" : "1", "productId" : "1", "amount" : "1" }', @token='B893414D-EE90-4D45-BC22-04CC8452307B'
		exec dbo.spAddProductToCart @params='{ "productId" : "1", "amount" : "1" }', @token='A71DAD79-4F50-4772-8917-C0DC32D23D39'
	*/

	declare @userId int;
	set @userId = (select top 1 userId from UserToken where id = @token and isActive = 1) 
	if(isnull(@userId,0) = 0)
	begin
		select 90 as code,'user is not loged in' as msg
		return;
	end
		
	declare @cartId int = JSON_VALUE(@params,'$.cartId');
	declare @productId int = JSON_VALUE(@params,'$.productId');
	declare @amount int = JSON_VALUE(@params,'$.amount');

	declare @jsonValue nvarchar(max)
	if(isnull(@cartId,'') = '' )
	begin
		set @jsonValue = json_query('{"' + CAST(@productId AS NVARCHAR) + '": ' + CAST(@amount AS NVARCHAR) + '}');
		insert into Cart (userId, jsonValue, isActive)
		values (@userId, @jsonValue, 1);
		
		set @cartId = scope_identity();
	end

	set @jsonValue = (select top 1 jsonValue from Cart where id = @cartId and userId = @userId and isActive = 1)
	
	if(isnull(@jsonValue,'') = '')
		set @jsonValue = '{}';

	set @jsonValue = json_modify(@jsonValue, '$."' + CAST(@productId AS NVARCHAR) + '"', @amount);

	update Cart set jsonValue = @jsonValue where id = @cartId and userId = @userId;


	select 0 as code, 'Product Added' as msg
    select * from Cart with (nolock) where id = @cartId
end
go


--drop procedure if exists  dbo.spChangeProductAmountInCart
--go
create or alter procedure spChangeProductAmountInCart	
	@token			uniqueidentifier = null,
	@params		nvarchar(max) = null
as
begin
	/*
		exec dbo.spChangeProductAmountInCart @params='{ "cartId" : "1", "productId" : "1", "amount" : "1" }', @token='B893414D-EE90-4D45-BC22-04CC8452307B'
		exec dbo.spChangeProductAmountInCart @params='{ "productId" : "1", "amount" : "1" }', @token='A71DAD79-4F50-4772-8917-C0DC32D23D39'
	*/
	declare @userId int;
	set @userId = (select top 1 userId from UserToken where id = @token and isActive = 1) 
	if(isnull(@userId,0) = 0)
	begin
		select 90 as code,'user is not loged in' as msg
		return;
	end
	
	declare @cartId int = JSON_VALUE(@params,'$.cartId');
	declare @productId int = JSON_VALUE(@params,'$.productId');
	declare @amount int = JSON_VALUE(@params,'$.amount');

	declare @jsonValue nvarchar(max)
	set @jsonValue = (select top 1 jsonValue from Cart where id = @cartId and userId = @userId and isActive = 1)
	
	if(isnull(@jsonValue,'') = '')
		select 80 as code, 'CartId: '+ CAST(@cartId AS NVARCHAR) +' is incorrect' as msg

	declare @currentAmount int;
    set @currentAmount = JSON_VALUE(@jsonValue, '$."' + CAST(@productId AS NVARCHAR) + '"');
	
	if(isnull(@currentAmount,0) = 0)
		set @currentAmount = 0

	set @currentAmount = @currentAmount + @amount;

	set @jsonValue = json_modify(@jsonValue, '$."' + CAST(@productId AS NVARCHAR) + '"', @currentAmount);
	update Cart set jsonValue = @jsonValue where id = @cartId and userId = @userId;

	select 0 as code, 'Cart Updated' as msg
    select * from Cart with (nolock) where id = @cartId
end
go



--drop procedure if exists  dbo.spDeleteProductFromCart
--go
create or alter procedure spDeleteProductFromCart	
	@token			uniqueidentifier = null,
	@params		nvarchar(max) = null
as
begin
	/*
		exec dbo.spDeleteProductFromCart @params='{ "cartId" : "1", "productId" : "1" }', @token='B893414D-EE90-4D45-BC22-04CC8452307B'
	*/
	declare @userId int;
	set @userId = (select top 1 userId from UserToken where id = @token and isActive = 1) 
	if(isnull(@userId,0) = 0)
	begin
		select 90 as code,'user is not loged in' as msg
		return;
	end
	
	declare @cartId int = JSON_VALUE(@params,'$.cartId');
	declare @productId int = JSON_VALUE(@params,'$.productId');

	declare @jsonValue nvarchar(max)
	set @jsonValue = (select top 1 jsonValue from Cart where id = @cartId and userId = @userId and isActive = 1)
	
	if(isnull(@jsonValue,'') = '')
		select 80 as code, 'CartId: '+ CAST(@cartId AS NVARCHAR) +' is incorrect' as msg
	
	set @jsonValue = JSON_MODIFY(@jsonValue, '$."' + CAST(@productId AS NVARCHAR) + '"', NULL)

	update Cart set jsonValue = @jsonValue where id = @cartId and userId = @userId;

	select 0 as code, 'Cart Updated' as msg
    select * from Cart with (nolock) where id = @cartId
end
go



