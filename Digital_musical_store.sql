-- PROJECT OF DIGITAL MUSIC STORE

-- QUESTION SET 1 - Easy
--[Q1. who is the senior most employee based on job title]
select * from employee;
select *
from employee
order by levels desc
limit 1;

--[Q2. which countries have the most invoice]
select * from invoice;
select billing_country, count(invoice_id)
from invoice
group by billing_country
order by count(invoice_id) desc
limit 1;

--[Q4.what are the top 3 values of total invoice]
select total
from invoice
order by total desc
limit 3;

--[Which city has the best customers? 
--We would like to throw a promotional Music Festival in the city we made the most money.
--Write a query that returns one city that has the highest sum of invoice totals.]
select billing_city,sum(total)
from invoice
group by billing_city
order by sum(total) desc;

--[Q5.Who is the best customer? 
--The customer who has spent the most money will be declared the best customer. 
--Write a query that returns the person who has spent the most money.]
select * from customer;

select c.first_name,c.customer_id,c.*,sum(i.total)
from customer as c
join invoice as i
on c.customer_id = i.customer_id
group by c.first_name,c.customer_id
order by sum(i.total) desc;



--QUESTION SET 2 - Moderate
--[Q1. Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
--Return your list ordered alphabetically by email starting with A.]
select * from track;
select c.email,c.first_name,c.last_name
from customer as c
join invoice as i
on c.customer_id = i.customer_id
join invoice_line as il 
on il.invoice_id = i.invoice_id
where track_id in (select t.track_id
from track as t
join genre as g
on t.genre_id = g.genre_id
where g.name = 'Rock')
order by c.email;


select c.email,c.first_name,c.last_name
from customer as c
join invoice as i
on c.customer_id = i.customer_id
join invoice_line as il 
on il.invoice_id = i.invoice_id
join track as t
on t.track_id = il.track_id
join genre as g
on g.genre_id = t.genre_id
where g.name = 'Rock'
order by c.email

--[Q2.Let's invite the artists who have written the most rock music in our dataset. 
--Write a query that returns the Artist name and total track count of the top 10 rock bands. ]
select * from track;
select ar.name,ar.artist_id,count(ar.artist_id) as song
from album as a
join artist as ar
on a.artist_id = ar.artist_id
join track as t
on t.album_id = a.album_id
join genre as g
on g.genre_id = t.genre_id
where g.name = 'Rock'
group by ar.name,ar.artist_id
order by song desc
limit 10;


--[Q3. Return all the track names that have a song length longer than the average song length. 
--Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first.]
with avg_len as (
select name, avg(milliseconds) as avg_length from track
group by name )

select t.name , t.milliseconds , t.track_id
from track as t
join avg_len as a
on a.name = t.name
where t.milliseconds > a.avg_length
order by t.milliseconds desc;

select name,milliseconds
from track
where milliseconds > (select avg(milliseconds)as avg_length
from track)
order by milliseconds desc;


--Question set 3 = Advance
--[Q1.Find how much amount spent by each customer on artists?
-- Write a query to return customer name, artist name and total spent]
WITH best_selling_artist AS (
	SELECT artist.artist_id AS artist_id, artist.name AS artist_name, SUM(invoice_line.unit_price*invoice_line.quantity) AS total_sales
	FROM invoice_line
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN album ON album.album_id = track.album_id
	JOIN artist ON artist.artist_id = album.artist_id
	GROUP BY 1
	ORDER BY 3 DESC
	LIMIT 1
)
SELECT c.customer_id, c.first_name, c.last_name, bsa.artist_name, SUM(il.unit_price*il.quantity) AS amount_spent
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album alb ON alb.album_id = t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = alb.artist_id
GROUP BY 1,2,3,4
ORDER BY 5 DESC;


--[Q2.We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
--with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
--the maximum number of purchases is shared return all Genres. ]

WITH popular_genre AS 
(
    SELECT COUNT(invoice_line.quantity) AS purchases, customer.country, genre.name, genre.genre_id, 
	ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS RowNo 
    FROM invoice_line 
	JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
	JOIN customer ON customer.customer_id = invoice.customer_id
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN genre ON genre.genre_id = track.genre_id
	GROUP BY 2,3,4
	ORDER BY 2 ASC, 1 DESC
)
SELECT * FROM popular_genre WHERE RowNo <= 1


--[Q3. Write a query that determines the customer that has spent the most on music for each country. 
--Write a query that returns the country along with the top customer and how much they spent. 
--For countries where the top amount spent is shared, provide all customers who spent this amount.]

WITH Customter_with_country AS (
		SELECT customer.customer_id,first_name,last_name,billing_country,SUM(total) AS total_spending,
	    ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUM(total) DESC) AS RowNo 
		FROM invoice
		JOIN customer ON customer.customer_id = invoice.customer_id
		GROUP BY 1,2,3,4
		ORDER BY 4 ASC,5 DESC)
SELECT * FROM Customter_with_country WHERE RowNo <= 1