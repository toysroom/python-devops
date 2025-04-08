import os
from flask import Flask, jsonify

app = Flask(__name__)

@app.route("/", methods=["GET"])
def home():
    return jsonify({"message": "API di test funzionante con terraform!"})

if __name__ == "__main__":
    port = int(os.environ.get('PORT', 4000))
    app.run(host='0.0.0.0', port=port, debug=True)
