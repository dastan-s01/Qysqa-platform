CREATE TABLE lectures (
                          id SERIAL PRIMARY KEY,
                          title TEXT,
                          filename TEXT,
                          full_text TEXT,
                          summary TEXT,
                          created_at TIMESTAMP DEFAULT now()
);