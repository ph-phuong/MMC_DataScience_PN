USE				testing_system_db
;

-- Question 1: Tạo view có chứa danh sách nhân viên thuộc phòng ban sale
DROP VIEW IF EXISTS AccountSale;
CREATE VIEW 	AccountSale AS
	SELECT			a.FullName
	FROM			jobaccount a
	JOIN			department d
	ON				a.DepartmentID = d.DepartmentID
	WHERE			d.DepartmentName = N'Sale'
	;

-- Question 2: Tạo view có chứa thông tin các account tham gia vào nhiều group nhất
DROP VIEW IF EXISTS AccountMaxGroup;
CREATE VIEW 	AccountMaxGroup AS
	WITH 	CountGroups AS (
		SELECT			AccountID, COUNT(AccountID) AS CountGroup
		FROM			groupaccount
		GROUP BY		AccountID
	)
	SELECT		AccountID, CountGroup
	FROM		CountGroups
	WHERE		CountGroup = (SELECT MAX(CountGroup) FROM CountGroups)
;

-- Question 3: Tạo view có chứa câu hỏi có những content quá dài (content quá 80 từ được coi là quá dài) và xóa nó đi
DROP VIEW IF EXISTS LongContentQuestion80;
CREATE VIEW 	LongContentQuestion80 AS 
	SELECT		QuestionID, LENGTH(ContentQuestion)
	FROM 		question
	WHERE		LENGTH(ContentQuestion) > 80
;
-- DELETE FROM question
-- WHERE 		QuestionID in (SELECT QuestionID FROM LongContentQuestion80); 		

-- Question 4: Tạo view có chứa danh sách các phòng ban có nhiều nhân viên nhất
DROP VIEW IF EXISTS MaxAccountDepartment;
CREATE VIEW 	MaxAccountDepartment AS 
WITH CountAccounts AS (
	SELECT 		DepartmentID, COUNT(DepartmentID) AS CountAccount
	FROM		jobaccount
	GROUP BY	DepartmentID
)
SELECT		DepartmentID, CountAccount
FROM 		CountAccounts
WHERE		CountAccount = (SELECT MAX(CountAccount) FROM CountAccounts)
;

-- Question 5: Tạo view có chứa tất các các câu hỏi do user họ Nguyễn tạo
DROP VIEW IF EXISTS QuestionOfNguyen;
CREATE VIEW 	QuestionOfNguyen AS 
	SELECT		q.QuestionID, q.ContentQuestion, a.FullName
	FROM		jobaccount a
	JOIN		question q
	ON			a.AccountID = q.CreatorID
	WHERE		a.FullName LIKE "Nguyễn%"
;