with municipalities as (

    select distinct patient_municipality_code as municipality_code
    from {{ ref('silver_hospitalizations') }}

    union

    select distinct hospital_municipality_code as municipality_code
    from {{ ref('silver_hospitalizations') }}

)

select
    municipality_code,
    substr(municipality_code, 1, 2) as state_code
from municipalities
where municipality_code is not null
