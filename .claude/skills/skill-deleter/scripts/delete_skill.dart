import 'dart:io';

void main(List<String> args) async {
  if (args.isEmpty || !args.any((a) => a.startsWith('--name='))) {
    print('Usage: dart run delete_skill.dart --name=<skill-name> [--dry-run]');
    exit(1);
  }

  final dryRun = args.contains('--dry-run');
  final skillName = args
      .firstWhere((a) => a.startsWith('--name='))
      .split('=')[1]
      .trim()
      .toLowerCase();

  print('🗑️  ========================================================');
  print('🗑️  Skill Deleter & Reference Cleaner: $skillName');
  print('🗑️  ========================================================\n');

  final projectDir = Directory.current;
  final skillDir = Directory('${projectDir.path}/.claude/skills/$skillName');

  if (!File('${skillDir.path}/SKILL.md').existsSync()) {
    print('❌ Skill "$skillName" not found in .claude/skills/.');
    exit(1);
  }

  print('📁 Found target skill directory:\n   - ${skillDir.path}');

  // Scan codebase for references
  print('\n🔍 Scanning codebase for references to "$skillName"...');
  final referencingFiles = <File, List<int>>{};

  void searchReferences(FileSystemEntity root) {
    final files = root is Directory
        ? root.existsSync()
            ? root.listSync(recursive: true).whereType<File>()
            : <File>[]
        : root is File && root.existsSync()
            ? [root]
            : <File>[];

    for (final file in files) {
      // Skip the target skill itself, generated docs, and binary/VCS noise.
      if (file.path.startsWith(skillDir.path)) continue;
      if (file.path.contains('/.git/') || file.path.contains('/build/')) continue;
      if (file.path.endsWith('.html') || file.path.endsWith('.DS_Store')) continue;

      try {
        final lines = file.readAsLinesSync();
        final matchingLines = <int>[];
        for (var i = 0; i < lines.length; i++) {
          if (lines[i].toLowerCase().contains(skillName)) {
            matchingLines.add(i + 1);
          }
        }
        if (matchingLines.isNotEmpty) {
          referencingFiles[file] = matchingLines;
        }
      } catch (_) {}
    }
  }

  searchReferences(Directory('${projectDir.path}/lib'));
  searchReferences(Directory('${projectDir.path}/test'));
  searchReferences(Directory('${projectDir.path}/.claude'));
  searchReferences(File('${projectDir.path}/.claude/CLAUDE.md'));

  if (referencingFiles.isNotEmpty) {
    print('⚠️  Found ${referencingFiles.length} file(s) referencing "$skillName":');
    for (final entry in referencingFiles.entries) {
      print('   📄 ${entry.key.path} (lines: ${entry.value.join(", ")})');
    }
  } else {
    print('✅ No active references to "$skillName" found.');
  }

  if (dryRun) {
    print('\n[DRY-RUN] Would delete ${skillDir.path}. No files modified.');
    return;
  }

  print('\n🗑️  Deleting skill directory...');
  skillDir.deleteSync(recursive: true);
  print('   🗑️ Deleted ${skillDir.path}');

  print('\n✅ Skill "$skillName" deleted successfully!');
  if (referencingFiles.isNotEmpty) {
    print('👉 Remember to review and clean remaining references listed above.');
  }
}
