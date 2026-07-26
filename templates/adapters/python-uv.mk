# name: python-uv
# desc: Python + uv + Ruff（格式/lint 一体）+ mypy + pytest
# needs: uv

SETUP     := uv sync --frozen
DEV       := uv run python -m app
FMT       := uv run ruff format .
FMT_CHECK := uv run ruff format --check .
LINT      := uv run ruff check .
TYPECHECK := uv run mypy src
TEST      := uv run pytest
BUILD     := uv build
SHIP      :=
