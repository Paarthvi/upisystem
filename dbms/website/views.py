from flask import Blueprint, render_template, session, flash, redirect
from .dbConnection import conn

views = Blueprint("views", __name__)
cursor = conn.cursor()

@views.route('/')
def home():
    if 'ssn' not in session.keys():
            flash("Login to a user first", category='error')
            return redirect('/login')
    cursor.execute("SELECT count(*) from bank_transactions where transaction_message = 'Bank to Bank transaction';")
    bank_output = cursor.fetchall()
    cursor.execute("SELECT count(*) from upi_transaction;")
    upi_output = cursor.fetchall()
    cursor.execute("SELECT COUNT(*) from personal_transaction")
    personal_output = cursor.fetchall()
    cursor.execute("SELECT COUNT(*) from commercial_transaction")
    commercial_output = cursor.fetchall()
#     return render_template("home.html", bank_transactions = bank_output[0][0]/2, upi_transactions = upi_output[0][0])
    return render_template("home.html", bank_transactions = bank_output[0][0]/2, upi_transactions = upi_output[0][0],
                           personal_transaction = personal_output[0][0], commercial_transaction=commercial_output[0][0])