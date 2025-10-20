-------------------------------------------------------------------------------
--Zadanie I
-------------------------------------------------------------------------------
-- Usuwanie wszystkich istniejących tabel 
-------------------------------------------------------------------------------
BEGIN
  EXECUTE IMMEDIATE 'DROP TABLE job_history CASCADE CONSTRAINTS PURGE';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/
BEGIN
  EXECUTE IMMEDIATE 'DROP TABLE employees CASCADE CONSTRAINTS PURGE';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/
BEGIN
  EXECUTE IMMEDIATE 'DROP TABLE departments CASCADE CONSTRAINTS PURGE';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/
BEGIN
  EXECUTE IMMEDIATE 'DROP TABLE locations CASCADE CONSTRAINTS PURGE';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/
BEGIN
  EXECUTE IMMEDIATE 'DROP TABLE countries CASCADE CONSTRAINTS PURGE';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/
BEGIN
  EXECUTE IMMEDIATE 'DROP TABLE regions CASCADE CONSTRAINTS PURGE';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/
BEGIN
  EXECUTE IMMEDIATE 'DROP TABLE jobs CASCADE CONSTRAINTS PURGE';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/
BEGIN
  EXECUTE IMMEDIATE 'DROP TABLE job_grades CASCADE CONSTRAINTS PURGE';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

-------------------------------------------------------------------------------
--Zadanie II
-------------------------------------------------------------------------------
-- Kopiowanie struktur i danych (CTAS)
-------------------------------------------------------------------------------
CREATE TABLE regions     AS SELECT * FROM hr.regions;
CREATE TABLE countries   AS SELECT * FROM hr.countries;
CREATE TABLE locations   AS SELECT * FROM hr.locations;
CREATE TABLE jobs        AS SELECT * FROM hr.jobs;
CREATE TABLE departments AS SELECT * FROM hr.departments;
CREATE TABLE employees   AS SELECT * FROM hr.employees;
CREATE TABLE job_history AS SELECT * FROM hr.job_history;
CREATE TABLE job_grades  AS SELECT * FROM hr.job_grades;

-------------------------------------------------------------------------------
-- Klucze główne (PK)
-------------------------------------------------------------------------------
ALTER TABLE regions     ADD CONSTRAINT regions_pk       PRIMARY KEY (region_id);
ALTER TABLE countries   ADD CONSTRAINT countries_pk     PRIMARY KEY (country_id);
ALTER TABLE locations   ADD CONSTRAINT locations_pk     PRIMARY KEY (location_id);
ALTER TABLE jobs        ADD CONSTRAINT jobs_pk          PRIMARY KEY (job_id);
ALTER TABLE departments ADD CONSTRAINT departments_pk   PRIMARY KEY (department_id);
ALTER TABLE employees   ADD CONSTRAINT employees_pk     PRIMARY KEY (employee_id);
ALTER TABLE job_history ADD CONSTRAINT job_history_pk   PRIMARY KEY (employee_id, start_date);
ALTER TABLE job_grades  ADD CONSTRAINT job_grades_uk    UNIQUE (grade_level);

-------------------------------------------------------------------------------
-- Klucze obce (FK)
-------------------------------------------------------------------------------
ALTER TABLE countries   ADD CONSTRAINT countries_region_fk
  FOREIGN KEY (region_id)    REFERENCES regions(region_id);

ALTER TABLE locations   ADD CONSTRAINT locations_country_fk
  FOREIGN KEY (country_id)   REFERENCES countries(country_id);

ALTER TABLE departments ADD CONSTRAINT departments_location_fk
  FOREIGN KEY (location_id)  REFERENCES locations(location_id);

ALTER TABLE employees   ADD CONSTRAINT employees_job_fk
  FOREIGN KEY (job_id)       REFERENCES jobs(job_id);

ALTER TABLE employees   ADD CONSTRAINT employees_dept_fk
  FOREIGN KEY (department_id)REFERENCES departments(department_id);

ALTER TABLE employees   ADD CONSTRAINT employees_mgr_fk
  FOREIGN KEY (manager_id)   REFERENCES employees(employee_id);

ALTER TABLE departments ADD CONSTRAINT departments_mgr_fk
  FOREIGN KEY (manager_id)   REFERENCES employees(employee_id);

ALTER TABLE job_history ADD CONSTRAINT jhist_emp_fk
  FOREIGN KEY (employee_id)  REFERENCES employees(employee_id);

ALTER TABLE job_history ADD CONSTRAINT jhist_job_fk
  FOREIGN KEY (job_id)       REFERENCES jobs(job_id);

