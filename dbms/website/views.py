from flask import Blueprint, render_template, session, flash, redirect


views = Blueprint("views", __name__)

@views.route('/')
def home():
    if 'ssn' not in session.keys():
            flash("Login to a user first", category='error')
            return redirect('/login')
    return render_template("home.html")
