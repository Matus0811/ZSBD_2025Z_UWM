------------------------------------------------------------
-- Trigger archiwizujący usunięte bilety 
------------------------------------------------------------
CREATE OR REPLACE TRIGGER trg_archive_ticket
BEFORE DELETE ON tickets
FOR EACH ROW
BEGIN
  INSERT INTO tickets_archive (
    ticket_id,
    seance_id,
    customer_id,
    price,
    sale_date,
    deleted_at
  )
  VALUES (
    :OLD.ticket_id,
    :OLD.seance_id,
    :OLD.customer_id,
    :OLD.price,
    :OLD.sale_date,
    SYSDATE
  );
END;
/
