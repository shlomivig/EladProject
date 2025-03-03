
use EladInterViewProject
go
drop table if exists Users
go
CREATE TABLE Users
(
	id				int identity(1,1) primary key (Id desc),		
	fName			nvarchar(128),
	lName			nvarchar(128),
	isMale			bit,
	username		nvarchar(128),
	password		varchar(32),
	phone			varchar(128),
	countryCode		varchar(4),
	city			nvarchar(128),
	address			nvarchar(128),
	zipcode			varchar(16),	
	isActive		smallint default 1, 
	iTime			datetime default getdate()
)
CREATE nonclustered INDEX idx_Users_phone ON Users (phone);

insert into Users (fName, lName, isMale, username, password, phone, countryCode, city, address, zipcode)
values 
('John', 'Doe', 1, 'john.doe@example.com', 'password123', '0501234567', '+1', 'New York', '123 5th Ave', '10001'),
('Jane', 'Smith', 0, 'jane.smith@example.com', 'password123', '0522345678', '+1', 'Los Angeles', '456 Sunset Blvd', '90001'),
('David', 'Johnson', 1, 'david.johnson@example.com', 'password123', '0533456789', '+1', 'Chicago', '789 Lake Shore Dr', '60007'),
('Emily', 'Davis', 0, 'emily.davis@example.com', 'password123', '0544567890', '+1', 'Miami', '101 Ocean Dr', '33101'),
('Michael', 'Wilson', 1, 'michael.wilson@example.com', 'password123', '0555678901', '+1', 'Houston', '202 Main St', '77001');
go



drop table if exists UserToken--
go
CREATE TABLE UserToken
(
	id			uniqueidentifier primary key not null default newid(),	    
	userId		int unique NOT NULL,  
	isActive	smallint default 1, 
    lastLogin	datetime default null,
    iTime		datetime default getdate()
)
go
INSERT INTO UserToken (userId)
VALUES 
(1),
(2),
(3),
(4),
(5);


drop table if exists Categories --
go
CREATE TABLE Categories
(
    id				int identity(1,1), 
    name			nvarchar(128) not null,
    description		nvarchar(128) null,
    isActive		bit default 1,
    iTime			DATETIME DEFAULT GETDATE()
)
go

insert into Categories (name, description)
values 
('Art', ''),
('Clothes', ''),
('T-Toys', '');



drop table if exists Products --
go
CREATE TABLE Products
(
   	id				int identity(1,1) primary key (Id desc),		
	name			nvarchar(128),
	description		nvarchar(128),
	categoryId		int,
	price			bit,
	isActive		smallint default 1, 
	iTime			datetime default getdate()
)
go

insert into Products (name, description, categoryId, price)
values 
('Art Painting', 'A stunning artistic painting', 1, 1000),
('Sculpture', 'A beautiful modern sculpture', 1, 1500),
('T-Shirt', 'A comfortable cotton T-shirt', 2, 100),
('Teddy Bear', 'A soft and cuddly teddy bear for kids', 3, 15);



drop table if exists Cart --
go
CREATE TABLE Cart
(
   	id				int identity(1,1) primary key (Id desc),		
	userId			int,
	jsonValue		nvarchar(max),
	isActive		smallint default 1, 
	iTime			datetime default getdate()
)
go

