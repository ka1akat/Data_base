CREATE DATABASE library_system
  WITH CONNECTION LIMIT = 75;

CREATE TABLESPACE digital_content
    LOCATION '/Users/karakatzaslan/postgres_tables//storage/ebooks';


CREATE TABLE book_catalog (
                              catalog_id PRIMARY KEY,
                              isbn CHAR(13) NOT NULL,
                              book_title VARCHAR(150),
                              author_name VARCHAR(100),
                              publisher VARCHAR(80),
                              publication_year SMALLINT,
                              total_pages INT,
                              book_format CHAR(10),
                              purchase_price DECIMAL(10,2),
                              is_available BOOLEAN
);
CREATE TABLE digital_downloads (
                                   download_id  PRIMARY KEY,
                                   user_id INT,
                                   catalog_id INT,
                                   download_timestamp TIMESTAMP,
                                   file_format VARCHAR(10),
                                   file_size_mb REAL,
                                   download_completed BOOLEAN,
                                   expiry_date DATE,
                                   access_count SMALLINT
);

ALTER TABLE book_catalog
    ADD COLUMN genre VARCHAR(50),
  ADD COLUMN library_section CHAR(3) ;
ALTER TABLE digital_downloads
    ADD COLUMN device_type VARCHAR(30),
ALTER COLUMN file_size_mb TYPE INT,
  ADD COLUMN last_accessed TIMESTAMPTZ;

CREATE TABLE reading_sessions (
                    session_id SERIAL PRIMARY KEY,
                    user_ref INTEGER NOT NULL,
                    book_ref INTEGER NOT NULL,
                    session_start TIMESTAMPTZ NOT NULL,
                    reading_duration INTERVAL,
                    pages_read SMALLINT,
                    session_active BOOLEAN,
);


