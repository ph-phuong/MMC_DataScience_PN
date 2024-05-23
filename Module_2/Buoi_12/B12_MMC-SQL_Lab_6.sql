USE				testing_system_db
;

-- Question 1: Tạo store để người dùng nhập vào tên phòng ban và in ra tất cả các account thuộc phòng ban đó
DROP PROCEDURE IF EXISTS AccountInDept;
DELIMITER $$
CREATE PROCEDURE AccountInDept (IN dept_name NVARCHAR(20))
	BEGIN
		SELECT			d.DepartmentName, a.AccountID, a.FullName
        FROM			department d
        LEFT JOIN		jobaccount a
        ON				a.DepartmentID = d.DepartmentID
        WHERE			d.DepartmentName = dept_name
        ;
    END$$
DELIMITER ;

CALL AccountInDept(N'Bán hàng');

-- Question 2: Tạo store để in ra số lượng account trong mỗi group
DROP PROCEDURE IF EXISTS AccountInGroup ;
DELIMITER $$
CREATE PROCEDURE AccountInGroup ()
	BEGIN
		SELECT			ga.GroupID, jg.GroupName, COUNT(ga.GroupID)
		FROM 			groupaccount ga
        JOIN			jobgroup jg
        ON				ga.GroupID = jg.GroupID
        GROUP BY		ga.GroupID
        ;
	END $$
DELIMITER ;

CALL AccountInGroup();

-- Question 3: Tạo store để thống kê mỗi type question có bao nhiêu question được tạo trong tháng hiện tại
-- Thống kê mỗi type question có bao nhiêu question theo ngày chọn
DROP PROCEDURE IF EXISTS QuestionInType;
DELIMITER $$
CREATE PROCEDURE QuestionInType (IN found_day INT)
	BEGIN
		SELECT			tq.TypeID, tq.TypeName, COUNT(q.TypeID)
		FROM			question q
		JOIN			typequestion tq
		ON				q.TypeID = tq.TypeID
        WHERE			DAY(q.CreateDate) = found_day
		GROUP BY		q.TypeID
		;
	END $$
DELIMITER ;

CALL QuestionInType(6);

-- Question 4: Tạo store để trả ra id của type question có nhiều câu hỏi nhất
DROP PROCEDURE IF EXISTS MaxQuestionInType;
DELIMITER $$
CREATE PROCEDURE MaxQuestionInType ()
	BEGIN
		WITH CountQuestions AS (
			SELECT			tq.TypeID, COUNT(q.TypeID) AS CountQuestion
			FROM			question q
			JOIN			typequestion tq
			ON				q.TypeID = tq.TypeID
			GROUP BY		q.TypeID
		)
		SELECT		TypeID, CountQuestion
		FROM 		CountQuestions
		WHERE		CountQuestion = (SELECT MAX(CountQuestion) FROM CountQuestions)
		;
	END $$
DELIMITER ;

CALL MaxQuestionInType();

-- Question 5: Sử dụng store ở question 4 để tìm ra tên của type question
DROP PROCEDURE IF EXISTS MaxQuestionInType_Name;
DELIMITER $$
CREATE PROCEDURE MaxQuestionInType_Name (OUT max_question_type_ID INT)
	BEGIN
		WITH CountQuestions AS (
			SELECT			tq.TypeID, COUNT(q.TypeID) AS CountQuestion
			FROM			question q
			JOIN			typequestion tq
			ON				q.TypeID = tq.TypeID
			GROUP BY		q.TypeID
		)
		SELECT		TypeID INTO max_question_type_ID
		FROM 		CountQuestions
		WHERE		CountQuestion = (SELECT MAX(CountQuestion) FROM CountQuestions)
		;
	END $$
DELIMITER ;

SET @max_question_type_ID = NULL;
CALL MaxQuestionInType_Name(@max_question_type_ID);
SELECT 		TypeName
FROM		typequestion
WHERE		TypeID = @max_question_type_ID
;

-- Ghi chú cá nhân: trong mysql, khi tạo Stored Procedure không có tham số thì không thể 
-- 			dùng lệnh truy vấn giữa Stored Procedure và 1 bảng khác, 
-- 			về biến tạm hoặc bảng tạm từ Stored Procedure	


