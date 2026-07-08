-- 1. Crea el esquema de la BBDD. (adjuntado como imagen)

-- 2. Muestra los nombres de todas las películas con una clasificación por edades de 'R'.

select 
	title as titulo, 
	rating as clasificacion
from film
where rating = 'R';

-- 3. Encuentra los nombres de los actores que tengan un “actor_id” entre 30 y 40.

select 
	first_name as nombre, 
	actor_id as id_actor
from actor 
where actor_id between 30 and 40;

-- 4. Obtén las películas cuyo idioma coincide con el idioma original. (en esta base de datos la columna de original language me sale nula pero la query sería así)
select title as titulo
from film
where language_id = original_language_id ;

-- 5. Ordena las películas por duración de forma ascendente.

select 
	title as titulo, 
	length as duracion 
from film
order by length asc;

-- 6. Encuentra el nombre y apellido de los actores que tengan ‘Allen’ en su apellido.
select 
	first_name as nombre, 
	last_name as apellido
from actor 
where last_name ='ALLEN';

--7. Encuentra la cantidad total de películas en cada clasificación de la tabla “film” y muestra la clasificación junto con el recuento.
select 
	count(film_id ) as total_peliculas, 
	rating as clasificacion
from film
group by clasificacion  ; 

-- 8. Encuentra el título de todas las películas que son ‘PG-13’ o tienen una duración mayor a 3 horas en la tabla film.
select 
	title as titulo, 
	rating as clasificacion, 
	length as duracion
from film 
where rating = 'PG-13' or length > 180;

-- 9. Encuentra la variabilidad de lo que costaría reemplazar las películas.
select round(stddev(replacement_cost ),2) as variabilidad_remplazo
from film;

-- 10. Encuentra la mayor y menor duración de una película de nuestra BBDD.
select 
	MAX(length ) as duracion_maxima , 
	MIN(length ) as duracion_minima
from film ;

-- 11. Encuentra lo que costó el antepenúltimo alquiler ordenado por día.
select 
	p.amount as precio, 
	r.rental_date as fecha_alquiler
from rental r
inner join payment p
	on r.rental_id = p.rental_id
order by r.rental_date desc 
limit 1
offset 2;

-- 12. Encuentra el título de las películas en la tabla “film” que no sean ni ‘NC-17’ ni ‘G’ en cuanto a su clasificación.
select 
	title as titulo, 
	rating as clasificacion
from film  
where rating not in ('NC-17', 'G');

-- 13. Encuentra el promedio de duración de las películas para cada clasificación de la tabla film y muestra la clasificación junto con el
-- promedio de duración.
select 
	AVG(length) as promedio_duracion, 
	rating as clasificacion
from film 
group by clasificacion ;

-- 14. Encuentra el título de todas las películas que tengan una duración mayor a 180 minutos
select 
	title as titulo, 
	length as duracion
from film 
where length > 180;

-- 15. ¿Cuánto dinero ha generado en total la empresa?
select SUM(amount) as total_generado
from payment ; 

-- 16. Muestra los 10 clientes con mayor valor de id.
select 
	first_name as nombre, 
	customer_id as id_cliente
from customer 
order by customer_id desc
limit 10;

-- 17. Encuentra el nombre y apellido de los actores que aparecen en la película con título ‘Egg Igby’
select 
	a.first_name as nombre, 
	a.last_name as apellido
from actor a 
inner join film_actor fa 
	on a.actor_id = fa.actor_id
inner join film f 
	on fa.film_id = f.film_id 
where f.title = 'EGG IGBY';

-- 18. Selecciona todos los nombres de las películas únicos.
select distinct title 
from  film;

-- 19. Encuentra el título de las películas que son comedias y tienen una duración mayor a 180 minutos en la tabla “film”.
select 
 	f.title as titulo, 
 	c."name" as categoria, 
 	f.length as duracion
from film f
inner join film_category fc 
	on f.film_id = fc.film_id 
inner join category c 
	on fc.category_id = c.category_id
where c."name" = 'Comedy' and f.length > 180;

-- 20. Encuentra las categorías de películas que tienen un promedio de duración superior a 110 minutos y muestra el nombre de la categoría
-- junto con el promedio de duración.
select 
    f.title,                    
    AVG(f.length) as duracion
from film f
inner join film_category fc 
	on f.film_id = fc.film_id 
