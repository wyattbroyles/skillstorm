import os
import requests
from flask import Flask, request, redirect
from dotenv import load_dotenv

app = Flask(__name__)

# Your GitHub OAuth application details
load_dotenv()
github_id = os.getenv('github_id')
github_sec = os.getenv('github_sec')

# Step 1: Redirect the user to GitHub's OAuth page
@app.route('/')
def home():
    return '<a href="/login">Login with GitHub</a>'

@app.route('/login')
def login():
    return redirect(f'https://github.com/login/oauth/authorize?client_id={github_id}&scope=repo')

# Step 2: GitHub redirects back to your site with a code
@app.route('/callback')
def callback():
    code = request.args.get('code')
    # Step 3: Exchange the code for an access token
    token_url = 'https://github.com/login/oauth/access_token'
    token_data = {
        'client_id': github_id,
        'client_secret': github_sec,
        'code': code,
    }
    token_headers = {'Accept': 'application/json'}
    token_response = requests.post(token_url, data=token_data, headers=token_headers)
    token_json = token_response.json()
    access_token = token_json.get('access_token')

    if access_token:
        # Step 4: Use the access token to make API requests
        user_url = 'https://api.github.com/user'
        user_headers = {
            'Authorization': f'Bearer {access_token}',
            'Accept': 'application/json',
        }
        user_response = requests.get(user_url, headers=user_headers)
        user_json = user_response.json()
        return f'Hello, {user_json["login"]}!'
    else:
        return 'Error retrieving access token'

if __name__ == '__main__':
    app.run(debug=True, port=8000)