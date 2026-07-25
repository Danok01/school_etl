import random
from datetime import datetime, timedelta
from faker import Faker
import pandas as pd
from sqlalchemy import create_engine
import os
from dotenv import load_dotenv

load_dotenv()
url = os.getenv("URL")

fake = Faker()


# Database Connection
ENGINE = create_engine(url)

NUM_STUDENTS = 200
NUM_COURSES = 10
NUM_ENROLLMENTS = 600

def generate_students():
    students = []
    for i in range(1, NUM_STUDENTS + 1):
        students.append({
            "id": i,
            "full_name": fake.name(),
            "email": fake.email(),
            "date_of_birth": fake.date_of_birth(minimum_age=18, maximum_age=25).isoformat(),
            "created_at": (datetime.now() - timedelta(days=random.randint(100, 500))).isoformat()
        })
    return pd.DataFrame(students)

def generate_courses():
    departments = ["Computer Science", "Mathematics", "Physics", "History", "Literature"]
    courses = []
    for i in range(1, NUM_COURSES + 1):
        courses.append({
            "course_id": i,
            "title": f"{random.choice(departments)} {random.randint(101, 404)}",
            "credits": random.choice([3, 4]),
            "department": random.choice(departments)
        })
    return pd.DataFrame(courses)

def generate_enrollments():
    enrollments = []
    for i in range(1, NUM_ENROLLMENTS + 1):
        enrollments.append({
            "enrollment_id": i,
            "student_id": random.randint(1, NUM_STUDENTS),
            "course_id": random.randint(1, NUM_COURSES),
            "enrollment_date": fake.date_between(start_date="-1y", end_date="today").isoformat(),
            "grade_numeric": round(random.uniform(50.0, 100.0), 2)
        })
    return pd.DataFrame(enrollments)

def main():
    print("Generating fake data...")
    df_students = generate_students()
    df_courses = generate_courses()
    df_enrollments = generate_enrollments()

    print("Pushing raw tables to PostgreSQL (Raw Bronze Ingestion)...")
    df_students.to_sql("raw_students", ENGINE, schema="public", if_exists="replace", index=False)
    df_courses.to_sql("raw_courses", ENGINE, schema="public", if_exists="replace", index=False)
    df_enrollments.to_sql("raw_enrollments", ENGINE, schema="public", if_exists="replace", index=False)
    print("Raw data successfully ingested!")

if __name__ == "__main__":
    main()