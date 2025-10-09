CREATE DATABASE timetable;
Use timetable;


-- Drop existing tables
DROP TABLE IF EXISTS StudentCourseEnrollment;
DROP TABLE IF EXISTS timeslots;
DROP TABLE IF EXISTS instructors;
DROP TABLE IF EXISTS Student;
DROP TABLE IF EXISTS courses;



CREATE TABLE courses (
    id INT PRIMARY KEY,
    name NVARCHAR(255) NOT NULL,
    color NVARCHAR(20) NOT NULL,
    department NVARCHAR(100) NOT NULL
);

-- Insert courses into the 'courses' table
INSERT INTO courses (id, name, color, department)
VALUES
(101, 'MLOps', '#A9D2E1', 'Computer Science'),
(102, 'Network Security','#C1D8E7', 'Computer Science'),
(103, 'Machine Learning', '#8C9FB2', 'Computer Science'),
(104, 'Web Development',  '#ADC4D6', 'Computer Science'),
(105, 'Database Management',  '#9CA8B9', 'Computer Science'),
(106, 'Cybersecurity',  '#ADC4D6', 'Computer Science'),
(107, 'Artificial Intelligence','#8C9FB2', 'Computer Science'),
(108, 'Cloud Computing','#C1D8E7', 'Computer Science'),
(109, 'Human-Computer Interaction','#ADC4D6', 'Computer Science'),
(110, 'Software Testing', '#9CA8B9', 'Computer Science'),
(111, 'Mobile App Development','#A9D2E1', 'Computer Science'),
(112, 'Robotics',  '#C1D8E7', 'Computer Science'),
(113, 'Data Warehousing', '#8C9FB2', 'Computer Science'),
(114, 'Game Development', '#C1D8E7', 'Computer Science'),
(115, 'IoT Programming',  '#9CA8B9', 'Computer Science'),
(116, 'E-commerce Technologies',  '#A9D2E1', 'Computer Science'),
(117, 'Big Data Analytics', '#C1D8E7', 'Computer Science'),
(118, 'Embedded Systems','#9CA8B9', 'Computer Science');

Select * from courses;

-- Create courseSections table
CREATE TABLE courseSections (
    courseID INT,
    section NVARCHAR(1),
    PRIMARY KEY (courseID, section),
    FOREIGN KEY (courseID) REFERENCES courses(id)
);

-- Insert data into courseSections table
INSERT INTO courseSections (courseID, section)
VALUES
(101, 'A'), (101, 'B'),
(102, 'A'), (102, 'B'), (102, 'C'),
(103, 'A'), (103, 'B'),
(104, 'A'), (104, 'B'), (104, 'C'),
(105, 'A'), (105, 'B'),
(106, 'A'), (106, 'B'), (106, 'C'),
(107, 'A'), (107, 'B'), (107, 'C'),
(108, 'A'), (108, 'B'), (108, 'C'),
(109, 'A'), (109, 'B'),
(110, 'A'), (110, 'B'), (110, 'C'),
(111, 'A'), (111, 'B'),
(112, 'A'), (112, 'B'), (112, 'C'),
(113, 'A'), (113, 'B'),
(114, 'A'), (114, 'B'), (114, 'C'),
(115, 'A'), (115, 'B'),
(116, 'A'), (116, 'B'), (116, 'C'),
(117, 'A'), (117, 'B'),
(118, 'A'), (118, 'B');

-- Check the data in the courseSections table
SELECT * FROM courseSections;

--INSTRUCTORS 
CREATE TABLE instructors (
    id INT PRIMARY KEY,
    name NVARCHAR(255) NOT NULL
);

