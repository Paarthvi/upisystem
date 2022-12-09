from flask import Blueprint,render_template, request, flash, session, redirect
from .dbConnection import conn

viewtransactions = Blueprint('viewTransaction', __name__)
cursor = conn.cursor()

@viewtransactions.route('/viewTransaction', methods =['GET','POST'])
def viewDetails():
    if 'ssn' not in session.keys():
        flash("Login to a user first", category='error')
        return redirect('/login')
    if request.method == 'GET':
        return render_template("viewTransaction.html",
                               firstName=session['first_name'],
                               lastName=session['last_name'],
                               ssn=session['ssn'],)
    if request.method == 'POST':
        received_data = dict(request.form)
        if "bankAccountNumber" in received_data.keys():
            return viewBankTransactions(received_data)
        if "email" in received_data.keys():
            return viewUPItransactions(received_data)
        else:
            flash("Invalid input", category='error')
            return render_template("viewTransaction.html",
                                    firstName=session['first_name'],
                                    lastName=session['last_name'],
                                    ssn=session['ssn'],)


def viewBankTransactions(received_data):
    accountNumber = received_data.get('bankAccountNumber')
    cursor.execute("SELECT checkIfAccountBelongsToSSN(%s, %s)", (session['ssn'], accountNumber))
    all_rows = cursor.fetchall()
    if len(accountNumber)!=10 or not all_rows[0][0]:
        if len(accountNumber)!=10:
            flash("Account number should be 10 characters", category='error')
        if not all_rows[0][0]:
            flash("Bank account is not valid", category='error')
        return render_template("viewTransaction.html",
                               firstName=session['first_name'],
                               lastName=session['last_name'],
                               ssn=session['ssn'],)
    cursor.callproc("viewTransaction", (accountNumber,))
    for result in cursor.stored_results():
        all_rows = result.fetchall()
    return render_template("displayTransactions.html", length=len(all_rows), table_list=all_rows)

def viewUPItransactions(received_data):
    emailID = received_data.get('email')
    cursor.execute("SELECT checkIfEmailBelongsToSSN(%s, %s)", (session['ssn'], emailID))
    all_rows = cursor.fetchall()
    if (not all_rows[0][0]):
        flash("Email ID is not valid", category='error')
        return render_template("viewTransaction.html",
                               firstName=session['first_name'],
                               lastName=session['last_name'],
                               ssn=session['ssn'],)
    cursor.callproc("viewUPITransaction", (emailID,))
    for result in cursor.stored_results():
        all_rows = result.fetchall()
    print(all_rows)
    return render_template("displayUPITransactions.html", length=len(all_rows), table_list=all_rows)