inner join category c 
	on fc.category_id = c.category_id
group by f.title                           
having AVG(f.length) > 110;

-- 21. ¿Cuál es la media de duración del alquiler de las películas?
select 
	AVG(rental_duration ) as duracion_media_alquiler, 
	title as nombre
from film
group by title ;

-- 22. Crea una columna con el nombre y apellidos de todos los actores y actrices
select 
	first_name as nombre, 
	last_name as apellido
from actor;

-- 23. Números de alquiler por día, ordenados por cantidad de alquiler de forma descendente.
select 
	count(rental_id ) as numero_alquiler, 
	rental_date::date as fecha_alquiler
from rental
group by fecha_alquiler   
order by numero_alquiler desc;

-- 24. Encuentra las películas con una duración superior al promedio.
select 
	title as titulo, 
	length as duracion

from film      -- Aquí usamos una subconsulta ya que así si se añaden o eliminan peliculas el promedio siempre va a estar actualizado.
where length > (
    select AVG(length) 
    from film
);

-- 25. Averigua el número de alquileres registrados por mes.
select 
    to_char(rental_date, 'YYYY-MM') as mes, -- convertir un tipo de dato (como una fecha) en una cadena de texto, dándole exactamente el formato visual que tú quieras.
    count(rental_id) as total_alquileres
from rental
group by 1 -- Agrupa por la primera columna del select
order by mes asc;

-- 26. Encuentra el promedio, la desviación estándar y varianza del total pagado.
select 
    round(AVG(amount),2) as promedio,
    round(stddev(amount),2) as desviacion_estandar,
    round(variance(amount),2) as varianza 
from payment;

-- 27. ¿Qué películas se alquilan por encima del precio medio?
select 
    title as titulo, 
    rental_rate as precio_alquiler
from film
where             -- usamos subcolsulta para calcular el promedio del precio
    rental_rate > (
        select AVG(rental_rate) 
        from film
    )
order by rental_rate desc;

-- 28. Muestra el id de los actores que hayan participado en más de 40 películas.
select 
    actor_id as id_actor, 
    count(film_id) as total_peliculas
from film_actor
group by actor_id
having count(film_id) > 40
order by total_peliculas asc;

-- 29. Obtener todas las películas y, si están disponibles en el inventario, mostrar la cantidad disponible.
select 
    f.film_id as pelicula_id,
    f.title as titulo,
    count(i.inventory_id) as cantidad_disponible
from film f
left join   inventory i    -- usamos left join por si no están disponibles que igualmente aparezcan.
   on f.film_id = i.film_id
group by 
    f.film_id, 
    f.title
order by cantidad_disponible desc;

-- 30. Obtener los actores y el número de películas en las que ha actuado.
select 
    a.actor_id as actor_id,
    a.first_name as nombre,
    a.last_name as apellido,
    count(fa.film_id) as total_peliculas
from actor a
inner join  film_actor fa 
	on a.actor_id = fa.actor_id
group by 
    a.actor_id,
    a.first_name,
    a.last_name;

-- 31. Obtener todas las películas y mostrar los actores que han actuado en ellas, incluso si algunas películas no tienen actores asociados.
select 
    f.film_id as pelicula_id,
    f.title as pelicula,
    a.actor_id as actor_id,
    a.first_name as nombre_actor,
    a.last_name as apellido_actor
from film f
left join film_actor fa 
	on f.film_id = fa.film_id
left join actor a 
	on fa.actor_id = a.actor_id
order by 
    f.title asc;

-- 32. Obtener todos los actores y mostrar las películas en las que han actuado, incluso si algunos actores no han actuado en ninguna película.
select 
    a.actor_id as actor_id,
    a.first_name as nombre_actor,
    a.last_name as apellido_actor,
    f.film_id as pelicula_id,
    f.title as pelicula
from actor a
left join film_actor fa 
	on a.actor_id = fa.actor_id
left join film f 
	on fa.film_id = f.film_id
order by 
    a.last_name asc, 
    a.first_name asc,
	f.title asc;

-- 33. Obtener todas las películas que tenemos y todos los registros de alquiler.

select 
    f.title as nombre_pelicula,
    i.inventory_id as id_inventario,
    r.rental_id as id_alquiler,
    r.rental_date as fecha_alquiler
from film f
left join inventory i 
	on f.film_id = i.film_id
