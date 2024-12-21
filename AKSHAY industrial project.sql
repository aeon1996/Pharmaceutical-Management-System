-- Create Database
Create Database PharmaDB;
USE PharmaDB;


-- 1. CREATE TABLE SCHEMA
-- Raw Materials Table
Create Table Raw_Materials (
    MaterialID int primary key,
    Name varchar(50) not null,
    Quantity int not null,
    SupplierID varchar(10) not null);

-- Production Batches Table
Create Table Production_Batches (
    BatchID int primary key,
    ProductID int not null,
    Startdate date not null,
    Enddate date,
    QA_Status varchar(20));

-- Quality Tests Table
Create Table Quality_Tests (
    TestID int primary key,
    BatchID int,
    Parameter varchar(50) not null,
    Result varchar(20),
    date date not null,
    foreign key (BatchID) references Production_Batches(BatchID));

-- Employees Table
Create Table Employees (
    EmployeeID varchar(10) primary key,
    name varchar(50) not null,
    Role varchar(50),
    DepartmentID varchar(10),
    Attendance varchar(20));

-- Orders Table
Create Table Orders (
    OrderID varchar(10) primary key,
    CustomerID varchar(10) not null,
    ProductID int not null,
    Quantity int not null,
    Dispatchdate date not null);
    
-- Dispatch Queue Table (Linked to Orders)
Create Table Dispatch_Queue (
    DispatchID int auto_increment primary key,
    OrderID varchar(10),
    DispatchStatus varchar(20) DEFAULT 'Pending',
    foreign key (OrderID) references Orders(OrderID));


-- 2. INSERT SAMPLE DATA

-- insert data into Raw Materials
insert into Raw_Materials values
(1, 'Paracetamol', 500, 'S101'),
(2, 'Ibuprofen', 300, 'S102'),
(3, 'Amoxicillin', 200, 'S103');

-- insert data into Production Batches
insert into Production_Batches values
(1001, 201, '2024-12-01', '2024-12-05', 'Passed'),
(1002, 202, '2024-12-03', '2024-12-07', 'Failed'),
(1003, 203, '2024-12-04', '2024-12-09', 'in-Progress');

-- insert data into Quality Tests
insert into Quality_Tests values
(1, 1001, 'Potency', 'Passed', '2024-12-06'),
(2, 1002, 'Stability', 'Failed', '2024-12-08'),
(3, 1001, 'Microbial Test', 'Passed', '2024-12-06');

-- insert data into Employees
insert into Employees values
('E001', 'John Smith', 'Quality Analyst', 'D101', 'Present'),
('E002', 'Alice Brown', 'Production Manager', 'D102', 'Absent'),
('E003', 'Rajesh Kumar', 'HR Manager', 'D103', 'Present');

-- insert data into Orders
insert into Orders values
('O001', 'C001', 201, 50, '2024-12-07'),
('O002', 'C002', 202, 100, '2024-12-08'),
('O003', 'C003', 203, 200, '2024-12-09');

-- 3. STORED PROCEDURES

-- a) Automate Stock Reconciliation
DELIMITER //
Create procedure Stock_Reconciliation()
begin
    update Raw_Materials
    set Quantity = Quantity + 100
    where Quantity < 100;
end //
DELIMITER ;


-- b) Generate Quality Assurance Report
DELIMITER //
Create procedure Generate_QA_Report()
begin
    select BatchID, Parameter, Result, date
    from Quality_Tests
    order by date desc;
end //
DELIMITER ;

4. TRIGGERS

-- a) Before Update Trigger: Alert if Stock Falls Below Threshold
DELIMITER //
Create trigger Before_Stock_Update
before update on Raw_Materials
for each row
begin
    if new.Quantity < 100 then
        signal sqlstate '45000' 
        set message_text = 'Stock below minimum threshold! Alert Admin.';
    end if;
end //
DELIMITER ;

-- b) After insert Trigger: Log New Orders into Dispatch Queue
DELIMITER //
create trigger After_Order_insert
after insert on Orders
for each row
begin
    insert into Dispatch_Queue (OrderID, DispatchStatus) 
    values (new.OrderID, 'Pending');
end //
DELIMITER ;


-- 5. VIEWS FOR MANAGEMENT INSIGHTS

-- a) View for Daily Production Statistics
Create VIEW Daily_Production_Stats AS
SELECT BatchID, ProductID, Startdate, Enddate, QA_Status
FROM Production_Batches
WHERE Enddate = curdate();

-- b) View for Pending Orders
Create view Pending_Orders as
select o.OrderID, o.CustomerID, o.ProductID, o.Quantity, d.DispatchStatus
from Orders o
join Dispatch_Queue d on o.OrderID = d.OrderID
where d.DispatchStatus = 'Pending';

-- 5. TESTING THE IMPLEMENTATIONS

-- a) Test Stored procedures
call Stock_Reconciliation();
call Generate_QA_Report();

-- b) Test Triggers
update Raw_Materials set Quantity = 50 where MaterialID = 1;
insert into Orders values ('O004', 'C004', 204, 75, '2024-12-10');


-- c) Test Views
select * from Daily_Production_Stats;
select * from Pending_Orders;
