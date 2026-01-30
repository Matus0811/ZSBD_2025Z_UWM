------------------------------------------------------------
-- Dane testowe do projektu – sieć kin
------------------------------------------------------------

-- Kina
INSERT INTO cinemas (name, city)
VALUES ('Cinema City', 'Warszawa');

INSERT INTO cinemas (name, city)
VALUES ('Multikino', 'Kraków');

-- Filmy
INSERT INTO movies (title, duration)
VALUES ('Incepcja', 148);

INSERT INTO movies (title, duration)
VALUES ('Matrix', 136);

-- Sale
INSERT INTO halls (cinema_id, name, seats)
VALUES (1, 'Sala 1', 120);

INSERT INTO halls (cinema_id, name, seats)
VALUES (2, 'Sala A', 100);

-- Seanse
INSERT INTO seances (movie_id, hall_id, seance_date)
VALUES (1, 1, SYSDATE + 1);

INSERT INTO seances (movie_id, hall_id, seance_date)
VALUES (2, 2, SYSDATE + 2);

-- Klienci
INSERT INTO customers (first_name, last_name, email)
VALUES ('Jan', 'Kowalski', 'jan.kowalski@example.com');

INSERT INTO customers (first_name, last_name, email)
VALUES ('Anna', 'Nowak', 'anna.nowak@example.com');

-- Bilety
INSERT INTO tickets (seance_id, customer_id, price)
VALUES (1, 1, 25.00);

INSERT INTO tickets (seance_id, customer_id, price)
VALUES (2, 2, 28.00);

COMMIT;
