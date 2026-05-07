import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';
import '../models/bk_model.dart';
import '../services/firebase_service.dart';
import '../theme/bk_theme.dart';
import 'form_screen.dart';

class CrudScreen extends StatefulWidget {
  final String? filtroCategoria;
  const CrudScreen({super.key, this.filtroCategoria});

  @override
  State<CrudScreen> createState() => _CrudScreenState();
}

class _CrudScreenState extends State<CrudScreen> {
  late String? _selectedCategoria;
  final List<String?> _categorias = [null, 'hamburguesa', 'combo', 'sucursal'];
  final Map<String?, String> _catLabels = {
    null: 'Todos',
    'hamburguesa': '🍔 Hamburguesas',
    'combo': '🍟 Combos',
    'sucursal': '🏬 Sucursales',
  };

  @override
  void initState() {
    super.initState();
    _selectedCategoria = widget.filtroCategoria;
  }

  void _confirmDelete(EntidadBK e) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar',
            style: TextStyle(color: BKColors.textPrimary)),
        content: Text(
          '¿Eliminar "${e.nombre}"? Esta acción no se puede deshacer.',
          style: const TextStyle(color: BKColors.textSecondary),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar',
                  style: TextStyle(color: BKColors.textSecondary))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: BKColors.danger),
            onPressed: () async {
              Navigator.pop(context);
              await FirebaseService.eliminarEntidad(e.id);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('✅ Eliminado exitosamente')));
              }
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _openForm({EntidadBK? entidad}) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => FormScreen(entidad: entidad)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BKColors.darkBg,
      appBar: AppBar(
        title: const Text('👑 KING ADMIN'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: BKColors.yellow),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_rounded,
                color: BKColors.yellow, size: 30),
            onPressed: () => _openForm(),
            tooltip: 'Agregar nuevo',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // ── Category Filter Chips ──
          Container(
            color: BKColors.darkBg,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _categorias.map((cat) {
                  final selected = _selectedCategoria == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(_catLabels[cat]!),
                      selected: selected,
                      onSelected: (_) =>
                          setState(() => _selectedCategoria = cat),
                      selectedColor: BKColors.yellow,
                      labelStyle: TextStyle(
                        color: selected ? BKColors.brown : BKColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                      backgroundColor: BKColors.surface,
                      side: BorderSide(
                          color: selected
                              ? BKColors.yellow
                              : BKColors.brown.withOpacity(0.5)),
                      checkmarkColor: BKColors.brown,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // ── List ──
          Expanded(
            child: StreamBuilder<List<EntidadBK>>(
              stream: FirebaseService.obtenerEntidades(
                  categoria: _selectedCategoria),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _ShimmerList();
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}',
                        style: const TextStyle(color: BKColors.danger)),
                  );
                }
                final items = snapshot.data ?? [];
                if (items.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('🍔', style: TextStyle(fontSize: 64)),
                        SizedBox(height: 16),
                        Text('No hay elementos',
                            style: TextStyle(
                                color: BKColors.textSecondary, fontSize: 18)),
                        SizedBox(height: 8),
                        Text('Toca + para agregar uno nuevo',
                            style: TextStyle(
                                color: BKColors.textSecondary, fontSize: 13)),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                  itemCount: items.length,
                  itemBuilder: (ctx, i) => _EntidadCard(
                    entidad: items[i],
                    onEdit: () => _openForm(entidad: items[i]),
                    onDelete: () => _confirmDelete(items[i]),
                  )
                      .animate(delay: (50 * i).ms)
                      .fadeIn()
                      .slideX(begin: 0.1),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        icon: const Icon(Icons.add_rounded),
        label: const Text('NUEVO',
            style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1)),
      ),
    );
  }
}

// ── Entidad Card ─────────────────────────────────────────────────────────────

class _EntidadCard extends StatelessWidget {
  final EntidadBK entidad;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _EntidadCard(
      {required this.entidad, required this.onEdit, required this.onDelete});

  Color get _catColor {
    switch (entidad.categoria) {
      case 'hamburguesa':
        return BKColors.red;
      case 'combo':
        return BKColors.yellow;
      case 'sucursal':
        return BKColors.brown;
      default:
        return BKColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: BKColors.cardBg,
        borderRadius: BorderRadius.circular(20),
        border:
            Border.all(color: _catColor.withOpacity(0.35), width: 1.5),
        boxShadow: [
          BoxShadow(
              color: _catColor.withOpacity(0.15),
              blurRadius: 16,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          // ── Thumbnail ──
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(20)),
            child: entidad.imagen.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: entidad.imagen,
                    width: 110,
                    height: 110,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Shimmer.fromColors(
                      baseColor: BKColors.surface,
                      highlightColor: BKColors.brown,
                      child: Container(
                          width: 110, height: 110, color: BKColors.surface),
                    ),
                    errorWidget: (_, __, ___) => Container(
                      width: 110,
                      height: 110,
                      color: BKColors.surface,
                      child: const Icon(Icons.broken_image_rounded,
                          color: BKColors.textSecondary, size: 40),
                    ),
                  )
                : Container(
                    width: 110,
                    height: 110,
                    color: BKColors.surface,
                    child: Icon(Icons.lunch_dining,
                        color: _catColor, size: 40),
                  ),
          ),

          // ── Info ──
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _catColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                      border:
                          Border.all(color: _catColor.withOpacity(0.5)),
                    ),
                    child: Text(
                      entidad.categoria.toUpperCase(),
                      style: TextStyle(
                        color: _catColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    entidad.nombre,
                    style: const TextStyle(
                      color: BKColors.textPrimary,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  if (entidad.precio != null)
                    Text(
                      '\$${entidad.precio!.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: BKColors.yellow,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                  if (entidad.ubicacion != null)
                    Text(
                      '📍 ${entidad.ubicacion}',
                      style: const TextStyle(
                          color: BKColors.textSecondary, fontSize: 11),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: entidad.disponible
                              ? BKColors.success.withOpacity(0.15)
                              : BKColors.danger.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          entidad.disponible ? '✅ Disponible' : '❌ Agotado',
                          style: TextStyle(
                            color: entidad.disponible
                                ? BKColors.success
                                : BKColors.danger,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── Actions ──
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.edit_rounded, color: BKColors.yellow),
                tooltip: 'Editar',
                onPressed: onEdit,
              ),
              IconButton(
                icon:
                    const Icon(Icons.delete_rounded, color: BKColors.danger),
                tooltip: 'Eliminar',
                onPressed: onDelete,
              ),
            ],
          ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }
}

// ── Shimmer placeholder ──────────────────────────────────────────────────────

class _ShimmerList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: BKColors.cardBg,
        highlightColor: BKColors.surface,
        child: Container(
          margin: const EdgeInsets.only(bottom: 14),
          height: 110,
          decoration: BoxDecoration(
            color: BKColors.cardBg,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }
}