left join rental r 
	on i.inventory_id = r.inventory_id
order by 
    f.title asc, 
    i.inventory_id asc,
    r.rental_date desc;

-- 34. Encuentra los 5 clientes que más dinero se hayan gastado con nosotros.
select 
    c.customer_id as cliente_id,
    c.first_name as nombre,
    c.last_name as apellido,
    round(SUM(p.amount), 2) as total_gastado
from customer c
inner join payment p 
	on c.customer_id = p.customer_id
group by 
    c.customer_id,
    c.first_name,
    c.last_name
order by total_gastado desc
limit 5;

-- 35. Selecciona todos los actores cuyo primer nombre es 'Johnny'.
select 
    actor_id as actor_id,
    first_name as nombre,
    last_name as apellido
from actor
where first_name = 'JOHNNY';

-- 36. Renombra la columna “first_name” como Nombre y “last_name” como Apellido.
select 
    first_name as Nombre,
    last_name as Apellido
from actor;

-- 37. Encuentra el ID del actor más bajo y más alto en la tabla actor
select 
    MIN(actor_id) as id_actor_mas_bajo, 
    MAX(actor_id) as id_actor_mas_alto
from actor;

-- 38. Cuenta cuántos actores hay en la tabla “actor”.
select 
    count(*) as total_actores
from actor;

-- 39. Selecciona todos los actores y ordénalos por apellido en orden ascendente.
select 
    actor_id as actor_id,
    first_name as nombre,
    last_name as apellido
from actor
order by last_name asc;

-- 40. Selecciona las primeras 5 películas de la tabla “film”
select 
    film_id as pelicula_id,
    title as titulo
from film
order by film_id asc
limit 5;

-- 41. Agrupa los actores por su nombre y cuenta cuántos actores tienen el mismo nombre. ¿Cuál es el nombre más repetido?
select 
    first_name as nombre,
    count(*) as cantidad_repetidos
from actor
group by first_name
order by cantidad_repetidos desc; -- en este caso los más repetidos son Kenneth, Penelope y Julia

-- 42. Encuentra todos los alquileres y los nombres de los clientes que los realizaron.
select 
    r.rental_id as alquiler_id,
    r.rental_date as fecha_alquiler,
    c.first_name as nombre_cliente,
    c.last_name as apellido_cliente
from rental r
inner join customer c 
	on r.customer_id = c.customer_id
order by r.rental_date desc;

-- 43. Muestra todos los clientes y sus alquileres si existen, incluyendo aquellos que no tienen alquileres.
select 
    c.customer_id as id_cliente,
    c.first_name as nombre,
    c.last_name as apellido,
    r.rental_id as id_alquiler,
    r.rental_date as fecha_alquiler
from customer c
left join rental r 
	on c.customer_id = r.customer_id
order by 
    c.last_name asc, 
    r.rental_date desc;

-- 44. Realiza un CROSS JOIN entre las tablas film y category. ¿Aporta valor esta consulta? ¿Por qué? Deja después de la consulta la contestación.
select 
    f.title as pelicula,
    c.name as categoria
from film f
cross join category c
order by f.title asc;

-- Genera datos irreales ya que un cross join realiza un producto cartesiano, lo que significa que combina cada una de las películas con todas las categorías que hay. Como resultado, 
-- la consulta te dirá que la película "ACADEMY DINOSAUR" pertenece al género de Acción, pero también al de Comedia, Terror, etc., al mismo tiempo. Esto es falso, ya que una película solo pertenece 
-- a su género real.

-- 45. Encuentra los actores que han participado en películas de la categoría 'Action'.
select 
    a.first_name as nombre,
    a.last_name as apellido
from actor a
inner join film_actor fa 
	on a.actor_id = fa.actor_id
inner join film_category fc 
	on fa.film_id = fc.film_id
inner join category c 
	on fc.category_id = c.category_id
where c.name = 'Action'
group by 
    a.first_name,
    a.last_name
order by a.last_name asc;

-- 46. Encuentra todos los actores que no han participado en películas.
select 
    first_name as nombre,
    last_name as apellido
from actor
where actor_id not in (select distinct actor_id from film_actor);

-- 47. Selecciona el nombre de los actores y la cantidad de películas en las que han participado.
select 
    a.first_name as nombre,
    a.last_name as apellido,
    count(fa.film_id) as cantidad_peliculas
