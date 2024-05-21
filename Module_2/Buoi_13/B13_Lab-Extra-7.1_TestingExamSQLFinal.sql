-- 1. Tạo bảng với ràng buộc và kiểu dữ liệu. Sau đó, thêm ít nhất 5 bản ghi vào bảng.

DROP DATABASE IF EXISTS Customer;
CREATE DATABASE Customer;
USE Customer;

-- Tạo bảng
DROP TABLE IF EXISTS Customer;
CREATE TABLE Customer (
	CustomerID 			TINYINT AUTO_INCREMENT PRIMARY KEY,
    CusName 			NVARCHAR(100) NOT NULL,
    Phone 				VARCHAR(11) NOT NULL,
    Email 				VARCHAR(50) NOT NULL,
    Address				VARCHAR(100) NOT NULL,
    Note				NVARCHAR(100)
    )
;

DROP TABLE IF EXISTS Car;
CREATE TABLE Car (
	CarID 				TINYINT AUTO_INCREMENT PRIMARY KEY,
    Maker	 			ENUM('Honda','Toyota','Nissan'),
    Model 				NVARCHAR(20) NOT NULL,
    CarYear 			VARCHAR(4) NOT NULL,
    Color				VARCHAR(20),
    Note				NVARCHAR(100)
    )
;

DROP TABLE IF EXISTS CusOrder;
CREATE TABLE CusOrder (
	OrderID 			TINYINT AUTO_INCREMENT PRIMARY KEY,
    CustomerID 			TINYINT NOT NULL,
    CarID 				TINYINT NOT NULL,
    Amount	 			TINYINT DEFAULT 1,
    OrderDate			DATETIME DEFAULT CURRENT_TIMESTAMP,
    DeliveryDate 		DATETIME NOT NULL,
    DeliveryAddress		NVARCHAR(100) NOT NULL,
    OrderStatus			ENUM('0: đã đặt hàng', '1: đã giao', '2: đã hủy') DEFAULT '0: đã đặt hàng',
    Note				NVARCHAR(100),
    FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID),
    FOREIGN KEY (CarID) REFERENCES Car(CarID)
    )
;

-- Tạo giá trị

INSERT INTO Customer(CusName 			,Phone 			,Email 					,Address				,Note)
VALUES
					(N'Nguyễn Văn A'	,'01234567899'	,'nguyenvana@gmail.com'	, N'1 Phan Huy Ích'		, 'VIP'),
                    (N'Nguyễn Văn B'	,'01234567898'	,'nguyenvanb@gmail.com'	, N'2 Phan Huy Ích'		, Null),
                    (N'Nguyễn Văn C'	,'01234567897'	,'nguyenvanc@gmail.com'	, N'3 Phan Huy Ích'		, 'VIP'),
                    (N'Nguyễn Văn D'	,'01234567896'	,'nguyenvand@gmail.com'	, N'4 Phan Huy Ích'		, Null),
                    (N'Nguyễn Văn E'	,'01234567895'	,'nguyenvane@gmail.com'	, N'5 Phan Huy Ích'		, 'VIP')
;

INSERT INTO Car (Maker		, Model				, CarYear		,Color		, Note)
VALUES			('HONDA'	, 'A001'			, 1950			,'Black'	, 'VIP'),
				('HONDA'	, 'A002'			, 1955			,'White'	, 'VIP'),
                ('TOYOTA'	, 'B001'			, 1951			,'Red'		, 'VIP'),
                ('TOYOTA'	, 'B002'			, 1960			,'Black'	, 'VIP'),
                ('NISSAN'	, 'C001'			, 1950			,'Black'	, 'VIP');
                
INSERT INTO CusOrder(CustomerID	, CarID	,Amount	,OrderDate		,DeliveryDate	,DeliveryAddress	,OrderStatus		, Note)
VALUES				(1			, 1		,1		,'2023/02/15'	,'2023/02/27'	,N'1 Phan Huy Ích'	,'1: đã giao'		,Null),
					(1			, 3		,1		,'2023/12/05'	,'2023/12/31'	,N'1 Phan Huy Ích'	,'2: đã hủy'		,Null),
                    (2			, 2		,1		,'2023/02/01'	,'2023/02/15'	,N'2 Phan Huy Ích'	,'1: đã giao'		,Null),
                    (3			, 5		,2		,'2023/01/15'	,'2023/01/20'	,N'3 Phan Huy Ích'	,'1: đã giao'		,Null),
                    (4			, 1		,1		,'2023/04/07'	,'2023/04/20'	,N'4 Phan Huy Ích'	,'0: đã đặt hàng'	,Null);
                    
