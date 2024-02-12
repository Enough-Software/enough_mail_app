/// This command line tool reads the localization arb files from a referenced
/// project and extends them with arb files from the current project.
/// It can additionally replace text-parts in the referenced arb files.
///
/// Input:
/// - The path to the referenced project, a l10n yaml configuration is expected
/// - The path to the current project, a l10n yaml configuration is expected
/// - One or more replace commands
///
/// Intermediate Output:
/// - The extended arb files in the current project
///
/// The tool then runs `flutter gen-l10n` to generate the dart files.
/// The tool then ensures compatibility of the generated localizations
/// classes with the referenced original classes by adding an
/// `implements $referencedProjectLocalizations` and a corresponding import
/// to the generated class.
library;

import 'dart:convert';
import 'dart:io';

// ignore_for_file: avoid_print

/// The main function of the tool
void main(List<String> arguments) {
  final args = arguments.toList();
  if (args.length < 3) {
    print(
      'Usage: localization_extender.dart '
      '<referencedProjectPath> <currentProjectPath> '
      '<currentProjectLocalizationPath> [replaceCommands]',
    );

    return;
  }
  String parseImportPackage(String path) {
    String parsePackageWithSeparator(String path, String separator) {
      final parts = path.split(separator);
      if (path.endsWith(separator) && parts.length > 1) {
        return parts[parts.length - 2];
      }

      return parts.last;
    }

    return path.contains(Platform.pathSeparator)
        ? parsePackageWithSeparator(path, Platform.pathSeparator)
        : parsePackageWithSeparator(path, '/');
  }

  final referencedProjectPath = args.removeAt(0);
  final currentProjectPath = args.removeAt(0);
  final currentProjectLocalizationPath = args.removeAt(0);
  final importPackage = parseImportPackage(referencedProjectPath);
  final replaceCommands = args;

  LocalizationExtender(
    referencedProjectPath: referencedProjectPath,
    currentProjectPath: currentProjectPath,
    replaceCommands: replaceCommands,
    importPackage: importPackage,
    currentProjectLocalizationPath: currentProjectLocalizationPath,
  ).run();
}

/// The localization extender
class LocalizationExtender {
  /// Creates a new localization extender
  LocalizationExtender({
    required this.referencedProjectPath,
    required this.currentProjectPath,
    required this.replaceCommands,
    required this.importPackage,
    required this.currentProjectLocalizationPath,
  });

  /// The path to the referenced project
  final String referencedProjectPath;

  /// The path to the current project
  final String currentProjectPath;

  /// The replace commands
  final List<String> replaceCommands;

  /// The path to the current project localization files
  final String currentProjectLocalizationPath;

  /// The package to be imported
  final String importPackage;

  /// Runs the localization extender
  void run() {
    final referencedProject = Project(referencedProjectPath);
    final now = DateTime.now()
        .toIso8601String()
        .replaceAll(':', '_')
        .replaceAll('.', '_');
    final temporaryPath = '$currentProjectPath/build/tmp/$now';
    final temporaryL10n = L10nYaml(
      path: temporaryPath,
      outputDir: 'localizations',
      arbDir: 'localizations',
      preferredSupportedLocales:
          referencedProject.l10nYaml.preferredSupportedLocales,
      templateArbFile: referencedProject.l10nYaml.templateArbFile,
      outputLocalizationFile: referencedProject.l10nYaml.outputLocalizationFile,
      outputClass: 'Custom${referencedProject.l10nYaml.outputClass}',
    )..write();

    final currentProject = Project(
      currentProjectPath,
      l10nYaml: temporaryL10n,
      localDir: currentProjectLocalizationPath,
    );
    final extendedArbFiles = <String, Map<String, dynamic>>{};
    // run the replace commands in the referenced ARB files:
    for (final arbFile in referencedProject.arbFiles) {
      final contents = arbFile.read();
      extendedArbFiles[arbFile.name] = contents;
    }
    for (final replaceCommand in replaceCommands) {
      final parts = replaceCommand.split('=');
      if (parts.length != 2) {
        print('Ignoring invalid replace command: $replaceCommand');
        continue;
      }
      final match = parts[0];
      final replacement = parts[1];
      for (final arb in extendedArbFiles.values) {
        replaceInArb(arb, match, replacement);
      }
    }

    // extend the referenced arb files with the current project arb files:
    for (final currentArbFile in currentProject.arbFiles) {
      final referencedArbMap = extendedArbFiles[currentArbFile.name];
      if (referencedArbMap == null) {
        print('No referenced arb file found for ${currentArbFile.name}');
        continue;
      }
      print('Extending ${currentArbFile.name}.');
      extendArb(referencedArbMap, currentArbFile.read());
    }

    // write the extended arb files to the current project:
    for (final entry in extendedArbFiles.entries) {
      final referencedEntries = extendedArbFiles[entry.key];
      if (referencedEntries == null) {
        continue;
      }
      final arbFile = referencedProject.arbFilesByName[entry.key];
      if (arbFile == null) {
        print('No arb file found for ${entry.key}');
        continue;
      }
      arbFile.writeTo('$temporaryPath/localizations', entry.value);
    }
    currentProject
      ..copyPubspecYaml(temporaryPath)
      ..runFlutterGenL10n(temporaryPath)
      ..ensureCompatibility(
        temporaryPath: temporaryPath,
        referencedProject: referencedProject,
        importPackage: importPackage,
        outputPath: currentProjectLocalizationPath,
      );
  }

