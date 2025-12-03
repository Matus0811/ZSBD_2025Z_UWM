-------------------------------------------------------------------------------
--Zadanie 1
-------------------------------------------------------------------------------
CREATE TABLE archiwum_departamentow (
    id               NUMBER,
    nazwa            VARCHAR2(30),
    data_zamkniecia  DATE,
    ostatni_manager  VARCHAR2(100)
);
/

CREATE OR REPLACE TRIGGER trg_archiwum_departamentow
AFTER DELETE ON departments
FOR EACH ROW
DECLARE
    v_manager VARCHAR2(100);
BEGIN
    IF :OLD.manager_id IS NOT NULL THEN
        SELECT first_name || ' ' || last_name
          INTO v_manager
          FROM employees
         WHERE employee_id = :OLD.manager_id;
    ELSE
        v_manager := 'BRAK MANAGERA';
    END IF;

    INSERT INTO archiwum_departamentow
        (id, nazwa, data_zamkniecia, ostatni_manager)
    VALUES
        (:OLD.department_id, :OLD.department_name, SYSDATE, v_manager);
END;
/
-------------------------------------------------------------------------------
--Zadanie 2
-------------------------------------------------------------------------------
CREATE TABLE zlodziej (
    id          NUMBER GENERATED ALWAYS AS IDENTITY,
    user_name   VARCHAR2(30),
    czas_zmiany DATE,
    opis        VARCHAR2(200)
);
/

CREATE OR REPLACE TRIGGER trg_sal_range
BEFORE INSERT OR UPDATE ON employees
FOR EACH ROW
BEGIN
    IF :NEW.salary NOT BETWEEN 2000 AND 26000 THEN
        INSERT INTO zlodziej (user_name, czas_zmiany, opis)
        VALUES (USER, SYSDATE, 'Próba ustawienia pensji: ' || :NEW.salary);

        RAISE_APPLICATION_ERROR(-20050, 'Pensja poza zakresem 2000 - 26000!');
    END IF;
END;
/
-------------------------------------------------------------------------------
--Zadanie 3
-------------------------------------------------------------------------------
CREATE SEQUENCE emp_ai_seq
    START WITH 10000
    INCREMENT BY 1;
/

CREATE OR REPLACE TRIGGER trg_emp_ai
BEFORE INSERT ON employees
FOR EACH ROW
BEGIN
    IF :NEW.employee_id IS NULL THEN
        :NEW.employee_id := emp_ai_seq.NEXTVAL;
    END IF;
END;
/
-------------------------------------------------------------------------------
--Zadanie 4
-------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER trg_block_job_grades
BEFORE INSERT OR UPDATE OR DELETE ON job_grades
BEGIN
    RAISE_APPLICATION_ERROR(-20051, 'Operacje na JOB_GRADES są zabronione!');
END;
/
-------------------------------------------------------------------------------
--Zadanie 5
-------------------------------------------------------------------------------
CREATE TABLE jobs_log (
    id          NUMBER GENERATED ALWAYS AS IDENTITY,
    job_id      VARCHAR2(10),
    old_min     NUMBER,
    old_max     NUMBER,
    new_min     NUMBER,
    new_max     NUMBER,
    zmienil     VARCHAR2(30),
    data_zmiany DATE
);
/

CREATE OR REPLACE TRIGGER trg_jobs_old_values
BEFORE UPDATE ON jobs
FOR EACH ROW
BEGIN
    INSERT INTO jobs_log (job_id, old_min, old_max, new_min, new_max, zmienil, data_zmiany)
    VALUES (:OLD.job_id, :OLD.min_salary, :OLD.max_salary,
            :NEW.min_salary, :NEW.max_salary, USER, SYSDATE);
END;
/
-------------------------------------------------------------------------------
--Zadanie 6
-------------------------------------------------------------------------------
BEGIN
    DBMS_OUTPUT.PUT_LINE('Testy wyzwalaczy wykonane.');
END;
/