-- Truy vấn
-- 2. Viết lệnh lấy ra thông tin của khách hàng: tên, số lượng oto khách hàng đã mua và sắp sếp tăng dần theo số lượng oto đã mua.
SELECT			a.CusName, o.Amount
FROM			customer a
JOIN			cusorder o
ON				a.CustomerID = o.CustomerID
ORDER BY		o.Amount 
;

-- 3. Viết hàm (không có parameter) trả về tên hãng sản xuất đã bán được nhiều oto nhất trong năm nay.
DROP FUNCTION IF EXISTS MaxAmountCar;
DELIMITER $$
CREATE FUNCTION MaxAmountCar() RETURNS VARCHAR(20)
DETERMINISTIC  -- Khai báo rằng hàm sẽ luôn trả về cùng một kết quả với cùng một đầu vào. Điều này giúp MySQL hiểu rằng hàm này an toàn để ghi vào binary log.
READS SQL DATA  -- Khai báo rằng hàm đọc dữ liệu từ bảng nhưng không thay đổi dữ liệu. Điều này cũng giúp MySQL xác định rằng hàm an toàn để ghi vào binary log.
	BEGIN
		DECLARE 	maker_name	VARCHAR(20);
        WITH CountMakers AS (
			SELECT		c.Maker, COUNT(o.CarID) AS CountMaker
			FROM		car c
			JOIN		cusorder o
			ON			c.CarID = o.CarID
			GROUP BY	c.Maker
        )
        SELECT	Maker INTO maker_name
        FROM	CountMakers
        WHERE	CountMaker = (SELECT MAX(CountMaker) FROM CountMakers);
        RETURN		maker_name;
    END $$
DELIMITER ;
SELECT MaxAmountCar();

-- 4. Viết 1 thủ tục (không có parameter) để xóa các đơn hàng đã bị hủy của những năm trước. In ra số lượng bản ghi đã bị xóa.
INSERT INTO CusOrder(CustomerID	, CarID	,Amount	,OrderDate		,DeliveryDate	,DeliveryAddress	,OrderStatus		, Note)
VALUES				(1			, 3		,1		,'2023/12/05'	,'2023/12/31'	,N'1 Phan Huy Ích'	,'2: đã hủy'		,Null);
                    
DROP PROCEDURE IF EXISTS CanceledOrder;
DELIMITER $$
CREATE PROCEDURE CanceledOrder ()
	BEGIN
		DECLARE deleted_count INT DEFAULT 0;
		
        DELETE FROM 	cusorder
		WHERE			OrderStatus = '2: đã hủy';
        
        SET deleted_count = ROW_COUNT();
        SELECT CONCAT ('Số lượng bản ghi đã xóa: ', deleted_count) AS Result;
	END $$
DELIMITER ;

SET SQL_SAFE_UPDATES = 0;
CALL CanceledOrder();
SET SQL_SAFE_UPDATES = 1;

-- 5. Viết 1 thủ tục (có CustomerID parameter) để in ra thông tin của các đơn hàng đã đặt hàng bao gồm: 
-- tên của khách hàng, mã đơn hàng, số lượng oto và tên hãng sản xuất.
DROP PROCEDURE IF EXISTS InforOrder;
DELIMITER $$
CREATE PROCEDURE InforOrder (IN Cus_Name NVARCHAR(100))
	BEGIN
		SELECT		o.OrderID, o.Amount, c.Maker
		FROM		cusorder o
		LEFT JOIN	customer cus
		ON			o.CustomerID = cus.CustomerID
		LEFT JOIN	car c
		ON			o.CarID = c.CarID 
        WHERE 		cus.CusName = Cus_Name
        ;
	END $$
DELIMITER ;

CALL InforOrder(N'Nguyễn Văn A');

-- 6. Viết trigger để tránh trường hợp người dụng nhập thông tin không hợp lệ vào database (DeliveryDate < OrderDate + 15).
DROP TRIGGER IF EXISTS trigger_deliveryDate;
DELIMITER $$
CREATE TRIGGER trigger_deliveryDate
BEFORE INSERT ON cusorder
FOR EACH ROW
	BEGIN
		IF NEW.DeliveryDate < NEW.OrderDate + INTERVAL 15 DAY THEN
			SIGNAL SQLSTATE  "12345"
			SET MESSAGE_TEXT = "DeliveryDate must be larger than OrderDate + 15";
		END IF;
    END $$
DELIMITER ;

INSERT INTO CusOrder(CustomerID	, CarID	,Amount	,OrderDate		,DeliveryDate	,DeliveryAddress	,OrderStatus		, Note)
VALUES				(2			, 2		,1		,'2023/10/05'	,'2023/10/18'	,N'2 Phan Huy Ích'	,'1: đã giao'		,Null);
