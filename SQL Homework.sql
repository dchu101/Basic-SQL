USE sakila;

# * 1a. Display the first and last names of all actors from the table `actor`.

SELECT first_name, last_name

FROM actor;

# * 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column `Actor Name`.

SELECT UPPER(CONCAT(first_name, " ", last_name)) as "Actor Name"

FROM actor;

# * 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?

SELECT actor_id, first_name, last_name

FROM actor

WHERE first_name = "Joe";

# * 2b. Find all actors whose last name contain the letters `GEN`:

SELECT actor_id, first_name, last_name

FROM actor

WHERE last_name LIKE "%gen%";

#* 2c. Find all actors whose last names contain the letters `LI`. This time, order the rows by last name and first name, in that order:

SELECT actor_id, first_name, last_name

FROM actor

WHERE last_name LIKE "%li%"

ORDER BY 3 ASC, 2 ASC;

# * 2d. Using `IN`, display the `country_id` and `country` columns of the following countries: Afghanistan, Bangladesh, and China:

SELECT country_id, country

FROM country

WHERE country IN ("Afghanistan", "Bangladesh", "China");

# * 3a. Add a `middle_name` column to the table `actor`. Position it between `first_name` and `last_name`. Hint: you will need to specify the data type.

ALTER table actor
ADD middle_name VARCHAR(255);

# * 3b. You realize that some of these actors have tremendously long last names. Change the data type of the `middle_name` column to `blobs`.

ALTER table actor
MODIFY middle_name BLOB;

#* 3c. Now delete the `middle_name` column.
ALTER table actor
DROP COLUMN middle_name;

# * 4a. List the last names of actors, as well as how many actors have that last name.

SELECT last_name, count(last_name)
FROM actor
GROUP BY 1;

# * 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors

SELECT last_name, count(last_name)
FROM actor
GROUP BY last_name
HAVING count(last_name) >= 2;

#* 4c. Oh, no! The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`, the name of Harpo's second cousin's husband's yoga teacher. Write a query to fix the record.

UPDATE actor
SET first_name="HARPO"
WHERE first_name="GROUCHO" AND last_name="WILLIAMS"

#* 4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. It turns out that `GROUCHO` was the correct name after all! In a single query, if the first name of the actor is currently `HARPO`, change it to `GROUCHO`. Otherwise, change the first name to `MUCHO GROUCHO`, as that is exactly what the actor will be with the grievous error. BE CAREFUL NOT TO CHANGE THE FIRST NAME OF EVERY ACTOR TO `MUCHO GROUCHO`, HOWEVER! (Hint: update the record using a unique identifier.)

UPDATE actor
SET first_name = 
	CASE WHEN first_name = "HARPO" THEN "GROUCHO"
	ELSE "MUCHO GROUCHO"
END
WHERE actor_id="172";

#* 5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it?

SHOW CREATE TABLE address;

#Better formatted version of above
describe address;

# * 6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member. Use the tables `staff` and `address`:

SELECT s.first_name, s.last_name, a.address

FROM staff as s LEFT JOIN address as a on s.address_id = a.address_id;

# * 6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. Use tables `staff` and `payment`.

SELECT s.first_name, s.last_name, SUM(p.amount) as "Total Sales 08/2005"

FROM payment as p LEFT JOIN staff as s on p.staff_id = s.staff_id

WHERE p.payment_date BETWEEN "2005-08-30" AND "2015-08-31"

GROUP BY 1, 2;

# * 6c. List each film and the number of actors who are listed for that film. Use tables `film_actor` and `film`. Use inner join.

SELECT f.title, COUNT(a.actor_id) as "Number of Actors"

FROM film_actor as a JOIN film as f ON a.film_id = f.film_id

GROUP BY 1;

# * 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?

SELECT f.title, count(i.inventory_id) as "Inventory Count"

FROM inventory as i JOIN film as f ON f.film_id = i.film_id

