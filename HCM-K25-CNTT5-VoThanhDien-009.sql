CREATE DATABASE EmployeManagement;

USE EmployeManagement;

DROP TABLE Employees;
DROP TABLE Employee_Details;
DROP TABLE Departments;
DROP TABLE Projects;
DROP TABLE Work_Assignments;

-- PHẦN 1: DDL - THIẾT KẾ CSDL
-- BẢNG 1: Employees
CREATE TABLE Employees (
	employee_id INT PRIMARY KEY AUTO_INCREMENT,
    full_name VARCHAR(255) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone_number VARCHAR(15) UNIQUE, 
    hire_date DATE DEFAULT (CURRENT_DATE),
    salary DECIMAL(10,2),
    CONSTRAINT ck_salary CHECK (salary > 0)
);

-- BẢNG 2: Employee_Details
CREATE TABLE Employee_Details (
	detail_id INT PRIMARY KEY AUTO_INCREMENT,
    employee_id INT UNIQUE,
    citizen_id VARCHAR(15) UNIQUE NOT NULL,
    address VARCHAR(255) NOT NULL,
    working_status ENUM('Active', 'Inactive'),
    FOREIGN KEY (employee_id) REFERENCES Employees(employee_id)
);

-- BẢNG 3: Departments
CREATE TABLE Departments (
	department_id INT PRIMARY KEY AUTO_INCREMENT,
    department_name VARCHAR(100) UNIQUE NOT NULL,
    description VARCHAR(255)
);

-- BẢNG 4: Projects
CREATE TABLE Projects (
	project_id INT PRIMARY KEY AUTO_INCREMENT,
    project_name VARCHAR(255) NOT NULL,
    department_id INT,
    budget DECIMAL(10,2),
    project_status ENUM('Pending', 'Doing', 'Done'),
    FOREIGN KEY (department_id) REFERENCES Departments(department_id)
);

-- BẢNG 5: Work_Assignments
CREATE TABLE Work_Assignments (
	assignment_id INT PRIMARY KEY,
    employee_id INT,
    project_id INT,
    start_date DATE NOT NULL,
    deadline DATE NOT NULL,
    completed_date DATE,
    FOREIGN KEY (employee_id) REFERENCES Employees(employee_id),
    FOREIGN KEY (project_id) REFERENCES Projects(project_id)
);

-- PHẦN 2: DML - INSERT, DELETE, UPDATE
-- CÂU 1: INSERT
INSERT INTO Employees(employee_id, full_name, email, phone_number, hire_date, salary) VALUES
(1, 'Nguyen Van A', 'anv@gmail.com', '0901234567', '2022-01-15', 12000000),
(2, 'Tran Thi B', 'btt@gmail.com', '0912345678', '2021-05-20', 18000000),
(3, 'Le Van C', 'cle@gmail.com', '0922334455', '2023-02-10', 9500000),
(4, 'Pham Minh D', 'dpham@gmail.com', '0933445566', '2020-11-05', 22000000),
(5, 'Hoang Anh E', 'ehoang@gmail.com', '0944556677', '2023-01-12', 15000000);

INSERT INTO Employee_Details (detail_id, employee_id, citizen_id, address, working_status) VALUES 
(1,1,'123456789', 'Ha Noi', 'Active'),
(2,2,'234567890', 'Hai Phong', 'Active'),
(3,3,'345678901', 'Da Nang', 'Inactive'),
(4,4,'456789012', 'Ho Chi Minh', 'Active'),
(5,5,'567890123', 'Can Tho', 'Active');

INSERT INTO Departments (department_id, department_name, description) VALUES 
(1, 'IT', 'Phòng công nghệ thông tin'),
(2, 'HR', 'Phòng nhân sự'),
(3, 'Marketing', 'Phòng marketing'),
(4, 'Finance', 'Phòng tài chính'),
(5, 'Sales', 'Phòng kinh doanh');

