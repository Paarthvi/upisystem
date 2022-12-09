from flask import Blueprint,render_template, request, flash, session, redirect
from .dbConnection import conn

userprofile = Blueprint('userProfile', __name__)
cursor = conn.cursor()

@userprofile.route('/userProfile', methods = ['GET', 'POST'])
def viewUserProfile():
    if 'ssn' not in session.keys():
            flash("Login to a user first", category='error')
            return redirect('/login')
    if request.method == 'GET':
        return render_template("userProfile.html",
                               firstName=session['first_name'],
                               lastName=session['last_name'],
                               ssn=session['ssn'],
                               houseNumber=session['house_number'],
                               streetName=session['street_name'],
                               city=session['city'],
                               state=session['state'],
                               pin=session['pin']
                               )

@userprofile.route('/accountDetails', methods = ['GET'])
def bankDetails():
    if 'ssn' not in session.keys():
            flash("Login to a user first", category='error')
            return redirect('/login')
    ssn = session['ssn']
    cursor.callproc("viewAccountDetails", (ssn,))
    # cursor.execute("SELECT bank_name, branch.branch_id, account_number, balance,"
    #                " branch.building_number, branch.street_name, branch.city, "
    #                "branch.pin FROM bank_account "
    #                "JOIN branch ON  bank_account.branch_id = branch.branch_id "
    #                "JOIN bank ON bank.bank_reg_id = branch.bank_reg_id where ssn =  %s;",(ssn,))
    # all_rows = cursor.fetchall()
    for result in cursor.stored_results():
        all_rows=result.fetchall()
    table = """<table>
                <tr>
                    <th>Bank Name</th>
                    <th>Branch ID</th>
                    <th>Bank Account</th>
                    <th>Balance</th>
                    <th>Building Number</th>
                    <th>Street Name</th>
                    <th>City</th>
                    <th>Pin</th>
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
    return table
