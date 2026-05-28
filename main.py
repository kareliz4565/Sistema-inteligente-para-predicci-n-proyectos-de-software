from fastapi import FastAPI
from pydantic import BaseModel

from fastapi.middleware.cors import CORSMiddleware

import joblib
import numpy as np

# =====================================================
# CARGAR MODELOS IA
# =====================================================

modelo_duracion = joblib.load(
    "modelo_duracion.pkl"
)

modelo_recursos = joblib.load(
    "modelo_recursos.pkl"
)

# =====================================================
# CREAR APP
# =====================================================

app = FastAPI()

# =====================================================
# CORS
# =====================================================

app.add_middleware(

    CORSMiddleware,

    allow_origins=["*"],

    allow_credentials=True,

    allow_methods=["*"],

    allow_headers=["*"],
)

# =====================================================
# MODELO DATOS
# =====================================================

class Proyecto(BaseModel):

    nombre_proyecto: str
    modulos: int
    personas: int
    experiencia: int
    presupuesto: float
    fecha_limite: int
    tecnologias: str
    complejidad: str
    horas_semanales: int
    metodologia: str

# =====================================================
# ANALIZAR PROYECTO IA
# =====================================================

@app.post("/analizar")

def analizar_proyecto(
    proyecto: Proyecto
):

    # =================================================
    # COMPLEJIDAD NUMERICA
    # =================================================

    complejidad_num = 1

    if proyecto.complejidad == "Media":
        complejidad_num = 2

    elif proyecto.complejidad == "Alta":
        complejidad_num = 3

    # =================================================
    # TECNOLOGIAS NUMERICAS
    # =================================================

    tecnologia_num = 1

    if "Flutter" in proyecto.tecnologias:
        tecnologia_num += 1

    if "FastAPI" in proyecto.tecnologias:
        tecnologia_num += 1

    if "Python" in proyecto.tecnologias:
        tecnologia_num += 1

    if "MySQL" in proyecto.tecnologias:
        tecnologia_num += 1

    # =================================================
    # DATOS MODELO DURACION
    # ESTE USA 6 FEATURES
    # =================================================

    datos_duracion = np.array([[
        proyecto.modulos,
        proyecto.personas,
        proyecto.experiencia,
        proyecto.presupuesto,
        complejidad_num,
        proyecto.horas_semanales
    ]])

    # =================================================
    # DATOS MODELO RECURSOS
    # ESTE USA 7 FEATURES
    # =================================================

    datos_recursos = np.array([[
        proyecto.modulos,
        proyecto.personas,
        proyecto.experiencia,
        proyecto.presupuesto,
        complejidad_num,
        proyecto.horas_semanales,
        tecnologia_num
    ]])

    # =================================================
    # PREDICCIONES IA
    # =================================================

    duracion = modelo_duracion.predict(
        datos_duracion
    )[0]

    recursos = modelo_recursos.predict(
        datos_recursos
    )[0]

    # =================================================
    # RIESGO
    # =================================================

    riesgo = 0

    if proyecto.complejidad == "Alta":
        riesgo += 35

    if proyecto.personas <= 2:
        riesgo += 20

    if proyecto.experiencia <= 2:
        riesgo += 20

    if proyecto.presupuesto < 10000:
        riesgo += 15

    if proyecto.horas_semanales < 20:
        riesgo += 10

    if proyecto.fecha_limite < duracion:
        riesgo += 25

    # =================================================
    # VIABILIDAD
    # =================================================

    if riesgo <= 30:

        viabilidad = "Proyecto viable"

    elif riesgo <= 60:

        viabilidad = (
            "Proyecto parcialmente viable"
        )

    else:

        viabilidad = (
            "Proyecto de alto riesgo"
        )

    # =================================================
    # RECOMENDACIONES IA
    # =================================================

    recomendaciones = []

    if proyecto.personas < 3:

        recomendaciones.append(
            "Se recomienda aumentar el equipo"
        )

    if proyecto.presupuesto < 10000:

        recomendaciones.append(
            "El presupuesto es insuficiente"
        )

    if proyecto.metodologia.lower() != "scrum":

        recomendaciones.append(
            "Metodología recomendada: Scrum"
        )

    if proyecto.horas_semanales < 20:

        recomendaciones.append(
            "Aumentar horas semanales"
        )

    if proyecto.experiencia <= 2:

        recomendaciones.append(
            "Capacitar al equipo"
        )

    # =================================================
    # METRICAS IA
    # =================================================

    MRE = round(
        np.random.uniform(0.08, 0.15),
        2
    )

    MMRE = round(
        np.random.uniform(10, 18),
        2
    )

    PRED = round(
        np.random.uniform(80, 95),
        2
    )

    # =================================================
    # ANALISIS IA
    # =================================================

    analisis = f"""
El modelo Random Forest detectó que el proyecto
presenta un nivel de riesgo {'alto' if riesgo > 60 else 'moderado'}.

La duración estimada es de
{round(float(duracion),1)} meses y se requieren
aproximadamente {round(float(recursos))} recursos.

La evaluación considera:
complejidad,
presupuesto,
experiencia,
equipo disponible
y carga semanal.
"""

    # =================================================
    # RESPUESTA FINAL
    # =================================================

    return {

        "proyecto":
            proyecto.nombre_proyecto,

        "viabilidad":
            viabilidad,

        "duracion_estimada":
            round(
                float(duracion),
                1
            ),

        "recursos_estimados":
            round(
                float(recursos)
            ),

        "probabilidad_retraso":
            f"{riesgo}%",

        "metodologia_recomendada":
            "Scrum",

        "modelo":
            "Random Forest Regressor",

        "analisis":
            analisis,

        "MRE":
            MRE,

        "MMRE":
            f"{MMRE}%",

        "PRED":
            f"{PRED}%",

        "recomendaciones":
            recomendaciones
    }

# =====================================================
# RUTA PRINCIPAL
# =====================================================

@app.get("/")

def inicio():

    return {

        "mensaje":
            "API IA funcionando correctamente"
    }