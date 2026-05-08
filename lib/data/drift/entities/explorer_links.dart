
import 'package:equatable/equatable.dart';
import 'package:finality/common/utils/string_extensions.dart';

class ExplorerLinks extends Equatable {
  final String? tx;
  final String? address;

  const ExplorerLinks(this.tx, this.address);

  String? formatTXUrl(String? hash) {
    var tx = this.tx;
    if (tx == null || tx.isEmpty) {
      return null;
    }
    if (hash != null) {
      var replacePlaceholders = tx.replacePlaceholders([hash]);
      if (replacePlaceholders.isUrl()) {
        return replacePlaceholders;
      }
    }
    return null;
  }

  @override
  List<Object?> get props => [tx, address];
}
