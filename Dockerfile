# Dockerfile
FROM python:3.9-slim

# Set up PostgreSQL
RUN apt-get update \
    && apt-get install -y postgresql \
    && rm -rf /var/lib/apt/lists/*

# Set up Python environment
WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt

# Copy the rest of the application code into the container
COPY . .

# Copy the initialization script into the container
COPY init.sql /docker-entrypoint-initdb.d/init.sql

# Specify the command to run on container start
CMD ["python", "main.py"]