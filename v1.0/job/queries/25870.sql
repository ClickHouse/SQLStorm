WITH RankedMovies AS (
    SELECT 
        m.id AS movie_id,
        m.title,
        m.production_year,
        COUNT(DISTINCT c.person_id) AS cast_count,
        arrayDistinct(groupArray(assumeNotNull(p.name))) AS cast_names,
        arrayDistinct(groupArray(assumeNotNull(k.keyword))) AS keywords
    FROM 
        aka_title m
    JOIN 
        cast_info c ON m.id = c.movie_id
    JOIN 
        aka_name p ON c.person_id = p.person_id
    JOIN 
        movie_keyword mk ON m.id = mk.movie_id
    JOIN 
        keyword k ON mk.keyword_id = k.id
    GROUP BY 
        m.id, m.title, m.production_year
),
TopMovies AS (
    SELECT 
        movie_id,
        title,
        production_year,
        cast_count,
        cast_names,
        keywords,
        ROW_NUMBER() OVER (ORDER BY cast_count DESC, production_year DESC) AS rank
    FROM 
        RankedMovies
)

SELECT 
    tm.title,
    tm.production_year,
    tm.cast_count,
    arrayStringConcat(groupArray(assumeNotNull(CAST(tm.cast_names AS text))), ', ') AS cast,
    arrayStringConcat(groupArray(assumeNotNull(CAST(tm.keywords AS text))), ', ') AS movie_keywords
FROM 
    TopMovies tm
WHERE 
    tm.rank <= 10
GROUP BY 
    tm.title, tm.production_year, tm.cast_count
ORDER BY 
    tm.cast_count DESC;
