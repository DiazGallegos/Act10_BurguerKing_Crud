import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/bk_model.dart';
import '../services/firebase_service.dart';
import '../theme/bk_theme.dart';

class FormScreen extends StatefulWidget {
  final EntidadBK? entidad;
  const FormScreen({super.key, this.entidad});

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreCtrl;
  late TextEditingController _precioCtrl;
  late TextEditingController _ubicacionCtrl;
  late TextEditingController _imagenCtrl;

  String _categoria = 'hamburguesa';
  bool _disponible = true;
  bool _loading = false;
  String _previewUrl = '';

  bool get _isEditing => widget.entidad != null;

  @override
  void initState() {
    super.initState();
    final e = widget.entidad;
    _nombreCtrl = TextEditingController(text: e?.nombre ?? '');
    _precioCtrl =
        TextEditingController(text: e?.precio?.toStringAsFixed(2) ?? '');
    _ubicacionCtrl = TextEditingController(text: e?.ubicacion ?? '');
    _imagenCtrl = TextEditingController(text: e?.imagen ?? '');
    _categoria = e?.categoria ?? 'hamburguesa';
    _disponible = e?.disponible ?? true;
    _previewUrl = e?.imagen ?? '';
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _precioCtrl.dispose();
    _ubicacionCtrl.dispose();
    _imagenCtrl.dispose();
    super.dispose();
  }

  void _updatePreview() {
    setState(() => _previewUrl = _imagenCtrl.text.trim());
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_imagenCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ La URL de imagen es obligatoria'),
          backgroundColor: BKColors.danger,
        ),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      final entidad = EntidadBK(
        id: widget.entidad?.id ?? '',
        nombre: _nombreCtrl.text.trim(),
        categoria: _categoria,
        precio: _precioCtrl.text.isEmpty
            ? null
            : double.tryParse(_precioCtrl.text),
        ubicacion:
            _ubicacionCtrl.text.isEmpty ? null : _ubicacionCtrl.text.trim(),
        imagen: _imagenCtrl.text.trim(),
        disponible: _disponible,
      );

