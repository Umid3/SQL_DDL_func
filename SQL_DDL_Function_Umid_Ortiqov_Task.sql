-- 1)Creating a view sales_revenue_by_category_qtr:
CREATE VIEW sales_revenue_by_category_qtr AS
SELECT c.name AS category, SUM(p.amount) AS total_revenue
FROM category c
JOIN film_category fc ON c.category_id = fc.category_id
JOIN film f ON fc.film_id = f.film_id
JOIN inventory i ON f.film_id = i.film_id
JOIN rental r ON i.inventory_id = r.inventory_id
JOIN payment p ON r.rental_id = p.rental_id
WHERE EXTRACT(QUARTER FROM r.rental_date) = EXTRACT(QUARTER FROM CURRENT_DATE)
      AND EXTRACT(YEAR FROM r.rental_date) = EXTRACT(YEAR FROM CURRENT_DATE)
GROUP BY c.name
HAVING SUM(p.amount) > 0;

-- 2)Creating a query language function get_sales_revenue_by_category_qtr:
CREATE OR REPLACE FUNCTION get_sales_revenue_by_category_qtr(current_quarter INT)
RETURNS TABLE(category VARCHAR, total_revenue DECIMAL)
AS $$
BEGIN
    RETURN QUERY
    SELECT c.name AS category, SUM(p.amount) AS total_revenue
    FROM category c
    JOIN film_category fc ON c.category_id = fc.category_id
    JOIN film f ON fc.film_id = f.film_id
    JOIN inventory i ON f.film_id = i.film_id
    JOIN rental r ON i.inventory_id = r.inventory_id
    JOIN payment p ON r.rental_id = p.rental_id
    WHERE EXTRACT(QUARTER FROM r.rental_date) = current_quarter
          AND EXTRACT(YEAR FROM r.rental_date) = EXTRACT(YEAR FROM CURRENT_DATE)
    GROUP BY c.name
    HAVING SUM(p.amount) > 0;
END;
$$ LANGUAGE plpgsql;


-- 3)Create a procedure language function called "new_movie"
CREATE OR REPLACE FUNCTION new_movie(movie_title VARCHAR(255)) RETURNS INTEGER AS $$
DECLARE
  film_id INT;
  language_id INT;
BEGIN
  SELECT nextval('film_id_seq') INTO film_id;

  SELECT language_id INTO language_id FROM language WHERE name = 'Klingon';
  IF language_id IS NULL THEN
    RAISE 'Language does not exist.' USING ERRCODE = 'class condition';
  END IF;

  INSERT INTO film (film_id, title, language_id, rental_rate, rental_duration, replacement_cost, release_year)
  VALUES (film_id, movie_title, language_id, 4.99, 3, 19.99, CURRENT_YEAR);

  RETURN film_id;
END;
$$ LANGUAGE plpgsql;
