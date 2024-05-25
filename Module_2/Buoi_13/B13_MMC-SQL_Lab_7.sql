USE				testing_system_db
;

-- Question 1: Tạo trigger không cho phép người dùng nhập vào Group có ngày tạo trước 1 năm trước
DROP TRIGGER IF EXISTS group_date_check;
DELIMITER //
CREATE TRIGGER group_date_check
	BEFORE INSERT ON jobgroup
    FOR EACH ROW
    BEGIN
		DECLARE u_create_date DATETIME;
        SET u_create_date = DATE_SUB(NOW(), INTERVAL 1 YEAR);
		IF NEW.CreateDate <=  u_create_date THEN
			SIGNAL SQLSTATE "12345"
            SET MESSAGE_TEXT = "Can not create this group before 8 year";
		END IF;
    END //
DELIMITER ;

SHOW TRIGGERS;

INSERT INTO jobgroup( GroupName			, CreatorID		, CreateDate)
VALUES 				(N'Testing Sgroup_date_checkystem 2',   1			,'2013-03-05');

-- Question 2: Tạo trigger Không cho phép người dùng thêm bất kỳ user nào vào department "Sale" nữa, 
-- khi thêm thì hiện ra thông báo "Department "Sale" cannot add more user"
DROP TRIGGER IF EXISTS not_add_sale_dept;
DELIMITER //
CREATE TRIGGER not_add_sale_dept
	BEFORE INSERT ON jobaccount
    FOR EACH ROW
	BEGIN
		DECLARE 	u_deptID INT;
        SELECT 		DepartmentID INTO u_deptID
        FROM		department
        WHERE		DepartmentName = 'Sale';
        IF NEW.DepartmentID = u_deptID THEN
			SIGNAL SQLSTATE "12345"
            SET MESSAGE_TEXT = "Can not create user in 'Sale' Department";
		END IF;
    END //
DELIMITER ;

INSERT INTO jobaccount(Email				, Username			, FullName				, DepartmentID	, PositionID, CreateDate)
VALUES 				('haidangxx4@gmail.com'	, 'dangblack23'		,'Nguyễn hải Đăng'		,   '2'			,   '2'		,'2020-03-05');

--  Question 3: Cấu hình 1 group có nhiều nhất là 5 user
DROP TRIGGER IF EXISTS user_5acc_group
DELIMITER //
CREATE TRIGGER user_5acc_group
	BEFORE INSERT ON groupaccount
    FOR EACH ROW
	BEGIN
		DECLARE		acc_count INT;
		SELECT 		COUNT(*) INTO acc_count
		FROM		groupaccount
		WHERE 		GroupId = NEW.GroupId;
	
		IF acc_count >= 5 THEN
			SIGNAL SQLSTATE "45000"
            SET MESSAGE_TEXT = "Maximum of Quantity user in each group is 5 user";
		END IF;
    END //
DELIMITER ;

INSERT INTO jobaccount(Email				, Username			, FullName				, DepartmentID	, PositionID, CreateDate)
VALUES 				('haidangxx4@gmail.com'	, 'haidangxx4'		,'Nguyễn hải Đăng Phạm'	,   '10'		,   '2'		,'2020-03-05');

INSERT INTO groupaccount	(  GroupID	, AccountID	, JoinDate	 )
VALUES 						(	'1'		,    '27'		,'2020-03-05');

-- Question 4: Cấu hình 1 bài thi có nhiều nhất là 3 Question 
-- Đổi : 1 question có nhiều nhất 3 bài thi
DROP TRIGGER IF EXISTS max3_exam_question;
DELIMITER //
CREATE TRIGGER max3_exam_question
	BEFORE INSERT ON examquestion
    FOR EACH ROW
    BEGIN
		DECLARE 	u_questionid INT;
		SELECT 		COUNT(*) INTO u_questionid
		FROM		examquestion
		WHERE		QuestionID = NEW.QuestionID
		;
        IF u_questionid >= 3 THEN
			SIGNAL SQLSTATE "45000"
            SET MESSAGE_TEXT = "Maximum of Quantity exam in each question is 3";
		END IF;
	END //
DELIMITER ;

DELETE FROM examquestion
WHERE		ExamID = 11;
INSERT INTO examquestion(ExamID	, QuestionID	) 
VALUES 					(11		,		2		);

-- Question 5: Tạo trigger không cho phép người dùng xóa tài khoản có email là admin@gmail.com 
-- (đây là tài khoản admin, không cho phép user xóa), còn lại các tài khoản khác thì sẽ cho phép xóa và 
-- sẽ xóa tất cả các thông tin liên quan tới user đó.

INSERT INTO jobaccount(Email				, Username		, FullName		, DepartmentID	, PositionID, CreateDate)
VALUES 				('admin@gmail.com'		, 'admin1'		,'admin1'		,   '8'			,   '3'		,'2020-01-01');