-- Question 6: Viết 1 store cho phép người dùng nhập vào 1 chuỗi và trả về group có tên chứa chuỗi của người dùng nhập vào hoặc 
--  trả về user có username chứa chuỗi của người dùng nhập vào
DROP PROCEDURE IF EXISTS find_account_or_group;
DELIMITER //
CREATE PROCEDURE find_account_or_group (IN input_string VARCHAR(100))
	BEGIN
		SELECT	a.Username, jg.GroupName
		FROM	jobaccount a
		JOIN	groupaccount ga
		ON		a.AccountID = ga.AccountID
		JOIN	jobgroup jg
		ON		ga.GroupID = jg.GroupID
		WHERE	a.Username LIKE CONCAT('%', input_string, '%') OR jg.GroupName LIKE CONCAT('%', input_string, '%')
        ;
	END //
DELIMITER ;
;

CALL find_account_or_group('sale');

-- Question 7: Viết 1 store cho phép người dùng nhập vào thông tin fullName, email và trong store sẽ tự động gán:
-- username sẽ giống email nhưng bỏ phần @..mail đi
-- positionID: sẽ có default là developer
-- departmentID: sẽ được cho vào 1 phòng chờ
-- Sau đó in ra kết quả tạo thành công
DROP PROCEDURE IF EXISTS input_infor;
DELIMITER //
CREATE PROCEDURE input_infor (IN u_full_name VARCHAR(100), IN u_email VARCHAR(100))
	BEGIN
		DECLARE u_user_name VARCHAR(100);
        DECLARE u_positionID INT DEFAULT 1;
        DECLARE u_departmentID INT DEFAULT 1;
        
        SET u_user_name = SUBSTRING_INDEX(u_email, '@', 1);
        
        INSERT INTO jobaccount (Email	,Username	, FullName		,DepartmentID	, PositionID, CreateDate)
        VALUES 				(u_email	,u_user_name	, u_full_name	,u_departmentID	, u_positionID, NOW());
        
        SELECT "Tạo dữ liệu thành công" AS Result;
	END //
DELIMITER ;
;

CALL input_infor('lehai', 'lehai01@gmail.com');
 
-- Question 8: Viết 1 store cho phép người dùng nhập vào Essay hoặc Multiple-Choice để thống kê câu hỏi essay hoặc multiple-choice nào có content dài nhất
DROP PROCEDURE IF EXISTS length_question_Type ;
DELIMITER $$
CREATE PROCEDURE length_question_Type (IN u_user ENUM('Essay', 'Multiple-Choice'))
	BEGIN
		DECLARE longest_content_length INT;
    
		SELECT 		MAX(LENGTH(q.ContentQuestion)) INTO longest_content_length
		FROM 		question q
		JOIN 		typequestion tq ON q.TypeID = tq.TypeID
		WHERE 		tq.TypeName = u_user;
    
		SELECT 		q.ContentQuestion, LENGTH(q.ContentQuestion)
		FROM 		question q
        JOIN		typequestion tq
        ON			q.TypeID = tq.TypeID
        WHERE		tq.TypeName = u_user AND LENGTH(q.ContentQuestion) = longest_content_length
		;
	END $$
DELIMITER ;  

CALL 	length_question_Type ('Multiple-Choice');
     
-- Question 9: Viết 1 store cho phép người dùng xóa exam dựa vào ID
DROP PROCEDURE IF EXISTS  exam_delete;
DELIMITER //
CREATE PROCEDURE exam_delete (IN u_userID INT)
	BEGIN
		DELETE FROM 	exam
        WHERE			CreatorID = u_userID
        ;
    END //
DELIMITER ;

INSERT INTO Exam	(CodeExam		, Title					, CategoryID	, Duration	, CreatorID		, CreateDate )
VALUES 				('VTIQ014'		, N'Đề thi C'			,	1			,	60		,   '1'			,'2020-04-05');

CALL exam_delete('1');

