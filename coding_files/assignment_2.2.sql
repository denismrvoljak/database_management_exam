select distinct -- Use distinct to ensure actors are listed once per language
    a.actor_id,
    a.name_first,
    a.name_last,
    l.lang_name as language_name
from actor a
join film_actor fa on a.actor_id = fa.actor_id
join film f on fa.film_id = f.film_id
join language l on f.language_id = l.language_id
order by a.actor_id asc;