import 'dart:convert';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    return MaterialApp(

      debugShowCheckedModeBanner: false,

      theme: ThemeData.dark(),

      home: const WelcomeScreen(),
    );
  }
}

// =====================================================
// PANTALLA BIENVENIDA
// =====================================================

class WelcomeScreen extends StatelessWidget {

  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: Container(

        width: double.infinity,

        decoration: const BoxDecoration(

          gradient: LinearGradient(

            colors: [

              Color(0xff050816),
              Color(0xff0f172a),
              Color(0xff111827),

            ],

            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        child: Center(

          child: Padding(

            padding: const EdgeInsets.all(30),

            child: Column(

              mainAxisAlignment: MainAxisAlignment.center,

              children: [

                const Icon(

                  Icons.auto_awesome,

                  size: 100,

                  color: Colors.cyanAccent,
                ),

                const SizedBox(height: 30),

                const Text(

                  "Project AI Analyzer",

                  style: TextStyle(

                    fontSize: 34,

                    fontWeight: FontWeight.bold,

                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 20),

                const Text(

                  "Sistema inteligente para predicción y análisis de proyectos",

                  textAlign: TextAlign.center,

                  style: TextStyle(

                    fontSize: 18,

                    color: Colors.white70,
                  ),
                ),

                const SizedBox(height: 50),

                ElevatedButton(

                  style: ElevatedButton.styleFrom(

                    backgroundColor: Colors.cyanAccent,

                    foregroundColor: Colors.black,

                    padding: const EdgeInsets.symmetric(

                      horizontal: 40,

                      vertical: 18,
                    ),
                  ),

                  onPressed: () {

                    Navigator.push(

                      context,

                      MaterialPageRoute(

                        builder: (_) => const AIScreen(),
                      ),
                    );
                  },

                  child: const Text(

                    "Comenzar evaluación",

                    style: TextStyle(

                      fontSize: 18,
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// =====================================================
// IA SCREEN
// =====================================================

class AIScreen extends StatefulWidget {

  const AIScreen({super.key});

  @override
  State<AIScreen> createState() =>
      _AIScreenState();
}

class _AIScreenState
    extends State<AIScreen> {

  final nombreController =
      TextEditingController();

  final modulosController =
      TextEditingController();

  final personasController =
      TextEditingController();

  final experienciaController =
      TextEditingController();

  final presupuestoController =
      TextEditingController();

  final tecnologiasController =
      TextEditingController();

  final horasController =
      TextEditingController();

  DateTime? fechaLimite;

  String complejidad = "Media";

  String metodologia = "Scrum";

  Map<String, dynamic>? resultado;

  // =====================================================
  // FECHA
  // =====================================================

  Future<void> seleccionarFecha() async {

    DateTime? picked =
        await showDatePicker(

      context: context,

      initialDate: DateTime.now(),

      firstDate: DateTime(2024),

      lastDate: DateTime(2035),
    );

    if (picked != null) {

      setState(() {

        fechaLimite = picked;
      });
    }
  }

  // =====================================================
  // CONECTAR FASTAPI
  // =====================================================

  Future<void> analizarProyecto() async {

    if (fechaLimite == null) {
      return;
    }

    final hoy = DateTime.now();

    final diferencia =
        fechaLimite!
            .difference(hoy)
            .inDays;

    final meses =
        (diferencia / 30).round();

    final url = Uri.parse(
      "http://127.0.0.1:8000/analizar",
    );

    final response = await http.post(

      url,

      headers: {

        "Content-Type":
            "application/json"
      },

      body: jsonEncode({

        "nombre_proyecto":
            nombreController.text,

        "modulos":
            int.parse(
              modulosController.text
            ),

        "personas":
            int.parse(
              personasController.text
            ),

        "experiencia":
            int.parse(
              experienciaController.text
            ),

        "presupuesto":
            double.parse(
              presupuestoController.text
            ),

        "fecha_limite":
            meses,

        "tecnologias":
            tecnologiasController.text,

        "complejidad":
            complejidad,

        "horas_semanales":
            int.parse(
              horasController.text
            ),

        "metodologia":
            metodologia,
      }),
    );

    final data =
        jsonDecode(response.body);

    setState(() {

      resultado = data;
    });
  }

  // =====================================================
  // INPUTS
  // =====================================================

  Widget campo(
    String texto,
    TextEditingController controller,
  ) {

    return Padding(

      padding:
          const EdgeInsets.symmetric(
        vertical: 8,
      ),

      child: TextField(

        controller: controller,

        style: const TextStyle(
          color: Colors.white,
        ),

        decoration: InputDecoration(

          labelText: texto,

          labelStyle: const TextStyle(
            color: Colors.cyanAccent,
          ),

          filled: true,

          fillColor: Colors.white10,

          border: OutlineInputBorder(

            borderRadius:
                BorderRadius.circular(
              16,
            ),
          ),
        ),
      ),
    );
  }

  // =====================================================
  // CARD
  // =====================================================

  Widget cardResultado(
    String titulo,
    String valor,
  ) {

    return Container(

      width: double.infinity,

      margin: const EdgeInsets.only(
        bottom: 15,
      ),

      padding: const EdgeInsets.all(
        20,
      ),

      decoration: BoxDecoration(

        color: Colors.white10,

        borderRadius:
            BorderRadius.circular(20),

        border: Border.all(
          color: Colors.cyanAccent,
        ),
      ),

      child: Column(

        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          Text(

            titulo,

            style: const TextStyle(

              color: Colors.cyanAccent,

              fontSize: 18,

              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          Text(

            valor,

            style: const TextStyle(

              color: Colors.white,

              fontSize: 17,
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // GRAFICA
  // =====================================================

  Widget graficaIA() {

    if (resultado == null) {
      return const SizedBox();
    }

    double riesgo = double.parse(
      resultado![
              "probabilidad_retraso"]
          .replaceAll("%", ""),
    );

    double pred = double.parse(
      resultado!["PRED"]
          .replaceAll("%", ""),
    );

    double mmre = double.parse(
      resultado!["MMRE"]
          .replaceAll("%", ""),
    );

    return Container(

      height: 300,

      padding: const EdgeInsets.all(
        20,
      ),

      decoration: BoxDecoration(

        color: Colors.white10,

        borderRadius:
            BorderRadius.circular(20),
      ),

      child: BarChart(

        BarChartData(

          alignment:
              BarChartAlignment
                  .spaceAround,

          maxY: 100,

          titlesData:
              FlTitlesData(

            leftTitles:
                const AxisTitles(

              sideTitles:
                  SideTitles(
                showTitles: true,
              ),
            ),

            bottomTitles:
                AxisTitles(

              sideTitles:
                  SideTitles(

                showTitles: true,

                getTitlesWidget:
                    (value, meta) {

                  switch (
                      value.toInt()) {

                    case 0:
                      return const Text(
                        "Riesgo",
                      );

                    case 1:
                      return const Text(
                        "PRED",
                      );

                    case 2:
                      return const Text(
                        "MMRE",
                      );
                  }

                  return const Text(
                    "",
                  );
                },
              ),
            ),
          ),

          barGroups: [

            BarChartGroupData(

              x: 0,

              barRods: [

                BarChartRodData(

                  toY: riesgo,

                  color:
                      Colors.redAccent,
                )
              ],
            ),

            BarChartGroupData(

              x: 1,

              barRods: [

                BarChartRodData(

                  toY: pred,

                  color:
                      Colors.greenAccent,
                )
              ],
            ),

            BarChartGroupData(

              x: 2,

              barRods: [

                BarChartRodData(

                  toY: mmre,

                  color:
                      Colors.cyanAccent,
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  // =====================================================
  // BUILD
  // =====================================================

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
          const Color(0xff050816),

      appBar: AppBar(

        backgroundColor:
            Colors.black,

        title: const Text(
          "AI Project Evaluation",
        ),

        centerTitle: true,
      ),

      body: SingleChildScrollView(

        padding: const EdgeInsets.all(
          20,
        ),

        child: Column(

          children: [

            campo(
              "Nombre proyecto",
              nombreController,
            ),

            campo(
              "Cantidad módulos",
              modulosController,
            ),

            campo(
              "Cantidad personas",
              personasController,
            ),

            campo(
              "Experiencia equipo (1-5)",
              experienciaController,
            ),

            campo(
              "Presupuesto",
              presupuestoController,
            ),

            campo(
              "Tecnologías",
              tecnologiasController,
            ),

            campo(
              "Horas semanales",
              horasController,
            ),

            const SizedBox(height: 15),

            Container(

              width: double.infinity,

              padding:
                  const EdgeInsets.all(
                16,
              ),

              decoration: BoxDecoration(

                color: Colors.white10,

                borderRadius:
                    BorderRadius.circular(
                  16,
                ),
              ),

              child: Column(

                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,

                children: [

                  const Text(

                    "Fecha límite",

                    style: TextStyle(
                      color:
                          Colors.cyanAccent,
                    ),
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  Text(

                    fechaLimite == null

                        ? "Selecciona fecha"

                        : "${fechaLimite!.day}/${fechaLimite!.month}/${fechaLimite!.year}",

                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  ElevatedButton(

                    onPressed:
                        seleccionarFecha,

                    child: const Text(
                      "Elegir fecha",
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 20),

            DropdownButtonFormField(

              value: complejidad,

              dropdownColor:
                  const Color(
                      0xff111827),

              decoration: InputDecoration(

                filled: true,

                fillColor:
                    Colors.white10,

                border:
                    OutlineInputBorder(

                  borderRadius:
                      BorderRadius.circular(
                    16,
                  ),
                ),
              ),

              items: [

                "Baja",
                "Media",
                "Alta"

              ].map((e) {

                return DropdownMenuItem(

                  value: e,

                  child: Text(e),
                );

              }).toList(),

              onChanged: (value) {

                setState(() {

                  complejidad = value!;
                });
              },
            ),

            const SizedBox(height: 20),

            DropdownButtonFormField(

              value: metodologia,

              dropdownColor:
                  const Color(
                      0xff111827),

              decoration: InputDecoration(

                filled: true,

                fillColor:
                    Colors.white10,

                border:
                    OutlineInputBorder(

                  borderRadius:
                      BorderRadius.circular(
                    16,
                  ),
                ),
              ),

              items: [

                "Scrum",
                "Kanban",
                "XP"

              ].map((e) {

                return DropdownMenuItem(

                  value: e,

                  child: Text(e),
                );

              }).toList(),

              onChanged: (value) {

                setState(() {

                  metodologia = value!;
                });
              },
            ),

            const SizedBox(height: 30),

            ElevatedButton(

              style:
                  ElevatedButton.styleFrom(

                backgroundColor:
                    Colors.cyanAccent,

                foregroundColor:
                    Colors.black,

                padding:
                    const EdgeInsets.symmetric(

                  horizontal: 40,

                  vertical: 18,
                ),
              ),

              onPressed:
                  analizarProyecto,

              child: const Text(

                "Analizar Proyecto",

                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            ),

            const SizedBox(height: 30),

            if (resultado != null) ...[

              cardResultado(

                "Estado Proyecto",

                resultado![
                    "viabilidad"],
              ),

              cardResultado(

                "Duración estimada",

                "${resultado!["duracion_estimada"]} meses",
              ),

              cardResultado(

                "Recursos estimados",

                resultado![
                        "recursos_estimados"]
                    .toString(),
              ),

              cardResultado(

                "Modelo IA",

                resultado!["modelo"],
              ),

              cardResultado(

                "MRE",

                resultado!["MRE"]
                    .toString(),
              ),

              cardResultado(

                "MMRE",

                resultado!["MMRE"],
              ),

              cardResultado(

                "PRED",

                resultado!["PRED"],
              ),

              cardResultado(

                "Análisis IA",

                resultado!["analisis"],
              ),

              cardResultado(

                "Recomendaciones",

                resultado![
                        "recomendaciones"]
                    .join("\n"),
              ),

              const SizedBox(height: 30),

              const Text(

                "Dashboard Random Forest",

                style: TextStyle(

                  fontSize: 22,

                  fontWeight:
                      FontWeight.bold,

                  color:
                      Colors.cyanAccent,
                ),
              ),

              const SizedBox(height: 20),

              graficaIA(),
            ]
          ],
        ),
      ),
    );
  }
}