DROP TRIGGER IF EXISTS admin_delete;
DELIMITER //
CREATE TRIGGER admin_delete
	BEFORE DELETE ON jobaccount
    FOR EACH ROW
    BEGIN
        IF OLD.email = 'admin@gmail.com' THEN
			SIGNAL SQLSTATE "45000"
            SET MESSAGE_TEXT = "Can not delete email : admin@gmail.com ";
		END IF;
	END //
DELIMITER ;

DELETE FROM		jobaccount
WHERE			email = 'admin@gmail.com';

--  Question 6: Không sử dụng cấu hình default cho field DepartmentID của table Account,
-- hãy tạo trigger cho phép người dùng khi tạo account không điền vào departmentID thì sẽ được phân vào phòng ban "waiting Department".
DROP TRIGGER IF EXISTS default_depart;
DELIMITER //
CREATE TRIGGER default_depart
	BEFORE INSERT ON jobaccount
    FOR EACH ROW
    BEGIN
    DECLARE u_departmentID INT DEFAULT 12;
        IF NEW.DepartmentID IS NULL THEN 
			SET NEW.DepartmentID = u_departmentID;
		END IF;
	END //
DELIMITER ;

INSERT INTO jobaccount(Email				, Username		, FullName		, DepartmentID	, PositionID, CreateDate)
VALUES 				('thienphong@gmail.com'	, 'thienphong'	,'thienphong1'	,   	Null	,   '2'		,'2020-05-01');

--  Question 7: Cấu hình 1 bài thi chỉ cho phép user tạo tối đa 4 answers cho mỗi question, trong đó có tối đa 2 đáp án đúng.
DROP TRIGGER IF EXISTS max4ans_2right_question;
DELIMITER //
CREATE TRIGGER max4ans_2right_question
	BEFORE INSERT ON answer
    FOR EACH ROW
    BEGIN
		DECLARE 	u_questionid INT; 
        DECLARE		u_iscorrect BOOLEAN;
        
		SELECT 		COUNT(*) INTO u_questionid
		FROM		answer
		WHERE		QuestionID = NEW.QuestionID;
        
        SELECT 		COUNT(*) INTO u_iscorrect
		FROM		answer
		WHERE		QuestionID = NEW.QuestionID AND isCorrect = TRUE;
        
        IF u_questionid >= 4 THEN
			SIGNAL SQLSTATE "45000"
            SET MESSAGE_TEXT = "Can not create this group_q7_1";
		END IF;
        
		IF NEW.isCorrect = TRUE AND u_iscorrect > 2 THEN
			SIGNAL SQLSTATE "45000"
            SET MESSAGE_TEXT = "Can not create this group_q7_2";
		END IF;
	END //
DELIMITER ;

-- Có thể gộp 2 truy vấn SELECT trong Trigger
-- SELECT 
		-- COUNT(*) INTO u_total_answers,
		-- SUM(CASE WHEN isCorrect = TRUE THEN 1 ELSE 0 END) INTO u_correct_answers
-- FROM    answer
-- WHERE   QuestionID = NEW.QuestionID;

INSERT INTO Answer	(ContentAnswer	, QuestionID	, isCorrect	)
VALUES 				(N'Trả lời 11'	,   1			,	1		);


--  Question 8: Viết trigger sửa lại dữ liệu cho đúng:
-- ● Nếu người dùng nhập vào gender của account là nam, nữ, chưa xác định
-- ● Thì sẽ đổi lại thành M, F, U cho giống với cấu hình ở database
ALTER TABLE		jobaccount
ADD COLUMN		Gender ENUM('M', 'F', 'U');

SET SQL_SAFE_UPDATES = 0;
UPDATE 			jobaccount
SET				Gender = 'F'
WHERE			AccountID IN (4,6,7,10);
SET SQL_SAFE_UPDATES = 1;

ALTER TABLE jobaccount
MODIFY COLUMN Gender VARCHAR(10);

DROP TRIGGER IF EXISTS gender_alter;
DELIMITER //
CREATE TRIGGER gender_alter
	BEFORE INSERT ON jobaccount
    FOR EACH ROW
    BEGIN
        IF NEW.Gender = 'male' THEN 
            SET NEW.Gender = 'M';
        ELSEIF NEW.Gender = 'female' THEN 
            SET NEW.Gender = 'F';
        ELSEIF NEW.Gender IS NULL THEN 
            SET NEW.Gender = 'U';
		END IF;
	END //
DELIMITER ;

INSERT INTO jobaccount(Email			, Username	, FullName	, DepartmentID	, PositionID, CreateDate	, Gender)
VALUES 				('hathu@gmail.com'	, 'hathu'	,'hathu'	,   	Null	,   '2'		,'2020-06-01'	, 'female');

