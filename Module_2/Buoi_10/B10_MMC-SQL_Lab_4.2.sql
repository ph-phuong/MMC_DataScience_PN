USE				testing_system_db
;

-- Question 1: Viết lệnh để lấy ra danh sách nhân viên và thông tin phòng ban của họ
SELECT 		FullName, DepartmentID
FROM		jobaccount
;	

-- Question 2: Viết lệnh để lấy ra thông tin các account được tạo sau ngày 20/12/2010
SELECT 		FullName, DepartmentID
FROM		jobaccount
WHERE		CreateDate > "2010/12/20"
;	

-- Question 3: Viết lệnh để lấy ra tất cả các developer
SELECT 		a.FullName, p.PositionName
FROM		jobaccount a
JOIN		position p
ON			a.PositionID  = p.PositionID
WHERE		p.PositionName = 'Dev'
;

-- Question 4: Viết lệnh để lấy ra danh sách các phòng ban có >1 nhân viên
SELECT 		COUNT(d.DepartmentName), d.DepartmentName
FROM		jobaccount a
JOIN		department d
ON			a.DepartmentID  = d.DepartmentID
GROUP BY	d.DepartmentName
HAVING		COUNT(d.DepartmentName) > 1
;

-- Question 5: Viết lệnh để lấy ra danh sách câu hỏi được sử dụng trong đề thi nhiều nhất
SELECT		TypeID, COUNT(TypeID)
FROM		question
GROUP BY	TypeID
ORDER BY	TypeID
LIMIT		1
;

SELECT 		TypeID, COUNT(TypeID) AS TypeCount
FROM 		question
GROUP BY 	TypeID
HAVING 		COUNT(TypeID) = (
    SELECT 	MAX(TypeCount)
    FROM (
        SELECT 		COUNT(TypeID) AS TypeCount
        FROM 		question
        GROUP BY 	TypeID
    ) AS TypeCounts
)
;

WITH TypeCounts AS (
	SELECT			TypeID, COUNT(TypeID) AS TypeCount
    FROM			question
    GROUP BY		TypeID
)	
SELECT 	TypeID, TypeCount
FROM	TypeCounts
WHERE	TypeCount  = (SELECT MAX(TypeCount) FROM TypeCounts)
;
-- Question 6: Thông kê mỗi category Question được sử dụng trong bao nhiêu Question
SELECT		CategoryID, COUNT(CategoryID)
FROM		question
GROUP BY	CategoryID
;

-- Question 7: Thông kê mỗi Question được sử dụng trong bao nhiêu Exam
INSERT INTO Exam	(CodeExam		, Title					, CategoryID	, Duration	, CreatorID		, CreateDate )
VALUES 				('VTIQ011'		, N'Đề thi C#'			,	1			,	60		,   '5'			,'2019-04-15'),
					('VTIQ012'		, N'Đề thi PHP'			,	10			,	60		,   '2'			,'2019-05-05'),
                    ('VTIQ013'		, N'Đề thi PHP'			,	10			,	120		,   '5'			,'2019-03-05')
;
                    
INSERT INTO ExamQuestion(ExamID	, QuestionID	) 
VALUES 					(	14	,		3		),
						(	15	,		2		), 
						(	16	,		2		)
;

SELECT		eq.QuestionID, COUNT(e.ExamID)
FROM		exam e
JOIN		examquestion eq
ON			e.ExamID = eq.ExamID
GROUP BY	eq.QuestionID
;

-- Question 8: Lấy ra Question có nhiều câu trả lời nhất
WITH CountExams AS (
	SELECT		eq.QuestionID, COUNT(e.ExamID) AS CountExam
	FROM		exam e
	JOIN		examquestion eq
	ON			e.ExamID = eq.ExamID
	GROUP BY	eq.QuestionID
)
SELECT		QuestionID, CountExam
FROM		CountExams
WHERE		CountExam = (SELECT MAX(CountExam) FROM CountExams)
;

-- Question 9: Thống kê số lượng account trong mỗi group
SELECT		ga.GroupID, COUNT(a.AccountID)
FROM		jobaccount a
JOIN		groupaccount ga
ON			a.AccountID = ga.GroupID
GROUP BY	ga.GroupID
;

