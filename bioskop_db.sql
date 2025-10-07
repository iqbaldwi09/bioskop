-- PostgreSQL conversion of MySQL dump (bioskop_db)
-- Generated: 2025-10-08

BEGIN;

-- 1) Create enum types
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'payments_status') THEN
        CREATE TYPE payments_status AS ENUM ('pending','success','failed','refunded');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'refunds_status') THEN
        CREATE TYPE refunds_status AS ENUM ('pending','success','failed');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'seat_type') THEN
        CREATE TYPE seat_type AS ENUM ('regular','vip');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'showtimes_status') THEN
        CREATE TYPE showtimes_status AS ENUM ('active','cancelled');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'tickets_status') THEN
        CREATE TYPE tickets_status AS ENUM ('booked','paid','refunded','cancelled');
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'users_role') THEN
        CREATE TYPE users_role AS ENUM ('customer','admin');
    END IF;
END $$;


-- 2) bioskops
CREATE TABLE IF NOT EXISTS bioskops (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    city VARCHAR(100) NOT NULL,
    address TEXT NOT NULL
);

-- seed data
INSERT INTO bioskops (id, name, city, address) VALUES
(1, 'Amplaz XXI', 'Yogyakarta', 'Jl. Laksda Adisucipto No.80, Ambarukmo, Caturtunggal, Kec. Depok, Kabupaten Sleman, Daerah Istimewa Yogyakarta 55281')
ON CONFLICT (id) DO NOTHING;
INSERT INTO bioskops (id, name, city, address) VALUES
(2, 'Lippo XXI', 'Yogyakarta', 'Jl. Laksda Adisucipto. 32-34, Daerah Istimewa Yogyakarta 55221 Lippo Plaza Jogja Ground Floor #G-05, Kota Yogyakarta, Daerah Istimewa Yogyakarta 55221')
ON CONFLICT (id) DO NOTHING;

-- Ensure sequence nextval >= max(id)+1
SELECT setval(pg_get_serial_sequence('bioskops','id'), COALESCE((SELECT MAX(id) FROM bioskops), 1));


-- 3) movies
CREATE TABLE IF NOT EXISTS movies (
    id BIGSERIAL PRIMARY KEY,
    title VARCHAR(150) NOT NULL,
    duration_minutes INTEGER NOT NULL,
    rating VARCHAR(10),
    description TEXT,
    poster_url VARCHAR(255),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

INSERT INTO movies (id, title, duration_minutes, rating, description, poster_url, created_at) VALUES
(1, 'Avengers: Endgame', 181, 'PG-13', 'Superhero epic conclusion', NULL, '2025-10-07 17:00:00+00')
ON CONFLICT (id) DO NOTHING;
INSERT INTO movies (id, title, duration_minutes, rating, description, poster_url, created_at) VALUES
(2, 'Inception', 148, 'PG-13', 'Dream heist thriller', NULL, '2025-10-07 17:00:00+00')
ON CONFLICT (id) DO NOTHING;

SELECT setval(pg_get_serial_sequence('movies','id'), COALESCE((SELECT MAX(id) FROM movies), 1));


-- 4) payments
CREATE TABLE IF NOT EXISTS payments (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    amount NUMERIC(10,2) NOT NULL,
    payment_method VARCHAR(50),
    status payments_status DEFAULT 'pending',
    transaction_ref VARCHAR(100),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

SELECT setval(pg_get_serial_sequence('payments','id'), COALESCE((SELECT MAX(id) FROM payments), 1));


-- 5) refunds
CREATE TABLE IF NOT EXISTS refunds (
    id BIGSERIAL PRIMARY KEY,
    ticket_id BIGINT NOT NULL,
    reason TEXT,
    status refunds_status DEFAULT 'pending',
    processed_at TIMESTAMPTZ
);

SELECT setval(pg_get_serial_sequence('refunds','id'), COALESCE((SELECT MAX(id) FROM refunds), 1));


-- 6) seats
CREATE TABLE IF NOT EXISTS seats (
    id BIGSERIAL PRIMARY KEY,
    bioskop_id BIGINT NOT NULL,
    seat_number VARCHAR(10) NOT NULL,
    seat_type seat_type DEFAULT 'regular'
);

INSERT INTO seats (id, bioskop_id, seat_number, seat_type) VALUES
(1, 1, 'A1', 'regular') ON CONFLICT (id) DO NOTHING,
(2, 1, 'A2', 'vip') ON CONFLICT (id) DO NOTHING,
(3, 2, 'B1', 'regular') ON CONFLICT (id) DO NOTHING;

