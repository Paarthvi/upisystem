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

@banktransaction.route('/bankDetails', methods = ['GET'])
def bankDetails():
    cursor.execute("SELECT bank_name, branch_id, branch.pin FROM bank JOIN branch ON bank.bank_reg_id = branch.bank_reg_id;")
    all_rows = cursor.fetchall()
    table = """<table>
                <tr>
                    <th>Bank Name</th>
                    <th>Braanch ID</th>
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