WITH movie_details AS (
    SELECT 
        t.id AS title_id,
        t.title,
        t.production_year,
        a.name AS actor_name,
        c.kind AS cast_type,
        p.info AS person_info,
        k.keyword
    FROM 
        title t
    JOIN 
        cast_info ci ON t.id = ci.movie_id
    JOIN 
        aka_name a ON ci.person_id = a.person_id
    JOIN 
        comp_cast_type c ON ci.person_role_id = c.id
    LEFT JOIN 
        person_info p ON a.person_id = p.person_id
    LEFT JOIN 
        movie_keyword mk ON t.id = mk.movie_id
    LEFT JOIN 
        keyword k ON mk.keyword_id = k.id
    WHERE 
        t.production_year BETWEEN 2000 AND 2020
        AND c.kind = 'actor'
        AND t.title ILIKE '%adventure%'
),
aggregated_data AS (
    SELECT 
        title_id,
        title,
        production_year,
        arrayDistinct(groupArray(assumeNotNull(actor_name))) AS actors,
        arrayDistinct(groupArray(assumeNotNull(cast_type))) AS roles,
        arrayDistinct(groupArray(assumeNotNull(person_info))) AS additional_info,
        arrayDistinct(groupArray(assumeNotNull(keyword))) AS keywords
    FROM 
        movie_details
    GROUP BY 
        title_id, title, production_year
)
SELECT 
    ad.title,
    ad.production_year,
    arrayStringConcat(arrayDistinct(groupArray(assumeNotNull(CAST(ad.actors AS text)))), ', ') AS actor_names,
    arrayStringConcat(arrayDistinct(groupArray(assumeNotNull(CAST(ad.roles AS text)))), ', ') AS cast_roles,
    arrayStringConcat(arrayDistinct(groupArray(assumeNotNull(CAST(ad.additional_info AS text)))), ', ') AS person_information,
    arrayStringConcat(arrayDistinct(groupArray(assumeNotNull(CAST(ad.keywords AS text)))), ', ') AS movie_keywords
FROM 
    aggregated_data ad
GROUP BY 
    ad.title, ad.production_year
ORDER BY 
    ad.production_year DESC, ad.title;
