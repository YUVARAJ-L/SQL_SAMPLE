use ram
/*Project Phase I
1. Who is the senior most employee based on job title?
2. Which countries have the most Invoices?
3. What are top 3 values of total invoice? 
4. Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money.
Write a query that returns one city that has the highest sum of invoice totals. Return both the city name & sum of all invoice totals 
5. Who is the best customer? The customer who has spent the most money will be declared the best customer. 
Write a query that returns the person who has spent the most money 

Project Phase II
1. Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A 
2. Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the Artist name and total track count of the top 10 rock bands 
3. Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first

Project Phase III
1. Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent 
2. We want to find out the most popular music Genre for each country. 
We determine the most popular genre as the genre with the highest amount of purchases. 
Write a query that returns each country along with the top Genre. 
For countries where the maximum number of purchases is shared return all Genres
3. Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount
*/
select * from artist;
select * from album;
select * from customer;
select * from employee;
select * from genre;
select * from invoice;
select * from invoice_line;
select * from media_type;
select * from playlist;
select * from playlist_track;
select * from track;
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#1. Who is the senior most employee based on job title?
select * from employee;
select title from
(select title,max(right(levels,1)) as lev from employee
group by title) kk
order by lev desc
limit 1
=======================================================================================================================================================================================
SELECT *
FROM employee
where reports_to not in (select employee_id from employee)
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

#2. Which countries have the most Invoices?
select * from invoice;
select billing_country, count(billing_country) as counts from invoice
group by billing_country
order by counts desc
limit 5

#3. What are top 3 values of total invoice?
select * from invoice;
select total from invoice
order by total desc
limit 3

#4. Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money.
#Write a query that returns one city that has the highest sum of invoice totals. Return both the city name & sum of all invoice totals 
select * from invoice;
select billing_city,round(sum(total),2) as totalinvoice from invoice
group by billing_city
order by totalinvoice desc
limit 5

#5. Who is the best customer? The customer who has spent the most money will be declared the best customer. 
#Write a query that returns the person who has spent the most money 
select a.first_name,round(sum(b.total),2) as maxspend from customer a inner join invoice b on a.customer_id=b.customer_id
group by a.first_name
order by maxspend desc
limit 5

-- 1. Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
-- Return your list ordered alphabetically by email starting with A 
select a.first_name as customerFname,a.last_name as customerLname,a.email 
from customer a left join invoice b on a.customer_id=b.customer_id 
left join invoice_line c on b.invoice_id=c.invoice_id
left join track d on c.track_id=d.track_id
left join genre e on d.genre_id=e.genre_id
where e.name="rock"
order by a.email

#2. Let's invite the artists who have written the most rock music in our dataset. 
#Write a query that returns the Artist name and total track count of the top 10 rock bands 
select g.name as artistname,sum(c.track_id) as countofrock
from customer a left join invoice b on a.customer_id=b.customer_id 
left join invoice_line c on b.invoice_id=c.invoice_id
left join track d on c.track_id=d.track_id
left join genre e on d.genre_id=e.genre_id
left join album f on d.album_id=f.album_id
left join artist g on f.artist_id=g.artist_id
where e.name="rock"
group by g.name
order by countofrock desc
limit 10

#3. Return all the track names that have a song length longer than the average song length. 
#Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first
select d.name as trackname,d.milliseconds
from customer a left join invoice b on a.customer_id=b.customer_id 
left join invoice_line c on b.invoice_id=c.invoice_id
left join track d on c.track_id=d.track_id
where d.milliseconds>=
(select avg(d.milliseconds) as avgmillisecond
from customer a left join invoice b on a.customer_id=b.customer_id 
left join invoice_line c on b.invoice_id=c.invoice_id
left join track d on c.track_id=d.track_id)
order by d.milliseconds desc

-- 1. Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent 
select a.first_name as customername,g.name as artistname,sum(b.total) as spendingamt
from customer a left join invoice b on a.customer_id=b.customer_id 
left join invoice_line c on b.invoice_id=c.invoice_id
left join track d on c.track_id=d.track_id
left join genre e on d.genre_id=e.genre_id
left join album f on d.album_id=f.album_id
left join artist g on f.artist_id=g.artist_id
group by a.first_name,g.name
order by a.first_name

-- 2. We want to find out the most popular music Genre for each country. 
-- We determine the most popular genre as the genre with the highest amount of purchases. 
-- Write a query that returns each country along with the top Genre. 
-- For countries where the maximum number of purchases is shared return all Genres
with cte1 as(
select a.country,e.genre_id,count(e.genre_id)as genre_ide
from customer a inner join invoice b on a.customer_id=b.customer_id 
inner join invoice_line c on b.invoice_id=c.invoice_id
inner join track d on c.track_id=d.track_id
inner join genre e on d.genre_id=e.genre_id
group by a.country, e.genre_id)
,cte2 as(
select country, genre_id,genre_ide as cnt,(rank() over(partition by country order by genre_ide desc)) as rnkbygenreidcnt
from cte1)
,cte3 as(
select * from cte2
where rnkbygenreidcnt=1)
,cte4 as(
select  genre_id,count(genre_id)as cc from cte3
group by genre_id)
,cte5 as(
select genre_id,rank() over(order by cc desc) as aa from cte4)
,cte6 as
(select a.*,b.aa as rnkbygenreidrnk from cte3 a inner join cte5 b on a.genre_id=b.genre_id
where b.aa=1)
select a.country,a.genre_id,(a.cnt*b.unit_price) as cost from cte6 a inner join track b on a.genre_id=b.genre_id

-- 3. Write a query that determines the customer that has spent the most on music for each country. 
-- Write a query that returns the country along with the top customer and how much they spent. 
-- For countries where the top amount spent is shared, provide all customers who spent this amount
with cte as(
select a.customer_id,b.billing_country,sum(b.total) as spend
from customer a inner join invoice b on a.customer_id=b.customer_id 
group by  a.customer_id,b.billing_country)
,cte2 as
(select *,(dense_rank() over(partition by billing_country order by spend desc)) as rnk
from cte)
select a.customer_id,b.first_name,round(a.spend,3) as spend,a.billing_country from cte2 a left join customer b on a.customer_id=b.customer_id
where rnk=1
order by spend desc