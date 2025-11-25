-------------------------------------------------------------------------------
--Zadanie 1
-------------------------------------------------------------------------------
DECLARE
    v_numer_max   departments.department_id%TYPE;
    v_nowa_nazwa  departments.department_name%TYPE := 'EDUCATION';
BEGIN
    SELECT MAX(department_id)
    INTO v_numer_max
    FROM departments;

    INSERT INTO departments (department_id, department_name)
    VALUES (v_numer_max + 10, v_nowa_nazwa);

    DBMS_OUTPUT.PUT_LINE('Dodano nowy departament: ' || v_nowa_nazwa ||
                         ' o numerze ' || (v_numer_max + 10));
END;
/

-------------------------------------------------------------------------------
--Zadanie 2
-------------------------------------------------------------------------------
DECLARE
    v_numer_max   departments.department_id%TYPE;
BEGIN
    SELECT MAX(department_id)
    INTO v_numer_max
    FROM departments;

    UPDATE departments
       SET location_id = 3000
     WHERE department_id = v_numer_max + 10;

    DBMS_OUTPUT.PUT_LINE('Zmieniono location_id na 3000 dla departamentu ' || (v_numer_max + 10));
END;
/

-------------------------------------------------------------------------------
--Zadanie 3
-------------------------------------------------------------------------------
DECLARE
    v_dept_name departments.department_name%TYPE;
    v_dept_id   departments.department_id%TYPE;
BEGIN
    SELECT department_name, department_id
      INTO v_dept_name, v_dept_id
      FROM departments
     WHERE department_id = (SELECT MAX(department_id) FROM departments);

    DELETE FROM departments
     WHERE department_id = v_dept_id;

    DBMS_OUTPUT.PUT_LINE('Usunięto departament: ' || v_dept_name ||
                         ' (ID: ' || v_dept_id || ')');
END;
/

-------------------------------------------------------------------------------
--Zadanie 4
-------------------------------------------------------------------------------
DECLARE
    v_last_name  employees.last_name%TYPE;
    v_salary     employees.salary%TYPE;
BEGIN
    SELECT last_name, salary
      INTO v_last_name, v_salary
      FROM employees
     WHERE employee_id = 100;

    DBMS_OUTPUT.PUT_LINE('Pracownik: ' || v_last_name ||
                         ', zarobki: ' || v_salary);
END;
/

-------------------------------------------------------------------------------
--Zadanie 5
-------------------------------------------------------------------------------
DECLARE
    v_avg_salary NUMBER;
BEGIN
    SELECT AVG(salary)
      INTO v_avg_salary
      FROM employees;

    DBMS_OUTPUT.PUT_LINE('Średnie wynagrodzenie: ' || ROUND(v_avg_salary, 2));
END;
/

-------------------------------------------------------------------------------
--Zadanie 6
-------------------------------------------------------------------------------
DECLARE
    v_count NUMBER;
BEGIN
    SELECT COUNT(*)
      INTO v_count
      FROM employees
     WHERE department_id = 90;

    DBMS_OUTPUT.PUT_LINE('Liczba pracowników w dziale 90: ' || v_count);
END;
/

-------------------------------------------------------------------------------
--Zadanie 7
-------------------------------------------------------------------------------
DECLARE
    v_last_name employees.last_name%TYPE;
    v_salary    employees.salary%TYPE;
BEGIN
    SELECT last_name, salary
      INTO v_last_name, v_salary
      FROM employees
     WHERE employee_id = 101;

    IF v_salary > 10000 THEN
        DBMS_OUTPUT.PUT_LINE('Pracownik ' || v_last_name ||
                             ' ma wysokie zarobki: ' || v_salary);
    ELSE
        DBMS_OUTPUT.PUT_LINE('Pracownik ' || v_last_name ||
                             ' ma standardowe zarobki: ' || v_salary);
    END IF;
END;
/

-------------------------------------------------------------------------------
--Zadanie 8
-------------------------------------------------------------------------------
DECLARE
    v_emp_id employees.employee_id%TYPE := 100;
    v_new_sal NUMBER := 12000;
BEGIN
    UPDATE employees
       SET salary = v_new_sal
     WHERE employee_id = v_emp_id;

    DBMS_OUTPUT.PUT_LINE('Zmieniono pensję pracownika ' || v_emp_id ||
                         ' na ' || v_new_sal);
END;
/

-------------------------------------------------------------------------------
--Zadanie 9
-------------------------------------------------------------------------------
DECLARE
    v_job_id employees.job_id%TYPE;
    v_emp_id employees.employee_id%TYPE := 100;
BEGIN
    SELECT job_id
      INTO v_job_id
      FROM employees
     WHERE employee_id = v_emp_id;

    DBMS_OUTPUT.PUT_LINE('Stanowisko pracownika ' || v_emp_id ||
                         ': ' || v_job_id);
END;
/

-------------------------------------------------------------------------------
--Zadanie 10
-------------------------------------------------------------------------------
DECLARE
    v_total NUMBER := 0;
BEGIN
    FOR r IN (SELECT salary FROM employees) LOOP
        v_total := v_total + r.salary;
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('Łączna suma wynagrodzeń: ' || v_total);
END;
/
