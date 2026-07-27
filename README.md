# School ETL Pipeline & dbt Medallion Architecture

A production-grade Data Engineering & ETL pipeline for a school management system. This project demonstrates raw data generation using **Python + Faker**, staging into **PostgreSQL**, and transforming data across a **Medallion Architecture (Bronze → Silver → Gold)** using **dbt (data build tool)**.

---

## 🌟 Project Highlights & Recent Updates

### Newly Integrated Features
- **Project-Level `profiles.yml` Integration:** Connection profiles are modularized directly within the `dbt_school/` directory rather than relying on the global `~/.dbt/` folder.
- **Enhanced Security & Git Hygiene:** Included a project-level `.gitignore` file within `dbt_school/` to prevent accidental commit of database credentials and local dbt artifacts (`target/`, `dbt_packages/` `etc`).

---

## 📁 Repository Structure

```text
school_etl/
├── docker-compose.yml         # Containerized PostgreSQL service
├── data_generator/
│   ├── generate_data.py       # Python script generating fake school data into Postgres
│   └── requirements.txt       # Dependencies for ingestion script
└── dbt_school/
    ├── .gitignore             # Git ignore rule for target/, dbt_packages/, and sensitive files
    ├── dbt_project.yml        # Core dbt configuration file
    ├── profiles.yml           # Local dbt profile definition for Postgres
    └── models/
        ├── 1_bronze/          # Raw / Staging sources & models (Views)
        │   ├── schema.yml
        │   ├── stg_students.sql
        │   ├── stg_courses.sql
        │   └── stg_enrollments.sql
        ├── 2_silver/          # Cleansed, joined, & enriched models (Tables)
        │   ├── schema.yml
        │   └── int_student_enrollments.sql
        └── 3_gold/            # Analytical Marts (Facts & Dimensions)
            ├── schema.yml
            ├── dim_students.sql
            └── fct_student_performance.sql
```

---

## 🔧 Modular Configuration Details

### 1. Project Profile Configuration (`dbt_school/profiles.yml`)
The `profiles.yml` file is located at the root of the `dbt_school/` directory. It defines the database target and connection parameters required for dbt to communicate with PostgreSQL.

```yaml
school_db:
  outputs:
    dev:
      type: postgres
      host: "{{ env_var('DB_HOST', 'localhost') }}"
      user: "{{ env_var('DB_USER', 'school_user') }}"
      password: "{{ env_var('DB_PASSWORD', 'school_password') }}"
      port: {{ env_var('DB_PORT', 5432) }}
      dbname: "{{ env_var('DB_NAME', 'school_db') }}"
      schema: public
      threads: 2
  target: dev
```

> **Key Architectural Advantage:** Keeping `profiles.yml` in the project folder eliminates external user-directory dependencies (`~/.dbt/`) while using Jinja `env_var()` functions allows dynamic variable injection in production environments as expected.

### 2. Version Control Protection (`dbt_school/.gitignore`)
To prevent sensitive credentials and build metadata from entering version control, the following `.gitignore` is maintained inside `dbt_school/`:

```gitignore
# dbt execution artifacts
target/
dbt_packages/
logs/
*.yml

```

---

## 🏗️ Medallion Data Architecture

```
+-------------------+      +-------------------+      +-------------------+      +-------------------+
|  Python Ingestion | ---> |   Bronze Layer    | ---> |   Silver Layer    | ---> |    Gold Layer     |
| (Faker + Postgres)|      |  (Staging Views)  |      |  (Enriched Tables)|      | (Analytics Marts) |
+-------------------+      +-------------------+      +-------------------+      +-------------------+
```

### 1. Bronze Layer (`models/1_bronze/`)
* **Purpose:** Direct standardisation of raw ingested PostgreSQL tables (`raw_students`, `raw_courses`, `raw_enrollments`).
* **Materialization:** `view`
* **Transformations:** Data type casting, column renaming, whitespace trimming, string lowercasing.

### 2. Silver Layer (`models/2_silver/`)
* **Purpose:** Business logic enrichment, relationship joining, and attribute derivation.
* **Materialization:** `table`
* **Key Model:** `int_student_enrollments` — Joins student, course, and enrollment data while computing letter grades (`A`–`F`) and calculating student age dynamically using `age(current_date, date_of_birth)`.

### 3. Gold Layer (`models/3_gold/`)
* **Purpose:** Business-ready dimensional models and analytical aggregates.
* **Materialization:** `table`
* **Key Models:**
  * `dim_students`: Student-centric dimension including total course load and overall GPA.
  * `fct_student_performance`: Course-centric aggregate containing student counts, average grades, minimum grades, and maximum grades.

---

## 🚀 Step-by-Step Setup & Execution Guide

### Prerequisites
- Docker & Docker Compose
- Python 3.9+
- dbt-core & dbt-postgres

---

### Step 1: Start PostgreSQL Database
Spin up the local containerized PostgreSQL instance:

```bash
docker-compose up -d
```

Verify connection settings:
- **Host:** `host`
- **Port:** `port`
- **User:** `user`
- **Password:** `password`
- **Database:** `db`

---

### Step 2: Generate Raw Seed Data
Install Python dependencies and execute the ingestion script to populate PostgreSQL with mock school data:

```bash
# Navigate to the generator directory
cd data_generator

# Install dependencies
pip install -r req.txt

# Run generation script
python generate_data.py
```

---

### Step 3: Run dbt Pipelines with Local Profile

Navigate into the `dbt_school` directory and execute dbt commands using the local `profiles.yml` configuration file.

### Using Environment Variable
In your environment or active shell session:

```bash

# Standard commands automatically use local profiles.ymlnwhen inside `/dbt_school`
dbt debug
dbt run
dbt test
```

---

## 🛡️ Security & Best Practices Summary

1. **Environment Separation:** Always pass database credentials via environment variables (`DB_USER`, `DB_PASSWORD`) in production environments rather than storing plaintext passwords in `profiles.yml`.
2. **Modular Profiles:** Storing `profiles.yml` within the repository root simplifies CI/CD pipeline configuration (e.g., GitHub Actions / GitLab CI) without requiring manual setup of system-level `~/.dbt/` folders.
3. **Immutability:** The Bronze layer remains non-breaking views that mirror raw operational schemas, ensuring full data auditability.
