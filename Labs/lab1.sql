-------------------------------------------------------------------------------
-- Tworzenie tabeli "Regions"
-------------------------------------------------------------------------------
CREATE TABLE regions (
    region_id   NUMBER(4) CONSTRAINT regions_pk PRIMARY KEY,
    region_name VARCHAR2(25)
);

-------------------------------------------------------------------------------
-- Tworzenie tabeli "Countries"
-------------------------------------------------------------------------------
CREATE TABLE countries (
    country_id   CHAR(2) CONSTRAINT countries_pk PRIMARY KEY,
    country_name VARCHAR2(40) NOT NULL,
    region_id    NUMBER(4)
);

-- Dodawanie klucza obcego do tabeli "Countries"
ALTER TABLE countries
    ADD CONSTRAINT countries_region_fk
    FOREIGN KEY (region_id) REFERENCES regions(region_id);

-------------------------------------------------------------------------------
-- Tworzenie tabeli "Locations"
-------------------------------------------------------------------------------
CREATE TABLE locations (
    location_id    NUMBER(6) CONSTRAINT locations_pk PRIMARY KEY,
    street_address VARCHAR2(40),
    postal_code    VARCHAR2(12),
    city           VARCHAR2(30) NOT NULL,
    state_province VARCHAR2(25),
    country_id     CHAR(2)
);

-- Dodawanie klucza obcego do tabeli "Locations"
ALTER TABLE locations
    ADD CONSTRAINT locations_country_fk
    FOREIGN KEY (country_id) REFERENCES countries(country_id);

-------------------------------------------------------------------------------
-- Tworzenie tabeli "Jobs"
-------------------------------------------------------------------------------
CREATE TABLE jobs (
    job_id     VARCHAR2(10) CONSTRAINT jobs_pk PRIMARY KEY,
    job_title  VARCHAR2(35) NOT NULL,
    min_salary NUMBER(8,2) NOT NULL,
    max_salary NUMBER(8,2) NOT NULL
);

-- Dodanie ograniczenia CHECK: min_salary ≤ max_salary - 2000
ALTER TABLE jobs
    ADD CONSTRAINT jobs_minmax_chk
    CHECK (min_salary <= max_salary - 2000);

-------------------------------------------------------------------------------
-- Tworzenie tabeli "Departments"
-------------------------------------------------------------------------------
CREATE TABLE departments (
    department_id   NUMBER(4) CONSTRAINT departments_pk PRIMARY KEY,
    department_name VARCHAR2(30) NOT NULL,
    manager_id      NUMBER(6),
    location_id     NUMBER(6)
);

-- Dodanie klucza obcego do tabeli "Departments" (location_id → locations)
ALTER TABLE departments
    ADD CONSTRAINT departments_location_fk
    FOREIGN KEY (location_id) REFERENCES locations(location_id);

-------------------------------------------------------------------------------
-- Tworzenie tabeli "Employees"
-------------------------------------------------------------------------------
CREATE TABLE employees (
    employee_id   NUMBER(6) CONSTRAINT employees_pk PRIMARY KEY,
    first_name    VARCHAR2(20),
    last_name     VARCHAR2(25) NOT NULL,
    email         VARCHAR2(100) CONSTRAINT employees_email_uk UNIQUE NOT NULL,
    phone_number  VARCHAR2(20),
    hire_date     DATE NOT NULL,
    job_id        VARCHAR2(10) NOT NULL,
    salary        NUMBER(8,2) DEFAULT 0 CHECK (salary >= 0),
    manager_id    NUMBER(6),
    commission_pct NUMBER(4,2),
    department_id NUMBER(4)
);

-- Dodanie klucza obcego do tabeli "Employees" (job_id → jobs)
ALTER TABLE employees
    ADD CONSTRAINT employees_job_fk
    FOREIGN KEY (job_id) REFERENCES jobs(job_id);

-- Dodanie klucza obcego do tabeli "Employees" (manager_id → employees)
ALTER TABLE employees
    ADD CONSTRAINT employees_mgr_fk
    FOREIGN KEY (manager_id) REFERENCES employees(employee_id);

-- Dodanie klucza obcego do tabeli "Employees" (department_id → departments)
ALTER TABLE employees
    ADD CONSTRAINT employees_dept_fk
    FOREIGN KEY (department_id) REFERENCES departments(department_id);

-- Dodanie klucza obcego do tabeli "Departments" (manager_id → employees)
ALTER TABLE departments
    ADD CONSTRAINT departments_mgr_fk
    FOREIGN KEY (manager_id) REFERENCES employees(employee_id);