SELECT setval(pg_get_serial_sequence('seats','id'), COALESCE((SELECT MAX(id) FROM seats), 1));


-- 7) showtimes
CREATE TABLE IF NOT EXISTS showtimes (
    id BIGSERIAL PRIMARY KEY,
    bioskop_id BIGINT NOT NULL,
    movie_id BIGINT NOT NULL,
    start_time TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    end_time TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    status showtimes_status DEFAULT 'active',
    price NUMERIC(10,2) NOT NULL DEFAULT 0.00
);

-- Note: in original dump one showtime had empty string for status; here we set it to 'active'
INSERT INTO showtimes (id, bioskop_id, movie_id, start_time, end_time, status, price) VALUES
(1, 1, 2, '2025-10-10 20:00:00', '2025-10-10 22:00:00', 'active', 60000.00) ON CONFLICT (id) DO NOTHING,
(2, 2, 2, '2025-10-10 20:00:00', '2025-10-10 22:30:00', 'active', 50000.00) ON CONFLICT (id) DO NOTHING;

SELECT setval(pg_get_serial_sequence('showtimes','id'), COALESCE((SELECT MAX(id) FROM showtimes), 1));


-- 8) tickets
CREATE TABLE IF NOT EXISTS tickets (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    showtime_id BIGINT NOT NULL,
    seat_id BIGINT NOT NULL,
    price NUMERIC(10,2) NOT NULL,
    status tickets_status DEFAULT 'booked',
    payment_id BIGINT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

SELECT setval(pg_get_serial_sequence('tickets','id'), COALESCE((SELECT MAX(id) FROM tickets), 1));


-- 9) users
CREATE TABLE IF NOT EXISTS users (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    role users_role DEFAULT 'customer',
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

INSERT INTO users (id, name, email, password_hash, role, created_at, updated_at) VALUES
(1, 'Admin ', 'admin@gmail.com', '$2a$10$UXlBR5A6TVqO6zgP533ppucuzXQ29.pXiN8VP5RSmJymmDXsHJPwy', 'admin', '2025-10-07 19:36:13+00', '2025-10-07 20:22:15+00')
ON CONFLICT (id) DO NOTHING;

SELECT setval(pg_get_serial_sequence('users','id'), COALESCE((SELECT MAX(id) FROM users), 1));


-- 10) Indexes & constraints (foreign keys)
-- seats.bioskop_id -> bioskops.id
ALTER TABLE seats
    ADD CONSTRAINT IF NOT EXISTS seats_bioskops_fk FOREIGN KEY (bioskop_id) REFERENCES bioskops (id);

-- showtimes foreign keys
ALTER TABLE showtimes
    ADD CONSTRAINT IF NOT EXISTS showtimes_bioskop_fk FOREIGN KEY (bioskop_id) REFERENCES bioskops (id),
    ADD CONSTRAINT IF NOT EXISTS showtimes_movie_fk FOREIGN KEY (movie_id) REFERENCES movies (id);

-- payments.user_id -> users.id
ALTER TABLE payments
    ADD CONSTRAINT IF NOT EXISTS payments_user_fk FOREIGN KEY (user_id) REFERENCES users (id);

-- refunds.ticket_id -> tickets.id
ALTER TABLE refunds
    ADD CONSTRAINT IF NOT EXISTS refunds_ticket_fk FOREIGN KEY (ticket_id) REFERENCES tickets (id);

-- tickets foreign keys
ALTER TABLE tickets
    ADD CONSTRAINT IF NOT EXISTS tickets_user_fk FOREIGN KEY (user_id) REFERENCES users (id),
    ADD CONSTRAINT IF NOT EXISTS tickets_showtime_fk FOREIGN KEY (showtime_id) REFERENCES showtimes (id),
    ADD CONSTRAINT IF NOT EXISTS tickets_seat_fk FOREIGN KEY (seat_id) REFERENCES seats (id);

-- unique index for tickets (showtime_id, seat_id)
CREATE UNIQUE INDEX IF NOT EXISTS uniq_showtime_seat ON tickets (showtime_id, seat_id);

-- other useful indexes
CREATE INDEX IF NOT EXISTS idx_showtimes_movie ON showtimes (movie_id);
CREATE INDEX IF NOT EXISTS idx_showtimes_bioskop_movie ON showtimes (bioskop_id, movie_id);
CREATE INDEX IF NOT EXISTS idx_tickets_user_showtime ON tickets (user_id, showtime_id);
CREATE INDEX IF NOT EXISTS idx_seats_bioskop ON seats (bioskop_id);


COMMIT;
