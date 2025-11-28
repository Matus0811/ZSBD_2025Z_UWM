-------------------------------------------------------------------------------
--Zadanie 1
-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION get_job_title (
    p_job_id IN jobs.job_id%TYPE
) RETURN VARCHAR2 IS
    v_title jobs.job_title%TYPE;
BEGIN
    SELECT job_title
      INTO v_title
      FROM jobs
     WHERE job_id = p_job_id;

    RETURN v_title;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20010, 'Praca o podanym ID nie istnieje.');
END;
/
-------------------------------------------------------------------------------
--Zadanie 2
-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION get_yearly_salary (
    p_emp_id IN employees.employee_id%TYPE
) RETURN NUMBER IS
    v_salary employees.salary%TYPE;
    v_comm   employees.commission_pct%TYPE;
BEGIN
    SELECT salary, commission_pct
      INTO v_salary, v_comm
      FROM employees
     WHERE employee_id = p_emp_id;

    RETURN (v_salary * 12) + (v_salary * NVL(v_comm,0));

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20011, 'Pracownik o podanym ID nie istnieje.');
END;
/
-------------------------------------------------------------------------------
--Zadanie 3
-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION get_area_code (
    p_phone IN VARCHAR2
) RETURN VARCHAR2 IS
BEGIN
    RETURN SUBSTR(p_phone, 1, 3);
END;
/
-------------------------------------------------------------------------------
--Zadanie 4
-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION format_string (
    p_text IN VARCHAR2
) RETURN VARCHAR2 IS
    v_len NUMBER := LENGTH(p_text);
BEGIN
    IF v_len < 2 THEN
        RETURN UPPER(p_text);
    END IF;

    RETURN UPPER(SUBSTR(p_text,1,1)) ||
           LOWER(SUBSTR(p_text,2,v_len-2)) ||
           UPPER(SUBSTR(p_text,v_len,1));
END;
/
-------------------------------------------------------------------------------
--Zadanie 5
-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION pesel_to_date (
    p_pesel IN VARCHAR2
) RETURN DATE IS
    v_year  NUMBER;
    v_month NUMBER;
    v_day   NUMBER;
BEGIN
    v_year  := SUBSTR(p_pesel,1,2);
    v_month := SUBSTR(p_pesel,3,2);
    v_day   := SUBSTR(p_pesel,5,2);

    IF v_month > 20 THEN
        v_month := v_month - 20;
        v_year  := v_year + 2000;
    ELSE
        v_year  := v_year + 1900;
    END IF;

    RETURN TO_DATE(v_year || '-' || v_month || '-' || v_day, 'YYYY-MM-DD');
END;
/
-------------------------------------------------------------------------------
--Zadanie 6
-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION employees_and_departments_in_country (
    p_country_name IN countries.country_name%TYPE
) RETURN VARCHAR2 IS
    v_country_id countries.country_id%TYPE;
    v_emps   NUMBER;
    v_depts  NUMBER;
BEGIN
    SELECT country_id
      INTO v_country_id
      FROM countries
     WHERE country_name = p_country_name;

    SELECT COUNT(*)
      INTO v_depts
      FROM departments d 
      JOIN locations l ON d.location_id = l.location_id
     WHERE l.country_id = v_country_id;

    SELECT COUNT(*)
      INTO v_emps
      FROM employees e
      JOIN departments d ON e.department_id = d.department_id
      JOIN locations  l  ON d.location_id = l.location_id
     WHERE l.country_id = v_country_id;

    RETURN 'Liczba pracowników: ' || v_emps ||
           ', liczba departamentów: ' || v_depts;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20012, 'Taki kraj nie istnieje.');
END;
/
-------------------------------------------------------------------------------
--Zadanie 7
-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION create_access_id (
    p_first_name IN VARCHAR2,
    p_last_name  IN VARCHAR2,
    p_phone      IN VARCHAR2
) RETURN VARCHAR2 IS
BEGIN
    RETURN UPPER(SUBSTR(p_last_name,1,3)) ||
           SUBSTR(REGEXP_REPLACE(p_phone,'[^0-9]',''), -4) ||
           UPPER(SUBSTR(p_first_name,1,1));
END;
/
