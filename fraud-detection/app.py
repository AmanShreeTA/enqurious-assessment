from flask import Flask, request, jsonify
import random
import os

app = Flask(__name__)

PORT = int(os.getenv("PORT", "3000"))


def calculate_risk_score(transaction):
    """Simple fraud detection logic"""
    risk_score = 0.0

    # High amount increases risk
    if transaction.get("amount", 0) > 10000:
        risk_score += 0.3
    if transaction.get("amount", 0) > 50000:
        risk_score += 0.3

    # Random factor to simulate ML model
    risk_score += random.random() * 0.4

    return min(risk_score, 1.0)


@app.route('/health', methods=['GET'])
def health():
    return jsonify({
        "status": "healthy",
        "service": "fraud-detection"
    })


@app.route('/api/check-fraud', methods=['POST'])
def check_fraud():
    try:
        transaction = request.get_json()
        risk_score = calculate_risk_score(transaction)

        transaction_id = transaction.get("transaction_id", "unknown")
        print(f"Fraud check for transaction {transaction_id}: Risk Score = {risk_score}")

        return jsonify({
            "transaction_id": transaction_id,
            "risk_score": risk_score,
            "recommendation": "reject" if risk_score > 0.8 else "approve"
        })
    except Exception as e:
        return jsonify({
            "error": "Fraud detection failed",
            "message": str(e)
        }), 500


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=PORT)
