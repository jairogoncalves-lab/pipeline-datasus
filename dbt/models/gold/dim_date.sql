with dates as (

    select distinct admission_date as date_day
    from {{ ref('silver_hospitalizations') }}
    where admission_date is not null

    union

    select distinct discharge_date as date_day
    from {{ ref('silver_hospitalizations') }}
    where discharge_date is not null

)

select
    date_day,
    cast(strftime(date_day, '%Y%m%d') as integer) as date_key,
    extract(year from date_day) as year,
    extract(month from date_day) as month,
    extract(day from date_day) as day,
    extract(quarter from date_day) as quarter,
    extract(dow from date_day) as day_of_week,
    strftime(date_day, '%A') as day_name,
    strftime(date_day, '%B') as month_name
from dates
