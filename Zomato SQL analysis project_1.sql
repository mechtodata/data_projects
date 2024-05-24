CREATE TABLE goldusers_signup(userid integer,gold_signup_date date); 

INSERT INTO goldusers_signup(userid,gold_signup_date) 
 VALUES (1,'09-22-2017'),
        (3,'04-21-2017')

CREATE TABLE users(userid integer,signup_date date); 

INSERT INTO users(userid,signup_date) 
 VALUES (1,'09-02-2014'),
        (2,'01-15-2015'),
        (3,'04-11-2014');


CREATE TABLE sales(userid integer,created_date date,product_id integer); 

INSERT INTO sales(userid,created_date,product_id) 
 VALUES (1,'04-19-2017',2),
        (3,'12-18-2019',1),
        (2,'07-20-2020',3),
        (1,'10-23-2019',2),
        (1,'03-19-2018',3),
        (3,'12-20-2016',2),
        (1,'11-09-2016',1),
        (1,'05-20-2016',3),
        (2,'09-24-2017',1),
        (1,'03-11-2017',2),
        (1,'03-11-2016',1),
        (3,'11-10-2016',1),
        (3,'12-07-2017',2),
        (3,'12-15-2016',2),
        (2,'11-08-2017',2),
        (2,'09-10-2018',3);

CREATE TABLE product(product_id integer,product_name text,price integer); 

INSERT INTO product(product_id,product_name,price) 
 VALUES (1,'p1',980),
        (2,'p2',870),
        (3,'p3',330);

select * from sales;
select * from users;
select * from goldusers_signup;
select * from product;


--1. what is the total amount each customer spent on zomato?

select userid,sum(price) as total_amount_spent from sales 
left join product on sales.product_id = product.product_id 
group by userid;

--2. how many days has each customer visited zomato ?

select userid, count (distinct created_date) as no_of_visit  from sales 
group by userid;

--3. what was the first product purchased by each customer ?

select * from (
select *, rank() over( partition by userid order by created_date asc) as rn from sales)as a

where rn =1 


--4 what is the most purchased item on the menu and how many times it was purchased by all customers ?

select userid, count (product_id) as purchasedtimes_by_all_customer from sales where product_id =
(select top 1  product_id as most_purchased_item from sales
group by product_id
order by count(product_id) desc )
group by userid

--5 which item was the most populer for each customer ?

select * from 
(select *,rank() over (partition by userid order by cnt desc) rnk from
(select userid, product_id,count(product_id)cnt  from sales group by userid, product_id) as a) as b
where rnk =1 


--6 which item was purchased first by the customer after they became a member ?
--select d.* from
 select * from 
( select c.*, rank() over (partition by userid order by created_date ) as rnk from 
(select a.userid,a.created_date, a.product_id,b.gold_signup_date from sales as a 
 inner join  goldusers_signup as b on a.userid = b.userid and created_date > =gold_signup_date)c)d where rnk =1;


--7 hich item was purchased first by the customer before they became a member ?

 select d.* from 
( select c.*, rank() over (partition by userid order by created_date asc) as rnk from 
(select a.userid,a.created_date, a.product_id,b.gold_signup_date from sales as a 
 inner join  goldusers_signup as b on a.userid = b.userid and created_date <= gold_signup_date)c)d where rnk =1;

 --8 what is the total ordes and amount spent for each member before they become a member ?

 select userid, count(userid) as total_orders , sum(price) amount_spent from 
 (select c.*, d.price from
 (select a.userid,a.created_date, a.product_id,b.gold_signup_date from sales as a 
 inner join  goldusers_signup as b on a.userid = b.userid and created_date <= gold_signup_date) c
 inner join product as d on c.product_id = d.product_id) e
 group by (userid)
