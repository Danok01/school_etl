with students as (
    select * from {{ ref('stg_students') }}
),
courses as (
    select * from {{ ref('stg_courses') }}
),
enrollments as (
    select * from {{ ref('stg_enrollments') }}
)

select
    e.enrollment_id,
    s.student_id,
    s.student_name,
    s.email,
    c.course_id,
    c.course_title,
    c.department,
    c.credit_hours,
    e.enrollment_date,
    e.grade_numeric,
    -- Derived letter grade
    case
        when e.grade_numeric >= 90 then 'A'
        when e.grade_numeric >= 80 then 'B'
        when e.grade_numeric >= 70 then 'C'
        when e.grade_numeric >= 60 then 'D'
        else 'F'
    end as letter_grade,
    -- Student age calculation
    extract(year from age(current_date, s.date_of_birth)) as student_age
from enrollments e
join students s on e.student_id = s.student_id
join courses c on e.course_id = c.course_id