-- Insert data into instructors table
INSERT INTO instructors (id, name)
VALUES
(111, 'Dr. Ramesh Kumar'),
(211, 'Dr. Suresh Mehta'),
(322, 'Dr. Anil Verma'),
(433, 'Dr. Vijay Sharma'),
(523, 'Dr. Rajesh Patel'),
(612, 'Dr. Mohan Iyer'),
(765, 'Dr. Sunil Nair'),
(834, 'Dr. Neelam Desai'),
(936, 'Dr. Kavita Reddy'),
(109, 'Dr. Ashok Menon'),
(113, 'Dr. Prakash Joshi'),
(128, 'Dr. Pooja Kapoor'),
(139, 'Dr. Arvind Yadav'),
(145, 'Dr. Dinesh Bhatia'),
(156, 'Dr. Meenakshi Pillai'),
(163, 'Ms. Ananya Gupta'),
(172, 'Ms. Shweta Jain'),
(189, 'Mr. Karan Malhotra'),
(190, 'Ms. Isha Agarwal'),
(204, 'Mr. Rohan Kulkarni'),
(216, 'Mr. Sandeep Saxena'),
(228, 'Mr. Aman Choudhary'),
(239, 'Mr. Rohit Sharma'),
(243, 'Mr. Nikhil Deshmukh'),
(254, 'Ms. Radhika Nanda'),
(265, 'Mr. Manish Chauhan'),
(277, 'Mr. Vikram Singh');


SELECT * FROM instructors;

ALTER TABLE courses
ADD instructor_id INT,
CONSTRAINT FK_instructor_id FOREIGN KEY (instructor_id) REFERENCES instructors(id);

-- Create courses taaught by which instructor
CREATE TABLE CoursesTaughtBy (
    instructor_id INT,
    course_id INT,
    section NVARCHAR(1),
    PRIMARY KEY (instructor_id, course_id, section),
    FOREIGN KEY (instructor_id) REFERENCES instructors(id),
    FOREIGN KEY (course_id, section) REFERENCES courseSections(courseID, section)
);

-- Insert data into instructors_taught_by table (assigning instructors to teach courses and sections)
-- Ensure each instructor teaches a maximum of 3 sections
INSERT INTO CoursesTaughtBy (instructor_id, course_id, section)
VALUES

(111, 101, 'A'), (111, 101, 'B'), --MLOPS
(612, 102, 'A'), (190, 102, 'B'), (211, 102, 'C'), --NetSec
(228, 103, 'A'), (936, 103, 'B'), --ML
(113, 104, 'A'), (113, 104, 'B'), (163, 104, 'C'), --web
(765, 105, 'A'),(765, 105, 'B'), --DB
(523, 106, 'A'), (523, 106, 'B'),(145, 106, 'C'), --cyber
(228, 107, 'A'), (322, 107, 'B'), (243, 107, 'C'), --AI
(433, 108, 'A'), (523, 108, 'B'),(433, 108, 'C'), --cloud
(128, 109, 'A'),(128, 109, 'B'), --HCI
(172,110,'A'),(172,110,'B'),(172,110,'C'), --S/w testing
(228,111,'A'),(243,111,'B'), --mobile app
(265,112,'A'),(139,112,'B'),(189,112,'C'), --robotics
(254,113,'A'),(216,113,'B'), --data warehousing
(204,114,'A'),(204,114,'B'),(277,114,'C'), --game dev
(156,115,'A'),(145,115,'B'), --IOT
(109,116,'A'),(109,116,'B'),(612,116,'C'), --ecommerce tech
(139,117,'A'),(239,117,'B'), --bigdata
(189,118,'A'),(189,118,'B');--embedded 

SELECT * FROM CoursesTaughtBy;



CREATE TABLE timeslots (
    id INT PRIMARY KEY IDENTITY(1,1),
    course_name NVARCHAR(255) NOT NULL,
    start_time DATETIME NOT NULL,
    end_time DATETIME NOT NULL,
    room_number NVARCHAR(10) NOT NULL
);



