with source as (

    select *
    from read_parquet(
        's3://{{ var("bronze_bucket") }}/bronze/sih/group=RD/uf=*/year=*/month=*/data.parquet',
        hive_partitioning = true,
        union_by_name = true
    )

)

select
    uf,
    cast(year as integer) as year,
    cast(month as integer) as month,
    n_aih as admission_id,
    uf_zi as management_uf_code,
    munic_res as patient_municipality_code,
    munic_mov as hospital_municipality_code,
    cnes as hospital_cnes_code,
    nasc as birth_date_raw,
    sexo as sex_code,
    idade as age_raw,
    dt_inter as admission_date_raw,
    dt_saida as discharge_date_raw,
    dias_perm as length_of_stay_raw,
    diag_princ as primary_diagnosis_code,
    diag_secun as secondary_diagnosis_code,
    espec as bed_specialty_code,
    morte as death_code,
    raca_cor as race_color_code,
    val_tot as total_cost_raw,
    val_uti as icu_cost_raw
from source