-------------------------------------------------------------------------------
-- Tworzenie tabeli "Job_History"
-------------------------------------------------------------------------------
CREATE TABLE job_history (
    employee_id   NUMBER(6) NOT NULL,
    start_date    DATE NOT NULL,
    end_date      DATE NOT NULL,
    job_id        VARCHAR2(10) NOT NULL,
    department_id NUMBER(4) NOT NULL,
    CONSTRAINT job_history_pk PRIMARY KEY (employee_id, start_date)
);

-- Dodanie kluczy obcych do tabeli "Job_History"
ALTER TABLE job_history
    ADD CONSTRAINT jhist_emp_fk FOREIGN KEY (employee_id) REFERENCES employees(employee_id);

ALTER TABLE job_history
    ADD CONSTRAINT jhist_job_fk FOREIGN KEY (job_id) REFERENCES jobs(job_id);

ALTER TABLE job_history
    ADD CONSTRAINT jhist_dept_fk FOREIGN KEY (department_id) REFERENCES departments(department_id);

-------------------------------------------------------------------------------
-- Wstawianie danych testowych do tabel nadrzędnych
-------------------------------------------------------------------------------
INSERT INTO regions VALUES (1, 'Europe');

INSERT INTO countries VALUES ('PL', 'Poland', 1);

INSERT INTO locations VALUES (
    100,
    'Ul. Długa 1',
    '10-100',
    'Olsztyn',
    'Warmińsko-Mazurskie',
    'PL'
);

INSERT INTO departments VALUES (
    10,
    'IT',
    NULL,
    100
);

-------------------------------------------------------------------------------
-- Wstawianie danych do tabeli "Jobs"
-------------------------------------------------------------------------------
INSERT INTO jobs VALUES ('DEV',   'Developer', 4000, 7000);
INSERT INTO jobs VALUES ('DBA',   'DBA',       6500, 8700);
INSERT INTO jobs VALUES ('SALES', 'Sales Rep', 3000, 6000);
INSERT INTO jobs VALUES ('HR',    'HR Spec',   2500, 5000);

-------------------------------------------------------------------------------
-- Wstawianie danych do tabeli "Employees"
-------------------------------------------------------------------------------
INSERT INTO employees VALUES (
    1, 'Anna',  'Kowalska', 'anna.kowalska@example.com', '555-100-100',
    DATE '2025-10-03', 'DEV', 7000, NULL, NULL, 10
);

INSERT INTO employees VALUES (
    2, 'Bartek', 'Nowak', 'bartek.nowak@example.com', '555-100-101',
    DATE '2025-10-03', 'SALES', 4500, 1, 0.10, 10
);

INSERT INTO employees VALUES (
    3, 'Celina', 'Wiśniewska', 'celina.w@example.com', '555-100-102',
    DATE '2025-10-03', 'HR', 3800, 1, NULL, 10
);

INSERT INTO employees VALUES (
    4, 'Damian', 'Zieliński', 'damian.z@example.com', '555-100-103',
    DATE '2025-10-03', 'DEV', 5200, 1, NULL, 10
);

COMMIT;

-------------------------------------------------------------------------------
-- Aktualizacje i operacje zgodne z ćwiczeniem
-------------------------------------------------------------------------------

-- Zmiana managera pracowników 2 i 3
UPDATE employees
    SET manager_id = 1
    WHERE employee_id IN (2, 3);

COMMIT;

-- Podniesienie min_salary i max_salary o 500 dla zawodów z literą 'b' lub 's'
UPDATE jobs
    SET min_salary = min_salary + 500,
        max_salary = max_salary + 500
    WHERE UPPER(job_title) LIKE '%B%' OR UPPER(job_title) LIKE '%S%';

COMMIT;

-- Usunięcie rekordów z max_salary > 9000
DELETE FROM jobs WHERE max_salary > 9000;
COMMIT;

-------------------------------------------------------------------------------
-- FLASHBACK TABLE – odzyskiwanie po DROP
-------------------------------------------------------------------------------
DROP TABLE job_history;

-- Sprawdzenie kosza
SELECT original_name, operation, droptime FROM user_recyclebin
 WHERE original_name = 'JOB_HISTORY';

-- Przywrócenie tabeli
FLASHBACK TABLE job_history TO BEFORE DROP;

-------------------------------------------------------------------------------
-- Sprawdzenie działania
-------------------------------------------------------------------------------
SELECT * FROM jobs;
SELECT employee_id, last_name, manager_id FROM employees;