ALTER TABLE job_history ADD CONSTRAINT jhist_dept_fk
  FOREIGN KEY (department_id)REFERENCES departments(department_id);

-------------------------------------------------------------------------------
--Zadanie III
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
--Zadanie 1 
-------------------------------------------------------------------------------
CREATE OR REPLACE VIEW v_wynagrodzenie_d20_50 AS
SELECT last_name || ' ' || salary AS wynagrodzenie
FROM employees
WHERE department_id IN (20, 50)
  AND salary BETWEEN 2000 AND 7000;

-------------------------------------------------------------------------------
--Zadanie 2
-------------------------------------------------------------------------------
SELECT hire_date,
       last_name,
       &kolumna AS kolumna_uzytkownika
FROM employees
WHERE manager_id IS NOT NULL
  AND EXTRACT(YEAR FROM hire_date) = 2005
ORDER BY &kolumna;

-------------------------------------------------------------------------------
--Zadanie 3
-------------------------------------------------------------------------------
SELECT (first_name || ' ' || last_name) AS imie_nazwisko,
       salary,
       phone_number
FROM employees
WHERE SUBSTR(last_name, 3, 1) = 'e'
  AND UPPER(first_name) LIKE '%' || UPPER('&fraza') || '%'
ORDER BY 1 DESC, 2 ASC;

-------------------------------------------------------------------------------
--Zadanie 4
-------------------------------------------------------------------------------
CREATE OR REPLACE VIEW v_dodatki AS
SELECT first_name || ' ' || last_name AS imie_nazwisko,
       ROUND(MONTHS_BETWEEN(SYSDATE, hire_date)) AS miesiace,
       CASE
         WHEN ROUND(MONTHS_BETWEEN(SYSDATE, hire_date)) < 150 THEN salary * 0.10
         WHEN ROUND(MONTHS_BETWEEN(SYSDATE, hire_date)) BETWEEN 150 AND 199 THEN salary * 0.20
         ELSE salary * 0.30
       END AS wysokosc_dodatku
FROM employees;

-------------------------------------------------------------------------------
--Zadanie 5
-------------------------------------------------------------------------------
CREATE OR REPLACE VIEW v_dept_min_gt_5000 AS
SELECT department_id,
       SUM(salary) AS suma_zarobkow,
       ROUND(AVG(salary)) AS srednia_zarobkow
FROM employees
GROUP BY department_id
HAVING MIN(salary) > 5000;

-------------------------------------------------------------------------------
--Zadanie 6
-------------------------------------------------------------------------------
CREATE OR REPLACE VIEW v_prac_toronto AS
SELECT e.last_name,
       e.department_id,
       d.department_name,
       e.job_id
FROM employees e
JOIN departments d ON d.department_id = e.department_id
JOIN locations l ON l.location_id = d.location_id
WHERE UPPER(l.city) = 'TORONTO';

-------------------------------------------------------------------------------
--Zadanie 7
-------------------------------------------------------------------------------
CREATE OR REPLACE VIEW v_jennifer_team AS
SELECT e1.first_name || ' ' || e1.last_name AS jennifer,
       e2.first_name || ' ' || e2.last_name AS wspolpracownik
FROM employees e1
JOIN employees e2
  ON e2.department_id = e1.department_id
 AND e2.employee_id <> e1.employee_id
WHERE UPPER(e1.first_name) = 'JENNIFER';

-------------------------------------------------------------------------------
--Zadanie 8
-------------------------------------------------------------------------------
CREATE OR REPLACE VIEW v_dept_bez_prac AS
SELECT d.department_id, d.department_name
FROM departments d
LEFT JOIN employees e ON e.department_id = d.department_id
WHERE e.employee_id IS NULL;

-------------------------------------------------------------------------------
--Zadanie 9
-------------------------------------------------------------------------------
CREATE OR REPLACE VIEW v_grade AS
SELECT e.first_name, e.last_name, e.job_id,
       d.department_name,
       e.salary,
       g.grade_level AS grade
FROM employees e
JOIN departments d ON d.department_id = e.department_id
JOIN job_grades g ON e.salary BETWEEN g.lowest_sal AND g.highest_sal;

-------------------------------------------------------------------------------
--Zadanie 10
-------------------------------------------------------------------------------
CREATE OR REPLACE VIEW v_ponad_srednia AS
SELECT first_name, last_name, salary
FROM employees
WHERE salary > (SELECT AVG(salary) FROM employees);

