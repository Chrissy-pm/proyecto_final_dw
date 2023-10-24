class Medicina {
  final int id;
  final String nombre;
  final bool perecedero;
  final String fechaIngreso;
  final String fechaLote;
  final String fechaCaducidad;
  final String casa;
  final String tipoMedicamento;
  final String imagen;

  Medicina({
    required this.id,
    required this.nombre,
    required this.perecedero,
    required this.fechaIngreso,
    required this.fechaLote,
    required this.fechaCaducidad,
    required this.casa,
    required this.tipoMedicamento,
    required this.imagen,
  });

  factory Medicina.fromJson(Map<String, dynamic> json) {
    return Medicina(
      id: json['ID_Medicina'],
      nombre: json['Nombre'],
      perecedero: json['Perecedero'],
      fechaIngreso: json['Fecha_Ingreso'],
      fechaLote: json['Fecha_Lote'],
      fechaCaducidad: json['Fecha_Caducidad'],
      casa: json['Casa'],
      tipoMedicamento: json['TipoMedicamento'],
      imagen: json['Imagen'],
    );
  }
}
