from flask import Blueprint,render_template, request
from .dbConnection import conn

upiTransaction = Blueprint('upiTransaction', __name__)
cursor = conn.cursor()


@upiTransaction.route('/upiTransaction', methods = ['GET', 'POST'])
def makeUpiTransaction():
    if 'ssn' not in session.keys():
            flash("Login to a user first", category='error')
            return redirect('/login')
    if request.method == 'GET':
        return render_template("upiTransaction.html")
