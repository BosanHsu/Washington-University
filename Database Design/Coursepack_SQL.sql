USE coursepacks;

#1 Select articles (all types, articles, cases,…) with authors name start with letter “R” where
# ProtagonistRace is not white. List the title, price, and format. 

SELECT Author, Title, Price, Format
FROM articles
WHERE ProtagonistRace != "White" AND Author LIKE "R%";

#2) Select students with a GPA higher than the average GPA of all students. List student name, gender,
#   and GPA. 

SELECT StudentName, Gender, GPA
FROM students
WHERE GPA > ( SELECT AVG( GPA ) FROM students);

#3 List students who have a higher than average GPA. Include student name, major, year, GPA,
#  course number, and enrollment date. Sort the result by GPA in descending order. Sort the results
#  to show the highest GPAs first. 

SELECT students.StudentName, Major, Year, GPA, CourseNumber, EnrollmentDate
FROM students, enrollments
WHERE students.StudentName = enrollments.StudentName AND GPA > ( SELECT AVG( GPA ) FROM students)
ORDER BY GPA DESC;

#4 List the names of all the students who are taking more credits than the average in the current
#  semester. List the student name, and number of current credits taking. 

SELECT StudentName, CurrentCredits
FROM students
WHERE CurrentCredits > ( SELECT AVG( CurrentCredits ) FROM students );

#5 List all article (all types, articles, cases…) titles with price higher than the average article price.
#  Also list their price, publication year and assigned date. Sort the result by article title in ascending
#  order. 

SELECT Title, Price, YEAR(PublicationDate), AssignedDate
FROM articles, COURSEPACKS
WHERE articles.ArticleNumber = coursepacks.ArticleNumber AND Price > ( SELECT AVG( Price ) FROM articles ) 
ORDER BY Title;

#6 Find all of the articles (all types, articles, cases…) that were published on January 1st 2014. Sort
# the result by article title in descending order. List the publication date and title. 

SELECT Title, PublicationDate
FROM articles
WHERE PublicationDate = "2014-01-01" 
ORDER BY Title DESC;

#7 List the courses with a course name that has a letter S in the name and have a number of students
#  higher than the average number of students enrolled. List course number, name, and number of
#  students enrolled

SELECT courses.CourseNumber, courses.Name, COUNT(enrollments.StudentName) AS EnrollmentCount
FROM courses INNER JOIN enrollments
ON courses.CourseNumber = enrollments.CourseNumber
WHERE LOWER(courses.Name) LIKE "%s%"
GROUP BY courses.CourseNumber, courses.Name
HAVING COUNT(enrollments.StudentName) > 
	( SELECT AVG( EnrollmentCount ) 
      FROM( SELECT enrollments.CourseNumber, COUNT(enrollments.StudentName) AS EnrollmentCount FROM enrollments GROUP BY CourseNumber) 
	  AS Average );

#8 How many days passed between the assigned dates of the required article of DAT 560 with the 
#  earliest assigned date and the one with the latest assigned date? Hint: use subqueries.  
SELECT DATEDIFF(
    (SELECT MAX(AssignedDate) FROM coursepacks WHERE CourseNumber = "DAT 560" AND Required = "Required"),
    (SELECT MIN(AssignedDate) FROM coursepacks WHERE CourseNumber = "DAT 560" AND Required = "Required")
) AS DateDifference;

#9  How many male and female faculty assign group assignments respectively, exclude those without 
# a faculty name?
SELECT FacultyGender, COUNT(FacultyGender)
FROM courses INNER JOIN coursepacks ON courses.CourseNumber = coursepacks.CourseNumber
WHERE FacultyName IS NOT NULL AND coursepacks.Group = "Y"
GROUP BY FacultyGender
ORDER BY FacultyGender DESC;

SELECT FacultyGender, COUNT(FacultyGender)
FROM courses
WHERE EXISTS 
		(SELECT * FROM coursepacks WHERE courses.CourseNumber = coursepacks.CourseNumber
		AND FacultyName IS NOT NULL AND coursepacks.Group = "Y")
GROUP BY FacultyGender
ORDER BY FacultyGender DESC;

#10 For students with the letter “e” in their names, find the greatest and least total credit, and the 
#   difference between these two values. Only show one row.
SELECT MAX, MIN, (MAX - MIN) AS DIFF
FROM 
	(SELECT MAX(TotalCredit) AS MAX, MIN(TotalCredit) AS MIN
	FROM students
    WHERE LOWER(StudentName) LIKE "%e%" ) AS E;
    
#11 Which majors are the most popular?  Answer this question by listing the majors that have more 
#   students than the average. List the major and number of students in that major.
SELECT Major, COUNT(StudentName) AS NumOfStudents
FROM students
GROUP BY Major
HAVING COUNT(StudentName) > 
	( SELECT AVG( NumOfStudents ) 
      FROM ( SELECT COUNT(StudentName) AS NumOfStudents
			 FROM students
             GROUP BY Major) AS Numbers
      GROUP BY Major);
      
#12 Find titles with prices higher than the average price of the articles (all types, articles, cases…) not 
#   selected in any course packs. List only the title and order by the title name. 

SELECT Title
FROM articles
WHERE Price > ( SELECT AVG(Price)
				FROM articles LEFT JOIN coursepacks
                USING(ArticleNumber)
                WHERE coursepacks.CourseNumber IS NULL)
ORDER BY Title;


