use GUCera

go 

create proc studentRegister
@first_name varchar(20),
@last_name varchar(20),
@password varchar(20),
@email varchar(50),
@gender bit,
@adress varchar(10)
as
insert into Users (firstName,lastName,password,email,gender,address) values (@first_name,@last_name,@password,@email,@gender,@adress)
insert into Student(id)
select max(id)
from Users

go

create proc InstructorRegister
@first_name varchar(20),
@last_name varchar(20),
@password varchar(20),
@email varchar(50),
@gender bit,
@adress varchar(10)
as
insert into Users (firstName,lastName,password,email,gender,address) values (@first_name,@last_name,@password,@email,@gender,@adress)
insert into Instructor(id)
select max(id)
from Users


go

create proc userLogin
@ID int,
@password varchar(20),
@success bit output,
@type int output
as

if(exists(select* from Users where id=@ID and Users.password=@password))
set @success =1 else set @success = 0

	if(exists(select* from Instructor where id=@ID ))
		set @type =0
	if(exists(select* from Admin where id=@ID ))
		set @type =1
	if(exists(select* from Student where id=@ID))
		set @type =2

go

create proc addMobile
@ID int,
@mobile_number varchar(20)
as
insert into UserMobileNumber(id,mobileNumber) values (@ID,@mobile_number)

go

create proc AdminListInstr
as
select Users.firstName,Users.lastName
from Instructor
	inner join Users on Instructor.id=Users.id

go

create proc AdminViewInstructorProfile
@instrId int
as
if(exists(select * from Instructor where id=@instrID))
	begin
	select Users.firstName,Users.lastName,Users.gender,Users.email,Users.address,Instructor.rating
	from Instructor
	inner join Users on Instructor.id=Users.id
	where Instructor.id=@instrId
	end
else
	print'there is no instructor that has the id you entered'

go

create proc AdminViewAllCourses
as
select name,creditHours,price,content,accepted
from Course

go

create proc AdminViewNonAcceptedCourses
as
select name,creditHours,price,content
from Course
where accepted=0 or accepted is null

go

create proc AdminViewCourseDetails
@courseId int
as
if(exists(select * from Course where id=@courseId))
	begin
	select *
	from Course
	where Course.id=@courseId
	end
else
	print'there is no course that has the id you entered'
go

create proc AdminAcceptRejectCourse
@adminId int,
@courseId int
as
if(exists(select * from Course where id=@courseId) and exists (select * from Admin where id=@adminId))
	begin
	update Course
	set	
		adminID=@adminId,
		accepted=1
	where id=@courseId
	end
else
	print'invalid course or admin id'


go

create proc AdminCreatePromocode
@code varchar(6),
@issueDate datetime,
@expiryDate datetime,
@discount decimal(4,2),
@adminId int
as

insert into Promocode(code,issueDate,expiryDate,discount,adminID) values (@code,@issueDate,@expiryDate,@discount,@adminId)

go

create proc AdminListAllStudents
as
select Users.firstName,Users.lastName
from student 
	inner join Users on Student.id=Users.id

go

create proc AdminViewStudentProfile
@sid int
as
if(exists(select * from Student where id=@sid))
	begin
	select *
	from Student
		inner join Users on Student.id=Users.id
	where Student.id=@sid
	end
else
	print'there is no student that has the id you entered'

go

create proc AdminIssuePromocodeToStudent
@sid int,
@pid varchar(6)
as
insert into studentHasPromocode(sid,code) values(@sid,@pid)

go

create proc  InstAddCourse
@creditHours int,
@name varchar(10),
@price decimal(6,2),
@instructorId int
as
insert into Course(creditHours,name,price,instructorid) values (@creditHours,@name,@price,@instructorId)
declare @courseID int
select @courseId=max(id)
from Course
insert into InstructorTeachCourse(instId,cid) values (@instructorId,@courseID)

go

create proc UpdateCourseContent
@instrId int,
@courseId int,
@content varchar(20)
as 
if(exists(select* from Course where instructorid=@instrId and @courseId=id))
	begin
	update  Course
	set content = @content
	where id=@courseId and instructorid=@instrId
	end
else
	print'invalid course or instructor id'

go

create proc UpdateCourseDescription
@instrId int,
@courseId int,
@courseDescription varchar(200)
as
if(exists(select* from Course where instructorid=@instrId and @courseId=id))
	begin
	update  Course
	set courseDescription = @courseDescription
	where id=@courseId and instructorid=@instrId
	end
else
	print'invalid course or instructor id'

go

create proc AddAnotherInstructorToCourse
@insid int,
@cid int,
@adderIns int
as
if(exists(select * from InstructorTeachCourse where instId=@adderIns ) and exists(select * from Instructor where id=@adderIns) and exists(select * from Instructor where id=@insid))
	begin
	insert into InstructorTeachCourse(instId,cid) values (@insid,@cid)
	end
else
	print'either the instructor you want to add is not registered or invalid course id'

go

