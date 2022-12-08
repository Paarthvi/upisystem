from flask import Blueprint,render_template, request
from .dbConnection import conn

upiTransaction = Blueprint('upiTransaction', __name__)
cursor = conn.cursor()


@upiTransaction.route('/upiTransaction', methods = ['GET', 'POST'])
def makeUpiTransaction():
    if request.method == 'GET':
        return render_template("upiTransaction.html")
