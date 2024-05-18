USE				hr;

-- Bài toán 1: Viết truy vấn để lấy tên và ngày bắt đầu công việc của tất cả nhân viên làm việc trong phòng ban số 5
SELECT			e.F_NAME, e.L_NAME, h.START_DATE
FROM			employees e 
INNER JOIN		job_history h
ON				e.EMP_ID = h.EMPL_ID
WHERE			e.DEP_ID = 5
;

-- Bài toán 2: Viết truy vấn để lấy tên, ngày bắt đầu công việc và tên công việc của tất cả nhân viên làm việc trong phòng ban số 5.
SELECT			e.F_NAME, e.L_NAME, h.START_DATE, j.JOB_TITLE
FROM			employees e 
INNER JOIN		job_history h
ON				e.EMP_ID = h.EMPL_ID
INNER JOIN		jobs j
ON				e.JOB_ID = j.JOB_IDENT
WHERE			e.DEP_ID = 5
;

-- Bài toán 3: Thực hiện Left Outer Join trên các bảng  EMPLOYEES và DEPARTMENT và 
-- chọn employee id (id nhân viên), last name (họ), department id (id phòng ban), department name (tên phòng ban ) cho tất cả nhân viên.
SELECT			e.EMP_ID, e.F_NAME, e.L_NAME, e.DEP_ID, d.DEP_NAME
FROM			employees e 
LEFT JOIN		departments d
ON				e.DEP_ID = d.DEPT_ID_DEP
;

-- Bài toán 4: Viết lại truy vấn trước đó nhưng giới hạn tập kết quả chỉ có các hàng dành cho nhân viên sinh trước năm 1980.
SELECT			e.EMP_ID, e.L_NAME, e.DEP_ID, d.DEP_NAME
FROM			employees e 
LEFT JOIN		departments d
ON				e.DEP_ID = d.DEPT_ID_DEP
WHERE			YEAR(B_DATE) < '1980'
;

-- Bài toán 5: Viết lại truy vấn trước đó nhưng sẽ sử dụng INNER JOIN thay vì sử dụng LEFT OUTER JOIN.
SELECT			e.EMP_ID, e.L_NAME, e.DEP_ID, d.DEP_NAME
FROM			employees e 
INNER JOIN		departments d
ON				e.DEP_ID = d.DEPT_ID_DEP
WHERE			YEAR(B_DATE) < '1980'
;

-- Bài toán 6: Thực hiện một FULL OUTER JOIN trên bảng EMPLOYEES và DEPARTMENT và 
-- chọn First name (tên), Last name (họ) và Department name (tên phòng ban) của tất cả nhân viên.
-- Lưu ý là trong SQL server thì chúng ta có thể sử dụng trực tiếp FULL OUTER JOIN nhưng chúng ta đang sử dụng xampp 
--  và xampp sẽ cài đặt MySQL thay vì SQL server do đó  ta phải sử dụng LEFT OUTER JOIN kết hợp với RIGHT OUTER JOIN để thực hiện FULL OUTER JOIN
SELECT				e.EMP_ID, e.L_NAME, e.DEP_ID, d.DEP_NAME
FROM				employees e 
LEFT JOIN			departments d
ON					e.DEP_ID = d.DEPT_ID_DEP
UNION ALL
SELECT				e.EMP_ID, e.L_NAME, e.DEP_ID, d.DEP_NAME
FROM				employees e 
RIGHT JOIN			departments d
ON					e.DEP_ID = d.DEPT_ID_DEP
;

-- Bài toán 7: Viết lại truy vấn trước đó nhưng có tập kết quả bao gồm tất cả employee names (tên nhân viên) nhưng 
-- department id (id phòng ban) và department names (tên phòng ban) chỉ dành cho nhân viên nam.
SELECT				e.EMP_ID, e.F_NAME, e.L_NAME, d.DEPT_ID_DEP, d.DEP_NAME, e.SEX
FROM				employees e 
LEFT JOIN			departments d
ON					e.DEP_ID = d.DEPT_ID_DEP AND e.SEX = 'M'
UNION ALL
SELECT				e.EMP_ID, e.F_NAME, e.L_NAME, d.DEPT_ID_DEP, d.DEP_NAME, e.SEX
FROM				employees e 
RIGHT JOIN			departments d
ON					e.DEP_ID = d.DEPT_ID_DEP AND e.SEX = 'M'
;