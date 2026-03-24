release: python manage.py migrate && python manage.py collectstatic --noinput
web: gunicorn bookstore.wsgi:application