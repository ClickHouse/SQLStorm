WITH RankedMovies AS (
    SELECT 
        t.id AS movie_id,
        t.title,
        t.production_year,
        COUNT(DISTINCT c.person_id) AS total_cast_members,
        arrayStringConcat(arrayDistinct(groupArray(assumeNotNull(a.name))), ', ') AS actors_list,
        arrayStringConcat(arrayDistinct(groupArray(assumeNotNull(m.name))), ', ') AS production_companies,
        ROW_NUMBER() OVER (PARTITION BY t.production_year ORDER BY COUNT(DISTINCT c.id) DESC) AS rank
    FROM 
        aka_title t
    JOIN 
        cast_info c ON t.id = c.movie_id
    JOIN 
        aka_name a ON c.person_id = a.person_id
    JOIN 
        movie_companies mc ON t.id = mc.movie_id
    JOIN 
        company_name m ON mc.company_id = m.id
    GROUP BY 
        t.id, t.title, t.production_year
),
TopMovies AS (
    SELECT 
        movie_id, 
        title, 
        production_year, 
        total_cast_members, 
        actors_list, 
        production_companies 
    FROM 
        RankedMovies 
    WHERE 
        rank <= 10
)
SELECT 
    tm.production_year,
    COUNT(*) AS movie_count,
    arrayStringConcat(groupArray(assumeNotNull(tm.title)), '; ') AS top_movie_titles,
    arrayStringConcat(groupArray(assumeNotNull(tm.actors_list)), '; ') AS top_actors_in_movies,
    arrayStringConcat(arrayDistinct(groupArray(assumeNotNull(tm.production_companies))), '; ') AS unique_production_companies
FROM 
    TopMovies tm
GROUP BY 
    tm.production_year
ORDER BY 
    tm.production_year DESC;
