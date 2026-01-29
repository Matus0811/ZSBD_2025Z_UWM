------------------------------------------------------------
-- Procedura sprzedaży biletu 
------------------------------------------------------------
CREATE OR REPLACE PROCEDURE sell_ticket (
  p_seance_id   IN NUMBER,
  p_customer_id IN NUMBER,
  p_price       IN NUMBER
) AS
  e_invalid_price EXCEPTION;
BEGIN
  IF p_price <= 0 THEN
    RAISE e_invalid_price;
  END IF;

  INSERT INTO tickets (seance_id, customer_id, price)
  VALUES (p_seance_id, p_customer_id, p_price);

  COMMIT;
  DBMS_OUTPUT.PUT_LINE('Sprzedano bilet pomyślnie.');

EXCEPTION
  WHEN e_invalid_price THEN
    DBMS_OUTPUT.PUT_LINE('BŁĄD: Cena biletu musi być większa od zera!');
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Wystąpił błąd bazy danych: ' || SQLERRM);
    ROLLBACK;
END;
/

------------------------------------------------------------
-- Procedura usuwania biletu
------------------------------------------------------------
CREATE OR REPLACE PROCEDURE delete_ticket (
  p_ticket_id IN NUMBER
) AS
BEGIN
  DELETE FROM tickets
  WHERE ticket_id = p_ticket_id;

  IF SQL%ROWCOUNT = 0 THEN
    DBMS_OUTPUT.PUT_LINE('Nie znaleziono biletu o ID: ' || p_ticket_id);
  ELSE
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Usunięto bilet o ID: ' || p_ticket_id);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Błąd podczas usuwania: ' || SQLERRM);
    ROLLBACK;
END;
/

------------------------------------------------------------
-- Procedura aktualizacji emaila klienta 
------------------------------------------------------------
CREATE OR REPLACE PROCEDURE update_customer_email (
  p_customer_id IN NUMBER,
  p_new_email   IN VARCHAR2
) AS
BEGIN
  UPDATE customers
  SET email = p_new_email
  WHERE customer_id = p_customer_id;

  IF SQL%ROWCOUNT = 0 THEN
    DBMS_OUTPUT.PUT_LINE('Nie znaleziono klienta o ID: ' || p_customer_id);
  ELSE
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Zaktualizowano email dla klienta ID: ' || p_customer_id);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Błąd aktualizacji: ' || SQLERRM);
    ROLLBACK;
END;
/