INSERT INTO Projects (project_id, project_name, department_id, budget, project_status) VALUES
(1, 'Website Company', 1, 50000000, 'Doing'),
(2, 'Recruitment 2025', 2, 20000000, 'Pending'),
(3, 'Ads Campaign', 3, 30000000, 'Doing'),
(4, 'Accounting System', 4, 45000000, 'Done'),
(5, 'Customer Expansion', 5, 25000000, 'Pending');

INSERT INTO Work_Assignments (assignment_id, employee_id, project_id, start_date, deadline, completed_date) VALUES
(101, 1, 1, '2024-01-10', '2024-02-10', NULL),
(102, 2, 2, '2024-02-01', '2024-03-10', '2024-02-25'),
(103, 3, 3, '2024-03-05', '2024-04-05', NULL),
(104, 4, 4, '2023-10-10', '2023-12-10', '2023-12-05'),
(105, 5, 5, '2024-04-01', '2024-05-01', NULL);

-- CÂU 2: UPDATE & DELETE
UPDATE Projects
SET budget = budget + 5000000
WHERE department_id = 1;

DELETE FROM Work_Assignments
WHERE completed_date IS NOT NULL AND start_date < '2024-01-01';
 
-- PHẦN 3: TRUY VẤN CƠ BẢN
-- CÂU 1:
SELECT project_id, project_name, budget FROM Projects
WHERE department_id = 1 AND budget > 30000000;

-- CÂU 2: 
SELECT employee_id, full_name, email FROM Employees
WHERE (hire_date BETWEEN '2022-01-01' AND '2022-12-31') AND email LIKE '%@gmail.com%';

-- CÂU 3:
SELECT employee_id, full_name, salary FROM Employees
ORDER BY Salary DESC
LIMIT 3 OFFSET 1;

-- PHẦN 4: TRUY VẤN NÂNG CAO
-- CÂU 1:
SELECT w.assignment_id, e.full_name, p.project_name, w.start_date, w.deadline FROM Work_Assignments w
JOIN Employees e ON e.employee_id = w.employee_id
JOIN Projects p ON p.project_id = w.project_id
WHERE completed_date IS NULL;

-- CÂU 2:
SELECT d.department_name, SUM(p.budget) AS total_budget FROM Projects p
JOIN Departments d ON d.department_id = p.department_id
WHERE p.budget > 40000000
GROUP BY d.department_id;

-- CÂU 3:
SELECT e.employee_id, e.full_name, ed.working_status FROM Employees e
JOIN Employee_Details ed ON ed.employee_id = e.employee_id
WHERE ed.working_status = 'Active' AND e.employee_id NOT IN 
(SELECT w.employee_id FROM Work_Assignments w 
    JOIN Projects P on w.project_id = p.project_id 
    WHERE p.budget > 40000000);

-- PHẦN 5: INDEX & VIEW 
-- CÂU 1:
CREATE INDEX idx_assignment_dates ON Work_Assignments(start_date, completed_date);

-- CÂU 2:
DROP VIEW IF EXISTS vw_overdue_assignments;
CREATE VIEW vw_overdue_assignments AS
SELECT w.assignment_id, e.full_name, p.project_name, w.start_date, w.deadline FROM Work_Assignments w
JOIN Employees e ON e.employee_id = w.employee_id
JOIN Projects p ON p.project_id = w.project_id
WHERE (p.project_status = 'Pending' OR p.project_status = 'Doing') AND w.deadline > CURDATE();

SELECT * FROM vw_overdue_assignments;

-- PHẦN 6: TRIGGER
-- CÂU 1: 
DELIMITER $$
CREATE TRIGGER trg_after_assignment_insert 
AFTER INSERT ON Work_Assignments
FOR EACH ROW
BEGIN

	UPDATE Projects
    SET project_status = 'Doing'
    WHERE project_id = project_id;	

END$$
DELIMITER ;

-- CÂU 2:
DELIMITER $$
DROP TRIGGER IF EXISTS trg_prevent_delete_employee;
CREATE TRIGGER trg_prevent_delete_employee
BEFORE DELETE ON Employees
FOR EACH ROW
BEGIN
    
	IF completed_date IS NULL THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Không thể xóa nhân viên này vì còn công việc chưa hoàn thành';
	END IF;

END$$
DELIMITER ;

	
