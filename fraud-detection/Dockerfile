FROM python:3.11-slim

WORKDIR /app

RUN adduser --disabled-password appuser
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app.py .

USER appuser

ENV PORT=3000
EXPOSE 3000

CMD ["python", "app.py"]

