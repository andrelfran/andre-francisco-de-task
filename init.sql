-- init.sql

-- Create the database
CREATE DATABASE nyt_books_db;

-- Connect to the newly created database
\c nyt_books_db;

-- Create user
CREATE USER nyt_user WITH PASSWORD 'abc123';

-- Grant privileges to the user
GRANT ALL PRIVILEGES ON DATABASE nyt_books_db TO nyt_user;

-- Create tables
CREATE TABLE IF NOT EXISTS dim_dates (
    date_id SERIAL PRIMARY KEY,
    date DATE UNIQUE,
    year INT,
    quarter INT,
    month INT,
    day INT
);

CREATE TABLE IF NOT EXISTS dim_books (
    book_id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    author VARCHAR(255),
    publisher VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS dim_lists (
    list_id SERIAL PRIMARY KEY,
    list_name VARCHAR(255) UNIQUE,
    description TEXT
);

CREATE TABLE IF NOT EXISTS fact_book_rankings (
    date_id INT,
    book_id INT,
    list_id INT,
    rank INT,
    FOREIGN KEY (date_id) REFERENCES dim_dates(date_id),
    FOREIGN KEY (book_id) REFERENCES dim_books(book_id),
    FOREIGN KEY (list_id) REFERENCES dim_lists(list_id),
    PRIMARY KEY (date_id, book_id, list_id)
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_fact_book_rankings_book_id ON fact_book_rankings(book_id);
CREATE INDEX IF NOT EXISTS idx_fact_book_rankings_list_id ON fact_book_rankings(list_id);
