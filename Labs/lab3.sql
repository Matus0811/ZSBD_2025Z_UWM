-------------------------------------------------------------------------------
--Zadanie 1
-------------------------------------------------------------------------------
CREATE OR REPLACE VIEW v_wysokie_pensje AS
SELECT employee_id,
       first_name,
       last_name,
       job_id,
       salary,
       department_id
FROM employees
WHERE salary > 6000;
-------------------------------------------------------------------------------
--Zadanie 2
-------------------------------------------------------------------------------
CREATE OR REPLACE VIEW v_wysokie_pensje AS
SELECT employee_id,
       first_name,
       last_name,
       job_id,
       salary,
       department_id
FROM employees
WHERE salary > 12000;
-------------------------------------------------------------------------------
--Zadanie 3
-------------------------------------------------------------------------------
DROP VIEW v_wysokie_pensje;
-------------------------------------------------------------------------------
--Zadanie 4
-------------------------------------------------------------------------------
CREATE OR REPLACE VIEW v_finance_pracownicy AS
SELECT e.employee_id,
       e.last_name,
       e.first_name
FROM employees e
JOIN departments d ON e.department_id = d.department_id
WHERE UPPER(d.department_name) = 'FINANCE';
-------------------------------------------------------------------------------
--Zadanie 5
-------------------------------------------------------------------------------
CREATE OR REPLACE VIEW v_srednie_pensje AS
SELECT employee_id,
       last_name,
       first_name,
       salary,
       job_id,
       email,
       hire_date
FROM employees
WHERE salary BETWEEN 5000 AND 12000;
-------------------------------------------------------------------------------
--Zadanie 6
-------------------------------------------------------------------------------
/*
a) Próba dodania nowego pracownika – nie działa,
widok ma warunek WHERE i nie zawiera wszystkich kolumn. 
*/
INSERT INTO v_srednie_pensje (employee_id, last_name, first_name, salary, job_id, email, hire_date)
VALUES (999, 'Nowak', 'Adam', 8000, 'IT_PROG', 'anowak@example.com', SYSDATE);

/* 
b) Edycja pracownika – działa,
jeśli po zmianie dane dalej spełniają warunek widoku. 
*/
UPDATE v_srednie_pensje
SET salary = 9000
WHERE employee_id = 100;
/* 
c) Usunięcie pracownika – działa,
widok odnosi się bezpośrednio do tabeli employees. 
*/
DELETE FROM v_srednie_pensje
WHERE employee_id = 100;
-------------------------------------------------------------------------------
--Zadanie 7
-------------------------------------------------------------------------------
CREATE OR REPLACE VIEW v_dzialy_statystyki AS
SELECT d.department_id,
       d.department_name,
       COUNT(e.employee_id) AS liczba_pracownikow,
       ROUND(AVG(e.salary),2) AS srednia_pensja,
       MAX(e.salary) AS najwyzsza_pensja
FROM departments d
JOIN employees e ON e.department_id = d.department_id
GROUP BY d.department_id, d.department_name
HAVING COUNT(e.employee_id) >= 4;

/*
a) Próba dodania nowego rekordu – nie jest możliwa,
ponieważ widok korzysta z funkcji grupujących i HAVING. 
*/
INSERT INTO v_dzialy_statystyki (department_id, department_name, liczba_pracownikow, srednia_pensja, najwyzsza_pensja)
VALUES (999, 'Test Department', 5, 7000, 12000);

-------------------------------------------------------------------------------
--Zadanie 8
-------------------------------------------------------------------------------
CREATE OR REPLACE VIEW v_srednie_pensje_check AS
SELECT employee_id,
       last_name,
       first_name,
       salary,
       job_id,
       email,
       hire_date
FROM employees
WHERE salary BETWEEN 5000 AND 12000
WITH CHECK OPTION;

/* i. 
Dodanie pracownika z zarobkami pomiędzy 5000 a 12000 – możliwe,
rekord spełnia warunek widoku. 
*/
INSERT INTO v_srednie_pensje_check (employee_id, last_name, first_name, salary, job_id, email, hire_date)
VALUES (1000, 'Kowalski', 'Piotr', 8000, 'IT_PROG', 'pkowalski@example.com', SYSDATE);

/* 
ii. Dodanie pracownika z zarobkami powyżej 12000 – niedozwolone,
widok z opcją CHECK nie przyjmuje danych spoza określonego zakresu. 
*/
INSERT INTO v_srednie_pensje_check (employee_id, last_name, first_name, salary, job_id, email, hire_date)
VALUES (1001, 'Nowak', 'Anna', 15000, 'IT_PROG', 'anowak@example.com', SYSDATE);

-------------------------------------------------------------------------------
--Zadanie 9
-------------------------------------------------------------------------------
CREATE MATERIALIZED VIEW v_managerowie AS
SELECT e.employee_id,
       e.first_name,
       e.last_name,
       d.department_name
FROM employees e
JOIN departments d ON e.department_id = d.department_id
WHERE e.employee_id IN (
    SELECT DISTINCT manager_id
    FROM employees
    WHERE manager_id IS NOT NULL
);

-------------------------------------------------------------------------------
--Zadanie 10
-------------------------------------------------------------------------------
CREATE OR REPLACE VIEW v_najlepiej_oplacani AS
SELECT employee_id,
       first_name,
       last_name,
       salary,
       job_id,
       department_id
FROM employees
ORDER BY salary DESC
FETCH FIRST 10 ROWS ONLY;

