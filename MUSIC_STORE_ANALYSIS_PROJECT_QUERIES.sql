-- Who is the senior most employee based on job title ?
select * from employee
order by levels desc 
limit 1

-- Which are top 10 country have the most Invoices?
select count(*) as high, billing_country from invoice
group by billing_country
order by high desc 
limit 10 

-- What are top 3 values of total invoice 
select total from invoice 
order by total desc limit 3 

--which city hs the best customer? we would like to throw a promotional music festival in the city 
--we made the most most. Write a query that return one city that has the highest sum of invoices totals.
--Return both city and name and sum of all invoice totals 
select sum(total) as total_invoice , billing_city 
from invoice 
group by billing_city
order by total_invoice desc 

-- who is thre best customer ? The customer who has spent the most money will be declared the best customer.
--write  query that returns thr person who has spent the most money 

select c.customer_id, c.first_name,c.city,c.last_name,sum(i.total) as total
from customer c 
inner join invoice i 
on c.customer_id = i.customer_id
group by  c.customer_id
order by total desc limit 1 

--MODERATE 

--Write query to return the gmail,first and last name or genre of all rock music listeners.
--return your list ordered alphabetically by email starting with A

select distinct email,first_name, last_name 
from customer 
join invoice on customer.customer_id = invoice.customer_id 
join invoice_line on invoice.invoice_id = invoice_line.invoice_id
where track_id in( 
   select track_id from track 
   join genre on track.genre_id = genre.genre_id 
   where genre.name like 'Rock')
order by email

--Let's invite the artist who have written the most rock music in our dataset.
--Write a query that return the artist name and total track count of the top 10 rock

select artist.artist_id ,artist.name, count(artist.artist_id) as no_of_songs
from track 
join album on album.album_id = track.album_id 
join artist on artist.artist_id = album.artist_id
join genre on genre.genre_id = track.genre_id 
where genre.name like 'Rock'
group by artist.artist_id
order by no_of_songs desc limit 10 

-- Return all the track names that have a song length longer than the average song length.
-- Return the name and miliseconds for each track.
-- Order by the song length with the longest songs listed first.

select name , milliseconds 
from track 
where milliseconds > 
(select avg(milliseconds) as avg_track_len 
from track )
order by milliseconds  desc 

--ADVANCE 

--Find how much amount spent by each customer on artist? 
--Write a query to return customer name , artist name and total spent 

with best_selling as (
   select artist.artist_id as artist_id ,artist.name as artist_name , 
   sum(invoice_line.unit_price*invoice_line.quantity) as total_sale
   from invoice_line
   join track on track.track_id = invoice_line.track_id
   join album on album.album_id = track.album_id 
   join artist on artist.artist_id = album.artist_id 
   group by 1 
   order by 3 desc limit 1
)
select c.customer_id ,c.first_name,c.last_name ,bs.artist_name, sum(il.unit_price*il.quantity) as total_amount
from invoice i 
join customer c on c.customer_id = i.customer_id
join invoice_line il on il.invoice_id =  i.invoice_id 
join track t on t.track_id = il.track_id 
join album ab on ab.album_id = t.album_id 
join best_selling  bs on bs.artist_id = ab.artist_id 
group by c.customer_id ,c.first_name,bs.artist_name,c.last_name 
order by 5 desc

--We want to find out the most popular music genre for each country 
--(we determine the most popular genre as the genre wth the  highest amount of purchase)

with popular_genre as(
select count(invoice_line.quantity) as purchases, customer.country , genre.name, genre.genre_id,
row_number() over(partition by customer.country order by count(invoice_line.quantity) desc) as RowNo
from invoice_line 
join invoice on invoice.invoice_id = invoice_line.invoice_id
join customer on customer.customer_id = invoice.customer_id 
join track on track.track_id = invoice_line.track_id 
join genre on genre.genre_id = track.genre_id 
group by 2,3,4
order by 2 asc , 1 desc
)
select * from popular_genre where Rowno <= 1

--Write a query that detemines the customer that has spent the most on music for each country.
--Write a query that return the country along with the top customer and how much they spent.
--For countries where the top amount apent is shared, provided all customers who spent this amount.

with customer_and_country as (
select customer.customer_id , first_name, last_name,billing_country, sum(total) as total_spent,
row_number() over(partition by billing_country order by sum(total) desc) as Row_no
from invoice 
join customer on customer.customer_id = invoice.customer_id 
group by 1,2,3,4
order by 4 desc ,5 desc)
select * from customer_and_country where Row_no <=1






