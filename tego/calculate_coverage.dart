import 'dart:io';

void main() {
  final file = File('coverage/lcov.info');
  if (!file.existsSync()) {
    print('Coverage file not found');
    return;
  }

  final content = file.readAsStringSync();
  if (content.trim().isEmpty) {
    print('Coverage file is empty');
    return;
  }

  final lines = content.split('\n');
  int totalLines = 0;
  int coveredLines = 0;
  Map<String, Map<String, int>> fileStats = {};
  String? currentFile;

  for (String line in lines) {
    line = line.trim();
    if (line.startsWith('SF:')) {
      currentFile = line.substring(3);
      fileStats[currentFile] = {'total': 0, 'covered': 0};
    } else if (line.startsWith('DA:')) {
      // DA:line_number,hit_count
      final parts = line.substring(3).split(',');
      if (parts.length == 2) {
        final hitCount = int.tryParse(parts[1]) ?? 0;
        if (currentFile != null) {
          fileStats[currentFile]!['total'] = fileStats[currentFile]!['total']! + 1;
          if (hitCount > 0) {
            fileStats[currentFile]!['covered'] = fileStats[currentFile]!['covered']! + 1;
          }
        }
      }
    } else if (line.startsWith('LF:')) {
      totalLines += int.tryParse(line.substring(3)) ?? 0;
    } else if (line.startsWith('LH:')) {
      coveredLines += int.tryParse(line.substring(3)) ?? 0;
    }
  }

  // Calculate from DA lines if LF/LH not available
  if (totalLines == 0) {
    for (var stats in fileStats.values) {
      totalLines += stats['total']!;
      coveredLines += stats['covered']!;
    }
  }

  print('=== Test Coverage Report ===');
  print('');
  
  // Show per-file coverage
  for (var entry in fileStats.entries) {
    final fileName = entry.key.split('\\').last;
    final total = entry.value['total']!;
    final covered = entry.value['covered']!;
    final percentage = total > 0 ? (covered / total * 100) : 0.0;
    print('$fileName: ${covered}/${total} lines (${percentage.toStringAsFixed(1)}%)');
  }
  
  print('');
  print('=== Overall Coverage ===');
  print('Total lines: $totalLines');
  print('Covered lines: $coveredLines');
  
  if (totalLines > 0) {
    double coverage = (coveredLines / totalLines) * 100;
    print('Coverage: ${coverage.toStringAsFixed(2)}%');
    print('');
    
    if (coverage >= 70.0) {
      print('✅ Coverage meets requirement (≥70%)');
    } else {
      print('❌ Coverage below requirement (≥70%)');
      print('   Need to improve coverage by ${(70.0 - coverage).toStringAsFixed(2)}%');
    }
  } else {
    print('No coverage data found');
  }
}