import mysql.connector as db


def get_db_conn():
    username = "root"
    password = "#Prajwal2898"
    conn = db.connect(user=username, password=password, host="127.0.0.1", database="upi_system")
    return conn

conn = get_db_conn()