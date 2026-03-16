WITH RankedMovies AS (
    SELECT
        mt.title,
        mt.production_year,
        arrayDistinct(groupArray(assumeNotNull(an.name))) AS actors,
        arrayDistinct(groupArray(assumeNotNull(km.keyword))) AS keywords,
        arrayDistinct(groupArray(assumeNotNull(cn.name))) AS companies,
        RANK() OVER (PARTITION BY mt.production_year ORDER BY mt.production_year DESC) AS year_rank
    FROM
        aka_title mt
    JOIN
        cast_info ci ON mt.id = ci.movie_id
    JOIN
        aka_name an ON ci.person_id = an.person_id
    LEFT JOIN
        movie_keyword mk ON mt.id = mk.movie_id
    LEFT JOIN
        keyword km ON mk.keyword_id = km.id
    LEFT JOIN
        movie_companies mc ON mt.id = mc.movie_id
    LEFT JOIN
        company_name cn ON mc.company_id = cn.id
    GROUP BY
        mt.id, mt.title, mt.production_year
),

MostInformativeMovies AS (
    SELECT
        rm.title,
        rm.production_year,
        rm.actors,
        rm.keywords,
        rm.companies
    FROM
        RankedMovies rm
    WHERE
        rm.year_rank = 1
)

SELECT
    mi.title,
    mi.production_year ARRAY JOIN mi.actors AS actor_name ARRAY JOIN mi.keywords AS keyword ARRAY JOIN mi.companies AS company_nameFROM
    MostInformativeMovies mi
ORDER BY
    mi.production_year DESC,
    actor_name ASC,
    keyword ASC;
