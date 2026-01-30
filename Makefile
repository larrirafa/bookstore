    $(RUN_PYPKG_BIN) isort --recursive .

.PHONY: migrate
migrate:
        docker-compose exec web python manage.py migrate --noinput

.PHONY: seed
seed:
        poetry r