from actor a
left join film_actor fa 
	on a.actor_id = fa.actor_id
group by 
    a.first_name,
    a.last_name
order by 
    cantidad_peliculas desc;

-- 48. Crea una vista llamada “actor_num_peliculas” que muestre los nombres de los actores y el número de películas en las que han participado. 
create view actor_num_peliculas as
select 
    a.first_name as nombre,
    a.last_name as apellido,
    count(fa.film_id) as cantidad_peliculas
from actor a
left join film_actor fa 
	on a.actor_id = fa.actor_id
group by 
    a.first_name,
    a.last_name;

select *                -- Dejo aquí la query para poder ver el contenido de la vista
from actor_num_peliculas;

-- 49. Calcula el número total de alquileres realizados por cada cliente.
select 
    c.first_name as nombre,
    c.last_name as apellido,
    count(r.rental_id) as total_alquileres
from customer c
left join rental r -- Por si hubiera algún cliente que no haya alquilado ninguna peli.
	on c.customer_id = r.customer_id
group by 
    c.first_name,
    c.last_name
order by total_alquileres desc; -- Así podemos tener el resultado ordenado

-- 50. Calcula la duración total de las películas en la categoría 'Action'.
select 
    c.name as categoria,
    SUM(f.length) as duracion_total_minutos
from film f
inner join film_category fc 
	on f.film_id = fc.film_id
inner join category c 
	on fc.category_id = c.category_id
where c.name = 'Action'
group by c.name;

-- 51. Crea una tabla temporal llamada “cliente_rentas_temporal” para almacenar el total de alquileres por cliente.
create temporary table cliente_rentas_temporal as
select 
    c.first_name as nombre,
    c.last_name as apellido,
    count(r.rental_id) as total_alquileres
from customer c
left join rental r 
	on c.customer_id = r.customer_id
group by 
    c.first_name,
    c.last_name;


-- 52. Crea una tabla temporal llamada “peliculas_alquiladas” que almacene las películas que han sido alquiladas al menos 10 veces.
create temporary table peliculas_alquiladas as
select 
    f.title as titulo_pelicula,
    count(r.rental_id) as total_alquileres
from film f
inner join inventory i 
	on f.film_id = i.film_id
inner join rental r 
	on i.inventory_id = r.inventory_id
group by f.title
having count(r.rental_id) >= 10
order by total_alquileres desc;

-- 53. Encuentra el título de las películas que han sido alquiladas por el cliente con el nombre ‘Tammy Sanders’ y 
-- que aún no se han devuelto. Ordena los resultados alfabéticamente por título de película.
select 
	c.first_name as nombre,
	c.last_name as apellido,
	f.title as titulo_pelicula
from customer c
inner join rental r 
	on c.customer_id = r.customer_id
inner join inventory i 
	on r.inventory_id = i.inventory_id
inner join film f 
	on i.film_id = f.film_id
where 
    c.first_name = 'TAMMY' 
    and c.last_name = 'SANDERS'
    and r.return_date is null 
order by f.title asc;

-- 54. Encuentra los nombres de los actores que han actuado en al menos una película que pertenece a la categoría 
-- ‘Sci-Fi’. Ordena los resultados alfabéticamente por apellido
select distinct -- con esto no hace falta hacer group by ya que se va a hacer automaticamente
    a.first_name as nombre,
    a.last_name as apellido
from  actor a
inner join film_actor fa 
	on a.actor_id = fa.actor_id
inner join film_category fc 
	on fa.film_id = fc.film_id
inner join category c 
	on fc.category_id = c.category_id
where c.name = 'Sci-Fi'
order by a.last_name asc;

-- 55. Encuentra el nombre y apellido de los actores que han actuado en películas que se alquilaron después de que la película 
-- ‘Spartacus Cheaper’ se alquilara por primera vez. Ordena los resultados alfabéticamente por apellido.
select distinct
    a.first_name as nombre,
    a.last_name as apellido
from actor a
inner join film_actor fa 
	on a.actor_id = fa.actor_id
inner join inventory i 
	on fa.film_id = i.film_id
inner join rental r 
	on i.inventory_id = r.inventory_id
