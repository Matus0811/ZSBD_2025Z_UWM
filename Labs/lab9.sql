-------------------------------------------------------------------------------
--Zadanie 1
-------------------------------------------------------------------------------

CREATE OR REPLACE PACKAGE pkg_utils IS
    PROCEDURE add_job (
        p_job_id    IN jobs.job_id%TYPE,
        p_job_title IN jobs.job_title%TYPE
    );

    FUNCTION get_job_title (
        p_job_id IN jobs.job_id%TYPE
    ) RETURN VARCHAR2;

    FUNCTION get_yearly_salary (
        p_emp_id IN employees.employee_id%TYPE
    ) RETURN NUMBER;
END pkg_utils;
/
CREATE OR REPLACE PACKAGE BODY pkg_utils IS

    PROCEDURE add_job (
        p_job_id    IN jobs.job_id%TYPE,
        p_job_title IN jobs.job_title%TYPE
    ) IS
    BEGIN
        INSERT INTO jobs(job_id, job_title)
        VALUES (p_job_id, p_job_title);
    END;

    FUNCTION get_job_title (
        p_job_id IN jobs.job_id%TYPE
    ) RETURN VARCHAR2 IS
        v_title jobs.job_title%TYPE;
    BEGIN
        SELECT job_title
          INTO v_title
          FROM jobs
         WHERE job_id = p_job_id;

        RETURN v_title;
    END;

    FUNCTION get_yearly_salary (
        p_emp_id IN employees.employee_id%TYPE
    ) RETURN NUMBER IS
        v_sal employees.salary%TYPE;
        v_com employees.commission_pct%TYPE;
    BEGIN
        SELECT salary, commission_pct
          INTO v_sal, v_com
          FROM employees
         WHERE employee_id = p_emp_id;

        RETURN (v_sal * 12) + (v_sal * NVL(v_com,0));
    END;

END pkg_utils;
/

-------------------------------------------------------------------------------
--Zadanie 2
-------------------------------------------------------------------------------

CREATE TABLE regions_audit (
    id        NUMBER GENERATED ALWAYS AS IDENTITY,
    operacja  VARCHAR2(50),
    opis      VARCHAR2(200),
    data_op   DATE,
    user_name VARCHAR2(30)
);
/
CREATE OR REPLACE PACKAGE pkg_regions IS

    ex_region_exists EXCEPTION;
    ex_region_has_countries EXCEPTION;

    PROCEDURE add_region (
        p_region_id   IN regions.region_id%TYPE,
        p_region_name IN regions.region_name%TYPE
    );

    PROCEDURE update_region (
        p_region_id   IN regions.region_id%TYPE,
        p_region_name IN regions.region_name%TYPE
    );

    PROCEDURE delete_region (
        p_region_id IN regions.region_id%TYPE
    );

    FUNCTION get_region (
        p_region_id IN regions.region_id%TYPE
    ) RETURN VARCHAR2;

    FUNCTION get_region_by_name (
        p_region_name IN regions.region_name%TYPE
    ) RETURN NUMBER;

