from flask import Blueprint,render_template, request, flash
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
            flash("Login is successfull")
            return render_template("home.html")
        else:
            flash("Login failed, user or password is wrong", category='error')
    return render_template("login.html")

@auth.route('/logout')
def logout():
    return "<p>Logout</p>"
@auth.route('/transaction')
def transaction():
    if request.method == 'GET':
        return render_template("transaction.html")

@auth.route('/viewTransaction', methods =['GET','POST'])
def viewTransaction():
    if request.method == 'GET':
        return render_template("viewTransaction.html")
    if request.method == 'POST':
        accountNumber = request.form.get('bankAccountNumber')
        if len(accountNumber)!=10:
            flash("Account number should be 10 characters", category='error')
        cursor.execute("SELECT * from bank_transactions where personal_account_details = %s",accountNumber)
        all_rows = cursor.fetchall()
        for i in all_rows:
            print(i)
        print(request.form)
    return render_template("viewTransaction.html")






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