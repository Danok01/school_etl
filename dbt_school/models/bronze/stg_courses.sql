with source as (
    select * from {{ source('raw_school', 'raw_courses') }}
)

select
    cast(course_id as integer) as course_id,
    trim(title) as course_title,
    cast(credits as integer) as credit_hours,
    trim(department) as department
from source