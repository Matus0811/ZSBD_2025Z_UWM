------------------------------------------------------------
-- Tabela raportu miesięcznej sprzedaży biletów
------------------------------------------------------------
CREATE TABLE monthly_sales_report (
  report_month VARCHAR2(7),
  total_tickets NUMBER,
  total_revenue NUMBER(10,2)
);

------------------------------------------------------------
-- Procedura generująca raport miesięcznej sprzedaży
------------------------------------------------------------
CREATE OR REPLACE PROCEDURE generate_monthly_report AS
BEGIN
  DELETE FROM monthly_sales_report;

  INSERT INTO monthly_sales_report (
    report_month,
    total_tickets,
    total_revenue
  )
  SELECT
    TO_CHAR(sale_date, 'YYYY-MM'),
    COUNT(*),
    SUM(price)
  FROM tickets
  GROUP BY TO_CHAR(sale_date, 'YYYY-MM');

  COMMIT;
END;
/
 