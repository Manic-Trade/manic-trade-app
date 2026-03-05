import 'package:logger/logger.dart';

import '../env/env_config.dart';

final logger = Env.isDebug
    ? Logger(
        printer: PrettyPrinter(),
      )
    : Logger(
        filter: ProductionFilter(),
        level: Level.off,
        printer: SimplePrinter(),
      );
