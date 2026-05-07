import 'dart:io';

void main() async {
  print('');
  print('🍔 ================================================== 🍔');
  print('   CONFIGURADOR DE GITHUB - BK ADMIN PANEL');
  print('🍔 ================================================== 🍔');
  print('');

  // ── 1. URL del repo ────────────────────────────────────────────────────────
  stdout.write(
    '🔗 URL de tu repositorio GitHub:\n'
    '   Ej: https://github.com/usuario/repo.git\n\n'
    '> ',
  );

  String? repoUrl = stdin.readLineSync()?.trim();

  if (repoUrl == null || repoUrl.isEmpty) {
    print('\n❌ URL vacía. Saliendo.');
    return;
  }

  print('\n✅ Configuración recibida. Iniciando subida...\n');

  try {
    print('📦 Inicializando Git...');
    await _run('git', ['init']);

    print('📁 Agregando archivos...');
    await _run('git', ['add', '.']);

    print('📝 Creando commit...');
    await _run('git', [
      'commit',
      '-m',
      'Proyecto Final BK Admin Panel - Flutter + Firebase',
    ], ignoreError: true);

    print('🌐 Configurando remote...');
    await _run('git', ['remote', 'remove', 'origin'], ignoreError: true);
    await _run('git', ['remote', 'add', 'origin', repoUrl]);

    print('🔀 Asegurando rama main...');
    await _run('git', ['branch', '-M', 'main']);

    print('⬆️  Enviando a GitHub...');
    await _run('git', ['push', '-u', 'origin', 'main', '--force']);

    print('');
    print('🎉 ================================================== 🎉');
    print('   ✅ PROYECTO SUBIDO EXITOSAMENTE');
    print('   🚀 $repoUrl');
    print('🎉 ================================================== 🎉');
    print('');
  } catch (e) {
    print('\n❌ ERROR: $e');
    print('');
    print('💡 Verifica que:');
    print('   • GitHub Desktop o Git Credential Manager estén configurados');
    print('   • Tengas permisos sobre el repositorio');
    print('   • El repositorio exista en GitHub');
  }
}

// ── Helper: ejecuta comandos ────────────────────────────────────────────────
Future<void> _run(
  String cmd,
  List<String> args, {
  bool ignoreError = false,
}) async {
  print('   > $cmd ${args.join(' ')}');

  final result = await Process.run(cmd, args, runInShell: true);

  final out = result.stdout.toString().trim();
  final err = result.stderr.toString().trim();

  if (out.isNotEmpty) {
    print('   $out');
  }

  if (err.isNotEmpty && !err.contains('nothing to commit')) {
    print('   $err');
  }

  if (result.exitCode != 0 && !ignoreError) {
    if (out.contains('nothing to commit') ||
        err.contains('nothing to commit')) {
      print('   ℹ️  Sin cambios nuevos, continuando...\n');
      return;
    }

    throw Exception('Falló: $cmd ${args.join(' ')}');
  }

  print('');
}
