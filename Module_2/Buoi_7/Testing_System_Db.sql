CREATE DATABASE Testing_System_Db;
USE Testing_System_Db;

CREATE TABLE Department (
    DepartmentID            INT AUTO_INCREMENT PRIMARY KEY,
    DepartmentName          VARCHAR(50)
);

CREATE TABLE JobPosition (
    PositionID              INT AUTO_INCREMENT PRIMARY KEY,
    PositionName            VARCHAR(50)
);

CREATE TABLE Account (
    AccountID               INT AUTO_INCREMENT PRIMARY KEY,
    Email                   VARCHAR(50),
    Username                VARCHAR(50),
    FullName                VARCHAR(50),
    DepartmentID            INT,
    PositionID              INT,
    CreateDate              DATE,
);

CREATE TABLE JobGroup (
    GroupID                 INT AUTO_INCREMENT PRIMARY KEY,
    GroupName               VARCHAR(50),
    CreatorID               INT,
    CreateDate              DATE
);

CREATE TABLE GroupAccount (
    GroupID                 INT,
    AccountID               INT,
    JoinDate                DATE
)

CREATE TABLE TypeQuestion (
    TypeID                  INT AUTO_INCREMENT PRIMARY KEY,
    TypeName                VARCHAR(50)
);

CREATE TABLE CategoryQuestion (
    CategoryID              INT AUTO_INCREMENT PRIMARY KEY,
    CategoryName            VARCHAR(50)
);

CREATE TABLE Question (
    QuestionID              INT AUTO_INCREMENT PRIMARY KEY,
    ContentQuestion         VARCHAR(200),
    CategoryID              INT,
    TypeID                  INT,
    CreatorID               INT,
    CreateDate              DATE,
    FOREIGN KEY (CategoryID) REFERENCES CategoryQuestion(CategoryID),
    FOREIGN KEY (TypeID) REFERENCES TypeQuestion(TypeID),
    FOREIGN KEY (CreatorID) REFERENCES Account(AccountID)
);

CREATE TABLE Answer (
    AnswerID                INT AUTO_INCREMENT PRIMARY KEY,
    ContentAnswer           VARCHAR(200),
    QuestionID              INT,
    isCorrect               BOOLEAN,
    FOREIGN KEY (QuestionID) REFERENCES Question(QuestionID)
);

CREATE TABLE Exam (
    ExamID                  INT AUTO_INCREMENT PRIMARY KEY,
    CodeExam                INT,
    Title                   VARCHAR(50),
    CategoryID              INT,
    Duration                INT,
    CreatorID               INT,
    CreateDate              DATE,
    FOREIGN KEY (CategoryID) REFERENCES CategoryQuestion(CategoryID),
    FOREIGN KEY (CreatorID) REFERENCES Account(AccountID)
);

CREATE TABLE ExamQuestion (
    ExamID                  INT,
    QuestionID              INT,
    FOREIGN KEY (ExamID) REFERENCES Exam(ExamID),
    FOREIGN KEY (QuestionID) REFERENCES Question(QuestionID)
);