create proc InstructorViewAcceptedCoursesByAdmin
@instrId int
as
if(exists(select * from Instructor where id=@instrId))
	begin
	select InstructorTeachCourse.instId,Course.name,Course.creditHours
	from InstructorTeachCourse
		inner join Course on InstructorTeachCourse.cid=Course.id
	where InstructorTeachCourse.instId=@instrId and Course.accepted=1
	end
else
	print'invalid instructor id'

go

create proc DefineCoursePrerequisites
@cid int,
@prerequisiteId int
as
if(exists(select * from Course where id=@cid)and exists(select * from Course where id=@prerequisiteId))
	begin
	insert into CoursePrerequisiteCourse(cid,prerequisiteId) values (@cid,@prerequisiteId)
	end
else
	print'invalid course id'

go

create proc DefineAssignmentOfCourseOfCertianType
@instId int,
@cid int,
@number int,
@type varchar(10),
@fullgrade int,
@weight decimal(4,1),
@deadline datetime,
@content varchar(200)
as
if(exists(select * from InstructorTeachCourse where instId=@instId and cid=@cid))
	begin
	insert into Assignment(cid,number,type,fullGrade,weight,deadline,content) values (@cid,@number,@type,@fullgrade,@weight,@deadline,@content)
	end
else
	print 'you don`t this course so you can`t add an assignment'

go

create proc updateInstructorRate
@insid int
as
if(exists(select * from Instructor where id=@insid))
	begin
	declare @rating decimal (10,2)
	select @rating=AVG(rate)
	from StudentRateInstructor
	where instId=@insid

	update Instructor
	set rating=@rating
	where id=@insid
	
	end
else
	print'invalid instructor id'

go

create proc  ViewInstructorProfile
@instrId int
as
if(exists(select * from Instructor where id=@instrId))
	begin
	select * 
	from Instructor
		inner join Users on Instructor.id=Users.id
	where Instructor.id=@instrId
	end
else
	print'invalid instructor id'

go

create proc InstructorViewAssignmentsStudents
@instrId int,
@cid int
as
if(exists(select* from InstructorTeachCourse where cid=@cid and instId=@instrId))
	begin
	select sid,cid,assignmentNumber,assignmentType
	from StudentTakeAssignment
	where StudentTakeAssignment.cid=@cid
	end
else
	print'invalid instructor or course id'

go

create proc InstructorgradeAssignmentOfAStudent
@instrId int,
@sid int,
@cid int,
@assignmentNumber int,
@type varchar(10),
@grade decimal(5,2)
as
if(exists(select* from InstructorTeachCourse where cid=@cid and instId=@instrId))
	begin
	update StudentTakeAssignment
	set grade=@grade
	where sid=@sid and cid=@cid and assignmentNumber=@assignmentNumber and assignmentType=@type
	end
else
	print'invalid instructor or course id'

go

create proc ViewFeedbacksAddedByStudentsOnMyCourse
@instrId int,
@cid int
as
if(exists(select* from InstructorTeachCourse where cid=@cid and instId=@instrId))
	begin
	select Feedback.number,Feedback.comments,Feedback.numberOfLikes
	from InstructorTeachCourse
		inner join Feedback on InstructorTeachCourse.cid=Feedback.cid
	where InstructorTeachCourse.instId=@instrId and InstructorTeachCourse.cid=@cid
	end
else
	print'invalid course or instructor id'

go

create proc calculateFinalGrade
@cid int,
@sid int,
@insId int
as
declare @finalGrade decimal (10,2)
if(exists(select * from StudentTakeCourse where sid=@sid and cid=@cid and instId=@insId))
	begin
	select @finalgrade=SUM((StudentTakeAssignment.grade / Assignment.fullGrade) * Assignment.weight )
	from StudentTakeAssignment
		inner join Assignment on StudentTakeAssignment.cid=Assignment.cid
	where StudentTakeAssignment.sid=@sid and StudentTakeAssignment.cid=@cid
	update StudentTakeCourse
	set
		grade=@finalGrade
	where sid=@sid and cid=@cid and instId=@insId
	end
else
	print 'invalid course, student or instructor id'
go

create proc InstructorIssueCertificateToStudent
@cid int,
@sid int,
@insId int,
@issueDate datetime
as
if(exists(select* from InstructorTeachCourse where cid=@cid and instId=@insId) and exists(select * from StudentTakeCourse where sid=@sid and cid=@cid and instId=@insId))
	begin
	insert into StudentCertifyCourse(sid,cid,issueDate) values (@sid,@cid,@issueDate)
	end
else
	print 'invalid course, student or instructor id'

go

create proc viewMyProfile
@id int
as
if(exists(select * from Student where id=@id))
	BEGIN
	select *
	from Student
		inner join Users on Student.id=Users.id
	where Student.id=@id
	end
else
	print'invalid id'

go

