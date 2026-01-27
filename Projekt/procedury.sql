------------------------------------------------------------
-- Procedura sprzedaży biletu
------------------------------------------------------------
CREATE OR REPLACE PROCEDURE sell_ticket (
  p_seance_id   IN NUMBER,
  p_customer_id IN NUMBER,
  p_price       IN NUMBER
) AS
BEGIN
  INSERT INTO tickets (seance_id, customer_id, price)
  VALUES (p_seance_id, p_customer_id, p_price);

  COMMIT;
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

  COMMIT;
END;
/
