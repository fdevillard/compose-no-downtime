FROM python:3.12

COPY ./requirements.txt .
RUN pip install -r requirements.txt

COPY . .

HEALTHCHECK --interval=5s --timeout=3s \
  CMD curl -f http://localhost:8080/ || exit 1

ENTRYPOINT ["flask", "--app", "main", "run", "--host", "0.0.0.0", "--port", "8080"]