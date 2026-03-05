import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:finality/common/widgets/drag_handle.dart';
import 'package:flutter/material.dart';

class BottomSheetNavigator extends StatelessWidget {
  const BottomSheetNavigator({
    super.key,
    required this.builder,
    this.useNavigator = false,
    this.backgroundColor,
  });

  final WidgetBuilder builder;
  final Color? backgroundColor;
  final bool useNavigator;

  @override
  Widget build(BuildContext context) {
    final content = useNavigator
        ? _NavigatorContent(builder: builder)
        : Builder(builder: builder);

    return Material(
      color: backgroundColor,
      child: Column(
        children: [
          const DragHandle(),
          Expanded(
            child: ScrollConfiguration(
              behavior: const _ClampingScrollBehavior(),
              child: content,
            ),
          ),
        ],
      ),
    );
  }
}

class _ClampingScrollBehavior extends ScrollBehavior {
  const _ClampingScrollBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const ClampingScrollPhysics();
  }
}

class _NavigatorContent extends StatefulWidget {
  const _NavigatorContent({
    required this.builder,
  });

  final WidgetBuilder builder;

  @override
  State<_NavigatorContent> createState() => _NavigatorContentState();
}

class _NavigatorContentState extends State<_NavigatorContent> {
  final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    BackButtonInterceptor.add(_backInterceptor);
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(_backInterceptor);
    super.dispose();
  }

  bool _backInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    final route = ModalRoute.of(context);
    if (route == null || !route.isCurrent) {
      return false;
    }
    final navigator = _navigatorKey.currentState;
    if (navigator?.canPop() ?? false) {
      navigator!.pop();
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final child = Navigator(
      key: _navigatorKey,
      onGenerateRoute: (_) => MaterialPageRoute(
        builder: widget.builder,
      ),
    );
    final platform = Theme.of(context).platform;
    return platform == TargetPlatform.iOS
        ? child
        : Theme(
            data: Theme.of(context).copyWith(
              platform: TargetPlatform.iOS,
            ),
            child: child,
          );
  }
}
