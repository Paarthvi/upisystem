from flask import Blueprint,render_template, request, flash

auth = Blueprint('auth', __name__)

@auth.route('/login', methods =['GET','POST'])
def login():
    return render_template("login.html")

@auth.route('/logout')
def logout():
    return "<p>Logout</p>"

@auth.route('/sign-up', methods =['GET','POST'])
def sign_up():
    if request.method == 'POST':
        phoneNumber = request.form.get('phoneNumber')
        firstName = request.form.get('firstName')
        password1 = request.form.get('password1')
        password2 = request.form.get('password2')
        if len(phoneNumber)!=10:
            flash("Invalid phone number. Phone number must be equal to 10 characters!", category='error')
        elif password1 != password2:
            flash("Passwords do not match. Please try again!", category='error')
        elif len(firstName) < 2:
            flash("Invalid first name. First name needs to be at least 2 characters!", category='error')
        else:
            flash("Account Created", category='success')


    return render_template("sign_up.html")