  /// Extends the arb file with the referenced arb file
  void extendArb(
    Map<String, dynamic> referencedArb,
    Map<String, dynamic> extendingArb,
  ) {
    referencedArb.addAll(extendingArb);
    // for (final entry in extendingArb.entries) {
    //   final key = entry.key;
    //   final value = entry.value;
    //   referencedArb[key] = value;
    //   if (value is String) {
    //     final referencedValue = referencedArb[key];
    //     if (referencedValue is String) {
    //       extendedArb[key] = '$value\n$referencedValue';
    //     } else {
    //       extendedArb[key] = value;
    //     }
    //   } else if (value is Map<String, dynamic>) {
    //     final referencedValue = referencedArb[key];
    //     if (referencedValue is Map<String, dynamic>) {
    //       extendedArb[key] = extendArb(value, referencedValue);
    //     } else {
    //       extendedArb[key] = value;
    //     }
    //   } else {
    //     extendedArb[key] = value;
    //   }
    // }

    // return extendedArb;
  }

  /// Replaces the value in the arb file
  void replaceInArb(
    Map<String, dynamic> arb,
    String match,
    String replacement,
  ) {
    for (final entry in arb.entries) {
      final value = entry.value;
      if (value is String) {
        final replacedValue = value.replaceAll(match, replacement);
        if (replacedValue != value) {
          arb[entry.key] = replacedValue;
        }
      }
    }
  }
}

/// A project
class Project {
  /// Creates a new project
  Project(this.path, {L10nYaml? l10nYaml, String? localDir}) {
    _load(l10nYaml, localDir);
  }

  /// The path to the project
  final String path;

  final _arbFilesByName = <String, ArbFile>{};
  final _arbFiles = <ArbFile>[];
  late final L10nYaml l10nYaml;

  /// The arb files of the project
  Map<String, ArbFile> get arbFilesByName => _arbFilesByName;
  List<ArbFile> get arbFiles => _arbFiles;

  /// Loads the project and resolves the arb files
  void _load(L10nYaml? givenL10nYaml, String? localDir) {
    // Load the l10n.yaml file:
    l10nYaml = givenL10nYaml ?? L10nYaml.fromPath(path);
    // load the arb files:
    final usedLocalDir = localDir ?? '$path/${l10nYaml.arbDir}';
    final dir = Directory(usedLocalDir);
    final files = dir.listSync();
    for (final file in files) {
      if (file is File && file.path.endsWith('.arb')) {
        final arbFile = ArbFile(file.path);
        _arbFilesByName[arbFile.name] = arbFile;
        _arbFiles.add(arbFile);
        print('Processing: $usedLocalDir/${arbFile.name}');
      }
    }
  }

  /// Runs `flutter gen-l10n`
  void runFlutterGenL10n(String path) {
    final process = Process.runSync(
      'flutter',
      [
        'gen-l10n',
      ],
      workingDirectory: path,
      runInShell: true,
    );
    if (process.exitCode != 0) {
      print(process.stdout);
      print(process.stderr);
    }
  }

  /// Ensures compatibility with the referenced project
  void ensureCompatibility({
    required String temporaryPath,
    required Project referencedProject,
    required String importPackage,
    required String outputPath,
  }) {
    final referencedProjectLocalizations =
        referencedProject.l10nYaml.outputClass;
    final dir = Directory('$temporaryPath/localizations');
    final files = dir.listSync(recursive: true);
    final generatedFiles =
        files.where((f) => f is File && f.path.endsWith('.g.dart')).toList();

    void writeFileToOutputDir(File file, String content) {
      File('$outputPath/${file.name}').writeAsStringSync(content);
    }

    for (final file in generatedFiles) {
      if (file is! File) {
        continue;
      }

      final content = file.readAsStringSync();
      if (!content.contains('abstract class ${l10nYaml.outputClass}')) {
        writeFileToOutputDir(file, content);
      }
      final import = "import 'package:$importPackage/$importPackage.dart';\n";
      final newContent = import +
          content.replaceFirst(
            'abstract class ${l10nYaml.outputClass}',
            'abstract class ${l10nYaml.outputClass} '
                'implements $referencedProjectLocalizations',
          );
      writeFileToOutputDir(file, newContent);
    }
  }

  /// Copies the pubspec.yaml file
  void copyPubspecYaml(String temporaryPath) {
    final file = File('$path/pubspec.yaml');
    final content = file.readAsStringSync();
    File('$temporaryPath/pubspec.yaml').writeAsStringSync(content);
  }
}

