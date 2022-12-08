from flask import Flask
from .views import views
from .auth import auth
from .bankTransaction import banktransaction
from .upiTransaction import upiTransaction
from .userProfile import userprofile

def create_app():
    app = Flask(__name__)
    app.config['SECRET_KEY'] = 'PS'
    app.register_blueprint(views, url_prefix= "/")
    app.register_blueprint(auth, url_prefix= "/")
    app.register_blueprint(banktransaction, url_prefix= "/")
    app.register_blueprint(upiTransaction, url_prefix= "/")
    app.register_blueprint(userprofile, url_prefix= "/")
    return app

# if __name__ == 'main':
#     app = create_app()
#     app.run(debug=True)