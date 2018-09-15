##1A. Display the first and last names of all actors from the table actor.


USE sakila;

SELECT first_name , Last_name 
FROM actor;

##1B Display the first and last name of each actor in a single column in upper case letters. 
#Name the column Actor Name.

SELECT concat(first_name," ", last_name) AS Actor_Name
FROM actor;

##2A You need to find the ID number, first name, and last name of an actor, 
#of whom you know only the first name, "Joe." 
#What is one query would you use to obtain this information?
SELECT actor_id, first_name, last_name
FROM actor
WHERE first_name = 'Joe';

##2B Find all actors whose last name contain the letters GEN:
SELECT last_name
FROM actor
WHERE last_name LIKE '%GEN%';

##2C Find all actors whose last names contain the letters LI. 
#This time, order the rows by last name and first name, in that order:
SELECT last_name, first_name
FROM actor
WHERE last_name LIKE '%LI%'
ORDER BY last_name, first_name;

##2D. Using IN, display the country_id and country columns of the following countries: 
#Afghanistan, Bangladesh, and China:
SELECT country_id, country
FROM country
WHERE country IN('Afghanistan', 'Bangladesh', 'China');

##3A You want to keep a description of each actor. 
#You don't think you will be performing queries on a description, 
#so create a column in the table actor named description and use the data type BLOB 
#(Make sure to research the type BLOB, as the difference between it and VARCHAR are significant).
SELECT * FROM sakila.actor; 
ALTER TABLE actor ADD description BLOB(60) AFTER last_name;

##3B Very quickly you realize that entering descriptions for each actor is too much effort. 
#Delete the description column.
ALTER TABLE actor
DROP COLUMN description;
SELECT * FROM sakila.actor;

##4A. List the last names of actors, as well as how many actors have that last name.
SELECT last_name, COUNT(last_name) AS 'Actors with last name' 
FROM actor GROUP BY last_name;

##4B List last names of actors and the number of actors who have that last name, 
##but only for names that are shared by at least two actors
SELECT last_name, COUNT(last_name) AS 'Number of Actors' 
FROM actor GROUP BY last_name HAVING count(*) >=2;

##4C. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. 
##Write a query to fix the record.
UPDATE actor 
SET first_name = 'HARPO'
WHERE First_name = 'GROUCHO' AND last_name = 'WILLIAMS';
#SELECT * FROM sakila.actor;

#4D. Perhaps we were too hasty in changing GROUCHO to HARPO. 
#It turns out that GROUCHO was the correct name after all! In a single query, 
#if the first name of the actor is currently HARPO, change it to GROUCHO.
UPDATE actor 
SET first_name = 'GROUCHO'
WHERE actor_id = 172;
SELECT * FROM sakila.actor;

#5A. You cannot locate the schema of the address table. Which query would you use to re-create it?
#5A Hint: https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html
DESCRIBE sakila.address;
SHOW CREATE TABLE sakila.address;

#CREATE TABLE `address` (\n  `address_id` smallint(5) unsigned NOT NULL AUTO_INCREMENT,\n  
#	`address` varchar(50) NOT NULL,\n  `address2` varchar(50) DEFAULT NULL,\n  
#	`district` varchar(20) NOT NULL,\n  `city_id` smallint(5) unsigned NOT NULL,\n  
#	`postal_code` varchar(10) DEFAULT NULL,\n  `phone` varchar(20) NOT NULL,\n  
#	`location` geometry NOT NULL,\n  
#	`last_update` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,\n  
#	PRIMARY KEY (`address_id`),\n  KEY `idx_fk_city_id` (`city_id`),\n  
#	SPATIAL KEY `idx_location` (`location`),\n  
#	CONSTRAINT `fk_address_city` FOREIGN KEY (`city_id`) 
#   REFERENCES `city` (`city_id`) ON UPDATE CASCADE\n) 
#   ENGINE=InnoDB AUTO_INCREMENT=606 DEFAULT CHARSET=utf8

##6A. Use JOIN to display the first and last names, as well as the address, 
#of each staff member. Use the tables staff and address:
SELECT first_name, last_name, address
FROM staff s
JOIN address a
ON s.address_id = a.address_id;

##6B. Use JOIN to display the total amount rung up by each staff member in August of 2005. 
#Use tables staff and payment.
SELECT first_name, last_name, SUM(amount)
FROM staff s
INNER JOIN payment p
ON s.staff_id = p.staff_id
GROUP BY p.staff_id
ORDER BY last_name ASC;

