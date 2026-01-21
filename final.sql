create database final;
use final;
-- Table 1: Readers
create table Readers (
    reader_id INT PRIMARY KEY AUTO_INCREMENT,
    full_name VARCHAR(255),
    Email VARCHAR(255) UNIQUE,
    phone_number VARCHAR(20),
    created_at DATE DEFAULT CURRENT_DATE
);

-- Table 2: Membership_Details
 create table Membership_Details (
    card_number varchar(50) PRIMARY KEY,
    reader_id INT UNIQUE,
    ranks VARCHAR(50) CHECK (ranks IN ('Standard', 'VIP')),
    expiry_date DATE,
    citizen_id VARCHAR(20) UNIQUE,
    FOREIGN KEY (reader_id) REFERENCES Readers(reader_id)
);

-- Table 3: Categories
create table Categories (
    category_id INT PRIMARY KEY AUTO_INCREMENT,
    category_name VARCHAR(255),
    descriptions TEXT
);

-- Table 4: Books
create table Books (
    book_id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(255),
    author VARCHAR(255),
    category_id INT,
    price DECIMAL(10, 2) CHECK (price > 0),
    stock_quantity INT CHECK (stock_quantity >= 0),
    FOREIGN KEY (category_id) REFERENCES Categories(category_id)
);

-- Table 5: Loan_Records
create table Loan_Records (
    loan_id INT PRIMARY KEY,
    reader_id INT,
    book_id INT,
    borrow_date DATE,
    due_date DATE,
    return_date DATE,
    FOREIGN KEY (reader_id) REFERENCES Readers(reader_id),
    FOREIGN KEY (book_id) REFERENCES Books(book_id),
    CHECK (due_date >  borrow_date)
);

insert into Readers(full_name,email,phone_number,created_at)
values 
('Nguyen Van A','anv@gmail.com','901234567','2022-01-15'),
('Tran Thi B','btt@gmail.com','912345678','2022-05-20'),
('Le Van C','cle@yahoo.com','922334455','2023-02-10'),
('Pham Minh D','dpham@hotmail.com','933445566','2023-05-1'),
('Hoang Anh E','ehoang@gmail.com','944556677','2024-01-12');

insert into Membership_Details(card_number,reader_id,ranks,expiry_date,citizen_id)
values('CARD-001',1,'Standard','2025-01-15','123456789'),
('CARD-002',2,'VIP','2025-05-20','234567890'),
('CARD-003',3,'Standard','2024-10-02','345678901'),
('CARD-004',4,'VIP','2025-05-11','456789012'),
('CARD-005',5,'Standard','2025-12-01','567890123');

insert into Categories(category_name,descriptions)
values ('IT','Sách về công nghệ thông tin và lập trình'),
('Kinh te','Sách kinh doanh, tài chính, khởi nghiệp'),
('Van hoc','Tiểu thuyết, truyện ngắn, thơ'),
('Ngoai ngu','Sách học tiếng Anh, Nhật, Hàn'),
('Lich su','Sách nghiên cứu lịch sử, văn hóa');
    
insert into Books(title,author,category_id,price,stock_quantity)
values ('Clean Code','Robert C. Martin',1,450000,10),
('Dac Nhan Tam','Dale Carnegie',2,150000,10),
('Harry Potter 1','J.K. Rowling',3,250000,10),
('IELTS Reading','Cambridge',4,180000,10),
('Dai Viet Su Ky','Le Van Huu',5,300000,10),
('Co So Du Lieu MySQL','Anh Quy Dep trai',1,900000,12);

insert into Loan_Records (loan_id,reader_id,book_id,borrow_date,due_date,return_date)
values(101,1,1,'2023-11-15','2023-11-22','2023-11-20'),
(102,2,2,'2023-12-1','2023-12-8','2023-12-5'),
(103,1,3,'2024-10-1','2024-10-17',null),
(104,3,4,'2023-05-20','2023-5-27',null),
(105,4,1,'2024-01-18','2024-01-25',null);

-- Gia hạn thêm 7 ngày
update Loan_Records lr
join Books b ON lr.book_id = b.book_id
join Categories c ON b.category_id = c.category_id
set lr.due_date = DATE_ADD(lr.due_date, interval (7) day)
wherewhere c.category_name = 'Van hoc' and lr.return_date is null;

