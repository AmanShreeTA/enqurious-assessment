from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import httpx
import os
import asyncpg
from datetime import datetime

app = FastAPI()

# Configuration from environment variables
FRAUD_SERVICE_URL = os.getenv("FRAUD_SERVICE_URL", "http://localhost:3000")
DB_HOST = os.getenv("DB_HOST", "localhost")
DB_PORT = int(os.getenv("DB_PORT", "5432"))
DB_NAME = os.getenv("DB_NAME", "transactions")
DB_USER = os.getenv("DB_USER", "postgres")
DB_PASSWORD = os.getenv("DB_PASSWORD", "password")


class Transaction(BaseModel):
    transaction_id: str
    amount: float
    currency: str
    merchant_id: str
    customer_id: str


@app.get("/health")
async def health():
    return {"status": "healthy", "service": "payment-gateway"}


@app.post("/api/process-payment")
async def process_payment(transaction: Transaction):
    try:
        # Check with fraud detection service
        async with httpx.AsyncClient() as client:
            fraud_response = await client.post(
                f"{FRAUD_SERVICE_URL}/api/check-fraud",
                json=transaction.dict(),
                timeout=5.0
            )
            fraud_data = fraud_response.json()

        if fraud_data.get("risk_score", 0) > 0.8:
            return {
                "status": "rejected",
                "reason": "High fraud risk",
                "risk_score": fraud_data.get("risk_score")
            }

        # Store transaction in database
        conn = await asyncpg.connect(
            host=DB_HOST,
            port=DB_PORT,
            database=DB_NAME,
            user=DB_USER,
            password=DB_PASSWORD
        )

        await conn.execute('''
            INSERT INTO transactions (transaction_id, amount, currency, merchant_id, customer_id, timestamp, status)
            VALUES ($1, $2, $3, $4, $5, $6, $7)
        ''', transaction.transaction_id, transaction.amount, transaction.currency,
           transaction.merchant_id, transaction.customer_id, datetime.utcnow(), "approved")

        await conn.close()

        return {
            "status": "approved",
            "transaction_id": transaction.transaction_id,
            "risk_score": fraud_data.get("risk_score")
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Processing failed: {str(e)}")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)