-------------------------------------------------------------------------------
--Zadanie 1
-------------------------------------------------------------------------------
SELECT employee_id,
       first_name,
       last_name,
       salary,
       RANK() OVER (ORDER BY salary DESC) AS ranking
FROM employees;

-------------------------------------------------------------------------------
--Zadanie 2
-------------------------------------------------------------------------------
SELECT employee_id,
       first_name,
       last_name,
       salary,
       SUM(salary) OVER () AS suma_wszystkich_pensji
FROM employees;

-------------------------------------------------------------------------------
--Zadanie 3
-------------------------------------------------------------------------------
SELECT e.last_name,
       p.product_name,
       (s.quantity * s.price) AS wartosc_sprzedazy,
       SUM(s.quantity * s.price) OVER (PARTITION BY e.employee_id ORDER BY s.sale_date) AS skumulowana_sprzedaz,
       RANK() OVER (ORDER BY (s.quantity * s.price) DESC) AS ranking_sprzedazy
FROM hr.employees e
JOIN hr.sales s ON e.employee_id = s.employee_id
JOIN hr.products p ON s.product_id = p.product_id;

-------------------------------------------------------------------------------
--Zadanie 4
-------------------------------------------------------------------------------
SELECT e.last_name,
       p.product_name,
       s.price AS cena_produktu,
       COUNT(*) OVER (PARTITION BY p.product_id, TRUNC(s.sale_date)) AS liczba_transakcji_dnia,
       SUM(s.quantity * s.price) OVER (PARTITION BY p.product_id, TRUNC(s.sale_date)) AS suma_dnia,
       LAG(s.price)  OVER (PARTITION BY p.product_id ORDER BY s.sale_date) AS poprzednia_cena,
       LEAD(s.price) OVER (PARTITION BY p.product_id ORDER BY s.sale_date) AS kolejna_cena
FROM hr.sales s
JOIN hr.employees e ON e.employee_id = s.employee_id
JOIN hr.products  p ON p.product_id  = s.product_id;

-------------------------------------------------------------------------------
--Zadanie 5
-------------------------------------------------------------------------------
SELECT p.product_name,
       s.price AS cena_produktu,
       SUM(s.quantity * s.price) OVER (
           PARTITION BY p.product_id, TRUNC(s.sale_date, 'MM')
       ) AS suma_miesiaca,
       SUM(s.quantity * s.price) OVER (
           PARTITION BY p.product_id, TRUNC(s.sale_date, 'MM')
           ORDER BY s.sale_date
       ) AS suma_narastajaca
FROM hr.sales s
JOIN hr.products p ON p.product_id = s.product_id
ORDER BY p.product_name, s.sale_date;

-------------------------------------------------------------------------------
--Zadanie 6
-------------------------------------------------------------------------------
SELECT 
    p.product_name,
    p.product_category AS kategoria,
    s2022.price AS cena_2022,
    s2023.price AS cena_2023,
    (s2023.price - s2022.price) AS roznica_cen
FROM hr.products p
JOIN hr.sales s2022 
    ON s2022.product_id = p.product_id
   AND EXTRACT(YEAR FROM s2022.sale_date) = 2022
JOIN hr.sales s2023 
    ON s2023.product_id = p.product_id
   AND EXTRACT(YEAR FROM s2023.sale_date) = 2023
   AND TO_CHAR(s2022.sale_date, 'MMDD') = TO_CHAR(s2023.sale_date, 'MMDD')
ORDER BY p.product_name, TO_CHAR(s2022.sale_date, 'MMDD');

-------------------------------------------------------------------------------
--Zadanie 7
-------------------------------------------------------------------------------
SELECT 
    p.product_category AS kategoria,
    p.product_name,
    s.price AS cena_produktu,
    MIN(s.price) OVER (PARTITION BY p.product_category) AS min_cena_kategorii,
    MAX(s.price) OVER (PARTITION BY p.product_category) AS max_cena_kategorii,
    (MAX(s.price) OVER (PARTITION BY p.product_category)
     - MIN(s.price) OVER (PARTITION BY p.product_category)) AS roznica_cen
FROM hr.sales s
JOIN hr.products p ON s.product_id = p.product_id
ORDER BY p.product_category, p.product_name;

-------------------------------------------------------------------------------
--Zadanie 8
-------------------------------------------------------------------------------
SELECT 
    p.product_name,
    s.sale_date,
    s.price AS cena_biezaca,
    ROUND(
        AVG(s.price) OVER (
            PARTITION BY p.product_id
            ORDER BY s.sale_date
            ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING
        ), 2
    ) AS srednia_kroczaca
FROM hr.sales s
JOIN hr.products p ON s.product_id = p.product_id
ORDER BY p.product_name, s.sale_date;

-------------------------------------------------------------------------------
--Zadanie 9
-------------------------------------------------------------------------------
SELECT 
    p.product_category AS kategoria,
    p.product_name,
    s.price AS cena,
    RANK()       OVER (PARTITION BY p.product_category ORDER BY s.price DESC) AS ranking,
    ROW_NUMBER() OVER (PARTITION BY p.product_category ORDER BY s.price DESC) AS numer_wiersza,
    DENSE_RANK() OVER (PARTITION BY p.product_category ORDER BY s.price DESC) AS ranking_gesty
FROM hr.sales s
JOIN hr.products p ON s.product_id = p.product_id
ORDER BY p.product_category, s.price DESC;

-------------------------------------------------------------------------------
--Zadanie 10
-------------------------------------------------------------------------------
SELECT 
    e.last_name,
    p.product_name,
    s.sale_date,
    (s.price * s.quantity) AS wartosc_sprzedazy,
    SUM(s.price * s.quantity) OVER (
        PARTITION BY e.employee_id
        ORDER BY s.sale_date
    ) AS wartosc_narastajaca,
    RANK() OVER (ORDER BY (s.price * s.quantity) DESC) AS ranking_globalny
FROM hr.sales s
JOIN hr.employees e ON e.employee_id = s.employee_id
JOIN hr.products  p ON p.product_id  = s.product_id
ORDER BY e.last_name, s.sale_date;

-------------------------------------------------------------------------------
--Zadanie 11
-------------------------------------------------------------------------------
SELECT DISTINCT 
    e.first_name,
    e.last_name,
    e.job_id
FROM hr.employees e
JOIN hr.sales s ON e.employee_id = s.employee_id
ORDER BY e.last_name;