WHERE title = "Hunchback Impossible"
 
 GROUP BY 1;
 
 # * 6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer. List the customers alphabetically by last name:

SELECT c.last_name, c.first_name, sum(p.amount) as "Total Rental Revenue"

FROM payment as p LEFT JOIN customer as c ON p.customer_id = c.customer_id

GROUP BY 1, 2

ORDER BY 1 ASC, 2 ASC;

# * 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters `K` and `Q` have also soared in popularity. Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English.

SELECT title,name FROM

	(SELECT title,language_id FROM film WHERE title LIKE "K%" or title LIKE "Q%") as f

	JOIN 

	(SELECT name,language_id FROM language WHERE name = "English") as l

	ON f.language_id = l.language_id

#* 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.

SELECT title, first_name, last_name, ab.actor_id FROM

    (
        (SELECT actor_id, title FROM 
            (SELECT actor_id, film_id FROM film_actor) as a
            LEFT JOIN
            (SELECT film_id,  title FROM film) AS b 
            ON a.film_id = b.film_id
        ) AS ab
    
		LEFT JOIN
        
        (SELECT actor_id, first_name, last_name FROM actor) AS c
        
        ON ab.actor_id = c.actor_id)
    
WHERE title = "Alone Trip";

# * 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.

SELECT first_name, last_name, email, country

FROM customer AS cu

JOIN  address AS a ON cu.address_id = a.address_id

JOIN city AS ci ON a.city_id = ci.city_id

JOIN  country as co ON ci.country_id = co.country_id

WHERE country = "Canada";

# * 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as famiy films.

SELECT f.film_id, title, c.name FROM

film as f

JOIN film_category as fc ON f.film_id = fc.film_id

JOIN category as c ON fc.category_id = c.category_id

WHERE c.name = "Family";

# * 7e. Display the most frequently rented movies in descending order.

SELECT film_id, title, COUNT(rental_id) AS "Total Rentals"

FROM

	(SELECT f.film_id, title, rental_id FROM

	rental as r 

	LEFT JOIN inventory AS i ON  r.inventory_id = i.inventory_id

	LEFT JOIN film AS f ON i.film_id = f.film_id) as rentals
    
GROUP BY 1, 2

ORDER BY 3 DESC, 2 ASC;

# * 7f. Write a query to display how much business, in dollars, each store brought in.

SELECT store_id, SUM(amount) as "Total Revenue" FROM 

payment AS p

LEFT JOIN staff AS s on p.staff_id = s.staff_id

GROUP BY 1

ORDER BY 2 DESC;

# * 7g. Write a query to display for each store its store ID, city, and country.

SELECT store_id, city, country FROM

store as st

JOIN address AS ad ON st.address_id = ad.address_id 

JOIN city AS ct ON ad.city_id = ct.city_id

JOIN country AS co on ct.country_id = co.country_id;

# * 7h. List the top five genres in gross revenue in descending order.

SELECT name as Category, sum(amount) as "Total Revenue" FROM payment AS p

	 JOIN rental AS r ON p.rental_id = r.rental_id

	 JOIN inventory AS i ON r.inventory_id = i.inventory_id

	 JOIN film_category AS fc ON i.film_id = fc.film_id

	 JOIN category AS c ON fc.category_id = c.category_id

GROUP BY 1

ORDER  BY 2 DESC

LIMIT 5;

# * 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.

CREATE VIEW top5 AS 
    
    SELECT name, sum(amount) FROM payment AS p

		JOIN rental AS r ON p.rental_id = r.rental_id

		JOIN inventory AS i ON r.inventory_id = i.inventory_id

		JOIN film_category AS fc ON i.film_id = fc.film_id

		JOIN category AS c ON fc.category_id = c.category_id

	GROUP BY 1

	ORDER  BY 2 DESC

	LIMIT 5;
    
# * 8b. How would you display the view that you created in 8a?

SELECT * FROM top5;

# * 8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.

DROP VIEW top5;