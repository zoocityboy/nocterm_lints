---
applyTo: "packages/nocterm_lints/**/*.dart"
description: "Standards and best practices for writing Dart analyzer plugins using the modern analysis_server_plugin framework"
---

# Analysis Server Plugin Guidelines

Use these guidelines when developing analyzer plugins using the `analysis_server_plugin` package. This framework (available since Dart 3.10) replaces the legacy `analyzer_plugin` system.

## Plugin Architecture

### Protocol & Entrypoint
- Plugins must provide a top-level `plugin` variable in `lib/main.dart`.
- The plugin class must extend `Plugin`.

### Registration
- Use `register(PluginRegistry registry)` to define capabilities.
- **Rules**: Register via `registry.registerWarningRule(Rule())` (enabled by default) or `registry.registerLintRule(Rule())` (must be enabled in options).
- **Fixes**: Use `registry.registerFixForRule(Rule.code, Producer.new)`.
- **Assists**: Use `registry.registerAssist(Producer.new)`.

## Writing Analysis Rules

### Rule Declaration
- Extend `AnalysisRule`.
- Define a `static const LintCode code` to identify the diagnostic.
- Use `registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context)` to register your visitor.

### Visitor Implementation
- Extend `SimpleAstVisitor<void>`.
- Use `rule.reportAtNode(node)` or `rule.reportAtToken(token)` to flag issues.
- Access semantic information (like types) via `context` if needed.

## Quick Fixes and Assists

### Correction Producers
- Extend `ResolvedCorrectionProducer`.
- Require `super.context` in the constructor.
- Implement `Future<void> compute(ChangeBuilder builder)`.
- Use `builder.addDartFileEdit` to specify changes (insertions, deletions, replacements).

### Kinds and Priorities
- **Fixes**: Define a `FixKind` with an ID like `dart.fix.my_plugin.rule_name`.
- **Assists**: Define an `AssistKind` with an ID like `dart.assist.my_plugin.action`.
- Use `CorrectionApplicability.singleLocation` as the default applicability.

## Testing Standards

### Test Setup
- Use `analyzer_testing` and `test_reflective_loader`.
- Extend `AnalysisRuleTest`.
- Annotate the class with `@reflectiveTest`.
- Override `setUp` to instantiate `rule` and call `super.setUp()`.

### Assertions
- `test_` prefix for test methods.
- Use `assertDiagnostics(source, [lint(offset, length)])` for rules.
- Use `assertHasFix(expectedSource)` to verify fixes.
- Use `newPackage(name).addFile(path, content)` in `setUp` to create mock dependencies for resolution.

## Configuration & Usage

### analysis_options.yaml
- Enable plugins in a top-level `plugins` section:
  ```yaml
  plugins:
    nocterm_lints:
      path: ./packages/nocterm_lints
  ```
- Enable specific lints under the plugin name:
  ```yaml
  plugins:
    nocterm_lints:
      diagnostics:
        my_rule_name: true
  ```

### Suppression
- Users can suppress plugin diagnostics using `// ignore: plugin_name/rule_name`.

**Documnetation: **

- [writing a plugin](https://raw.githubusercontent.com/dart-lang/sdk/refs/heads/main/pkg/analysis_server_plugin/doc/writing_a_plugin.md)
- [writing assists](https://raw.githubusercontent.com/dart-lang/sdk/refs/heads/main/pkg/analysis_server_plugin/doc/writing_assists.md)
- [writing fixes](https://raw.githubusercontent.com/dart-lang/sdk/refs/heads/main/pkg/analysis_server_plugin/doc/writing_fixes.md)
- [writing rules](https://raw.githubusercontent.com/dart-lang/sdk/refs/heads/main/pkg/analysis_server_plugin/doc/writing_rules.md)
- [using plugins](https://raw.githubusercontent.com/dart-lang/sdk/refs/heads/main/pkg/analysis_server_plugin/doc/using_plugins.md)