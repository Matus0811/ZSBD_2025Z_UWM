-------------------------------------------------------------------------------
--Zadanie 1
-------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE add_job (
    p_job_id    IN jobs.job_id%TYPE,
    p_job_title IN jobs.job_title%TYPE
) IS
BEGIN
    INSERT INTO jobs (job_id, job_title)
    VALUES (p_job_id, p_job_title);

    DBMS_OUTPUT.PUT_LINE('Dodano job: ' || p_job_id || ' - ' || p_job_title);

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Błąd dodawania job: ' || SQLERRM);
END;
/
-------------------------------------------------------------------------------
--Zadanie 2
-------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE update_job_title (
    p_job_id    IN jobs.job_id%TYPE,
    p_new_title IN jobs.job_title%TYPE
) IS
BEGIN
    UPDATE jobs
       SET job_title = p_new_title
     WHERE job_id = p_job_id;

    IF SQL%ROWCOUNT = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Nie zmodyfikowano żadnego job.');
    END IF;

    DBMS_OUTPUT.PUT_LINE('Zmieniono tytuł job: ' || p_job_id);

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Błąd: ' || SQLERRM);
END;
/
-------------------------------------------------------------------------------
--Zadanie 3
-------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE delete_job (
    p_job_id IN jobs.job_id%TYPE
) IS
BEGIN
    DELETE FROM jobs WHERE job_id = p_job_id;

    IF SQL%ROWCOUNT = 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Nie usunięto żadnego job.');
    END IF;

    DBMS_OUTPUT.PUT_LINE('Usunięto job: ' || p_job_id);

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Błąd usuwania: ' || SQLERRM);
END;
/
-------------------------------------------------------------------------------
--Zadanie 4
-------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE get_emp_data (
    p_emp_id IN employees.employee_id%TYPE,
    p_salary OUT employees.salary%TYPE,
    p_last_name OUT employees.last_name%TYPE
) IS
BEGIN
    SELECT salary, last_name
      INTO p_salary, p_last_name
      FROM employees
     WHERE employee_id = p_emp_id;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Brak pracownika.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Błąd: ' || SQLERRM);
END;
/
-------------------------------------------------------------------------------
--Zadanie 5
-------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE add_employee (
    p_first_name IN employees.first_name%TYPE DEFAULT 'NoName',
    p_last_name  IN employees.last_name%TYPE DEFAULT 'Unknown',
    p_salary     IN employees.salary%TYPE DEFAULT 5000,
    p_job_id     IN employees.job_id%TYPE DEFAULT 'IT_PROG',
    p_dept_id    IN employees.department_id%TYPE DEFAULT 90
) IS
BEGIN
    IF p_salary > 20000 THEN
        RAISE_APPLICATION_ERROR(-20003, 'Wynagrodzenie przekracza 20000.');
    END IF;

    INSERT INTO employees(employee_id, first_name, last_name, salary, job_id, department_id)
    VALUES(emp_seq.NEXTVAL, p_first_name, p_last_name, p_salary, p_job_id, p_dept_id);

    DBMS_OUTPUT.PUT_LINE('Dodano pracownika: ' || p_last_name);

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Błąd dodawania: ' || SQLERRM);
END;
/
-------------------------------------------------------------------------------
--Zadanie 6
-------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE avg_sub_salary (
    p_mgr_id IN employees.manager_id%TYPE,
    p_avg OUT NUMBER
) IS
BEGIN
    SELECT AVG(salary)
      INTO p_avg
      FROM employees
     WHERE manager_id = p_mgr_id;

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Błąd: ' || SQLERRM);
END;
/
-------------------------------------------------------------------------------
--Zadanie 7
-------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE raise_in_dept (
    p_dept_id IN employees.department_id%TYPE,
    p_percent IN NUMBER
) IS
BEGIN
    UPDATE employees e
       SET salary = salary + (salary * p_percent / 100)
     WHERE department_id = p_dept_id
       AND salary + (salary * p_percent / 100) BETWEEN
           (SELECT min_salary FROM jobs WHERE job_id = e.job_id)
           AND
           (SELECT max_salary FROM jobs WHERE job_id = e.job_id);

    IF SQL%ROWCOUNT = 0 THEN
        RAISE_APPLICATION_ERROR(-20004, 'Brak pracowników lub przekroczono zakres salary.');
    END IF;

    DBMS_OUTPUT.PUT_LINE('Zaktualizowano wynagrodzenia w dziale ' || p_dept_id);

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Błąd: ' || SQLERRM);
END;
/
-------------------------------------------------------------------------------
--Zadanie 8
-------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE move_employee (
    p_emp_id IN employees.employee_id%TYPE,
    p_new_dept IN employees.department_id%TYPE
) IS
    v_exists NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_exists
      FROM departments
     WHERE department_id = p_new_dept;

    IF v_exists = 0 THEN
        RAISE_APPLICATION_ERROR(-20005, 'Nowy departament nie istnieje.');
    END IF;

    UPDATE employees
       SET department_id = p_new_dept
     WHERE employee_id = p_emp_id;

    IF SQL%ROWCOUNT = 0 THEN
        RAISE_APPLICATION_ERROR(-20006, 'Pracownik nie istnieje.');
    END IF;

    DBMS_OUTPUT.PUT_LINE('Przeniesiono pracownika: ' || p_emp_id);

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Błąd: ' || SQLERRM);
END;
/
-------------------------------------------------------------------------------
--Zadanie 9
-------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE delete_department (
    p_dept_id IN departments.department_id%TYPE
) IS
    v_count NUMBER;
BEGIN
    SELECT COUNT(*)
      INTO v_count
      FROM employees
     WHERE department_id = p_dept_id;

    IF v_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20007, 'Departament ma pracowników – nie można usunąć.');
    END IF;

    DELETE FROM departments
     WHERE department_id = p_dept_id;

    DBMS_OUTPUT.PUT_LINE('Usunięto departament: ' || p_dept_id);

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Błąd: ' || SQLERRM);
END;
/
