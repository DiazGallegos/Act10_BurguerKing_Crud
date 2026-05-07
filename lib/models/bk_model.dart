class EntidadBK {
  final String id;
  final String nombre;
  final String categoria; // "hamburguesa", "combo", "sucursal"
  final double? precio;
  final String? ubicacion;
  final String imagen; // URL OBLIGATORIA DE LA FOTO
  final bool disponible;

  EntidadBK({
    required this.id,
    required this.nombre,
    required this.categoria,
    this.precio,
    this.ubicacion,
    this.imagen = '',
    this.disponible = true,
  });

  factory EntidadBK.fromMap(Map<String, dynamic> map) {
    return EntidadBK(
      id: map['id'] ?? '',
      nombre: map['nombre'] ?? '',
      categoria: map['categoria'] ?? 'hamburguesa',
      precio: map['precio'] != null
          ? double.tryParse(map['precio'].toString())
          : null,
      ubicacion: map['ubicacion'],
      imagen: map['imagen'] ?? '',
      disponible: map['disponible'] ?? true,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'nombre': nombre,
        'categoria': categoria,
        'precio': precio,
        'ubicacion': ubicacion,
        'imagen': imagen,
        'disponible': disponible,
      };

  EntidadBK copyWith({
    String? id,
    String? nombre,
    String? categoria,
    double? precio,
    String? ubicacion,
    String? imagen,
    bool? disponible,
  }) {
    return EntidadBK(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      categoria: categoria ?? this.categoria,
      precio: precio ?? this.precio,
      ubicacion: ubicacion ?? this.ubicacion,
      imagen: imagen ?? this.imagen,
      disponible: disponible ?? this.disponible,
    );
  }
}
