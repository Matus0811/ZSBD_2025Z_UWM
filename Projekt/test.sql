SET SERVEROUTPUT ON;

--==========================================================
--TEST 1: OBSLUGA BLEDOW I WALIDACJA
--==========================================================

-- 1.1. Próba sprzedaży biletu z ujemną ceną
BEGIN
  DBMS_OUTPUT.PUT_LINE('--- Proba sprzedazy biletu za -50 PLN ---');
  sell_ticket(p_seance_id => 1, p_customer_id => 1, p_price => -50);
END;
/

-- 1.2. Próba usunięcia nieistniejącego biletu
BEGIN
  DBMS_OUTPUT.PUT_LINE('--- Proba usuniecia biletu ID 99999 ---');
  delete_ticket(99999);
END;
/

--==========================================================
--TEST 2: POPRAWNE OPERACJE CRUD 
--==========================================================

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

-- 2.3. Aktualizacja adresu email
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

--==========================================================
--TEST 3: ARCHIWIZACJA I TRIGGERY 
--==========================================================
DECLARE
  v_ticket_to_delete NUMBER;
BEGIN
  -- Pobieramy ID ostatnio dodanego biletu
  SELECT MAX(ticket_id) INTO v_ticket_to_delete FROM tickets;
  
  DBMS_OUTPUT.PUT_LINE('--- Usuwanie biletu ID: ' || v_ticket_to_delete || ' ---');
  delete_ticket(v_ticket_to_delete);
END;
/

SELECT ticket_id, price, deleted_at FROM tickets_archive ORDER BY deleted_at DESC FETCH FIRST 5 ROWS ONLY;

--==========================================================
--TEST 4: RAPORTY I FUNKCJE OKIENKOWE 
--==========================================================
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


--==========================================================
--TEST 5: DODATKOWE FUNKCJE I WIDOKI
--==========================================================
--- 5.1. Test Funkcji: Sprawdzenie wolnych miejsc na seansach ---
SELECT 
    s.seance_id, 
    m.title,
    get_free_seats(s.seance_id) AS wolne_miejsca 
FROM seances s
JOIN movies m ON s.movie_id = m.movie_id;

--- 5.2. Test Widoku: Wyświetlenie czytelnego repertuaru ---
SELECT * FROM v_repertoire_info;