/// An arb file
class ArbFile {
  /// Creates a new arb file
  ArbFile(this.path);

  /// The path to the arb file
  final String path;

  /// The name of the arb file
  String get name {
    final parts = path.split(Platform.pathSeparator);

    return parts.last;
  }

  /// Reads the arb file
  Map<String, dynamic> read() {
    final file = File(path);
    final content = file.readAsStringSync();

    return _arbToJson(content);
  }

  /// Writes the arb file
  void write(Map<String, dynamic> arb) {
    final file = File(path);
    final content = _jsonToArb(arb);
    file.writeAsStringSync(content);
  }

  /// Converts arb to json
  Map<String, dynamic> _arbToJson(String arb) => jsonDecode(arb);

  /// Converts json to arb
  String _jsonToArb(Map<String, dynamic> json) => _prettyPrintJson(json);

  /// Converts JSON to a pretty printed string
  String _prettyPrintJson(Map<String, dynamic> json) {
    const encoder = JsonEncoder.withIndent('  ');

    return encoder.convert(json);
  }

  /// Writes the arb file to the output directory
  void writeTo(String outputDir, Map<String, dynamic> value) {
    final file = File('$outputDir/$name')..createSync(recursive: true);
    final content = _jsonToArb(value);
    file.writeAsStringSync(content);
  }
}

/// A l10n.yaml representation
class L10nYaml {
  /// Creates a new l10n.yaml representation
  L10nYaml({
    required this.arbDir,
    required this.outputDir,
    required this.templateArbFile,
    required this.outputLocalizationFile,
    required this.outputClass,
    required this.preferredSupportedLocales,
    required this.path,
  });

  /// Creates a new l10n.yaml representation
  L10nYaml.fromPath(this.path) {
    _load();
  }

  /// Creates a new l10n.yaml representation from another
  L10nYaml.from(
    L10nYaml other, {
    required this.path,
    required this.outputClass,
  })  : arbDir = other.arbDir,
        outputDir = other.outputDir,
        templateArbFile = other.templateArbFile,
        outputLocalizationFile = other.outputLocalizationFile,
        preferredSupportedLocales = other.preferredSupportedLocales;

  /// The path to the l10n.yaml file
  final String path;
  late final String arbDir;
  late final String outputDir;
  late final String templateArbFile;
  late final String outputLocalizationFile;
  late final String outputClass;
  late final String preferredSupportedLocales;

  /// The arb directory
  void _load() {
    final l10nPath = '$path/l10n.yaml';
    final file = File(l10nPath);
    final content = file.readAsStringSync();
    // print('$path/l10n.yaml:');
    // print(content);
    final map = _decodeSimpleYaml(content);
    /* 
    arb-dir: lib/src/localization
template-arb-file: app_en.arb
output-localization-file: app_localizations.g.dart
output-dir: lib/src/localization
output-class: AppLocalizations
synthetic-package: false
untranslated-messages-file: missing-translations.txt
preferred-supported-locales: en
nullable-getter: true
    */
    arbDir = map['arb-dir'] ?? '';
    outputDir = map['output-dir'] ?? '';
    templateArbFile = map['template-arb-file'] ?? '';
    outputLocalizationFile = map['output-localization-file'] ?? '';
    outputClass = map['output-class'] ?? '';
    preferredSupportedLocales = map['preferred-supported-locales'] ?? '';

    if (arbDir.isEmpty) {
      throw Exception('arb-dir not found in $l10nPath');
    }
    if (outputDir.isEmpty) {
      throw Exception('output-dir not found in $l10nPath');
    }
    if (outputClass.isEmpty) {
      throw Exception('output-class not found in $l10nPath');
    }
  }

  /// writes the yaml file
  void write() {
    final file = File('$path/l10n.yaml')..createSync(recursive: true);
    final content = '''
      # This file is auto-generated by the localization_extender.dart tool
      arb-dir: $arbDir
      output-dir: $outputDir
      template-arb-file: $templateArbFile
      output-localization-file: $outputLocalizationFile
      output-class: $outputClass
      preferred-supported-locales: $preferredSupportedLocales
      synthetic-package: false
    ''';
    file.writeAsStringSync(content);
  }

  // This function decodes YAML format String to a map
  // without supporting nested entries
  Map<String, dynamic> _decodeSimpleYaml(String yaml) {
    final lines = yaml.split('\n');
    final map = <String, dynamic>{};

    for (final line in lines) {
      final trimmedLine = line.trim();
      if (trimmedLine.isEmpty || trimmedLine.startsWith('#')) {
        continue;
      }

      final colonIndex = trimmedLine.indexOf(':');
      final key = trimmedLine.substring(0, colonIndex);
      final value = trimmedLine.substring(colonIndex + 1).trim();
      map[key] = value;
    }

    return map;
  }
}

extension _FileExtension on File {
  String get name {
    final parts = path.split(Platform.pathSeparator);

    return parts.last;
  }
}