-- Xóa các hồ sơ mượn trả theo yêu cầu 
delete from Loan_Records
where return_date is not null and  borrow_date < '2023-10-01';

-- PHẦN 2: TRUY VẤN DỮ LIỆU CƠ BẢN (15 ĐIỂM)
-- Câu 1:
select book_id,title,price 
from books b join Categories c on b.category_id= c.category_id
where c.category_name like 'IT' and b.price >200000;

-- Câu 2:
select reader_id,full_name,email
from readers
where email like'%@gmail.com' and year(created_at)=2022;

-- Câu 3:
select * from books
order by price desc limit 5 offset 2;

-- PHẦN 3: TRUY VẤN DỮ LIỆU NÂNG CAO (20 ĐIỂM)
-- Câu 1:

select loan_id,full_name,title,borrow_date,due_date
from loan_records l join readers r on l.reader_id=r.reader_id
					join books b on l.book_id=b.book_id
where return_date is null;

-- Câu 2:
select category_name, sum(stock_quantity)
from  books b join categories c on c.category_id = b.category_id 
group by b.category_id
having sum(stock_quantity)>10;

-- Câu 3:

select full_name
from readers r join membership_details m on r.reader_id = m.reader_id
               join loan_records l on r.reader_id=l.reader_id
               join books b on b.book_id=l.book_id
where ranks='VIP' and price <300000;
 

-- PHẦN 4: INDEX VÀ VIEW (10 ĐIỂM)

-- Câu 1:

create index idx_loan_dates on loan_records(borrow_date,return_date);

-- Câu 2:

create view vw_overdue_loans AS
select lr.loan_id, r.full_name AS reader_name, b.title AS book_title, lr.borrow_date, lr.due_date
from Loan_Records lr
join Readers r ON lr.reader_id = r.reader_id
join Books b ON lr.book_id = b.book_id
where CURDATE() > lr.due_date AND lr.return_date IS NULL;

-- PHẦN 5: TRIGGER (10 ĐIỂM)
-- Câu 1:

DELIMITER //
create trigger trg_after_loan_insert
after insert on Loan_Records
for each row
begin
update Books
set stock_quantity = stock_quantity - 1
where book_id = new.book_id;
end //
DELIMITER ;

-- Câu 2:
DELIMITER //
create trigger trg_prevent_delete_active_reader
before delete on Readers
for each row
begin
declare active_count int;
select COUNT(*) into active_count
from Loan_Records
where reader_id = old.reader_id and return_date is null;
if active_count > 0 then
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cannot delete reader with active loans';
end if;
end //
DELIMITER ;


-- PHẦN 6: STORED PROCEDURE (20 ĐIỂM)

-- Câu 1:
DELIMITER //
create procedure sp_check_availability(IN p_book_id INT, OUT p_message VARCHAR(20))
begin
declare v_stock int ;
select stock_quantity into v_stock from Books where book_id = p_book_id;
if v_stock is null then
set p_message = 'Not found';
elseif v_stock = 0 then
set p_message = 'Hết hàng';
elseif v_stock <= 5 then
set p_message = 'Sắp hết';
else
set p_message = 'Còn hàng';
end if;
end //
DELIMITER ;

-- Câu 2:
DELIMITER //
create procedure sp_return_book_transaction(IN p_loan_id INT)
begin
declare v_return_date DATE;
declare v_book_id INT;
DECLARE EXIT HANDLER FOR SQLEXCEPTION
begin
ROLLBACK;
end;

START TRANSACTION;

-- B2: kiểm tra return_date
select return_date, book_id INTO v_return_date, v_book_id
from Loan_Records
where loan_id = p_loan_id for update;

if v_return_date IS NOT NULL THEN
ROLLBACK;
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Sách đã trả rồi';
end if;

-- B3: cập nhật return_date = CURRENT_DATE
update Loan_Records
set return_date = current_date()
where loan_id = p_loan_id;

-- B4: tăng stock cho sách
update Books
set stock_quantity = stock_quantity + 1
where book_id = v_book_id;

COMMIT;
end //
DELIMITER ;

