import os
import requests
from datetime import datetime, timedelta
from dotenv import load_dotenv
import psycopg2
from psycopg2 import sql
import logging
import time

# Configure logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

# Load environment variables from .env file
load_dotenv()

# PostgreSQL connection details
DB_HOST = os.getenv('DB_HOST', 'localhost')
DB_PORT = os.getenv('DB_PORT', '5432')
DB_NAME = os.getenv('DB_NAME', None)
DB_USER = os.getenv('DB_USER', None)
DB_PASSWORD = os.getenv('DB_PASSWORD', None)

# NY Times API details
API_KEY = os.getenv('NYT_API_KEY')
BASE_URL = 'https://api.nytimes.com/svc/books/v3/lists/overview.json'

def fetch_data(date):
    url = f'{BASE_URL}?published_date={date}&api-key={API_KEY}'
    logging.info(f"Fetching data from {url}")

    try:
        response = requests.get(url)
        if response.status_code == 200:
            return response.json()
        elif response.status_code == 429:
            logging.info('Rate limit exceeded. Waiting for reset...')
            time.sleep(60)
            return fetch_data(date)  # Retry the request after waiting
        else:
            print(f'Error: {response.status_code}')
    except Exception as e:
        print(f'Error making API request: {str(e)}')

def insert_data_into_db(data):
    try:
        conn = psycopg2.connect(
            dbname=DB_NAME,
            user=DB_USER,
            password=DB_PASSWORD,
            host=DB_HOST,
            port=DB_PORT
        )
        cursor = conn.cursor()

        if data.get('results'):
            results = data.get('results')
            if results.get('lists'):
                lists = results.get('lists')

                published_date = datetime.strptime(results.get('published_date'), '%Y-%m-%d').date()

                for item in lists:
                    # Extract relevant information from the API response
                    list_name = item.get('list_name')
                    books = item.get('books', [])

                    # Insert date into dim_dates table
                    cursor.execute(
                        sql.SQL("INSERT INTO dim_dates (date, year, quarter, month, day) VALUES (%s, %s, %s, %s, %s) ON CONFLICT DO NOTHING"),
                        [published_date, published_date.year, (published_date.month - 1) // 3 + 1, published_date.month, published_date.day]
                    )
                    conn.commit()
                    logger.info(f"Inserted date {published_date} into dim_dates table")

                    # Get date_id
                    cursor.execute(
                        sql.SQL("SELECT date_id FROM dim_dates WHERE date = %s"),
                        [published_date]
                    )
                    date_id = cursor.fetchone()[0]

                    for book in books:
                        title = book.get('title')
                        author = book.get('author')
                        publisher = book.get('publisher')
                        rank = book.get('rank')

                        # Insert book into dim_books table
                        cursor.execute(
                            sql.SQL("INSERT INTO dim_books (title, author, publisher) VALUES (%s, %s, %s) ON CONFLICT DO NOTHING RETURNING book_id"),
                            [title, author, publisher]
                        )
                        book_id = cursor.fetchone()[0] if cursor.rowcount > 0 else None
                        if book_id:
                            logger.info(f"Inserted book {title} into dim_books table")

                        # Insert list into dim_lists table
                        cursor.execute(
                            sql.SQL("INSERT INTO dim_lists (list_name, description) VALUES (%s, %s) ON CONFLICT DO NOTHING RETURNING list_id"),
                            [list_name, list_name]  # Assuming list_name as description for simplicity
                        )
                        list_id = cursor.fetchone()[0] if cursor.rowcount > 0 else None
                        if list_id:
                            logger.info(f"Inserted list {list_name} into dim_lists table")

                        # Insert fact_book_ranking
                        if book_id and list_id:
                            cursor.execute(
                                sql.SQL("INSERT INTO fact_book_rankings (date_id, book_id, list_id, rank) VALUES (%s, %s, %s, %s)"),
                                [date_id, book_id, list_id, rank]
                            )
                            conn.commit()
                            logger.info(f"Inserted book {title} ranking into fact_book_rankings")

            else:
                logging.info('Lists are empty!')              
        else:
            logging.info('Results are empty!')

        cursor.close()
    except psycopg2.Error as e:
        logger.error(f"Error inserting data into PostgreSQL: {e}")
    finally:
        if conn:
            conn.close()

if __name__ == "__main__":

    start_date = datetime(2021, 9, 28)
    end_date = datetime(2023, 12, 31)
    delta = timedelta(days=1)

    while start_date <= end_date:
        formatted_date = start_date.strftime('%Y-%m-%d')
        logger.info(f"Processing data for {formatted_date}")
        data = fetch_data(formatted_date)
        insert_data_into_db(data)
        start_date += delta
