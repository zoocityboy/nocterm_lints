// Copyright (c) 2026, zoocityboy.
// Use of this source code is governed by a BSD-3-Clause license.
// See LICENSE file for details.

// Test support utilities for assist tests. Provides a base class with common setup and utilities for testing [ResolvedCorrectionProducer] assists, as well as
// a stub implementation of the `nocterm` framework to allow assists to resolve types without needing the full framework source.
// ignore_for_file: lines_longer_than_80_chars, comment_references, library_private_types_in_public_api, avoid_dynamic_calls

import 'dart:io' as io;

import 'package:analysis_server_plugin/edit/dart/correction_producer.dart'
    show ResolvedCorrectionProducer;
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/file_system/file_system.dart';
import 'package:analyzer/src/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/src/dart/analysis/byte_store.dart';
import 'package:analyzer/src/test_utilities/mock_sdk.dart';
import 'package:analyzer/utilities/package_config_file_builder.dart';
import 'package:analyzer_testing/resource_provider_mixin.dart';
import 'package:meta/meta.dart';
import 'package:nocterm_lints/utilities/logger.dart';

/// A minimal test base for testing [ResolvedCorrectionProducer] assists.
///
/// Deliberately avoids `withFineDependencies: true` (used by
/// [PubPackageResolutionTest]) which conflicts with
/// [ClassDeclarationImpl.name] inside the analyzer's `serializeAstUnlinked2`.
abstract class AssistTestBase with ResourceProviderMixin {
  static final MemoryByteStore _sharedByteStore = MemoryByteStore();

  final Map<String, String> _extraPackages = {};

  AnalysisContextCollectionImpl? _contextCollection;

  String get _sdkRootPath => '/sdk';
  String get _workspaceRoot => '/home';
  String get _testPackageRoot => '$_workspaceRoot/test';

  /// The `lib/` directory of the test package.
  String get testPackageLib => '$_testPackageRoot/lib';

  Folder get _sdkRoot => newFolder(_sdkRootPath);

  // Use the test-package root (not the workspace root) as the included path,
  // so the analyzer discovers the package_config.json at
  // `$_testPackageRoot/.dart_tool/package_config.json`.
  List<String> get _collectionIncludedPaths => [_testPackageRoot];

  /// Registers a stub package for use in analyzed test files.
  ///
  /// Returns a [_PackageBuilder] to add individual source files.
  _PackageBuilder registerPackage(String name) {
    _extraPackages[name] = '/package/$name';
    return _PackageBuilder('/package/$name', this);
  }

  @mustCallSuper
  void setUp() {
    NoctermLogger.createForTesting(io.File('/tmp/nocterm_test.log'))
      ..setEnabled(false)
      ..setLogLevel(LogLevel.error);

    createMockSdk(resourceProvider: resourceProvider, root: _sdkRoot);
    _writePackageConfig();
  }

  @mustCallSuper
  Future<void> tearDown() async {
    await _contextCollection?.dispose();
    _contextCollection = null;
  }

  /// Resolves the Dart file at [posixPath] and returns the
  /// [ResolvedUnitResult].
  Future<ResolvedUnitResult> resolveFile(String posixPath) async {
    final path = convertPath(posixPath);
    final ctx = _contextFor(path);
    await ctx.applyPendingFileChanges();
    return await ctx.currentSession.getResolvedUnit(path) as ResolvedUnitResult;
  }

  // ---------------------------------------------------------------------------
  // Internal helpers
  // ---------------------------------------------------------------------------

  void _writePackageConfig() {
    // Write a minimal pubspec.yaml so that the analyzer discovers this
    // directory as a Dart project root.
    newFile('$_testPackageRoot/pubspec.yaml', 'name: test\n');

    final config = PackageConfigFileBuilder()
      ..add(name: 'test', rootPath: _testPackageRoot);

    for (final entry in _extraPackages.entries) {
      config.add(name: entry.key, rootPath: entry.value);
    }

    final configPath = '$_testPackageRoot/.dart_tool/package_config.json';
    newFile(configPath, config.toContent(pathContext: pathContext));
  }

  AnalysisContextCollectionImpl _createContextCollection() {
    return AnalysisContextCollectionImpl(
      byteStore: _sharedByteStore,
      declaredVariables: {},
      enableIndex: true,
      includedPaths: _collectionIncludedPaths.map(convertPath).toList(),
      resourceProvider: resourceProvider,
      sdkPath: _sdkRoot.path,
      // Intentionally omitting `withFineDependencies: true` — that flag
      // is not needed for assist correction producer tests.
    );
  }

  dynamic _contextFor(String path) {
    _contextCollection ??= _createContextCollection();
    return _contextCollection!.contextFor(path);
  }
}

class _PackageBuilder {
  _PackageBuilder(this._packagePath, this._base);
  final String _packagePath;
  final AssistTestBase _base;

  void addFile(String localPath, String content) {
    _base.newFile('$_packagePath/$localPath', content);
  }
}
