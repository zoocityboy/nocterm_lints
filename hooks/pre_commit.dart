import 'package:hooksman/hooksman.dart';

Hook main() {
    return PreCommitHook(
        tasks: [
      ReRegisterHooks(),
      ShellTask(
        name: 'Lint & Format',
        include: [Glob('**.dart')],
        exclude: [Glob('**.g.dart')],
        commands: (filePaths) => [
          'dart analyze --fatal-infos ${filePaths.join(' ')}',
          'dart format ${filePaths.join(' ')}',
        ],
      ),
    ],
    );
}
