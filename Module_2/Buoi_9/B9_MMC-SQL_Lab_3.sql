USE 	testing_system_db;

-- Question 1: Thêm ít nhất 10 record vào mỗi table
SELECT 		* 
FROM 		answer
LIMIT 		5;

-- Question 2: Lấy ra tất cả các phòng ban Department
SELECT 		* 
FROM 		department;

-- Question 3: Lấy ra id của phòng ban "Sale"
SELECT 		DepartmentID
FROM 		department
WHERE 		DepartmentName = 'Sale';

-- Question 4: lấy ra thông tin account có full name dài nhất
UPDATE 		jobaccount
SET 		FullName = 'Nguyễn Đăng hải'
WHERE 		Email = 'account1@gmail.com';

SELECT 		FullName, LENGTH(FullName)
FROM 		jobaccount
WHERE 		LENGTH(FullName) = (SELECT MAX(LENGTH(FullName))
							FROM jobaccount);

-- Question 5: Lấy ra thông tin account có full name dài nhất và thuộc phòng ban có id = 3
INSERT INTO jobaccount(Email								, Username			, FullName				, DepartmentID	, PositionID, CreateDate)
VALUES 				('haidang30productions@gmail.com'		, 'dangwhite'		,'Nguyễn hải Đăng'		,   '3'			,   '3'		,'2020-03-06');

SELECT 		FullName, LENGTH(FullName), DepartmentID
FROM 		jobaccount
WHERE 		LENGTH(FullName) = (SELECT MAX(LENGTH(FullName))
							FROM jobaccount) && DepartmentID = '3';

-- Question 6: Lấy ra tên group đã tham gia trước ngày 20/12/2019
SELECT 		GroupName
FROM		jobgroup
WHERE		CreateDate < "2019/12/20";

-- Question 7: Lấy ra ID của question có >= 4 câu trả lời
SELECT 		COUNT(QuestionID), 	QuestionID
FROM		answer
GROUP BY	QuestionID
HAVING		COUNT(QuestionID) >=4;

-- Question 8: Lấy ra các mã đề thi có thời gian thi >= 60 phút và được tạo trước ngày 20/12/2019
SELECT		ExamID
FROM		exam
WHERE		Duration >= 60 AND	CreateDate < "2019/12/20";

-- Question 9: Lấy ra 5 group được tạo gần đây nhất
SELECT		GroupName, CreateDate
FROM		jobgroup
ORDER BY	CreateDate DESC
LIMIT		5;

-- Question 10: Đếm số nhân viên thuộc department có id = 2
SELECT		DepartmentID, COUNT(DepartmentID)
FROM		jobaccount
WHERE		DepartmentID = 2
GROUP BY	DepartmentID;	

-- Question 11: Lấy ra nhân viên có tên bắt đầu bằng chữ "D" và kết thúc bằng chữ "o"
SELECT		FullName
FROM		jobaccount
WHERE		FullName LIKE "D%o";

-- Question 12: Xóa tất cả các exam được tạo trước ngày 20/12/2019

-- Xóa khóa ngoại
ALTER TABLE 		examquestion
DROP FOREIGN KEY 	examquestion_ibfk_1;		

-- Tạo lại khóa ngoại với điều kiện nếu bảng cha xóa thì sẽ xóa bảng con
ALTER TABLE 		examquestion
ADD CONSTRAINT 		examquestion_ibfk_1 FOREIGN KEY (ExamID) REFERENCES exam (ExamID) ON DELETE CASCADE;

SET SQL_SAFE_UPDATES = 0;					-- Tắt chế độ safe update tạm thời

DELETE FROM			exam
WHERE				CreateDate < "2019-12-20";

SET SQL_SAFE_UPDATES = 1;					-- Bật lại chế độ safe update tạm thời

-- Tạo lại dữ liệu đã xóa
INSERT INTO Exam	(CodeExam		, Title					, CategoryID	, Duration	, CreatorID		, CreateDate )
VALUES 				('VTIQ001'		, N'Đề thi C#'			,	1			,	60		,   '5'			,'2019-04-05'),
					('VTIQ002'		, N'Đề thi PHP'			,	10			,	60		,   '2'			,'2019-04-05'),
                    ('VTIQ003'		, N'Đề thi C++'			,	9			,	120		,   '2'			,'2019-04-07');

-- Question 13: Xóa tất cả các question có nội dung bắt đầu bằng từ "câu hỏi"
ALTER TABLE			answer
DROP FOREIGN KEY	answer_ibfk_1;

ALTER TABLE			answer
ADD CONSTRAINT		answer_ibfk_1 FOREIGN KEY (QuestionID) REFERENCES question (QuestionID) ON DELETE CASCADE;

-- Cần thêm lệnh ON DELETE CASCADE tại khóa ngoại trong bảng examquestion 

SET SQL_SAFE_UPDATES = 0;					-- Tắt chế độ safe update tạm thời

DELETE FROM			question
WHERE				ContentQuestion LIKE "Câu hỏi%";

SET SQL_SAFE_UPDATES = 1;					-- Bật lại chế độ safe update tạm thời

-- Question 14: Update thông tin của account có id = 5 thành tên "Lô Văn Đề" và email thành lo.vande@mmc.edu.vn
UPDATE 			jobaccount	
SET				FullName = "Lô Văn Đề" , Email = "lo.vande@mmc.edu.vn"
WHERE			AccountID = 5;

-- Question 15: Update account có id = 5 sẽ thuộc group có id = 4
UPDATE			groupaccount
SET				GroupID = 4
WHERE			AccountID = 5;