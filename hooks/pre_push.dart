import 'package:hooksman/hooksman.dart';

Hook main() {
    return PrePushHook(
        tasks: [
      ReRegisterHooks(),
      ShellTask(
        name: 'Tests',
        include: [Glob('**.dart')],
        exclude: [Glob('hooks/**')],
        commands: (filePaths) => ['sip test --concurrent --bail'],
      ),
    ],
  );
}
