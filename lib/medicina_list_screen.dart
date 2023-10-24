import 'package:flutter/material.dart';
import 'medicina.dart';  // Asegúrate de importar la clase Medicina y definir sus propiedades correctamente.
import 'api.dart';  // Asegúrate de tener la función fetchAllMedicinas() definida en tu archivo api.dart.

class MedicinaListScreen extends StatelessWidget {
  const MedicinaListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medicinas'),
      ),
      body: Center(
        child: FutureBuilder<List<Medicina>>(
          future: fetchAllMedicinas(),  // Asumiendo que esta función retorna una lista de Medicina
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Text('No se encontraron medicinas.');
            } else {
              List<Medicina> medicinas = snapshot.data!;
              return ListView.builder(
                itemCount: medicinas.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Medicina ID: ${medicinas[index].id}'),
                        Text('Nombre: ${medicinas[index].nombre}'),
                        Text('Perecedero: ${medicinas[index].perecedero}'),
                        Text('Fecha Ingreso: ${medicinas[index].fechaIngreso}'),
                        Text('Fecha Lote: ${medicinas[index].fechaLote}'),
                        Text('Fecha Caducidad: ${medicinas[index].fechaCaducidad}'),
                        Text('Casa: ${medicinas[index].casa}'),
                        Text('Tipo de Medicamento: ${medicinas[index].tipoMedicamento}'),
                        Image.network(medicinas[index].imagen),
                      ],
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}
