CREATE TABLE wyddb1.dbo.Event (
	startTime date NOT NULL,
	endTime date NOT NULL,
	isAllDay bit NOT NULL DEFAULT 0,
	subject varchar(255),
	color varchar(8),
	startTimeZone varchar(255),
	endTimeZone varchar(255),
	recurrenceRule varchar(255),
	notes varchar(255),
	location varchar(255),
	recurrenceId int,
	Id int NOT NULL IDENTITY(1,1) PRIMARY KEY
);

CREATE TABLE wyddb1.dbo.[User] (
	Id int NOT NULL  IDENTITY(1,1) PRIMARY KEY,
	Utente varchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	mail varchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
);

CREATE TABLE wyddb1.dbo.User_Event (
	Confirmed bit NULL,
	Event int NULL,
	[User] int NULL
);


-- wyddb1.dbo.User_Event foreign keys

ALTER TABLE wyddb1.dbo.User_Event ADD CONSTRAINT FK_User_Event_Event FOREIGN KEY (Event) REFERENCES wyddb1.dbo.Event(Id);
ALTER TABLE wyddb1.dbo.User_Event ADD CONSTRAINT FK_User_Event_User FOREIGN KEY ([User]) REFERENCES wyddb1.dbo.[User](Id);
