from flask import Blueprint,render_template, request, flash
from .dbConnection import conn

banktransaction = Blueprint('banktransaction', __name__)
cursor = conn.cursor()


@banktransaction.route('/bankTransaction', methods = ['GET', 'POST'])
def bankTransaction():
    if request.method == 'GET':
        return render_template("bankTransaction.html")
    if request.method == 'POST':
        received_data = dict(request.form)
        if ("senderAccountNumber" in received_data.keys()):
            print("making transaction")
        elif ("bankName" in received_data.keys()):
            print("creating bank account")
        return render_template("bankTransaction.html")