#6c. List each film and the number of actors who are listed for that film. 
#Use tables film_actor and film. Use inner join.
SELECT title, COUNT(actor_id)
FROM film f
INNER JOIN film_actor fa
ON f.film_id = fa.film_id
GROUP BY title;

#6D. How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT title, 
(
	SELECT COUNT(inventory_id) FROM inventory
	WHERE film.film_id = inventory.film_id
) 	
AS 'Number of Copies'
FROM film
WHERE title = "Hunchback Impossible";

#6E. Using the tables payment and customer and the JOIN command, 
#list the total paid by each customer.
#List the customers alphabetically by last name:![Total amount paid](Images/total_payment.png)
SELECT c.first_name, c.last_name, sum(p.amount) AS `Total Paid`
FROM customer c
JOIN payment p 
ON c.customer_id= p.customer_id
GROUP BY c.last_name;

#7A. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. 
#As an unintended consequence, films starting with the letters K and Q have also soared in popularity. 
#Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
SELECT title
FROM film WHERE title 
LIKE 'K%' OR title LIKE 'Q%'
AND title IN 
(
	SELECT title 
	FROM film 
	WHERE language_id = 1
);

#7B. Use subqueries to display all actors who appear in the film Alone Trip.
SELECT first_name, last_name
FROM actor
WHERE actor_id IN 
(
	SELECT actor_id 
    FROM film_actor
    WHERE film_id IN
    (
		SELECT film_id
		FROM film
		WHERE title = 'Alone Trip'
	)
);

#7C. You want to run an email marketing campaign in Canada, 
#for which you will need the names and email addresses of all Canadian customers. 
#Use joins to retrieve this information.
SELECT country, last_name, first_name, email
FROM country c
LEFT JOIN customer cu
ON c.country_id = cu.customer_id
WHERE country = 'Canada';

#7D. Sales have been lagging among young families, and you wish to target all family movies 
#for a promotion. Identify all movies categorized as family films.
SELECT title, category
FROM film_list
WHERE category = 'Family';

#7E. Display the most frequently rented movies in descending order.
-- SELECT * FROM rental;
-- SELECT * FROM inventory;
SELECT t.title, COUNT(rental_id) AS 'Times Rented'
FROM rental r
JOIN inventory i
ON (r.inventory_id = i.inventory_id)
JOIN film t
ON (i.film_id = t.film_id)
GROUP BY t.title
ORDER BY `Times Rented` DESC;

#7F. Write a query to display how much business, in dollars, each store brought in.
SELECT store.store_id, SUM(amount)
FROM store
INNER JOIN staff
ON store.store_id = staff.store_id
INNER JOIN payment p 
ON p.staff_id = staff.staff_id
GROUP BY store.store_id
ORDER BY SUM(amount);

#7G. Write a query to display for each store its store ID, city, and country.
SELECT s.store_id, cty.city, country.country 
FROM store s
JOIN address a 
ON (s.address_id = a.address_id)
JOIN city cty
ON (cty.city_id = a.city_id)
JOIN country
ON (country.country_id = cty.country_id);

#7H. List the top five genres in gross revenue in descending order. 
#(Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
#SELECT * FROM category;
#SELECT * FROM film_category;
#SELECT * FROM inventory;
#SELECT * FROM payment;
#SELECT * FROM rental;
SELECT name AS top_five, SUM(amount) AS gross_revenue
FROM category c
INNER JOIN film_category fc
ON  c.category_id = fc.category_id
INNER JOIN inventory i
ON fc.film_id = i.film_id
INNER JOIN rental r
ON i.inventory_id = r.inventory_id
INNER JOIN payment p 
ON r.rental_id = p.rental_id
GROUP BY top_five 
ORDER BY gross_revenue  
LIMIT 5;

#8a. In your new role as an executive, you would like to have an easy way of viewing the 
#Top five genres by gross revenue. Use the solution from the problem above to create a view. 
#If you haven't solved 7h, you can substitute another query to create a view.

CREATE VIEW top_five_genres_by_gross_revenue AS

SELECT name AS top_five, SUM(amount) AS gross_revenue
FROM category c
INNER JOIN film_category fc
ON  c.category_id = fc.category_id
INNER JOIN inventory i
ON fc.film_id = i.film_id
INNER JOIN rental r
ON i.inventory_id = r.inventory_id
INNER JOIN payment p 
ON r.rental_id = p.rental_id
GROUP BY top_five 
ORDER BY gross_revenue  
LIMIT 5;

#8B. How would you display the view that you created in 8a?
SELECT * FROM top_five_genres_by_gross_revenue;

#8C. You find that you no longer need the view top_five_genres. Write a query to delete it.
DROP VIEW top_five_genres_by_gross_revenue;









