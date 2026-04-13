task 12;
use normalization;
-- Main employee table
CREATE TABLE employees (
    emp_id INT PRIMARY KEY,
    name VARCHAR(50),
    salary INT,
    dept_id INT,
    last_modified TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Archive table (for deleted records)
CREATE TABLE employee_archive (
    emp_id INT,
    name VARCHAR(50),
    salary INT,
    dept_id INT,
    deleted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Department table
CREATE TABLE departments (
    dept_id INT PRIMARY KEY,
    dept_name VARCHAR(50),
    min_salary INT
);

INSERT INTO employees VALUES (1, 'Asha', 50000, 101, NOW());
INSERT INTO employees VALUES (2, 'Ravi', 40000, 102, NOW());

INSERT INTO departments VALUES (101, 'HR', 30000);
INSERT INTO departments VALUES (102, 'IT', 35000);

select * from employees;
select * from departments;

q1:
DELIMITER $$

CREATE TRIGGER prevent_salary_reduction
BEFORE UPDATE ON employees
FOR EACH ROW
BEGIN
    IF NEW.salary < OLD.salary THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Salary cannot be reduced!';
    END IF;
END$$

DELIMITER ;

UPDATE employees
SET salary = 30000
WHERE emp_id = 1;

q2:
DELIMITER $$

CREATE TRIGGER archive_deleted_employee
AFTER DELETE ON employees
FOR EACH ROW
BEGIN
    INSERT INTO employee_archive(emp_id, name, salary, dept_id)
    VALUES (OLD.emp_id, OLD.name, OLD.salary, OLD.dept_id);
END$$

DELIMITER ;

DELETE FROM employees
WHERE emp_id = 2;

SELECT * FROM employee_archive;


q3:
DELIMITER $$

CREATE TRIGGER update_last_modified
BEFORE UPDATE ON employees
FOR EACH ROW
BEGIN
    SET NEW.last_modified = CURRENT_TIMESTAMP;
END$$

DELIMITER ;

UPDATE employees
SET salary = 60000
WHERE emp_id = 1;

SELECT emp_id, salary, last_modified FROM employees;

q4:
DELIMITER $$

CREATE TRIGGER prevent_null_values
BEFORE INSERT ON employees
FOR EACH ROW
BEGIN
    IF NEW.name IS NULL OR NEW.salary IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Name and Salary cannot be NULL!';
    END IF;
END$$

DELIMITER ;

INSERT INTO employees(emp_id, name, salary, dept_id)
VALUES (3, NULL, 20000, 101);

q5:
DELIMITER $$

CREATE TRIGGER check_min_salary
BEFORE INSERT ON employees
FOR EACH ROW
BEGIN
    DECLARE min_sal INT;

    SELECT min_salary INTO min_sal
    FROM departments
    WHERE dept_id = NEW.dept_id;

    IF NEW.salary < min_sal THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Salary below department minimum!';
    END IF;
END$$

DELIMITER ;

INSERT INTO employees
VALUES (4, 'Kiran', 20000, 102, NOW());