END pkg_regions;
/
CREATE OR REPLACE PACKAGE BODY pkg_regions IS

    PROCEDURE log_error (
        p_operacja IN VARCHAR2,
        p_opis     IN VARCHAR2
    ) IS
    BEGIN
        INSERT INTO regions_audit (operacja, opis, data_op, user_name)
        VALUES (p_operacja, p_opis, SYSDATE, USER);
    END;

    PROCEDURE add_region (
        p_region_id   IN regions.region_id%TYPE,
        p_region_name IN regions.region_name%TYPE
    ) IS
        v_cnt NUMBER;
    BEGIN
        SELECT COUNT(*)
          INTO v_cnt
          FROM regions
         WHERE UPPER(region_name) = UPPER(p_region_name);

        IF v_cnt > 0 THEN
            RAISE ex_region_exists;
        END IF;

        INSERT INTO regions VALUES (p_region_id, p_region_name);

    EXCEPTION
        WHEN ex_region_exists THEN
            log_error('ADD', 'Region o tej nazwie już istnieje');
            RAISE_APPLICATION_ERROR(-20100, 'Region już istnieje');
    END;

    PROCEDURE update_region (
        p_region_id   IN regions.region_id%TYPE,
        p_region_name IN regions.region_name%TYPE
    ) IS
    BEGIN
        UPDATE regions
           SET region_name = p_region_name
         WHERE region_id = p_region_id;
    END;

    PROCEDURE delete_region (
        p_region_id IN regions.region_id%TYPE
    ) IS
        v_cnt NUMBER;
    BEGIN
        SELECT COUNT(*)
          INTO v_cnt
          FROM countries
         WHERE region_id = p_region_id;

        IF v_cnt > 0 THEN
            RAISE ex_region_has_countries;
        END IF;

        DELETE FROM regions WHERE region_id = p_region_id;

    EXCEPTION
        WHEN ex_region_has_countries THEN
            log_error('DELETE', 'Region ma przypisane kraje');
            RAISE_APPLICATION_ERROR(-20101, 'Nie można usunąć regionu');
    END;

    FUNCTION get_region (
        p_region_id IN regions.region_id%TYPE
    ) RETURN VARCHAR2 IS
        v_name regions.region_name%TYPE;
    BEGIN
        SELECT region_name
          INTO v_name
          FROM regions
         WHERE region_id = p_region_id;

        RETURN v_name;
    END;

    FUNCTION get_region_by_name (
        p_region_name IN regions.region_name%TYPE
    ) RETURN NUMBER IS
        v_id regions.region_id%TYPE;
    BEGIN
        SELECT region_id
          INTO v_id
          FROM regions
         WHERE UPPER(region_name) = UPPER(p_region_name);

        RETURN v_id;
    END;

END pkg_regions;
/

-------------------------------------------------------------------------------
--Zadanie 3
-------------------------------------------------------------------------------

CREATE OR REPLACE PACKAGE pkg_department_stats IS
    FUNCTION avg_salary_dept (
        p_dept_id IN departments.department_id%TYPE
    ) RETURN NUMBER;

    PROCEDURE min_max_salary_job (
        p_job_id IN jobs.job_id%TYPE,
        p_min OUT NUMBER,
        p_max OUT NUMBER
    );
END pkg_department_stats;
/
CREATE OR REPLACE PACKAGE BODY pkg_department_stats IS

    FUNCTION avg_salary_dept (
        p_dept_id IN departments.department_id%TYPE
    ) RETURN NUMBER IS
        v_avg NUMBER;
    BEGIN
        SELECT AVG(salary)
          INTO v_avg
          FROM employees
         WHERE department_id = p_dept_id;

        RETURN v_avg;
    END;

    PROCEDURE min_max_salary_job (
        p_job_id IN jobs.job_id%TYPE,
        p_min OUT NUMBER,
        p_max OUT NUMBER
    ) IS
    BEGIN
        SELECT MIN(salary), MAX(salary)
          INTO p_min, p_max
          FROM employees
         WHERE job_id = p_job_id;
    END;

END pkg_department_stats;
/

-------------------------------------------------------------------------------
--Zadanie 4
-------------------------------------------------------------------------------

CREATE OR REPLACE PACKAGE pkg_department_report IS
    PROCEDURE generate_report (
        p_dept_id IN departments.department_id%TYPE
    );
END pkg_department_report;
/
CREATE OR REPLACE PACKAGE BODY pkg_department_report IS

    PROCEDURE generate_report (
        p_dept_id IN departments.department_id%TYPE
    ) IS
    BEGIN
        DBMS_OUTPUT.PUT_LINE(
            'Średnia pensja: ' ||
            ROUND(pkg_department_stats.avg_salary_dept(p_dept_id),2)
        );
    END;

END pkg_department_report;
/

-------------------------------------------------------------------------------
--Zadanie 5
-------------------------------------------------------------------------------

CREATE OR REPLACE PACKAGE pkg_data_validation IS
    PROCEDURE normalize_phones;

    PROCEDURE raise_salary_by_job (
        p_job_id  IN jobs.job_id%TYPE,
        p_percent IN NUMBER
    );
END pkg_data_validation;
/
CREATE OR REPLACE PACKAGE BODY pkg_data_validation IS

    PROCEDURE normalize_phones IS
    BEGIN
        UPDATE employees
           SET phone_number =
               REGEXP_REPLACE(phone_number,'[^0-9]');
    END;

    PROCEDURE raise_salary_by_job (
        p_job_id  IN jobs.job_id%TYPE,
        p_percent IN NUMBER
    ) IS
    BEGIN
        UPDATE employees
           SET salary = salary + (salary * p_percent / 100)
         WHERE job_id = p_job_id;
    END;

END pkg_data_validation;
/
