Create database GUCera;

go

use GUCera

create table Users(
id int primary key identity,
firstName varchar(50),
lastName varchar(50),
password varchar(10),
gender bit,
email varchar(80) unique,
address varchar(80)
);


create table Instructor(
id int ,
rating decimal(3,2) default 0.0,
primary key (id),
foreign key (id) references Users on delete cascade on update cascade
);


create table UserMobileNumber(
id int ,
mobileNumber varchar(50) unique,
primary key (id,mobileNumber),
foreign key (id) references Users on delete cascade on update cascade
);


create table Student(
id int ,
GPA decimal(2,2) default 0.0,
primary key (id),
foreign key (id) references Users on delete cascade on update cascade
);


create table Admin(
id int ,
primary key (id),
foreign key (id) references Users on delete cascade on update cascade
);


create table Course(
id int primary key identity,
creditHours int,
name varchar(25) ,
courseDescription text,
price decimal (10,2),
content text,
adminID int,
instructorid int,
accepted bit

foreign key (adminId) references Admin on delete cascade on update cascade,
foreign key (instructorId) references Instructor on delete no action on update no action
);


create table Assignment(
cid int,
number int  ,
type varchar(25) ,
fullGrade int,
weight decimal (4,1) ,
deadline datetime,
content text,
primary key (cid,number,type),
foreign key (cid) references Course on delete cascade on update cascade
);


create table Feedback(
cid int,
number int identity,
comments varchar(100),
numberOfLikes int,
sid int,
primary key (cid,number),
foreign key (cid) references Course on delete cascade on update cascade,
foreign key (sid) references student on delete no action on update no action
);


create table Promocode(
code varchar(6) primary key,
issueDate datetime,
expiryDate datetime,
discount decimal(4,2),
adminID int,
foreign key (adminId) references Admin on delete cascade on update cascade
);


create table studentHasPromocode(
sid int,
code varchar(6),
primary key(sid,code),
foreign key (sid) references Student on delete no action on update no action,
foreign key (code) references Promocode on delete cascade on update cascade
);


create table CreditCard(
number varchar(20) primary key,
cardHolderName varchar(25),
expirayDate date,
cvv int 
);

create table StudentAddCreditcard(
sid int,
creditCardNumber varchar(20),
primary key(sid,creditCardNumber),
foreign key (sid) references Student on delete cascade on update cascade,
foreign key (creditCardNumber) references Creditcard on delete cascade on update cascade
);

create table StudentTakeCourse(
sid int,
cid int,
instId int,
payedfor bit default 0,
grade decimal(3,2) default 0.0,
primary key(sid,cid,instId),
foreign key (sid) references Student on delete no action on update no action,
foreign key (instId) references Instructor on delete no action on update no action,
foreign key (cid) references Course on delete cascade on update cascade
);

create table StudentTakeAssignment(
sid int,
cid int,
assignmentNumber int,
assignmentType varchar(25),
grade decimal(5,2) default 0,
primary key(sid,cid,assignmentNumber,assignmentType,grade),
foreign key (sid) references Student on delete no action on update no action,
Foreign key (cid,assignmentNumber,assignmentType) References  Assignment on delete cascade on update cascade

);

create table StudentRateInstructor(
sid int,
instId int,
rate decimal(3,2),
primary key (sid,instId),
foreign key (sid) references Student on delete cascade on update cascade,
foreign key (instId) references Instructor on delete no action on update no action
);


create table StudentCertifyCourse(
sid int,
cid int,
issueDate date,
primary key(sid,cid),
foreign key (sid) references Student on delete no action on update no action,
foreign key (cid) references Course on delete cascade on update cascade
);


create table CoursePrerequisiteCourse(
cid int,
prerequisiteId int,
primary key(cid,prerequisiteId),
foreign key (cid) references Course on delete cascade on update cascade,
foreign key (prerequisiteId) references Course on delete no action on update no action
);


create table InstructorTeachCourse(
instId int ,
cid int,
primary key(cid,instID),
foreign key (cid) references Course on delete cascade on update cascade,
foreign key (instId) references Instructor on delete no action on update no action
);
