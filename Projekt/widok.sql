------------------------------------------------------------
-- Widok: Czytelny repertuar dla obsługi
------------------------------------------------------------
CREATE OR REPLACE VIEW v_repertoire_info AS
SELECT 
    m.title AS Film,
    c.name AS Kino,
    h.name AS Sala,
    TO_CHAR(s.seance_date, 'YYYY-MM-DD HH24:MI') AS Data_Seansu,
    m.duration || ' min' AS Czas_Trwania
FROM seances s
JOIN movies m ON s.movie_id = m.movie_id
JOIN halls h ON s.hall_id = h.hall_id
JOIN cinemas c ON h.cinema_id = c.cinema_id;