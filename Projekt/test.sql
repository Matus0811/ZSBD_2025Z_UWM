/*
--------------------------------------------------------------------------------------
CO SPRAWDZAMY W TYM SKRYPCIE:
1. Walidację danych (blokada ujemnej ceny).
2. Obsługę wyjątków (próba usunięcia nieistniejącego rekordu).
3. Operacje CRUD (dodawanie, sprzedaż, aktualizacja maila).
4. Automatyzację (czy Trigger poprawnie archiwizuje usuwane dane).
5. Funkcje analityczne/okienkowe (wymagany ranking klientów). 
--------------------------------------------------------------------------------------
*/

SET SERVEROUTPUT ON;

==========================================================
--TEST 1: OBSLUGA BLEDOW I WALIDACJA
==========================================================

-- 1.1. Próba sprzedaży biletu z ujemną ceną (oczekiwany BŁĄD walidacji)
BEGIN
  DBMS_OUTPUT.PUT_LINE('--- Proba sprzedazy biletu za -50 PLN ---');
  sell_ticket(p_seance_id => 1, p_customer_id => 1, p_price => -50);
END;
/

-- 1.2. Próba usunięcia nieistniejącego biletu (oczekiwany komunikat o braku rekordu)
BEGIN
  DBMS_OUTPUT.PUT_LINE('--- Proba usuniecia biletu ID 99999 ---');
  delete_ticket(99999);
END;
/

==========================================================
--TEST 2: POPRAWNE OPERACJE CRUD (Create, Update)
==========================================================

-- 2.1. Dodanie nowego klienta
INSERT INTO customers (first_name, last_name, email) 
VALUES ('Testowy', 'Uzytkownik', 'test@test.pl');
COMMIT;

-- 2.2. Sprzedaż poprawnego biletu
DECLARE
  v_new_cust_id NUMBER;
BEGIN
  SELECT MAX(customer_id) INTO v_new_cust_id FROM customers;
  
  DBMS_OUTPUT.PUT_LINE('--- Sprzedaz poprawnego biletu dla klienta ID: ' || v_new_cust_id || ' ---');
  sell_ticket(p_seance_id => 1, p_customer_id => v_new_cust_id, p_price => 30.00);
END;
/

-- 2.3. Aktualizacja adresu email (Nowa procedura)
DECLARE
  v_cust_id NUMBER;
BEGIN
  SELECT MAX(customer_id) INTO v_cust_id FROM customers;
  
  DBMS_OUTPUT.PUT_LINE('--- Aktualizacja emaila ---');
  update_customer_email(v_cust_id, 'zmieniony.email@kino.pl');
END;
/

-- Weryfikacja zmiany
SELECT customer_id, first_name, email FROM customers WHERE email = 'zmieniony.email@kino.pl';

==========================================================
--TEST 3: ARCHIWIZACJA I TRIGGERY (Delete)
==========================================================
DECLARE
  v_ticket_to_delete NUMBER;
BEGIN
  -- Pobieramy ID ostatnio dodanego biletu
  SELECT MAX(ticket_id) INTO v_ticket_to_delete FROM tickets;
  
  DBMS_OUTPUT.PUT_LINE('--- Usuwanie biletu ID: ' || v_ticket_to_delete || ' ---');
  delete_ticket(v_ticket_to_delete);
END;
/

PROMPT --- Zawartosc archiwum (powinien pojawic sie usuniety bilet):
SELECT ticket_id, price, deleted_at FROM tickets_archive ORDER BY deleted_at DESC FETCH FIRST 5 ROWS ONLY;

==========================================================
--TEST 4: RAPORTY I FUNKCJE OKIENKOWE 
==========================================================
-- 4.1. Generowanie raportu miesięcznego
BEGIN
  DBMS_OUTPUT.PUT_LINE('--- Generowanie raportu miesiecznego ---');
  generate_monthly_report;
END;
/

SELECT * FROM monthly_sales_report;

--- Ranking klientow wg wydanych kwot ---

SELECT 
    c.first_name || ' ' || c.last_name AS klient,
    SUM(t.price) as suma_wydatkow,
    RANK() OVER (ORDER BY SUM(t.price) DESC) as ranking_klienta
FROM customers c
JOIN tickets t ON c.customer_id = t.customer_id
GROUP BY c.first_name, c.last_name, c.customer_id;