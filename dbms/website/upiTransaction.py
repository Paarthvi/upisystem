from flask import Blueprint,render_template, request, session, redirect, flash
from .dbConnection import conn
from datetime import date


upiTransaction = Blueprint('upiTransaction', __name__)
cursor = conn.cursor()


@upiTransaction.route('/upiTransaction', methods = ['GET', 'POST'])
def makeUpiTransaction():
    if 'ssn' not in session.keys():
            flash("Login to a user first", category='error')
            return redirect('/login')
    if request.method == 'GET':
        return render_template("upiTransaction.html")
    if request.method == 'POST':
        received_data = dict(request.form)
        print(received_data)
        if "receiverUpiId" in received_data.keys():
            performUpiTransaction(received_data)
            print("UPI Transaction")
        elif "gstNumber" in received_data.keys():
            print("Register Merchant")
            registerMerchant(received_data)
        else:
            print("Register Consumer")
            registerConsumer(received_data)
        return render_template("upiTransaction.html")

def registerConsumer(received_data):
    try:
        if received_data.get("bankAccount") == "":
            flash("Bank account cannot be empty", category='error')
            return
        if received_data.get("email") == "":
            flash("Email cannot be empty", category='error')
            return
        cursor.execute("SELECT checkIfAccountBelongsToSSN(%s, %s)", (session['ssn'], received_data.get("bankAccount")))
        all_rows = cursor.fetchall()
        if (not all_rows[0][0]):
            flash("Bank account is not valid", category='error')
            return
        cursor.callproc("registerForUPIConsumer", (session['ssn'], received_data["bankAccount"], received_data["email"]))
        flash("User registered for UPI as a Customer successfully")
    except Exception as e:
        flash(e, category='error')

def registerMerchant(received_data):
    try:
        if received_data.get("bankAccountNumber") == "":
            flash("Bank account cannot be empty", category='error')
            return
        if received_data.get("email") == "":
            flash("Email cannot be empty", category='error')
            return
        if received_data.get("gstNumber") == "":
            flash("GST Number cannot be empty", category='error')
            return
        if received_data.get("buildingNumber") == "":
            flash("Buildinng number cannot be empty", category='error')
            return
        if received_data.get("streetName") == "":
            flash("Street name cannot be empty", category='error')
            return
        if received_data.get("city") == "":
            flash("City cannot be empty", category='error')
            return
        if received_data.get("state") == "":
            flash("State cannot be empty", category='error')
            return
        if received_data.get("pin") == "":
            flash("Pin cannot be empty", category='error')
            return
        cursor.execute("SELECT checkIfAccountBelongsToSSN(%s, %s)", (session['ssn'], received_data.get("bankAccountNumber")))
        all_rows = cursor.fetchall()
        if (not all_rows[0][0]):
            flash("Bank account is not valid", category='error')
            return
        cursor.callproc("registerForUPIMerchant", (session['ssn'], received_data["bankAccountNumber"], received_data["email"],
                        received_data.get("gstNumber"), 2, received_data.get("buildingNumber"), received_data.get("streetName"),
                        received_data.get("city"), received_data.get("state"), received_data.get("pin")))
        flash("User registered for UPI as a Merchant successfully")
    except Exception as e:
        flash(e, category='error')

def performUpiTransaction(received_data):
    try:
        if received_data.get("senderUpiId") == "":
            flash("Sender email cannot be empty", category='error')
            return
        if received_data.get("receiverUpiId") == "":
            flash("Receiver email cannot be empty", category='error')
            return
        if received_data.get("transactionAmount") == "":
            flash("Email cannot be empty", category='error')
            return
        cursor.execute("SELECT checkIfEmailBelongsToSSN(%s, %s)", (session['ssn'], received_data.get("senderUpiId")))
        all_rows = cursor.fetchall()
        if (not all_rows[0][0]):
            flash("Email ID is not valid", category='error')
            return
        cursor.execute("SELECT checkIfEmailIfPresentAsUPICustomer(%s)", (received_data.get("senderUpiId"),))
        all_rows = cursor.fetchall()
        if (not all_rows[0][0]):
            flash("Sender email ID is not registered on UPI", category='error')
            return
        cursor.execute("SELECT checkIfEmailIfPresentAsUPICustomer(%s)", (received_data.get("receiverUpiId"),))
        all_rows = cursor.fetchall()
        if (not all_rows[0][0]):
            flash("Receiver email ID is not registered on UPI", category='error')
            return
        todays_date = str(date.today())
        cursor.callproc("makeUpiTransaction", (received_data["senderUpiId"], received_data["receiverUpiId"], received_data['transactionAmount'], todays_date))
        flash("Successfullt sent $" + str(received_data['transactionAmount']) + " from " + str(received_data["senderUpiId"]) + " to " + str(received_data["receiverUpiId"]))
    except Exception as e:
        flash(e, category='error')