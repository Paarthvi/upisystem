from flask import Blueprint,render_template, request, flash, redirect, session
from .dbConnection import conn
import hashlib

auth = Blueprint('auth', __name__)
cursor = conn.cursor()

@auth.route('/login', methods =['GET','POST'])
def login():
    if request.method == 'POST':
        phoneNumber = request.form.get('phoneNumber')
        password = request.form.get('password1')
        cursor.execute("SELECT verifyPassword(%s, %s)", (phoneNumber, password))
        all_rows = cursor.fetchall()
        if (all_rows[0][0] == 1):
            cursor.execute("SELECT * FROM individual WHERE phone_number = %s;", (phoneNumber,))
            fetchedRows = cursor.fetchall()
            print(fetchedRows)
            session["loggedin"] = True
            session["ssn"] = fetchedRows[0][0]
            session["first_name"] = fetchedRows[0][1]
            session["last_name"] = fetchedRows[0][2]
            session["house_number"] = fetchedRows[0][3]
            session["street_name"] = fetchedRows[0][4]
            session["city"] = fetchedRows[0][5]
            session["state"] = fetchedRows[0][6]
            session["pin"] = fetchedRows[0][7]
            session["phone_number"] = fetchedRows[0][8]
            flash("Login is successfull")
            # return render_template("transaction.html")
            return redirect("/transaction")
        else:
            flash("Login failed, user or password is wrong", category='error')
    return render_template("login.html")

@auth.route('/logout')
def logout():
    session.pop("loggedin", None)
    session.pop("ssn", None)
    session.pop("first_name", None)
    session.pop("last_name", None)
    session.pop("house_number", None)
    session.pop("street_name", None)
    session.pop("city", None)
    session.pop("state", None)
    session.pop("pin", None)
    session.pop("phone_number", None)
    flash("Logged out")
    return redirect("/login")

@auth.route('/transaction')
def transaction():
    if 'ssn' not in session.keys():
            flash("Login to a user first", category='error')
            return redirect('/login')
    if request.method == 'GET':
        return render_template("transaction.html")

# @auth.route('/viewTransaction', methods =['GET','POST'])
# def viewTransaction():
#     # if request.method == 'GET':
#     #     return render_template("viewTransaction.html")
#     if request.method == 'POST':
#         accountNumber = request.form.get('bankAccountNumber')
#         if len(accountNumber)!=10:
#             flash("Account number should be 10 characters", category='error')
#         cursor.execute("SELECT * from bank_transactions where personal_account_details = %s",(accountNumber,))
#         all_rows = cursor.fetchall()
#         for i in all_rows:
#             print(i)
#         print(request.form)
#     return render_template("viewTransaction.html")

@auth.route('/sign-up', methods =['GET','POST'])
def sign_up():
    if request.method == 'POST':
        ssn = request.form.get('SSN')
        firstName = request.form.get('firstName')
        lastName = request.form.get('lastName')
        houseNumber = request.form.get('houseNumber')
        streetName = request.form.get('streetName')
        city = request.form.get('city')
        state = request.form.get('state')
        pinCode = request.form.get('pin')
        phoneNumber = request.form.get('phoneNumber')
        password1 = request.form.get('password1')
        password2 = request.form.get('password2')
        print(request.form)
        faced_error = False
        for i in request.form.items():
            if len(i[1]) == 0:
                flash("All fields are mandatory. Please try again", category='error')
        if len(ssn) != 8:
            flash("Invalid SSN. SSN should be 8 characters long", category='error')
            faced_error = True
        elif len(houseNumber) > 5:
            flash("House number should be less than 6 characters", category='error')
            faced_error = True
        elif len(pinCode) != 5:
            flash("PIN code is invalid, it has to be 5 digit", category='error')
            faced_error = True
        elif len(phoneNumber)!=10:
            flash("Invalid phone number. Phone number must be equal to 10 characters!", category='error')
            faced_error = True
        elif password1 != password2:
            flash("Passwords do not match. Please try again!", category='error')
            faced_error = True
        elif len(firstName) < 2:
            flash("Invalid first name. First name needs to be at least 2 characters!", category='error')
            faced_error = True
        elif len(lastName) < 2:
            flash("Invalid first name. First name needs to be at least 2 characters!", category='error')
            faced_error = True
        if not faced_error:
            flash("Account Created", category='success')
            args = (ssn, firstName, lastName, houseNumber, streetName, city, state, pinCode, phoneNumber, password1)
            cursor.callproc("addIndividual", args)
            return render_template("home.html")
    return render_template("sign_up.html")