-- Khi đã set định dạng của cột thì không thể nhập khác định dạng dù đã dùng Trigger để thay đổi về đúng định dạng

-- Question 9: Viết trigger không cho phép người dùng xóa bài thi mới tạo được 2 ngày

INSERT INTO Question(ContentQuestion			, CategoryID, TypeID		, CreatorID	, CreateDate )
VALUES 				(N'Câu hỏi về Java nâng cao',	1		,   '1'			,   '21'	,'2024-05-23');

DROP TRIGGER IF EXISTS before2d_question_delete;
DELIMITER //
CREATE TRIGGER before2d_question_delete
	BEFORE DELETE ON question
    FOR EACH ROW
    BEGIN
        IF OLD.CreateDate > DATE_SUB(NOW(), INTERVAL 2 DAY) THEN
			SIGNAL SQLSTATE "45000"
            SET MESSAGE_TEXT = "'Cannot delete this question as it is within the 2-day restriction.'";
		END IF;
	END //
DELIMITER ;

DELETE FROM		question
WHERE			QuestionID = 12;

--  Question 10: Viết trigger chỉ cho phép người dùng chỉ được update, delete các question khi question đó chưa nằm trong exam nào
DROP TRIGGER IF EXISTS question_in_exam_delete;
DELIMITER //
CREATE TRIGGER question_in_exam_delete
	BEFORE DELETE ON question
    FOR EACH ROW
    BEGIN
		DECLARE 	question_in_exam INT;
		SELECT		COUNT(*) INTO question_in_exam
        FROM		examquestion
        WHERE 		QuestionID = OLD.QuestionID;
        
        IF question_in_exam > 0 THEN
			SIGNAL SQLSTATE "45000"
            SET MESSAGE_TEXT = "'Cannot delete this question as it exists in exam table.'";
		END IF;
	END //
DELIMITER ;

DROP TRIGGER IF EXISTS question_in_exam_update;
DELIMITER //
CREATE TRIGGER question_in_exam_update
  BEFORE UPDATE ON question
     FOR EACH ROW
     BEGIN
		DECLARE  	question_in_exam INT;
		SELECT  	COUNT(*) INTO question_in_exam
		FROM  		examquestion
		WHERE   	QuestionID = OLD.QuestionID;
			 
		IF question_in_exam > 0 THEN
			SIGNAL SQLSTATE "45000"
			SET MESSAGE_TEXT = "'Cannot update this question as it exists in exam table.'";
	   END IF;
	END //
DELIMITER ;

DELETE FROM		question
WHERE			QuestionID = 2;

UPDATE 			question
SET				ContentQuestion = "PHP"
WHERE			QuestionID = 2;

--  Question 12: Lấy ra thông tin exam trong đó:
-- ● Duration <= 30 thì sẽ đổi thành giá trị "Short time"
-- ● 30 < Duration <= 60 thì sẽ đổi thành giá trị "Medium time"
-- ● Duration > 60 thì sẽ đổi thành giá trị "Long time"
SELECT		ExamID, CodeExam, CASE 
									WHEN Duration <= 30 THEN "Short time"
                                    WHEN Duration <= 60 THEN "Medium time"
                                    ELSE "Long time"
							  END AS Duration
FROM		exam	
;

-- Question 13: Thống kê số account trong mỗi group và in ra thêm 1 column nữa có tên là the_number_user_amount và mang giá trị được quy định như sau:
-- ● Nếu số lượng user trong group =< 5 thì sẽ có giá trị là few
-- ● Nếu số lượng user trong group <= 20 và > 5 thì sẽ có giá trị là normal
-- ● Nếu số lượng user trong group > 20 thì sẽ có giá trị là higher
SELECT		GroupID, COUNT(GroupID) AS UserAccount, CASE
														WHEN COUNT(GroupID) <= 4 THEN 'few'
                                                        WHEN COUNT(GroupID) <= 20 THEN 'normal'
														ELSE 'higher'
                                                    END AS The_number_user_amount
FROM		groupaccount
GROUP BY	GroupID
;

--  Question 14: Thống kê số mỗi phòng ban có bao nhiêu user, nếu phòng ban nào không có user thì sẽ thay đổi giá trị 0 thành "Không có User"
INSERT INTO Department	(DepartmentName) 
VALUES					(N'Mua hàng'	);

SELECT		d.DepartmentID, d.DepartmentName, CASE 
													WHEN COUNT(a.DepartmentID) = 0 THEN "Không có User"
                                                    ELSE COUNT(a.DepartmentID)
											  END AS User_Count
FROM		department d
LEFT JOIN	jobaccount a
ON			d.DepartmentID = a.DepartmentID
GROUP BY	d.DepartmentID, d.DepartmentName
;