CREATE TABLE Student (
    RollNumber VARCHAR(8) PRIMARY KEY,
    Name NVARCHAR(100),
    ParentSection NVARCHAR(50),
    Degree NVARCHAR(50),
    Batch INT,
    Gender NVARCHAR(10),
    Email NVARCHAR(100),
    DateOfBirth DATE,
    CNIC CHAR(13),
    MobileNumber VARCHAR(15),
    BloodGroup NVARCHAR(5),
    Nationality NVARCHAR(50)
);

INSERT INTO Student (RollNumber, Name, ParentSection, Degree, Batch, Gender, Email, DateOfBirth, CNIC, MobileNumber, BloodGroup, Nationality) VALUES 
('20I-0546', 'Rohit Sharma', 'CS-A', 'CS', 20, 'male', 'r.sharma@gmail.com', '2002-04-01', '4210197475887', '+91 93319409717', 'A+', 'Indian'),
('20I-0547', 'Priya Mehta', 'CS-B', 'CS', 20, 'female', 'p.mehta@gmail.com', '2002-06-15', '4210197475888', '+91 93329409718', 'B+', 'Indian'),
('20I-0548', 'Aarti Singh', 'CS-C', 'CS', 20, 'female', 'a.singh@gmail.com', '2002-07-22', '4210197475889', '+91 93339409719', 'O+', 'Indian'),
('20I-0549', 'Suresh Verma', 'CS-D', 'CS', 20, 'male', 's.verma@gmail.com', '2002-03-30', '4210197475890', '+91 93349409720', 'AB+', 'Indian'),
('20I-0550', 'Amit Patel', 'CS-E', 'CS', 20, 'male', 'a.patel@gmail.com', '2002-05-25', '4210197475891', '+91 93359409721', 'A-', 'Indian'),
('20I-0551', 'Neha Iyer', 'CS-F', 'CS', 20, 'female', 'n.iyer@gmail.com', '2002-08-10', '4210197475892', '+91 93369409722', 'B-', 'Indian'),
('21I-0552', 'Rahul Nair', 'CS-A', 'CS', 21, 'male', 'r.nair@gmail.com', '2003-01-15', '4210197475893', '+91 93379409723', 'O-', 'Indian'),
('21I-0553', 'Kavya Reddy', 'CS-B', 'CS', 21, 'female', 'k.reddy@gmail.com', '2003-11-20', '4210197475894', '+91 93389409724', 'AB-', 'Indian'),
('21I-0554', 'Vikram Joshi', 'CS-C', 'CS', 21, 'male', 'v.joshi@gmail.com', '2003-09-05', '4210197475895', '+91 93399409725', 'A+', 'Indian'),
('21I-0555', 'Sneha Desai', 'CS-D', 'CS', 21, 'female', 's.desai@gmail.com', '2003-12-30', '4210197475896', '+91 93409409726', 'B+', 'Indian'),
('21I-0556', 'Arjun Menon', 'CS-E', 'CS', 21, 'male', 'a.menon@gmail.com', '2003-02-19', '4210197475897', '+91 93419409727', 'O+', 'Indian'),
('21I-0557', 'Pooja Sharma', 'CS-F', 'CS', 21, 'female', 'p.sharma@gmail.com', '2003-04-27', '4210197475898', '+91 93429409728', 'AB+', 'Indian'),
('22I-0558', 'Sanjay Gupta', 'CS-A', 'CS', 22, 'male', 's.gupta@gmail.com', '2004-06-16', '4210197475899', '+91 93439409729', 'A-', 'Indian'),
('22I-0559', 'Anjali Kapoor', 'CS-B', 'CS', 22, 'female', 'a.kapoor@gmail.com', '2004-10-11', '4210197475900', '+91 93449409730', 'B-', 'Indian'),
('22I-0560', 'Rakesh Yadav', 'CS-C', 'CS', 22, 'male', 'r.yadav@gmail.com', '2004-08-23', '4210197475901', '+91 93459409731', 'O-', 'Indian'),
('22I-0561', 'Meera Nanda', 'CS-D', 'CS', 22, 'female', 'm.nanda@gmail.com', '2004-07-14', '4210197475902', '+91 93469409732', 'AB-', 'Indian'),
('22I-0562', 'Tarun Bhatia', 'CS-E', 'CS', 22, 'male', 't.bhatia@gmail.com', '2004-03-08', '4210197475903', '+91 93479409733', 'A+', 'Indian'),
('22I-0563', 'Shreya Pillai', 'CS-F', 'CS', 22, 'female', 's.pillai@gmail.com', '2004-05-21', '4210197475904', '+91 93489409734', 'B+', 'Indian'),
('23I-0564', 'Anil Kumar', 'CS-A', 'CS', 23, 'male', 'a.kumar@gmail.com', '2005-01-01', '4210197475905', '+91 93499409735', 'O+', 'Indian'),
('23I-0565', 'Nisha Jain', 'CS-B', 'CS', 23, 'female', 'n.jain@gmail.com', '2005-02-28', '4210197475906', '+91 93509409736', 'AB+', 'Indian');



