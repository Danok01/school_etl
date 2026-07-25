with source as (
    select * from {{ source('raw_school', 'raw_enrollments') }}
)

select
    cast(enrollment_id as integer) as enrollment_id,
    cast(student_id as integer) as student_id,
    cast(course_id as integer) as course_id,
    cast(enrollment_date as date) as enrollment_date,
    cast(grade_numeric as numeric(5, 2)) as grade_numeric
from source