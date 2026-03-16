WITH MovieDetails AS (
    SELECT 
        t.id AS movie_id,
        t.title,
        t.production_year,
        k.keyword,
        arrayStringConcat(arrayDistinct(groupArray(assumeNotNull(cn.name))), ', ') AS production_companies,
        arrayStringConcat(arrayDistinct(groupArray(assumeNotNull(ak.name))), ', ') AS related_people,
        arrayStringConcat(arrayDistinct(groupArray(assumeNotNull(r.role))), ', ') AS roles
    FROM 
        aka_title AS t
    JOIN 
        movie_keyword AS mk ON t.id = mk.movie_id
    JOIN 
        keyword AS k ON mk.keyword_id = k.id
    JOIN 
        movie_companies AS mc ON t.id = mc.movie_id
    JOIN 
        company_name AS cn ON mc.company_id = cn.id
    JOIN 
        cast_info AS ci ON t.id = ci.movie_id
    JOIN 
        aka_name AS ak ON ci.person_id = ak.person_id
    JOIN 
        role_type AS r ON ci.role_id = r.id
    WHERE 
        t.production_year BETWEEN 2000 AND 2020
    GROUP BY 
        t.id, t.title, t.production_year, k.keyword
),
FilteredMovies AS (
    SELECT 
        movie_id,
        title,
        production_year,
        keyword,
        production_companies,
        related_people,
        roles
    FROM 
        MovieDetails
    WHERE 
        length(splitByString(', ', production_companies), 1) > 2 
        AND length(splitByString(', ', related_people), 1) > 5
),
RankedMovies AS (
    SELECT 
        movie_id,
        title,
        production_year,
        keyword,
        production_companies,
        related_people,
        roles,
        ROW_NUMBER() OVER (PARTITION BY production_year ORDER BY COUNT(related_people) DESC) AS rank
    FROM 
        FilteredMovies
    GROUP BY 
        movie_id, title, production_year, keyword, production_companies, related_people, roles
)
SELECT 
    movie_id,
    title,
    production_year,
    keyword,
    production_companies,
    related_people,
    roles,
    rank
FROM 
    RankedMovies
WHERE 
    rank <= 5
ORDER BY 
    production_year, rank;
