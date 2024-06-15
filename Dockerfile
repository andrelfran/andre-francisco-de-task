# Dockerfile
FROM python:3.9-slim

# Set up PostgreSQL
RUN apt-get update \
    && apt-get install -y postgresql \
    && rm -rf /var/lib/apt/lists/*

# Set environment variables
ENV POSTGRES_DB nyt_books_db
ENV POSTGRES_USER your_db_user
ENV POSTGRES_PASSWORD your_db_password

# Copy initialization script into the container
COPY init.sql /docker-entrypoint-initdb.d/

# Set up Python environment
WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt

# Copy source code into the container
COPY src/ .

# Run your Python application
CMD ["python", "main.py"]