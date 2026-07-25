with source as (
    select * from {{ source('raw_school', 'raw_students') }}
)

select
    cast(id as integer) as student_id,
    trim(full_name) as student_name,
    lower(trim(email)) as email,
    cast(date_of_birth as date) as date_of_birth,
    cast(created_at as timestamp) as registered_at
from source