Here's a detailed `README.md` file for your project:

```markdown
# NYT Books Data Project

This project retrieves data from the New York Times Books API and stores it in a PostgreSQL database. It then runs SQL queries to analyze the data and provides insights based on the queries.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Project Structure](#project-structure)
- [Setup and Installation](#setup-and-installation)
- [Environment Variables](#environment-variables)
- [Running the Project](#running-the-project)
- [SQL Queries](#sql-queries)
- [Dockerization](#dockerization)
- [Logging](#logging)
- [License](#license)

## Prerequisites

Before you begin, ensure you have met the following requirements:

- Docker
- Docker Compose
- A free developer account on [New York Times](https://developer.nytimes.com/) to get the API key

## Project Structure

```plaintext
project/
│
├── docker-compose.yml
├── Dockerfile
├── init.sql
├── requirements.txt
└── src/
    ├── main.py
    ├── database.py
    └── ...
```

- **docker-compose.yml**: Defines the services, including PostgreSQL setup.
- **Dockerfile**: Defines the PostgreSQL image and setup.
- **init.sql**: SQL script for database initialization.
- **requirements.txt**: Python dependencies.
- **src/**: Directory containing your Python project files.

## Setup and Installation

1. **Clone the repository:**

   ```bash
   git clone https://github.com/yourusername/nyt-books-data-project.git
   cd nyt-books-data-project
   ```

2. **Set up your environment variables:**

   Create a `.env` file in the root directory with the following content:

   ```plaintext
   DB_HOST=postgres
   DB_PORT=5432
   DB_NAME=nyt_books_db
   DB_USER=nyt_user
   DB_PASSWORD=nyt_password
   NYT_API_KEY=your_nyt_api_key
   ```

3. **Build and start the Docker containers:**

   ```bash
   docker-compose up --build
   ```

## Environment Variables

Ensure you have the following environment variables set up in your `.env` file:

- `DB_HOST`: Database host (default: `postgres`)
- `DB_PORT`: Database port (default: `5432`)
- `DB_NAME`: Database name (default: `nyt_books_db`)
- `DB_USER`: Database user (default: `nyt_user`)
- `DB_PASSWORD`: Database password (default: `nyt_password`)
- `NYT_API_KEY`: Your New York Times API key

## Running the Project

The Python application will automatically run after building and starting the Docker containers. It will:

1. Retrieve data from the New York Times Books API for the years 2021 to 2023.
2. Store the data in the PostgreSQL database.
3. Run the SQL queries and export the results as CSV files.

## SQL Queries

The project runs the following SQL queries:

1. **Book remaining in the top 3 ranks for the longest time in 2022:**

    ```sql
    -- Book remaining in the top 3 ranks for the longest time in 2022
    SELECT b.title, COUNT(*) as weeks_in_top_3
    FROM fact_book_rankings f
    JOIN dim_books b ON f.book_id = b.book_id
    JOIN dim_dates d ON f.date_id = d.date_id
    WHERE f.rank <= 3 AND d.year = 2022
    GROUP BY b.title
    ORDER BY weeks_in_top_3 DESC
    LIMIT 1;
    ```

2. **Top 3 lists with the least number of unique books:**

    ```sql
    -- Top 3 lists with the least number of unique books
    SELECT l.list_name, COUNT(DISTINCT f.book_id) as unique_books_count
    FROM fact_book_rankings f
    JOIN dim_lists l ON f.list_id = l.list_id
    GROUP BY l.list_name
    ORDER BY unique_books_count ASC
    LIMIT 3;
    ```

3. **Quarterly rank for publishers from 2021 to 2023:**

    ```sql
    -- Quarterly rank for publishers from 2021 to 2023
    SELECT d.year, d.quarter, b.publisher, SUM(
        CASE
            WHEN f.rank = 1 THEN 5
            WHEN f.rank = 2 THEN 4
            WHEN f.rank = 3 THEN 3
            WHEN f.rank = 4 THEN 2
            WHEN f.rank = 5 THEN 1
            ELSE 0
        END
    ) as points
    FROM fact_book_rankings f
    JOIN dim_books b ON f.book_id = b.book_id
    JOIN dim_dates d ON f.date_id = d.date_id
    GROUP BY d.year, d.quarter, b.publisher
    ORDER BY d.year, d.quarter, points DESC
    LIMIT 5;
    ```

4. **Books bought by Jake's and Pete's teams in 2023:**

    ```sql
    -- Books bought by Jake's and Pete's teams in 2023
    SELECT d.date, jake_books.title as jake_book, pete_books.title as pete_book
    FROM dim_dates d
    LEFT JOIN (
        SELECT f.date_id, b.title
        FROM fact_book_rankings f
        JOIN dim_books b ON f.book_id = b.book_id
        WHERE f.rank = 1 AND d.year = 2023
    ) as jake_books ON d.date_id = jake_books.date_id
    LEFT JOIN (
        SELECT f.date_id, b.title
        FROM fact_book_rankings f
        JOIN dim_books b ON f.book_id = b.book_id
        WHERE f.rank = 3 AND d.year = 2023
    ) as pete_books ON d.date_id = pete_books.date_id
    WHERE d.year = 2023;
    ```

## Dockerization

The project uses Docker for containerization. The `docker-compose.yml` file orchestrates the PostgreSQL and Python services. The `Dockerfile` sets up the environment for the Python application.

To build and run the containers:

```bash
docker-compose up --build
```

## Logging

The project uses Python's built-in logging module to log information, warnings, and errors. Logs are printed to the console with timestamps and log levels.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
```

### Summary

This `README.md` provides a comprehensive guide to setting up and running your project. It includes instructions for prerequisites, project structure, setup and installation, environment variables, running the project, SQL queries, Dockerization, and logging. Adjust paths, environment variables, and database configurations as needed based on your specific setup and deployment environment.r