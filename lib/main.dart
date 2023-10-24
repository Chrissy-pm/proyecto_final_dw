import 'dart:typed_data';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dialogs/flutter_dialogs.dart'; // Asegúrate de importar esta librería
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(const MyApp());

class Medicine {
  final int id;
  final String nombre;
  final bool perecedero;
  final String FIngreso;
  final String Lote;
  final String Caducidad;
  final String casa;
  final String tipoMedicamento;
  final Uint8List imagenBytes;
  final String Descripsion;

  Medicine({
    required this.id,
    required this.nombre,
    required this.perecedero,
    required this.FIngreso,
    required this.Lote,
    required this.Caducidad,
    required this.casa,
    required this.tipoMedicamento,
    required this.imagenBytes,
    required this.Descripsion,
  });

  factory Medicine.fromJson(Map<String, dynamic> json) {
    String imagenBase64 = json['Imagen'] as String? ?? '';
    List<int> bytes = base64.decode(imagenBase64);

    return Medicine(
      id: json['ID'] as int? ?? 0,
      nombre: json['Nombre'] as String? ?? '',
      perecedero: json['Perecedero'] as bool? ?? false,
      FIngreso: json['Ingreso'] as String? ?? '',
      Lote: json['Lote'] as String? ?? '',
      Caducidad: json['Caducidad'] as String? ?? '',
      casa: json['Casa'] as String? ?? '',
      tipoMedicamento: json['Tipo'] as String? ?? '',
      imagenBytes: Uint8List.fromList(bytes),
      Descripsion: json['Descripcion'] as String? ?? '',
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Catálogo de Medicamentos'),
          backgroundColor: Color.fromARGB(255, 36, 20, 129),
        ),
        body: const MedicineCatalogScreen(),
      ),
    );
  }
}

class MedicineCatalogScreen extends StatefulWidget {
  const MedicineCatalogScreen({Key? key}) : super(key: key);

  @override
  _MedicineCatalogScreenState createState() => _MedicineCatalogScreenState();
}

class _MedicineCatalogScreenState extends State<MedicineCatalogScreen> {
  List<Medicine> medicineList = [];
  List<Medicine> _filteredMedicineList = [];
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
    _fetchMedicineData();
  }

  Future<void> _checkConnectivity() async {
    var connectivityResult = await (Connectivity().checkConnectivity());

    if (connectivityResult == ConnectivityResult.none) {
      _showNoInternetDialog(); // Mostrar el cuadro de diálogo si no hay conexión a Internet
    }
  }

  void _showNoInternetDialog() {
  showPlatformDialog(
    context: context,
    builder: (_) => BasicDialogAlert(
      title: const Text("Acceso a Internet"),
      content: const Text("No tienes conexión a Internet. ¿Quieres habilitar el acceso a Internet manualmente en la configuración de tu dispositivo?"),
      actions: <Widget>[
        BasicDialogAction(
          onPressed: () {
            Navigator.of(context).pop(); // Cierra el cuadro de diálogo
            _openNetworkSettings(); // Abre la configuración de red
          },
          title: const Text("Sí"),
        ),
        BasicDialogAction(
          onPressed: () {
            Navigator.of(context).pop(); // Cierra el cuadro de diálogo
          },
          title: const Text("No"),
        ),
      ],
    ),
  );
}

void _openNetworkSettings() async {
  final url = 'app-settings:';

  if (await canLaunch(url)) {
    await launch(url);
  } else {
    print('No se pudo abrir la configuración de red');
  }
}
  Future<void> _fetchMedicineData() async {
    try {
      final response = await http.get(Uri.parse('http://167.71.172.206:3000/api/medicina'));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          medicineList = data.map((item) => Medicine.fromJson(item)).toList();
          _filteredMedicineList = medicineList;
          _showSnackBar('Conexión exitosa a la API');
        });
      } else {
        print('Error en la respuesta HTTP. Código: ${response.statusCode}');
        throw Exception('Failed to load medicine data');
      }
    } catch (error) {
      print('Error en la solicitud HTTP: $error');
      _showSnackBar('Error al conectar con la API: $error');
      print('Error fetching medicine data: $error');
    }
  }

  void _filterMedicines(String query) {
    List<Medicine> filteredList = [];
    if (query.isNotEmpty) {
      filteredList = medicineList
          .where((medicine) =>
              medicine.nombre.toLowerCase().contains(query.toLowerCase()))
          .toList();
    } else {
      filteredList = medicineList;
    }
    setState(() {
      _filteredMedicineList = filteredList;
    });
  }

  Future<void> _onMedicineCardTap(int index) async {
    final selectedMedicine = _filteredMedicineList[index];
    _navigateToMedicineDetail(selectedMedicine);
  }

  void _navigateToMedicineDetail(Medicine medicine) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MedicineDetailScreen(medicine: medicine)),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.blue, Colors.purple],
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (query) {
                        _filterMedicines(query);
                      },
                      decoration: InputDecoration(
                        hintText: 'Buscar medicamentos por nombre',
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _filterMedicines('');
                          },
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 1,
                        crossAxisSpacing: 5.0,
                        mainAxisSpacing: 5.0,
                      ),
                      itemCount: _filteredMedicineList.length,
                      itemBuilder: (context, index) {
                        Medicine medicine = _filteredMedicineList[index];
                        return GestureDetector(
                          onTap: () {
                            _onMedicineCardTap(index);
                          },
                          child: Card(
                            elevation: 1,
                            margin: const EdgeInsets.all(10.0),
                            color: Colors.white70,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  height: 150,
                                  width: 150,
                                  child: Image.memory(
                                    medicine.imagenBytes,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Text(
                                    '${medicine.nombre}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 25.0,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MedicineDetailScreen extends StatelessWidget {
  final Medicine medicine;

  const MedicineDetailScreen({Key? key, required this.medicine})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles del Medicamento'),
        backgroundColor: Color.fromARGB(255, 36, 20, 129),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue, Colors.purple],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Container(
                  height: 150,
                  width: 150,
                  child: Image.memory(
                    medicine.imagenBytes,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 16.0),
                Container(
                  padding: const EdgeInsets.all(16.0),
                  color: Color.fromARGB(179, 69, 15, 218),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'ID: ${medicine.id}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        'Nombre: ${medicine.nombre}',
                        style: const TextStyle(fontSize: 20.0),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        'Perecedero: ${medicine.perecedero ? 'Sí' : 'No'}',
                        style: const TextStyle(fontSize: 20.0),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        'Ingreso: ${medicine.FIngreso}',
                        style: const TextStyle(fontSize: 20.0),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        'Lote: ${medicine.Lote}',
                        style: const TextStyle(fontSize: 20.0),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        'Caducidad: ${medicine.Caducidad}',
                        style: const TextStyle(fontSize: 20.0),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        'Casa: ${medicine.casa}',
                        style: const TextStyle(fontSize: 20.0),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        'Tipo de Medicamento: ${medicine.tipoMedicamento}',
                        style: const TextStyle(fontSize: 20.0),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        'Descripción: ${medicine.Descripsion}',
                        style: const TextStyle(fontSize: 20.0),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}