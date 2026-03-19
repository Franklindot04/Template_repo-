FROM python:3.11-slim

ENV PYTHONUNBUFFERED=1

WORKDIR /app

COPY app.py .

RUN pip install fastapi uvicorn

EXPOSE 80

CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "80"]
