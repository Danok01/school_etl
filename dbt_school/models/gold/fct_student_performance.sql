with silver_data as (
    select * from {{ ref('int_student_enrollments') }}
)

select
    course_id,
    course_title,
    department,
    count(distinct student_id) as total_students,
    round(avg(grade_numeric), 2) as avg_course_grade,
    max(grade_numeric) as highest_grade,
    min(grade_numeric) as lowest_grade
from silver_data
group by 1, 2, 3