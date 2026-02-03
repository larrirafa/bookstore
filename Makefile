# =========================
# Project config
# =========================

# Set this to use it everywhere in the project setup
PYTHON_VERSION ?= 3.8.10

# the directories containing the library modules this repo builds
LIBRARY_DIRS = mylibrary

# build artifacts organized in this Makefile
BUILD_DIR ?= build

# Service name in docker compose (ajuste se no seu docker-compose.yml for diferente)
DOCKER_SERVICE ?= web

# PyTest options
PYTEST_HTML_OPTIONS = --html=$(BUILD_DIR)/report.html --self-contained-html
PYTEST_TAP_OPTIONS = --tap-combined --tap-outdir $(BUILD_DIR)
PYTEST_COVERAGE_OPTIONS = --cov=$(LIBRARY_DIRS)
PYTEST_OPTIONS ?= $(PYTEST_HTML_OPTIONS) $(PYTEST_TAP_OPTIONS) $(PYTEST_COVERAGE_OPTIONS)

# MyPy typechecking options
MYPY_OPTS ?= --python-version $(basename $(PYTHON_VERSION)) --show-column-numbers --pretty --html-report $(BUILD_DIR)/mypy

# Tools
PIP ?= pip3
POETRY_OPTS ?=
POETRY ?= poetry $(POETRY_OPTS)
RUN_PYPKG_BIN = $(POETRY) run

COLOR_ORANGE = \033[33m]
COLOR_RESET = \033[0m]


##@ Utility

.PHONY: help
help:  ## Display this help
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z0-9_-]+:.*?##/ { printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

.PHONY: version-python
version-python: ## Echos the version of Python in use
	@echo $(PYTHON_VERSION)


##@ Testing (Local via Poetry)

.PHONY: test
test: ## Runs tests (local, via poetry)
	$(RUN_PYPKG_BIN) pytest \
		$(PYTEST_OPTIONS) \
		tests/*.py


##@ Building and Publishing (Local via Poetry)

.PHONY: build
build: ## Runs a build (local, via poetry)
	$(POETRY) build

.PHONY: publish
publish: ## Publish a build to the configured repo
	$(POETRY) publish $(POETRY_PUBLISH_OPTIONS_SET_BY_CI_ENV)

.PHONY: deps-py-update
deps-py-update: pyproject.toml ## Update Poetry deps, e.g. after adding a new one manually
	$(POETRY) update


##@ Setup (Local)

.PHONY: deps
deps: deps-py ## Installs all dependencies (local)

.PHONY: deps-py
deps-py: ## Installs Python dev/runtime deps (local) WITHOUT pyenv
	$(PIP) install --upgrade pip setuptools wheel
	@echo "$(COLOR_ORANGE)Se seu Python for antigo (ex.: 3.6), use poetry==1.2.2. Se for 3.8+, pode usar poetry mais novo.$(COLOR_RESET)"
	$(PIP) install --upgrade poetry
	$(POETRY) install

.PHONY: pyenv-setup
pyenv-setup: ## (Optional) Install Python via pyenv and set local version
	@if command -v pyenv >/dev/null 2>&1; then \
		pyenv install --skip-existing $(PYTHON_VERSION); \
		pyenv local $(PYTHON_VERSION); \
	else \
		echo "pyenv nao instalado; pulando pyenv-setup"; \
	fi


##@ Code Quality (Local via Poetry)

.PHONY: check
check: check-py ## Runs linters and other important tools (local)

.PHONY: check-py
check-py: check-py-flake8 check-py-black check-py-mypy ## Checks only Python files (local)

.PHONY: check-py-flake8
check-py-flake8: ## Runs flake8 linter (local)
	$(RUN_PYPKG_BIN) flake8 .

.PHONY: check-py-black
check-py-black: ## Runs black in check mode (no changes) (local)
	$(RUN_PYPKG_BIN) black --check --line-length 118 --fast .

.PHONY: check-py-mypy
check-py-mypy: ## Runs mypy (local)
	$(RUN_PYPKG_BIN) mypy $(MYPY_OPTS) $(LIBRARY_DIRS)

.PHONY: format-py
format-py: ## Runs black, makes changes where necessary (local)
	$(RUN_PYPKG_BIN) black .

.PHONY: format-autopep8
format-autopep8: ## Runs autopep8 (local)
	$(RUN_PYPKG_BIN) autopep8 --in-place --recursive .

.PHONY: format-isort
format-isort: ## Runs isort (local)
	$(RUN_PYPKG_BIN) isort --recursive .


##@ Docker (Recommended)

.PHONY: docker-build
docker-build: ## Build images using docker compose
	docker compose build

.PHONY: docker-up
docker-up: ## Start containers in background
	docker compose up -d

.PHONY: docker-down
docker-down: ## Stop and remove containers
	docker compose down

.PHONY: docker-logs
docker-logs: ## Follow logs for the main service
	docker compose logs -f $(DOCKER_SERVICE)

.PHONY: docker-shell
docker-shell: ## Open a shell inside the main service container
	docker compose exec $(DOCKER_SERVICE) sh

.PHONY: docker-test
docker-test: ## Run tests inside container
	docker compose exec $(DOCKER_SERVICE) pytest $(PYTEST_OPTIONS) tests/*.py

.PHONY: docker-check
docker-check: ## Run linters/typecheck inside container
	docker compose exec $(DOCKER_SERVICE) flake8 .
	docker compose exec $(DOCKER_SERVICE) black --check --line-length 118 --fast .
	docker compose exec $(DOCKER_SERVICE) mypy $(MYPY_OPTS) $(LIBRARY_DIRS)

.PHONY: migrate
migrate: ## Django migrate inside container
	docker compose exec $(DOCKER_SERVICE) python manage.py migrate --noinput

.PHONY: seed
seed: ## Django seed inside container
	docker compose exec $(DOCKER_SERVICE) python manage.py seedmake