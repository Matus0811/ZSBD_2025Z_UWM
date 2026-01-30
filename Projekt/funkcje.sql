------------------------------------------------------------
-- Funkcja obliczająca liczbę wolnych miejsc na seansie
------------------------------------------------------------
CREATE OR REPLACE FUNCTION get_free_seats (
  p_seance_id IN NUMBER
) RETURN NUMBER IS
  v_total_seats NUMBER;
  v_sold_tickets NUMBER;
BEGIN
  -- 1. Pobierz pojemność sali dla tego seansu
  SELECT h.seats 
  INTO v_total_seats
  FROM seances s
  JOIN halls h ON s.hall_id = h.hall_id
  WHERE s.seance_id = p_seance_id;

  -- 2. Policz sprzedane bilety
  SELECT COUNT(*)
  INTO v_sold_tickets
  FROM tickets
  WHERE seance_id = p_seance_id;

  -- 3. Zwróć różnicę
  RETURN v_total_seats - v_sold_tickets;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN 0; -- Jeśli seans nie istnieje, zwróć 0
END;
/