where        -- subquery para sacar la fecha en la que se alquilo la pelicula por primera vez.
    r.rental_date > (
        select MIN(r2.rental_date)
        from rental r2
        inner join inventory i2 
        	on r2.inventory_id = i2.inventory_id
        inner join film f2 
        	on i2.film_id = f2.film_id
        where f2.title = 'SPARTACUS CHEAPER'
    )
order by a.last_name asc;

-- 56. Encuentra el nombre y apellido de los actores que no han actuado en ninguna película de la categoría ‘Music’.
select 
    a.first_name as nombre,
    a.last_name as apellido
from actor a
where         -- Para la exclusión he decidido crear una subquery con los que si tienen Music.
    a.actor_id not in (
        select distinct fa.actor_id
        from film_actor fa
        inner join film_category fc 
        	on fa.film_id = fc.film_id
        inner join category c 
        	on fc.category_id = c.category_id
        where c.name = 'Music'
    )
order by a.last_name asc;

-- 57. Encuentra el título de todas las películas que fueron alquiladas por más de 8 días.
select distinct f.title as titulo_pelicula
from film f
inner join inventory i 
	on f.film_id = i.film_id
inner join  rental r 
	on i.inventory_id = r.inventory_id
where (r.return_date::date - r.rental_date::date) > 8
order by f.title asc;

-- 58. Encuentra el título de todas las películas que son de la misma categoría que ‘Animation’
select f.title as titulo_pelicula
from film f
inner join film_category fc 
	on f.film_id = fc.film_id
where                	-- usamos otra subquery para hacerlo más sencillo
    fc.category_id = (
        select category_id 
        from category 
        where name = 'Animation'
    )
order by f.title asc;

-- 59. Encuentra los nombres de las películas que tienen la misma duración que la película con el título ‘Dancing Fever’. 
-- Ordena los resultados alfabéticamente por título de película.
select 
    f.title as titulo_pelicula,
    f.length as duracion
from film f
where 				-- subquery con el tiempo que dura la pelicula en cuestión 
    f.length = (
        select length 
        from film 
        where title = 'DANCING FEVER'
    )
order by f.title asc;

-- 60. Encuentra los nombres de los clientes que han alquilado al menos 7 películas distintas. 
-- Ordena los resultados alfabéticamente por apellido.
select 
    c.first_name as nombre,
    c.last_name as apellido,
    count(distinct i.film_id) as peliculas_distintas
from customer c
inner join rental r 
	on c.customer_id = r.customer_id
inner join inventory i on r.inventory_id = i.inventory_id
group by 
    c.customer_id,
    c.first_name,
    c.last_name
having count(distinct i.film_id) >= 7
order by c.last_name ASC;

-- 61. Encuentra la cantidad total de películas alquiladas por categoría y muestra el nombre de la categoría junto con el recuento de alquileres.
select 
    c.name as categoria,
    count(r.rental_id) as total_alquileres
from category c
inner join film_category fc 
	on c.category_id = fc.category_id
inner join inventory i 
	on fc.film_id = i.film_id
inner join rental r 
	on i.inventory_id = r.inventory_id
group by 
    c.category_id, 
    c.name
order by total_alquileres desc;

-- 62. Encuentra el número de películas por categoría estrenadas en 2006.
select 
    c.name as categoria,
    count(f.film_id) as cantidad_peliculas
from category c
inner join film_category fc 
	on c.category_id = fc.category_id
inner join film f 
	on fc.film_id = f.film_id
where f.release_year = 2006
group by 
    c.category_id, 
    c.name
order by cantidad_peliculas desc;

-- 63. Obtén todas las combinaciones posibles de trabajadores con las tiendas que tenemos.
select 
    s.staff_id as id_trabajador,
    s.first_name as nombre_trabajador,
    s.last_name as apellido_trabajador,
    st.store_id as id_tienda
from staff s
cross join store st
order by 
    s.staff_id, 
    st.store_id;

-- 64. Encuentra la cantidad total de películas alquiladas por cada cliente y muestra el ID del cliente, su nombre y apellido 
-- junto con la cantidad de películas alquiladas.
select 
    c.customer_id as id_cliente,
    c.first_name as nombre,
    c.last_name as apellido,
    count(r.rental_id) as total_peliculas_alquiladas
from customer c
inner join rental r 
	on c.customer_id = r.customer_id
group by  
    c.customer_id,
    c.first_name,
    c.last_name
order by total_peliculas_alquiladas desc;
