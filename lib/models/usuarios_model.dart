enum RolBK { gerente, empleado, cliente }

class UsuarioBK {
  final String uid;
  final String nombre;
  final String email;
  final RolBK rol;
  final int puntosCorona;
  final String? sucursalAsignada;

  UsuarioBK({
    required this.uid,
    required this.nombre,
    required this.email,
    this.rol = RolBK.cliente,
    this.puntosCorona = 0,
    this.sucursalAsignada,
  });

  factory UsuarioBK.fromMap(Map<String, dynamic> map) {
    return UsuarioBK(
      uid: map['uid'] ?? '',
      nombre: map['nombre'] ?? '',
      email: map['email'] ?? '',
      rol: RolBK.values.byName(map['rol'] ?? 'cliente'),
      puntosCorona: map['puntos_corona'] ?? 0,
      sucursalAsignada: map['sucursal_asignada'],
    );
  }

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'nombre': nombre,
        'email': email,
        'rol': rol.name,
        'puntos_corona': puntosCorona,
        'sucursal_asignada': sucursalAsignada,
      };
}
