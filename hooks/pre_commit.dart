import 'package:hooksman/hooksman.dart';

Hook main() {
  return PreCommitHook(
    tasks: [
      // ReRegisterHooks(),
      ShellTask(
        name: 'Lint & Format',
        include: [Glob('lib/**.dart')],
        exclude: [Glob('hooks/**.dart'), Glob('example/**.dart')],
        commands: (filePaths) => [
          'dart analyze --fatal-infos ${filePaths.join(' ')}',
          'dart format ${filePaths.join(' ')}',
        ],
      ),
    ],
  );
}
