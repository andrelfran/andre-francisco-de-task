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
   git clone https://github.com/andrelfran/andre-francisco-de-task.git
   cd andre-francisco-de-task
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

1. **Book remaining in the top 3 ranks for the longest time in 2022:**
2. **Top 3 lists with the least number of unique books:**
3. **Quarterly rank for publishers from 2021 to 2023:**
4. **Books bought by Jake's and Pete's teams in 2023:**

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