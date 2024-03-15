import time

from flask import Flask, jsonify

app = Flask(__name__)

# well, it takes a long time to start
time.sleep(10)

@app.route("/")
def hello_world():
    return jsonify({"version": "1.0.0"})