-------------------------------------------------------------------------------
--Zadanie 11
-------------------------------------------------------------------------------
CREATE OR REPLACE VIEW v_dept_ma_u AS
SELECT e.employee_id, e.first_name, e.last_name, e.department_id
FROM employees e
WHERE EXISTS (
  SELECT 1
  FROM employees x
  WHERE x.department_id = e.department_id
    AND LOWER(x.last_name) LIKE '%u%'
);

-------------------------------------------------------------------------------
--Zadanie 12
-------------------------------------------------------------------------------
CREATE OR REPLACE VIEW v_dluzszy_staz AS
SELECT first_name, last_name, hire_date,
       MONTHS_BETWEEN(SYSDATE, hire_date) AS miesiace
FROM employees
WHERE MONTHS_BETWEEN(SYSDATE, hire_date) >
      (SELECT AVG(MONTHS_BETWEEN(SYSDATE, hire_date)) FROM employees);

-------------------------------------------------------------------------------
--Zadanie 13
-------------------------------------------------------------------------------
CREATE OR REPLACE VIEW v_dept_stat AS
SELECT d.department_name,
       COUNT(e.employee_id) AS liczba_pracownikow,
       ROUND(AVG(e.salary),2) AS srednie_wynagrodzenie
FROM departments d
LEFT JOIN employees e ON e.department_id = d.department_id
GROUP BY d.department_name;

-------------------------------------------------------------------------------
--Zadanie 14
-------------------------------------------------------------------------------
CREATE OR REPLACE VIEW v_mniej_niz_it AS
SELECT e.first_name, e.last_name, e.salary
FROM employees e
WHERE e.salary < (
  SELECT MIN(e2.salary)
  FROM employees e2
  JOIN departments d ON d.department_id = e2.department_id
  WHERE UPPER(d.department_name) = 'IT'
);

-------------------------------------------------------------------------------
--Zadanie 15
-------------------------------------------------------------------------------
CREATE OR REPLACE VIEW v_dept_ma_ponad_srednia AS
SELECT DISTINCT d.department_id, d.department_name
FROM departments d
JOIN employees e ON e.department_id = d.department_id
WHERE e.salary > (SELECT AVG(salary) FROM employees);

-------------------------------------------------------------------------------
--Zadanie 16
-------------------------------------------------------------------------------
CREATE OR REPLACE VIEW v_top5_jobs AS
SELECT j.job_title,
       ROUND(AVG(e.salary),2) AS srednia
FROM employees e
JOIN jobs j ON j.job_id = e.job_id
GROUP BY j.job_title
FETCH FIRST 5 ROWS ONLY;

-------------------------------------------------------------------------------
--Zadanie 17
-------------------------------------------------------------------------------
CREATE OR REPLACE VIEW v_region_stat AS
SELECT r.region_name,
       COUNT(DISTINCT c.country_id) AS liczba_krajow,
       COUNT(e.employee_id) AS liczba_pracownikow
FROM regions r
LEFT JOIN countries c ON c.region_id = r.region_id
LEFT JOIN locations l ON l.country_id = c.country_id
LEFT JOIN departments d ON d.location_id = l.location_id
LEFT JOIN employees e ON e.department_id = d.department_id
GROUP BY r.region_name;

-------------------------------------------------------------------------------
--Zadanie 18
-------------------------------------------------------------------------------
CREATE OR REPLACE VIEW v_wiecej_niz_szef AS
SELECT e.employee_id, e.first_name, e.last_name, e.salary,
       m.employee_id AS manager_id, m.first_name AS mgr_first, 
       m.last_name AS mgr_last, m.salary AS mgr_salary
FROM employees e
JOIN employees m ON m.employee_id = e.manager_id
WHERE e.salary > m.salary;

-------------------------------------------------------------------------------
--Zadanie 19
-------------------------------------------------------------------------------
CREATE OR REPLACE VIEW v_hires_per_month AS
SELECT TO_CHAR(hire_date, 'MM') AS miesiac,
       TO_CHAR(hire_date, 'Mon', 'NLS_DATE_LANGUAGE=English') AS miesiac_nazwa,
       COUNT(*) AS ile_osob
FROM employees
GROUP BY TO_CHAR(hire_date, 'MM'),
         TO_CHAR(hire_date, 'Mon', 'NLS_DATE_LANGUAGE=English');

-------------------------------------------------------------------------------
--Zadanie 20
-------------------------------------------------------------------------------
CREATE OR REPLACE VIEW v_top3_dept_avg AS
SELECT d.department_name,
       ROUND(AVG(e.salary),2) AS srednia
FROM departments d
JOIN employees e ON e.department_id = d.department_id
GROUP BY d.department_name
FETCH FIRST 3 ROWS ONLY;
