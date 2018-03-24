from flask import Flask, jsonify, request
import json
import psycopg2, psycopg2.extras

app = Flask(__name__)

with open('config.json', 'r') as f:
    config = json.loads(f.read())

db = psycopg2.connect(host=config['database']['host'], database=config['database']['name'], user=config['database']['role'], password=config['database']['password'], cursor_factory=psycopg2.extras.RealDictCursor)

users = {
    1: {
        "uid": "1322541",
        "realname": "Tyler Crumpton",
        "username": "tylercrumpton",
        "balance": 1350,
    },
}


@app.route("/users")
def get_users():
    with db.cursor() as cur:
        cur.execute('''
            select username, balance
            from person
        ''')
        return jsonify(cur.fetchall())


@app.route("/users", methods=['POST'])
def add_user():
    user = {
        "uid": "8885412",
        "realname": "Tayler Crompton",
        "username": request.form['username'],
        "balance": 0,
    }
    users[2] = user

    return jsonify(user)