      if (_isEditing) {
        await FirebaseService.actualizarEntidad(entidad);
      } else {
        await FirebaseService.crearEntidad(entidad);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                _isEditing ? '✅ Actualizado exitosamente' : '✅ Creado exitosamente'),
            backgroundColor: BKColors.success,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error: $e'),
              backgroundColor: BKColors.danger),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BKColors.darkBg,
      appBar: AppBar(
        title: Text(_isEditing ? '✏️ EDITAR' : '➕ NUEVO ÍTEM'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: BKColors.yellow),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Image Preview ──────────────────────────────────────────
              _ImagePreviewSection(url: _previewUrl)
                  .animate()
                  .fadeIn(duration: 500.ms),
              const SizedBox(height: 24),

              // ── Image URL Field ────────────────────────────────────────
              _SectionLabel(label: '🖼️ URL de Imagen *'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _imagenCtrl,
                style: const TextStyle(color: BKColors.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'URL de la imagen (obligatorio)',
                  prefixIcon: Icon(Icons.image_outlined),
                  hintText: 'https://...',
                ),
                onChanged: (_) => Future.delayed(
                    const Duration(milliseconds: 800), _updatePreview),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'La imagen es obligatoria' : null,
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  icon: const Icon(Icons.preview_rounded,
                      color: BKColors.yellow, size: 18),
                  label: const Text('Previsualizar',
                      style: TextStyle(color: BKColors.yellow, fontSize: 13)),
                  onPressed: _updatePreview,
                ),
              ),
              const SizedBox(height: 20),

              // ── Nombre ────────────────────────────────────────────────
              _SectionLabel(label: '📋 Información General'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nombreCtrl,
                style: const TextStyle(color: BKColors.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Nombre *',
                  prefixIcon: Icon(Icons.fastfood_rounded),
                ),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'El nombre es requerido' : null,
              ),
              const SizedBox(height: 16),

              // ── Categoría ─────────────────────────────────────────────
              const Text('Categoría',
                  style: TextStyle(
                      color: BKColors.textSecondary, fontSize: 13)),
              const SizedBox(height: 8),
              Row(
                children: ['hamburguesa', 'combo', 'sucursal'].map((cat) {
                  final icons = {
                    'hamburguesa': '🍔',
                    'combo': '🍟',
                    'sucursal': '🏬',
                  };
                  final selected = _categoria == cat;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _categoria = cat),
                      child: AnimatedContainer(
                        duration: 200.ms,
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: selected
                              ? BKColors.red
                              : BKColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selected
                                ? BKColors.red
                                : BKColors.brown.withOpacity(0.5),
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(icons[cat]!,
                                style: const TextStyle(fontSize: 22)),
                            const SizedBox(height: 4),
                            Text(
                              cat.toUpperCase(),
                              style: TextStyle(
                                color: selected
                                    ? Colors.white
                                    : BKColors.textSecondary,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // ── Precio ────────────────────────────────────────────────
              if (_categoria != 'sucursal') ...[
                TextFormField(
                  controller: _precioCtrl,
                  style: const TextStyle(color: BKColors.textPrimary),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Precio (MXN)',
                    prefixIcon: Icon(Icons.attach_money_rounded),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // ── Ubicación ─────────────────────────────────────────────
              if (_categoria == 'sucursal') ...[
                TextFormField(
                  controller: _ubicacionCtrl,
                  style: const TextStyle(color: BKColors.textPrimary),
                  decoration: const InputDecoration(
                    labelText: 'Dirección / Ubicación',
                    prefixIcon: Icon(Icons.location_on_outlined),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // ── Disponible toggle ──────────────────────────────────────
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: BKColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: BKColors.brown.withOpacity(0.5)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Disponible / En stock',
                        style: TextStyle(
                            color: BKColors.textPrimary,
                            fontWeight: FontWeight.bold)),
                    Switch(
                      value: _disponible,
                      onChanged: (v) => setState(() => _disponible = v),
                      activeColor: BKColors.yellow,
                      activeTrackColor: BKColors.red,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 36),

              // ── Submit Button ──────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  child: _loading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          _isEditing
                              ? '💾  GUARDAR CAMBIOS'
                              : '🍔  CREAR ÍTEM',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w900),
                        ),
                ),
              ).animate(delay: 200.ms).fadeIn(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Image Preview ────────────────────────────────────────────────────────────

class _ImagePreviewSection extends StatelessWidget {
  final String url;
  const _ImagePreviewSection({required this.url});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: BKColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: url.isNotEmpty ? BKColors.yellow : BKColors.brown,
            width: url.isNotEmpty ? 2 : 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: url.isNotEmpty
          ? CachedNetworkImage(
              imageUrl: url,
              fit: BoxFit.contain,
              placeholder: (_, __) => const Center(
                child: CircularProgressIndicator(color: BKColors.yellow),
              ),
              errorWidget: (_, __, ___) => const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.broken_image_rounded,
                        color: BKColors.textSecondary, size: 48),
                    SizedBox(height: 8),
                    Text('URL inválida',
                        style: TextStyle(
                            color: BKColors.textSecondary, fontSize: 13)),
                  ],
                ),
              ),
            )
          : const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_photo_alternate_outlined,
                      color: BKColors.textSecondary, size: 56),
                  SizedBox(height: 8),
                  Text('Ingresa una URL para previsualizar',
                      style: TextStyle(
                          color: BKColors.textSecondary, fontSize: 13)),
                ],
              ),
            ),
    );
  }
}

// ── Section Label ────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: BKColors.yellow,
        fontWeight: FontWeight.w800,
        fontSize: 15,
        letterSpacing: 0.5,
      ),
    );
  }
}
