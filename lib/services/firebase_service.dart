import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/bk_model.dart';
import '../models/usuarios_model.dart';

class FirebaseService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // ─── AUTH ───────────────────────────────────────────────────────────────────

  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  static Future<UserCredential> signIn(String email, String password) =>
      _auth.signInWithEmailAndPassword(email: email, password: password);

  static Future<UserCredential> register(String email, String password) =>
      _auth.createUserWithEmailAndPassword(email: email, password: password);

  static Future<void> signOut() => _auth.signOut();

  static User? get currentUser => _auth.currentUser;

  // ─── USUARIOS ────────────────────────────────────────────────────────────────

  static Future<void> guardarUsuario(UsuarioBK usuario) async {
    await _db
        .collection('usuarios')
        .doc(usuario.uid)
        .set(usuario.toMap());
  }

  static Future<UsuarioBK?> obtenerUsuario(String uid) async {
    final doc = await _db.collection('usuarios').doc(uid).get();
    if (!doc.exists) return null;
    return UsuarioBK.fromMap(doc.data()!);
  }

  // ─── ENTIDADES BK (CRUD) ─────────────────────────────────────────────────────

  static Stream<List<EntidadBK>> obtenerEntidades({String? categoria}) {
    Query<Map<String, dynamic>> query = _db.collection('entidades_bk');
    if (categoria != null && categoria.isNotEmpty) {
      query = query.where('categoria', isEqualTo: categoria);
    }
    return query.snapshots().map((snap) => snap.docs
        .map((d) => EntidadBK.fromMap({...d.data(), 'id': d.id}))
        .toList());
  }

  static Future<void> crearEntidad(EntidadBK entidad) async {
    final ref = _db.collection('entidades_bk').doc();
    await ref.set({...entidad.toMap(), 'id': ref.id});
  }

  static Future<void> actualizarEntidad(EntidadBK entidad) async {
    await _db
        .collection('entidades_bk')
        .doc(entidad.id)
        .update(entidad.toMap());
  }

  static Future<void> eliminarEntidad(String id) async {
    await _db.collection('entidades_bk').doc(id).delete();
  }

  // ─── SEED DATA ───────────────────────────────────────────────────────────────

  static Future<void> seedDemoData() async {
    final existing = await _db.collection('entidades_bk').limit(1).get();
    if (existing.docs.isNotEmpty) return; // already seeded

    final demos = [
      EntidadBK(
        id: '',
        nombre: 'Whopper Clásico',
        categoria: 'hamburguesa',
        precio: 85.0,
        imagen:
            'https://www.bk.com/sites/default/files/styles/product_detail_main/public/sandwiches/Whopper.png',
        disponible: true,
      ),
      EntidadBK(
        id: '',
        nombre: 'Whopper Doble',
        categoria: 'hamburguesa',
        precio: 105.0,
        imagen:
            'https://www.bk.com/sites/default/files/styles/product_detail_main/public/sandwiches/DoubleWhopper.png',
        disponible: true,
      ),
      EntidadBK(
        id: '',
        nombre: 'Combo Whopper Mediano',
        categoria: 'combo',
        precio: 120.0,
        imagen:
            'https://www.bk.com/sites/default/files/styles/product_detail_main/public/combos/WhopperMealMD.png',
        disponible: true,
      ),
      EntidadBK(
        id: '',
        nombre: 'Combo Crispy Chicken',
        categoria: 'combo',
        precio: 115.0,
        imagen:
            'https://www.bk.com/sites/default/files/styles/product_detail_main/public/combos/CrispyChickenMealMD.png',
        disponible: true,
      ),
      EntidadBK(
        id: '',
        nombre: 'BK Sucursal Centro',
        categoria: 'sucursal',
        ubicacion: 'Av. Reforma 100, CDMX',
        imagen:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/8/85/Burger_King_logo_%281999%29.svg/800px-Burger_King_logo_%281999%29.svg.png',
        disponible: true,
      ),
      EntidadBK(
        id: '',
        nombre: 'BK Sucursal Norte',
        categoria: 'sucursal',
        ubicacion: 'Blvd. Díaz Ordaz 45, Monterrey',
        imagen:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/8/85/Burger_King_logo_%281999%29.svg/800px-Burger_King_logo_%281999%29.svg.png',
        disponible: true,
      ),
    ];

    for (final e in demos) {
      await crearEntidad(e);
    }
  }
}
