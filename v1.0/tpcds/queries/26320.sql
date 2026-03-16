
WITH AddressStats AS (
    SELECT 
        ca_city,
        ca_state,
        COUNT(*) AS address_count,
        arrayStringConcat(arrayDistinct(groupArray(assumeNotNull(ca_street_name))), ', ') AS unique_street_names,
        arrayStringConcat(arrayDistinct(groupArray(assumeNotNull(ca_street_type))), ', ') AS unique_street_types,
        arrayStringConcat(arrayDistinct(groupArray(assumeNotNull(CONCAT(ca_street_number, ' ', ca_street_name, ' ', ca_street_type)))), ', ') AS full_address
    FROM 
        customer_address
    GROUP BY 
        ca_city, ca_state
),
CustomerDemographics AS (
    SELECT 
        cd_gender,
        COUNT(DISTINCT c_customer_id) AS num_customers,
        arrayStringConcat(arrayDistinct(groupArray(assumeNotNull(cd_marital_status))), ', ') AS marital_statuses
    FROM 
        customer AS c
    JOIN 
        customer_demographics AS cd ON c.c_current_cdemo_sk = cd.cd_demo_sk
    GROUP BY 
        cd_gender
)
SELECT 
    a.ca_city,
    a.ca_state,
    a.address_count,
    a.unique_street_names,
    a.unique_street_types,
    a.full_address,
    c.cd_gender,
    c.num_customers,
    c.marital_statuses
FROM 
    AddressStats AS a
JOIN 
    CustomerDemographics AS c ON a.ca_state = 'CA'
ORDER BY 
    a.address_count DESC;
