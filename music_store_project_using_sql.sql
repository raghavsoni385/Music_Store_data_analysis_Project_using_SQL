-- Q.1: Who is the senior most employee based on job title ?

SELECT * FROM EMPLOYEE
ORDER BY levels desc
LIMIT 1;

-- Q.2: Which country have the Most Invoices?

SELECT COUNT(*)as c, billing_country
FROM invoice
GROUP BY billing_country
ORDER BY c desc;

-- Q.3: What are top 3 values of total invoices?

SELECT total FROM invoice
ORDER BY total desc
LIMIT 3;

-- Q.4: Which city has the best customers? We would like to throw a promotional
-- Music Festival in the city we made the most money. 
-- Write a query that returns one city that has the highest sum of invoice totals. 
-- Return both the city name & sum of all invoice totals?

SELECT SUM(total) as s,billing_city
FROM invoice
GROUP BY billing_city
ORDER BY s desc
LIMIT 1;

-- Q.5: Who is the best customer? The customer who has spent the most 
-- money will be declared the best customer. 
-- Write a query that returns the person who has spent the most money.

SELECT customer.customer_id as c,customer.first_name,customer.last_name,
SUM(invoice.total) as total
FROM customer
JOIN invoice
ON customer.customer_id = invoice.customer_id
GROUP BY customer.customer_id
ORDER BY total desc
LIMIT 1;

--  Q.6: Write query to return the email, first name, last name, &
--  Genre of all Rock Music listeners. 
-- Return your list ordered alphabetically by email starting with A.

SELECT DISTINCT customer.email,customer.first_name,customer.last_name
FROM customer
JOIN invoice ON customer.customer_id = invoice.Customer_id
JOIN invoice_line ON invoice.invoice_id = invoice_line.invoice_id
WHERE track_id IN (
       SELECT track_id
	   FROM track
	   JOIN genre ON track.genre_id = genre.genre_id
	   WHERE genre.name LIKE 'Rock')
ORDER BY email asc;

--  Q7:Let's invite the artists who have written the most rock music in our dataset. 
-- Write a query that returns the Artist name and total track count of the top 10 rock bands.

SELECT artist.artist_id, artist.name,COUNT(artist.artist_id) as no_of_songs
FROM track
JOIN album ON track.album_id = album.album_id
JOIN artist ON album.artist_id = artist.artist_id
JOIN genre ON track.genre_id = genre.genre_id
WHERE genre.name LIKE 'Rock'
GROUP BY artist.artist_id
ORDER BY no_of_songs desc
LIMIT 10;

--  Q.8: Return all the track names that have a song length longer than the average song length. 
-- Return the Name and Milliseconds for each track. Order by the song length with the longest 
-- songs listed first.

SELECT name,milliseconds
FROM track
WHERE milliseconds > (
     SELECT AVG(milliseconds)
	 FROM track )
ORDER BY milliseconds desc;

--  Q.9: Find how much amount spent by each customer on artists? Write a query
-- 	 to return customer name, artist name and total spent.

WITH best_selling_artist AS (
   SELECT artist.artist_id,artist.name,SUM(invoice_line.unit_price*invoice_line.quantity) AS total_sale
   FROM invoice_line
   JOIN track ON track.track_id = invoice_line.track_id
   JOIN album ON album.album_id = track.album_id
   JOIN artist ON artist.artist_id = album.artist_id
   GROUP BY artist.artist_id
   ORDER BY total_sale desc
   LIMIT 1
)

SELECT customer.customer_id,customer.first_name,customer.last_name,
best_selling_artist.name,SUM(invoice_line.unit_price*invoice_line.quantity) AS spent_amount
FROM invoice
JOIN customer ON customer.customer_id = invoice.customer_id
JOIN invoice_line ON invoice_line.invoice_id = invoice.invoice_id
JOIN track ON track.track_id = invoice_line.track_id
JOIN album ON album.album_id = track.album_id
JOIN best_selling_artist ON album.artist_id = best_selling_artist.artist_id
GROUP BY customer.customer_id, customer.first_name,customer.last_name,
best_selling_artist.name
ORDER BY spent_amount desc;


--  Q.10: We want to find out the most popular music Genre for each country. We 
--  determine the most popular genre as the genre with the highest amount of purchases.
--  Write a query that returns each country along with the top Genre. For countries where 
-- the maximum number of purchases is shared return all Genres.

-- 1st CT then extract data from CTE-

WITH popular_genre AS (
      SELECT COUNT(invoice_line.quantity) AS purchase, customer.country ,genre.name,genre.genre_id,
	  ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity)desc) As
	  row_no
	  FROM invoice_line
	  JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
	  JOIN customer ON customer.customer_id = invoice.customer_id
	  JOIN track ON track.track_id = invoice_line.track_id
	  JOIN genre ON genre.genre_id = track.genre_id
	  GROUP BY customer.country, genre.name,genre.genre_id 
	  ORDER BY customer.country asc, purchase desc 
	)
SELECT * FROM popular_genre WHERE row_no <= 1;


--  Q.11: Write a query that determines the customer that has spent the most on music 
--  for each country. Write a query that returns the country along with the top customer
--  and how much they spent. For countries where the top amount spent is shared, 
--  provide all customers who spent this amount. 

-- 1st CTE then extract specific data from CTE-

WITH customer_with_country AS (
    SELECT customer.customer_id, customer.first_name,customer.last_name,invoice.billing_country,
	SUM(invoice.total) AS total_spending,
	ROW_NUMBER() OVER(PARTITION BY invoice.billing_country ORDER BY SUM(invoice.total)desc) AS
	row_no
	FROM invoice
	JOIN customer ON customer.customer_id = invoice.customer_id
	GROUP BY customer.customer_id,customer.first_name,customer.last_name,invoice.billing_country
	ORDER BY invoice.billing_country asc,total_spending desc
)
SELECT * FROM customer_with_country WHERE row_no <= 1;



                    ----------------------------------------------------------