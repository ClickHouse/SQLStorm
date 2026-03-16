
SELECT 
    ca_city,
    COUNT(DISTINCT c_customer_sk) AS customer_count,
    AVG(cd_purchase_estimate) AS avg_purchase_estimate,
    arrayStringConcat(arrayDistinct(groupArray(assumeNotNull(CONCAT(c_first_name, ' ', c_last_name)))), ', ') AS customer_names,
    arrayStringConcat(arrayDistinct(groupArray(assumeNotNull(CASE 
        WHEN cd_gender = 'M' THEN 'Male' 
        WHEN cd_gender = 'F' THEN 'Female' 
        ELSE 'Other' END))), ', ') AS gender_distribution,
    arrayStringConcat(arrayDistinct(groupArray(assumeNotNull(CASE 
        WHEN cd_marital_status = 'M' THEN 'Married' 
        WHEN cd_marital_status = 'S' THEN 'Single' 
        ELSE 'Other' END))), ', ') AS marital_status_distribution
FROM 
    customer_address AS ca
JOIN 
    customer AS c ON ca.ca_address_sk = c.c_current_addr_sk
JOIN 
    customer_demographics AS cd ON c.c_current_cdemo_sk = cd.cd_demo_sk
GROUP BY 
    ca_city
HAVING 
    COUNT(DISTINCT c_customer_sk) > 10
ORDER BY 
    customer_count DESC;
