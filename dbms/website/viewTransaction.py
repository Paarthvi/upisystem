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
        accountNumber = request.form.get('bankAccountNumber')
        emailID = request.form.get('email')
        if len(accountNumber)!=10:
            flash("Account number should be 10 characters", category='error')
        cursor.callproc("viewTransaction", (accountNumber,))
        for result in cursor.stored_results():
            all_rows = result.fetchall()
        table = """<table>
                <tr>
                    <th>Bank Transaction ID</th>
                    <th>Transaction Type</th>
                    <th>Personal Account</th>
                    <th>Sender/Receiver Account</th>
                    <th>Transaction Date</th>
                    <th>Transaction Value</th>
                    <th>Transaction Message</th>
                </tr>\n"""
        for i in all_rows:
            table += f"""<tr>
                    <td>{i[0]}</td>
                    <td>{i[1]}</td>
                    <td>{i[2]}</td>
                    <td>{i[3]}</td>
                    <td>{i[4]}</td>
                    <td>{i[5]}</td>
                    <td>{i[6]}</td>
                </tr>\n"""
        table += "</table>"
        # return table
        return render_template("displayTransactions.html", length=len(all_rows), table_list=all_rows)

@viewtransactions.route('/viewTransaction', methods =['GET','POST'])
def viewUPItransactions():
    if request.method == 'POST':
        emailID = request.form.get('email')
        cursor.callproc("viewUPITransaction", (emailID,))
        for result in cursor.stored_results():
            all_rows = result.fetchall()
        table = """<table>
                <tr>
                    <th>UPI Transaction ID</th>
                    <th>Balance </th>
                    <th>Bank Transaction ID</th>
                    <th>Transaction Type</th>
                    <th>Personal Account</th>
                    <th>Sender/Receiver Account</th>
                    <th>Transaction Date</th>
                    <th>Transaction Value</th>
                </tr>\n"""
        for i in all_rows:
            table += f"""<tr>
                    <td>{i[0]}</td>
                    <td>{i[1]}</td>
                    <td>{i[2]}</td>
                    <td>{i[3]}</td>
                    <td>{i[4]}</td>
                    <td>{i[5]}</td>
                    <td>{i[6]}</td>
                    <td>{i[7]}</td>
                </tr>\n"""
        table += "</table>"
        # return table
        return render_template("displayUPITransactions.html", length=len(all_rows), table_list=all_rows)
#
# @viewtransactions.route('/transactionDetails',methods = ['GET'])
# def transactionDetails():
#     # if request.method == 'GET':
#     #     return render_template("viewTransaction.html")
#     if request.method == 'POST':
#
#         accountNumber = request.form.get('bankAccountNumber')
#         if len(accountNumber)!=10:
#             flash("Account number should be 10 characters", category='error')
#         cursor.execute("SELECT * from bank_transactions where personal_account_details = %s",(accountNumber,))
#         all_rows = cursor.fetchall()
#         table = """<table>
#                 <tr>
#                     <th>Bank Transaction ID</th>
#                     <th>Transaction Type</th>
#                     <th>Personal Account</th>
#                     <th>Sender/Receiver Account</th>
#                     <th>Transaction Date</th>
#                     <th>Transaction Value</th>
#                     <th>Transaction Message</th>
#                 </tr>\n"""
#         for i in all_rows:
#             table += f"""<tr>
#                     <td>{i[0]}</td>
#                     <td>{i[1]}</td>
#                     <td>{i[2]}</td>
#                     <td>{i[3]}</td>
#                     <td>{i[4]}</td>
#                     <td>{i[5]}</td>
#                     <td>{i[6]}</td>
#                 </tr>\n"""
#         table += "</table>"
#         return redirect('transactionDetails')