SELECT * from Student;

CREATE TABLE StudentCourseEnrollment (
    --EnrollmentID INT PRIMARY KEY IDENTITY(1,1),
    RollNumber VARCHAR(8),
    CourseID INT,
    CourseSection NVARCHAR(1), 
    EnrollmentDate DATE,
    CONSTRAINT PK_StudentCourseEnrollment PRIMARY KEY (RollNumber, CourseID, CourseSection),
    FOREIGN KEY (RollNumber) REFERENCES Student(RollNumber),
    FOREIGN KEY (CourseID, CourseSection) REFERENCES courseSections(courseID, section)
);



INSERT INTO StudentCourseEnrollment (RollNumber, CourseID, CourseSection, EnrollmentDate)
VALUES
('20I-0546', 101, 'A', '2023-01-15'),
('20I-0547', 102, 'B', '2023-01-15'),
('20I-0548', 103, 'B', '2023-01-15'),
('20I-0546', 102, 'A', '2023-01-15'),
('20I-0547', 109, 'B', '2023-01-16'),
('20I-0547', 110, 'C', '2023-01-17'),
('20I-0548', 104, 'B', '2023-01-16'),
('20I-0548', 116, 'C', '2023-01-16'),
('22I-0563', 103, 'B', '2023-01-15'),
('22I-0563', 104, 'B', '2023-01-15'),
('23I-0565', 103, 'A', '2023-01-18'),
('23I-0565', 101, 'A', '2023-01-18');
INSERT INTO StudentCourseEnrollment (RollNumber, CourseID, CourseSection, EnrollmentDate)
VALUES ('22I-0558',116,'A','2023-01-12');

SELECT * from StudentCourseEnrollment;


-- Create the buildings table
CREATE TABLE buildings (
    id INT IDENTITY(1,1) PRIMARY KEY,
    name VARCHAR(255) NOT NULL
);

-- Insert sample data for buildings
INSERT INTO buildings (name) VALUES ('A'), ('B'), ('C');

-- Create the rooms table
CREATE TABLE rooms (
    id INT IDENTITY(1,1) PRIMARY KEY,
    room_number INT NOT NULL,
    building_id INT FOREIGN KEY REFERENCES buildings(id) ON DELETE CASCADE
);


INSERT INTO rooms (room_number, building_id) 
VALUES
    (108, 1), (211, 1),(301, 1),(302, 1),(303, 1),(305, 1),--A block
	(310, 1),(311, 1),(314, 1),(315, 1),(316, 1),
	(130, 2),(227, 2),(229, 2),(230,2), --B block
	(110, 3),(301, 3),(302, 3),(303, 3),(304, 3),(305, 3),--C block
	(307, 3),(308, 3),(309, 3),(310, 3),(311, 3),
	(401, 3),(402, 3),(403, 3),(404, 3),(405, 3),
	(406, 3),(407, 3),(408, 3),(409, 3),(410, 3);
