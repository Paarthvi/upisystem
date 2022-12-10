from flask import Blueprint,render_template, request, flash, session, redirect
from .dbConnection import conn
from datetime import date

banktransaction = Blueprint('banktransaction', __name__)
cursor = conn.cursor()


@banktransaction.route('/bankTransaction', methods = ['GET', 'POST'])
def bankTransaction():
    if 'ssn' not in session.keys():
            flash("Login to a user first", category='error')
            return redirect('/login')
    if request.method == 'GET':
        return render_template("bankTransaction.html")
    if request.method == 'POST':
        received_data = dict(request.form)
        print(received_data)
        if ("senderAccountNumber" in received_data.keys()):
            print("making transaction")
            flash(makeBankTransaction(received_data))
        elif ("bankName" in received_data.keys()):
            print("Create bank account")
            createBankAccount(received_data)
        return render_template("bankTransaction.html")

def createBankAccount(received_data):
    try:
        todays_date = str(date.today())
        cursor.execute("SELECT * FROM bank_account WHERE branch_id = %s ORDER BY account_number DESC LIMIT 1;", (received_data['bankBranchId'],))
        fetchedRows = cursor.fetchall()
        if (len(fetchedRows) != 0):
            next_bank_account = str(int(fetchedRows[0][2]) + 1)
        else:
            next_bank_account = '0000000001'
        next_bank_account = (10-len(next_bank_account)) * '0' + next_bank_account
        cursor.callproc("createBankAccount", (session['ssn'], received_data['bankBranchId'], next_bank_account, received_data["initialDepositAmount"], todays_date))
        flash("Successfully created back account: " + next_bank_account)
    except Exception as e:
        flash(str(e), category='error')

def makeBankTransaction(received_data):
    try:
        todays_date = str(date.today())
        cursor.execute("SELECT checkIfAccountBelongsToSSN(%s, %s)", (session['ssn'], received_data['senderAccountNumber']))
        all_rows = cursor.fetchall()
        if (not all_rows[0][0]):
            flash("Bank account is not valid", category='error')
            return
        cursor.callproc('bankTransaction', (received_data['senderAccountNumber'], received_data['receiverAccountNumber'], received_data['transactionAmount'], todays_date, "Bank to Bank transaction"))
        return "Successfully transferred $" + received_data['transactionAmount']
    except Exception as e:
        str(e)


@banktransaction.route('/bankDetails', methods = ['GET'])
def bankDetails():
    if 'ssn' not in session.keys():
            flash("Login to a user first", category='error')
            return redirect('/login')
    cursor.execute("SELECT bank_name, branch_id, branch.pin FROM bank JOIN branch ON bank.bank_reg_id = branch.bank_reg_id;")
    all_rows = cursor.fetchall()
    table = """<table>
                <tr>
                    <th>Bank Name</th>
                    <th>Branch ID</th>
                    <th>PIN</th>
                </tr>\n"""
    for i in all_rows:
        table += f"""<tr>
                    <td>{i[0]}</td>
                    <td>{i[1]}</td>
                    <td>{i[2]}</td>
                </tr>\n"""
    table += "</table>"
    return table