"""Pruebas de la API de Trámites con SQLite temporal (no requieren Docker).

    pip install -r app/requirements.txt pytest
    pytest -q
"""
import importlib
import os
import sys
from datetime import date, timedelta

import pytest

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "app"))


@pytest.fixture()
def cliente(tmp_path, monkeypatch):
    monkeypatch.delenv("DB_HOST", raising=False)
    monkeypatch.setenv("DATA_DIR", str(tmp_path))
    monkeypatch.setenv("APP_VERSION", "test")
    import app as modulo

    modulo = importlib.reload(modulo)
    return modulo.app.test_client()


def test_salud_informa_version(cliente):
    r = cliente.get("/salud")
    assert r.status_code == 200
    assert r.get_json()["version"] == "test"


def test_listo_con_base_disponible(cliente):
    assert cliente.get("/listo").status_code == 200


def test_radicar_y_consultar(cliente):
    r = cliente.post("/solicitudes", json={"ciudadano": "Ana", "fecha_documento": date.today().isoformat()})
    assert r.status_code == 201
    sid = r.get_json()["id"]
    assert cliente.get(f"/solicitudes/{sid}").get_json()["estado"] == "RADICADA"


def test_documento_vencido_se_rechaza(cliente):
    viejo = (date.today() - timedelta(days=91)).isoformat()
    r = cliente.post("/solicitudes", json={"ciudadano": "Ana", "fecha_documento": viejo})
    assert r.status_code == 422


def test_ciudadano_obligatorio(cliente):
    r = cliente.post("/solicitudes", json={"fecha_documento": date.today().isoformat()})
    assert r.status_code == 400