-- Question 10: Tìm chức vụ có ít người nhất
WITH CountPersons AS (
	SELECT		PositionID, COUNT(AccountID) AS CountPerson
	FROM		jobaccount
	GROUP BY	PositionID
)
SELECT 	PositionID, CountPerson
FROM	CountPersons
WHERE 	CountPerson = (SELECT MAX(CountPerson) FROM CountPersons)
;

-- Question 11: Thống kê mỗi phòng ban có bao nhiêu dev, test, scrum master, PM
SELECT		p.PositionName, COUNT(a.AccountID)
FROM		jobaccount a
JOIN		position p
ON			a.PositionID = p.PositionID
GROUP BY	p.PositionName
;

-- Question 12: Lấy thông tin chi tiết của câu hỏi bao gồm: 
-- thông tin cơ bản của question, loại câu hỏi, ai là người tạo ra câu hỏi, câu trả lời là gì, …
SELECT 		q.QuestionID, q.ContentQuestion, cq.CategoryName, a.FullName, an.ContentAnswer
FROM 		question q
LEFT JOIN	categoryquestion cq
ON			q.CategoryID = cq.CategoryID
LEFT JOIN	jobaccount a
ON			a.AccountID = q.CreatorID
LEFT JOIN	answer an
ON			an.QuestionID = q.QuestionID
;

-- Question 13: Lấy ra số lượng câu hỏi của mỗi loại tự luận hay trắc nghiệm
SELECT 		q.QuestionID, q.ContentQuestion,  tq.TypeName
FROM 		question q
LEFT JOIN	typequestion tq
ON			q.TypeID = tq.TypeID
;

-- Question 14: Lấy ra group không có account nào
SELECT 		g.GroupID
FROM 		jobgroup g
LEFT JOIN 	groupaccount ga 
ON 			g.GroupID = ga.GroupID
WHERE 		ga.GroupID IS NULL
;
-- Question 15: Lấy ra group không có account nào
SELECT 		g.GroupID
FROM 		jobgroup g
LEFT JOIN 	groupaccount ga 
ON 			g.GroupID = ga.GroupID
WHERE 		ga.GroupID IS NULL
;

-- Question 16: Lấy ra question không có answer nào
SELECT 		q.QuestionID
FROM 		question q
LEFT JOIN 	answer a 
ON 			a.QuestionID = q.QuestionID
WHERE 		a.QuestionID IS NULL
;

-- Exercise 2: Union
-- Question 17:
-- a) Lấy các account thuộc nhóm thứ 1
SELECT 		AccountID
FROM 		groupaccount
WHERE 		GroupID = 1
;	

-- b) Lấy các account thuộc nhóm thứ 3
SELECT 		AccountID
FROM 		groupaccount
WHERE 		GroupID = 3
;

-- c) Ghép 2 kết quả từ câu a) và câu b) sao cho không có record nào trùng nhau
SELECT 		AccountID
FROM 		groupaccount
WHERE 		GroupID = 1
UNION
SELECT 		AccountID
FROM 		groupaccount
WHERE 		GroupID = 3
;

-- Question 18:
-- a) Lấy các group có lớn hơn 5 thành viên
SELECT 		COUNT(GroupID), GroupID
FROM 		groupaccount
GROUP BY	GroupID
HAVING		COUNT(GroupID) > 4
;

-- b) Lấy các group có nhỏ hơn 7 thành viên
SELECT 		COUNT(GroupID), GroupID
FROM 		groupaccount
GROUP BY	GroupID
HAVING		COUNT(GroupID) < 7
;

-- c) Ghép 2 kết quả từ câu a) và câu b)
SELECT 		COUNT(GroupID), GroupID
FROM 		groupaccount
GROUP BY	GroupID
HAVING		COUNT(GroupID) > 4
UNION
SELECT 		COUNT(GroupID), GroupID
FROM 		groupaccount
GROUP BY	GroupID
HAVING		COUNT(GroupID) < 7
;