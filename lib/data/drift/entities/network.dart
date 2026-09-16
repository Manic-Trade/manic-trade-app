import 'explorer_links.dart';
import 'token_unit.dart';

class Network {
  final String networkCode;
  final String name;
  final String derivationPath;
  final NetworkPlatform platform;
  final TokenUnit nativeTokenUnit;
  final bool enabled;
  final String? iconUrl;
  final ExplorerLinks? links;
  final int? evmChainId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Network(
      {required this.networkCode,
      required this.name,
      required this.derivationPath,
      required this.platform,
      required this.nativeTokenUnit,
      required this.enabled,
      this.iconUrl,
      this.links,
      this.evmChainId,
      this.createdAt,
      this.updatedAt});

  bool get isEvm => evmChainId != null;

  @override
  String toString() {
    return (StringBuffer('Network(')
          ..write('networkCode: $networkCode, ')
          ..write('name: $name, ')
          ..write('derivationPath: $derivationPath, ')
          ..write('platform: $platform, ')
          ..write('nativeTokenUnit: $nativeTokenUnit, ')
          ..write('enabled: $enabled, ')
          ..write('iconUrl: $iconUrl, ')
          ..write('links: $links, ')
          ..write('evmChainId: $evmChainId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      networkCode,
      name,
      derivationPath,
      platform,
      nativeTokenUnit,
      enabled,
      iconUrl,
      links,
      evmChainId,
      createdAt,
      updatedAt);
      
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Network &&
          other.networkCode == networkCode &&
          other.name == name &&
          other.derivationPath == derivationPath &&
          other.platform == platform &&
          other.nativeTokenUnit == nativeTokenUnit &&
          other.enabled == enabled &&
          other.iconUrl == iconUrl &&
          other.links == links &&
          other.evmChainId == evmChainId &&
          other.createdAt == createdAt &&
          other.updatedAt == updatedAt);
}



/// 网络平台类型
///
/// 不要修改枚举变量的顺序会导致数据库类型转换错误
/// 该枚举通过枚举的下标与数据库int类型进行转换，使用枚举的index值
enum NetworkPlatform {
  //不要修改枚举变量的顺序会导致数据库类型转换错误,按下标存入数据库
  solana,
  ethereum,
  bitcoin,
  doge;
}