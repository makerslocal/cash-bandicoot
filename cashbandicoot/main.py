from flask import Flask, jsonify, request, abort
import json
import psycopg2, psycopg2.extras
from functools import wraps

app = Flask(__name__)

with open('config.json', 'r') as f:
    config = json.loads(f.read())

db = psycopg2.connect(host=config['database']['host'], database=config['database']['name'], user=config['database']['role'], password=config['database']['password'], cursor_factory=psycopg2.extras.RealDictCursor)


def require_token(fn):
    @wraps(fn)
    def wrapper(*args, **kwargs):
        token = request.args.get('token', default=None)
        if token == None or get_service(token) == None:
            abort(403)
        return fn(*args, **kwargs)
    return wrapper

def get_service(token):
    with db.cursor() as cur:
        cur.execute('''
            select id, name
            from service
            where crypt(%s, hash) = hash
        ''', [token])
        try:
            return cur.fetchone()
        except TypeError:
            return None


@app.route("/users")
@require_token
def get_users():
    with db.cursor() as cur:
        cur.execute('''
            select username, balance
            from person
        ''')
        return jsonify(cur.fetchall())

@app.route("/user")
@app.route("/user/<username>")
@require_token
def get_user(username=None):
    if username is None:
        raise NotImplementedError("This is where we would use request.args to search LDAP, matching the arbitrary filter you provide in order to find the username, then we would return get_user(username=that_user).")
    else:
        with db.cursor() as cur:
            cur.execute('''
                select username, balance
                from person
                where username = %s
            ''', [username])
            return jsonify(cur.fetchone())

@app.route("/transaction", methods=["POST"])
@require_token
def add_transaction():
    username = request.form['username']
    amount = float(request.form['amount'])

    with db.cursor() as cur:
        #In psycopg2, "with" clauses like this will automatically BEGIN TRANSACTION.

        #First, try to make a new user, with the amount as their starting balance.
        #If there is a conflict, we take the number we just TRIED to use as their starting balance,
        #and instead, we add it to their existing balance, and update their row with that.
        cur.execute('''
            insert into person(username, balance)
            values(%s, %s)
            on conflict(username) do
            update set balance = person.balance + EXCLUDED.balance
        ''', [username, amount])

        #Now we insert the transaction row.
        cur.execute('''
            insert into transaction(service_id, person_id, amount)
            values(
                1,
                (select id from person where username = 'hfuller'),
                0.50
            )
        ''', [username])

        #Now we're done.
        db.commit()
    
    return get_user(username=username)