-- Question 10: Tìm ra các exam được tạo từ 9 năm trước và xóa các exam đó đi (sử dụng store ở câu 9 để xóa)
-- Sau đó in số lượng record đã remove từ các table liên quan trong khi removing 
INSERT INTO exam	(CodeExam		, Title					, CategoryID	, Duration	, CreatorID		, CreateDate )
VALUES 				('VTIQ014'		, N'Đề thi C##'			,	1			,	70		,   '5'			,'2015-04-05');

DROP PROCEDURE IF EXISTS  before9y_exam_delete;
DELIMITER //
CREATE PROCEDURE before9y_exam_delete ()
	BEGIN
		DECLARE delete_row_count INT  DEFAULT 0;
        
		DELETE FROM 	exam
        WHERE			YEAR(CreateDate) = YEAR(NOW()) - 9;
        
        SET delete_row_count = ROW_COUNT();
        
        SELECT CONCAT("Số lượng bản ghi đã xóa : ", delete_row_count) AS Result;
    END //
DELIMITER ;

SET SQL_SAFE_UPDATES = 0;
CALL before9y_exam_delete();
SET SQL_SAFE_UPDATES = 1;

--  Question 11: Viết store cho phép người dùng xóa phòng ban bằng cách người dùng nhập vào tên phòng ban và 
--  các account thuộc phòng ban đó sẽ được chuyển về phòng ban default là phòng ban chờ việc
INSERT INTO Department(DepartmentName) 
VALUES				(N'Phòng ban chờ');

DROP PROCEDURE IF EXISTS  depart_delete_transfer;
DELIMITER //
CREATE PROCEDURE depart_delete_transfer (IN u_DepartmentName NVARCHAR(100))
	BEGIN
		UPDATE			jobaccount
        SET 			DepartmentID = 12
        WHERE			DepartmentID = u_DepartmentName;
        
		DELETE FROM 	department
        WHERE			DepartmentID = u_DepartmentName;
    END //
DELIMITER ;

CALL depart_delete_transfer(7);

-- Question 12: Viết store để in ra mỗi tháng có bao nhiêu câu hỏi được tạo trong năm nay
DROP PROCEDURE IF EXISTS  month_question_count;
DELIMITER //
CREATE PROCEDURE month_question_count ()
	BEGIN
		SELECT		 	DAY(CreateDate) AS Create_Day, COUNT(DAY(CreateDate)) AS Day_Count
        FROM			question
        GROUP BY		DAY(CreateDate)
        ;
    END //
DELIMITER ;

CALL month_question_count ();

--  Question 13: Viết store để in ra mỗi tháng có bao nhiêu câu hỏi được tạo trong 6 tháng gần đây nhất
-- (Nếu tháng nào không có thì sẽ in ra là "không có câu hỏi nào trong tháng")
INSERT INTO question	(ContentQuestion				, CategoryID, TypeID		, CreatorID	, CreateDate )
VALUES 					(N'Câu hỏi về Java nâng cao'	,1			,  '1'			, '1'		,'2024-04-05');

DROP PROCEDURE IF EXISTS  count_questions_per_month;
DELIMITER //
CREATE PROCEDURE count_questions_per_month(IN start_date DATE)
BEGIN
    SELECT        	DATE_FORMAT(DATE_SUB(start_date, INTERVAL seq.month MONTH), '%Y-%m') AS month,    		-- Dùng hàm date_sub để trừ tháng nhập và tháng trong bảng tạm seq, định dạng thành Năm-Tháng và đặt tên cột month
					CASE
						WHEN COUNT(q.QuestionID) = 0 THEN "không có câu hỏi nào trong tháng"				
                        ELSE COUNT(q.QuestionID)
					END AS question_count
    FROM	        (SELECT 0 AS month UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5) seq  	-- Tạo bảng tạm seq gồm 1 cột month từ 0->5
    LEFT JOIN        question q 
	ON 				DATE_FORMAT(q.CreateDate, '%Y-%m') = DATE_FORMAT(DATE_SUB(start_date, INTERVAL seq.month MONTH), '%Y-%m')			-- Nối bảng tạm seq và bảng question bằng điều kiện Năm-Tháng
    GROUP BY 		seq.month
    ORDER BY 		seq.month
    ;
END //
DELIMITER ;

CALL count_questions_per_month('2024-05-01');
