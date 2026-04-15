Task 11
create database task11;
use task11;
CREATE TABLE employees (
    emp_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50),
    salary INT,
    dept VARCHAR(50)
);

CREATE TABLE audit_log (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    emp_id INT,
    old_salary INT,
    new_salary INT,
    action_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(50),
    stock INT
);

CREATE TABLE orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT,
    quantity INT
);

CREATE TABLE update_log (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    emp_id INT,
    old_dept VARCHAR(50),
    new_dept VARCHAR(50),
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);





INSERT INTO employees (name, salary, dept) VALUES
('John', 30000, 'HR'),
('Alice', 40000, 'IT');

INSERT INTO products (product_name, stock) VALUES
('Laptop', 10),
('Mouse', 50);


q1:
DELIMITER $$

CREATE PROCEDURE add_employee(
    IN emp_name VARCHAR(50),
    IN emp_salary INT,
    IN emp_dept VARCHAR(50)
)
BEGIN
    INSERT INTO employees(name, salary, dept)
    VALUES(emp_name, emp_salary, emp_dept);
END$$

DELIMITER ;

CALL add_employee('David', 35000, 'Finance');


q2:
DELIMITER $$

CREATE PROCEDURE get_employee_count(OUT total INT)
BEGIN
    SELECT COUNT(*) INTO total FROM employees;
END$$

DELIMITER ;


CALL get_employee_count(@count);
SELECT @count;

q3:
DELIMITER $$

CREATE PROCEDURE update_salary(
    IN empid INT,
    IN new_sal INT
)
BEGIN
    DECLARE old_sal INT;

    SELECT salary INTO old_sal FROM employees WHERE emp_id = empid;

    UPDATE employees SET salary = new_sal WHERE emp_id = empid;

    INSERT INTO audit_log(emp_id, old_salary, new_salary)
    VALUES(empid, old_sal, new_sal);
END$$

DELIMITER ;

CALL update_salary(1, 45000);
SELECT * FROM audit_log;

q4:
DELIMITER $$

CREATE TRIGGER validate_salary
BEFORE INSERT ON employees
FOR EACH ROW
BEGIN
    IF NEW.salary <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Salary must be positive';
    END IF;
END$$

DELIMITER ;

INSERT INTO employees(name, salary, dept)
VALUES('Test', -1000, 'HR');   --  Error


q5:
DELIMITER $$

CREATE TRIGGER update_stock
AFTER INSERT ON orders
FOR EACH ROW
BEGIN
    UPDATE products
    SET stock = stock - NEW.quantity
    WHERE product_id = NEW.product_id;
END$$

DELIMITER ;

INSERT INTO orders(product_id, quantity) VALUES(1, 2);
SELECT * FROM products;

q6:
DELIMITER $$

CREATE TRIGGER log_dept_change
AFTER UPDATE ON employees
FOR EACH ROW
BEGIN
    IF OLD.dept <> NEW.dept THEN
        INSERT INTO update_log(emp_id, old_dept, new_dept)
        VALUES(OLD.emp_id, OLD.dept, NEW.dept);
    END IF;
END$$

DELIMITER ;

UPDATE employees SET dept = 'Admin' WHERE emp_id = 1;
SELECT * FROM update_log;

q7:
DROP TRIGGER update_stock;