create proc editMyProfile
@id int,
@firstName varchar(10),
@lastName varchar(10),
@password varchar(10),
@gender binary,
@email varchar(10),
@address varchar(10)
as
if(exists(select * from Student where id=@id))
	begin
	if(@firstName is not null)
		begin
		update Users
		set 
			firstName=@firstName
		where id=@id
		end
	if(@lastName is not null)
		begin
		update Users
		set 
			lastName=@lastName
		where id=@id
		end
	if(@password is not null)
		begin
		update Users
		set 
			password=@password
		where id=@id
		end
	if(@gender is not null)
		begin
		update Users
		set 
			gender=@gender
		where id=@id
		end
	if(@email is not null)
		begin
		update Users
		set 
			email=@email
		where id=@id
		end
	if(@address is not null)
		begin
		update Users
		set 
			address=@address
		where id=@id
		end
	end
else
	print'invalid id'

go

create proc availableCourses
as
select Course.name
from Course
where accepted=1

go

create proc courseInformation
@id int
as
if(exists(select * from Course where id=@id))
	begin
	select * from Course where id=@id
	end
else
	print'invalid id'

go

create proc  enrollInCourse
@sid int,
@cid int,
@instr int
as
if(exists(select * from Student where id=@sid) and exists(select * from Course where id=@cid) and exists(select * from Instructor where id=@instr))
	begin
	insert into StudentTakeCourse(sid,cid,instId) values(@sid,@cid,@instr)
	end
else
	print'invalid course,instructor or student id'

go

create proc  addCreditCard
@sid int,
@number varchar(15),
@cardHolderName varchar(16),
@expiryDate datetime,
@cvv varchar(3)
as
if(exists(select * from Student where id=@sid))
	begin
	insert into CreditCard(number,cardHolderName,expirayDate,cvv) values (@number,@cardHolderName,@expiryDate,@cvv)
	insert into StudentAddCreditcard(sid,creditCardNumber) values (@sid,@number)
	end
else
	print 'invalid student id'

go

create proc viewPromocode
@sid int
as
if(exists(select * from Student where id=@sid))
	begin
	select Promocode.*
	from studentHasPromocode
		inner join Promocode on studentHasPromocode.code=Promocode.code
	where studentHasPromocode.sid=@sid
	end
else
	print 'invalid student id'

go

create proc  payCourse
@cid int,
@sid int
as
if(exists(select * from StudentAddCreditcard where sid=@sid))
	begin
	update StudentTakeCourse
	set 
		payedfor=1
	where sid=@sid and cid=@cid
	end
else
	print'your credit card is not added'

go

create proc  enrollInCourseViewContent
@id int,
@cid int
as
if(exists(select * from StudentTakeCourse where sid=@id and cid=@cid))
	begin
	select * 
	from Course
	where id=@cid
	end
else
	print'you are not enrolled in this course'

go

create proc viewAssign
@courseId int,
@sid int
as
if(exists(select * from StudentTakeCourse where sid=@sid and cid=@courseId))
	begin
	select *
	from Assignment
	where cid=@courseId
	end
else
	print'you are not enrolled in this course'

go

create proc  submitAssign
@assignType varchar(10),
@assignnumber int,
@sid int,
@cid int
as
if(exists(select * from StudentTakeCourse where sid=@sid and cid=@cid))
	begin
	insert into StudentTakeAssignment(sid,cid,assignmentNumber,assignmentType) values (@sid,@cid,@assignnumber,@assignType)
	end
else
	print'you are not enrolled in this course'

go

create proc viewAssignGrades
@assignnumber int,
@assignType varchar(10),
@cid int,
@sid int,
@assignGrade int output
as
if(exists(select * from StudentTakeCourse where sid=@sid and cid=@cid))
	begin
	select @assignGrade= max(StudentTakeAssignment.grade)
	from StudentTakeAssignment
	where sid=@sid and cid=@cid and assignmentNumber=@assignnumber and assignmentType=@assignType
	end
else
	print'you are not enrolled in this course'

go

create proc viewFinalGrade
@sid int,
@cid int,
@grade decimal(3,2) output
as
if(exists(select * from StudentTakeCourse where sid=@sid and cid=@cid))
	begin
	select @grade=StudentTakeCourse.grade
	from StudentTakeCourse
	where StudentTakeCourse.sid=@sid and StudentTakeCourse.cid=@cid
	end
else
	print'you are not enrolled in this course'

go

create proc addFeedback
@comment varchar(100),
@cid int,
@sid int
as
if(exists(select * from StudentTakeCourse where sid=@sid and cid=@cid))
	begin
	insert into Feedback(cid,sid,comments) values (@cid,@sid,@comment)
	end
else
	print'you are not enrolled in this course'

go

create proc  rateInstructor
@rate decimal(2,1),
@sid int,
@insid int
as
if(exists(select * from StudentTakeCourse where sid=@sid and instId=@insid))
	begin
	insert into StudentRateInstructor(sid,instId,rate) values (@sid,@insid,@rate)
	end
else
	print'you are not enrolled in a course with this instructor'

go

create proc viewCertificate
@cid int,
@sid int
as
if(exists(select * from StudentCertifyCourse where sid=@sid and cid=@cid))
	begin
	select * from StudentCertifyCourse where sid=@sid and cid=@cid
	end
else
	print'you are not enrolled in this course'