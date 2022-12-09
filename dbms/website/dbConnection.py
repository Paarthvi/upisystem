import mysql.connector as db
import os


def get_db_conn():
    with open(os.getcwd() + "/config.txt", 'r') as fhand:
        text = fhand.read().split("\n")
        username = text[0]
        password = text[1]
    conn = db.connect(user=username, password=password, host="127.0.0.1", database="upi_system")
    return conn

conn = get_db_conn()