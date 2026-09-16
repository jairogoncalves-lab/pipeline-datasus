with staging as (

    select * from {{ ref('stg_sih_rd') }}

),

deduped as (

    select
        *,
        row_number() over (
            partition by admission_id
            order by year desc, month desc
        ) as rn
    from staging

)

select
    admission_id,
    uf,
    year,
    month,
    patient_municipality_code,
    hospital_municipality_code,
    hospital_cnes_code,
    try_strptime(birth_date_raw, '%Y%m%d')::date as birth_date,
    case sex_code
        when '1' then 'M'
        when '3' then 'F'
        else 'U'
    end as sex,
    try_cast(age_raw as integer) as age,
    try_strptime(admission_date_raw, '%Y%m%d')::date as admission_date,
    try_strptime(discharge_date_raw, '%Y%m%d')::date as discharge_date,
    try_cast(length_of_stay_raw as integer) as length_of_stay_days,
    primary_diagnosis_code,
    nullif(secondary_diagnosis_code, '0000') as secondary_diagnosis_code,
    bed_specialty_code,
    death_code = '1' as died,
    race_color_code,
    try_cast(total_cost_raw as double) as total_cost,
    try_cast(icu_cost_raw as double) as icu_cost
from deduped
where rn = 1
