use ord;
create table customers (
    id int primary key,
    name varchar(100)
);
create table orderr (
    order_id int primary key,
    product varchar(100),
    customer_id int,
    foreign key (customer_id) references customers(id)
);
insert into customers values
(1,'arun'),
(2,'priya'),
(3,'karthik'),
(4,'divya'),
(5,'rahul');
insert into orderr values
(101,'laptop',1),
(102,'mobile',2),
(103,'tablet',1),
(104,'watch',3),
(105,'camera',2);

select customers.name, orderr.product
from customers
inner join orderr
on customers.id = orderr.customer_id;

select customers.name, orderr.product
from customers
left join orderr
on customers.id = orderr.customer_id;