with students as (
    select * from {{ ref('stg_students') }}
),
enrollments as (
    select * from {{ ref('int_student_enrollments') }}
)

select
    s.student_id,
    s.student_name,
    s.email,
    count(e.enrollment_id) as total_courses_enrolled,
    coalesce(round(avg(e.grade_numeric), 2), 0.0) as gpa_average
from students s
left join enrollments e on s.student_id = e.student_id
group by 1, 2, 3