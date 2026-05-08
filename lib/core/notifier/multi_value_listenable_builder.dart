import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/widgets.dart';

/// 用于同时监听两个 ValueListenable 的 Builder 组件
/// 类型参数 A 和 B 分别代表两个 ValueListenable 的值类型
class ValueListenableBuilder2<A, B> extends StatefulWidget {
  const ValueListenableBuilder2({
    super.key,
    required this.first,
    required this.second,
    required this.builder,
    this.child,
  });

  final ValueListenable<A> first;
  final ValueListenable<B> second;

  final Widget Function(
    BuildContext context,
    A firstValue,
    B secondValue,
    Widget? child,
  ) builder;

  final Widget? child;

  @override
  State<ValueListenableBuilder2<A, B>> createState() =>
      _ValueListenableBuilder2State<A, B>();
}

class _ValueListenableBuilder2State<A, B>
    extends State<ValueListenableBuilder2<A, B>> {
  late A _firstValue;
  late B _secondValue;

  @override
  void initState() {
    super.initState();
    _firstValue = widget.first.value;
    _secondValue = widget.second.value;
    widget.first.addListener(_onFirstValueChanged);
    widget.second.addListener(_onSecondValueChanged);
  }

  @override
  void didUpdateWidget(ValueListenableBuilder2<A, B> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.first != widget.first) {
      oldWidget.first.removeListener(_onFirstValueChanged);
      _firstValue = widget.first.value;
      widget.first.addListener(_onFirstValueChanged);
    }
    if (oldWidget.second != widget.second) {
      oldWidget.second.removeListener(_onSecondValueChanged);
      _secondValue = widget.second.value;
      widget.second.addListener(_onSecondValueChanged);
    }
  }

  @override
  void dispose() {
    widget.first.removeListener(_onFirstValueChanged);
    widget.second.removeListener(_onSecondValueChanged);
    super.dispose();
  }

  void _onFirstValueChanged() {
    setState(() {
      _firstValue = widget.first.value;
    });
  }

  void _onSecondValueChanged() {
    setState(() {
      _secondValue = widget.second.value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(
      context,
      _firstValue,
      _secondValue,
      widget.child,
    );
  }
}

/// 用于同时监听三个 ValueListenable 的 Builder 组件
class ValueListenableBuilder3<A, B, C> extends StatefulWidget {
  const ValueListenableBuilder3({
    super.key,
    required this.first,
    required this.second,
    required this.third,
    required this.builder,
    this.child,
  });

  final ValueListenable<A> first;
  final ValueListenable<B> second;
  final ValueListenable<C> third;
  final Widget Function(
    BuildContext context,
    A firstValue,
    B secondValue,
    C thirdValue,
    Widget? child,
  ) builder;
  final Widget? child;

  @override
  State<ValueListenableBuilder3<A, B, C>> createState() =>
      _ValueListenableBuilder3State<A, B, C>();
}

class _ValueListenableBuilder3State<A, B, C>
    extends State<ValueListenableBuilder3<A, B, C>> {
  late A _firstValue;
  late B _secondValue;
  late C _thirdValue;

  @override
  void initState() {
    super.initState();
    _firstValue = widget.first.value;
    _secondValue = widget.second.value;
    _thirdValue = widget.third.value;
    widget.first.addListener(_onFirstValueChanged);
    widget.second.addListener(_onSecondValueChanged);
    widget.third.addListener(_onThirdValueChanged);
  }

  @override
  void didUpdateWidget(ValueListenableBuilder3<A, B, C> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.first != widget.first) {
      oldWidget.first.removeListener(_onFirstValueChanged);
      _firstValue = widget.first.value;
      widget.first.addListener(_onFirstValueChanged);
    }
    if (oldWidget.second != widget.second) {
      oldWidget.second.removeListener(_onSecondValueChanged);
      _secondValue = widget.second.value;
      widget.second.addListener(_onSecondValueChanged);
    }
    if (oldWidget.third != widget.third) {
      oldWidget.third.removeListener(_onThirdValueChanged);
      _thirdValue = widget.third.value;
      widget.third.addListener(_onThirdValueChanged);
    }
  }

  @override
  void dispose() {
    widget.first.removeListener(_onFirstValueChanged);
    widget.second.removeListener(_onSecondValueChanged);
    widget.third.removeListener(_onThirdValueChanged);
    super.dispose();
  }

  void _onFirstValueChanged() {
    setState(() {
      _firstValue = widget.first.value;
    });
  }

  void _onSecondValueChanged() {
    setState(() {
      _secondValue = widget.second.value;
    });
  }

  void _onThirdValueChanged() {
    setState(() {
      _thirdValue = widget.third.value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(
      context,
      _firstValue,
      _secondValue,
      _thirdValue,
      widget.child,
    );
  }
}

/// 用于同时监听四个 ValueListenable 的 Builder 组件
class ValueListenableBuilder4<A, B, C, D> extends StatefulWidget {
  const ValueListenableBuilder4({
    super.key,
    required this.first,
    required this.second,
    required this.third,
    required this.fourth,
    required this.builder,
    this.child,
  });

  final ValueListenable<A> first;
  final ValueListenable<B> second;
  final ValueListenable<C> third;
  final ValueListenable<D> fourth;
  final Widget Function(
    BuildContext context,
    A firstValue,
    B secondValue,
    C thirdValue,
    D fourthValue,
    Widget? child,
  ) builder;
  final Widget? child;

  @override
  State<ValueListenableBuilder4<A, B, C, D>> createState() =>
      _ValueListenableBuilder4State<A, B, C, D>();
}

class _ValueListenableBuilder4State<A, B, C, D>
    extends State<ValueListenableBuilder4<A, B, C, D>> {
  late A _firstValue;
  late B _secondValue;
  late C _thirdValue;
  late D _fourthValue;

  @override
  void initState() {
    super.initState();
    _firstValue = widget.first.value;
    _secondValue = widget.second.value;
    _thirdValue = widget.third.value;
    _fourthValue = widget.fourth.value;
    widget.first.addListener(_onFirstValueChanged);
    widget.second.addListener(_onSecondValueChanged);
    widget.third.addListener(_onThirdValueChanged);
    widget.fourth.addListener(_onFourthValueChanged);
  }

  @override
  void didUpdateWidget(ValueListenableBuilder4<A, B, C, D> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.first != widget.first) {
      oldWidget.first.removeListener(_onFirstValueChanged);
      _firstValue = widget.first.value;
      widget.first.addListener(_onFirstValueChanged);
    }
    if (oldWidget.second != widget.second) {
      oldWidget.second.removeListener(_onSecondValueChanged);
      _secondValue = widget.second.value;
      widget.second.addListener(_onSecondValueChanged);
    }
    if (oldWidget.third != widget.third) {
      oldWidget.third.removeListener(_onThirdValueChanged);
      _thirdValue = widget.third.value;
      widget.third.addListener(_onThirdValueChanged);
    }
    if (oldWidget.fourth != widget.fourth) {
      oldWidget.fourth.removeListener(_onFourthValueChanged);
      _fourthValue = widget.fourth.value;
      widget.fourth.addListener(_onFourthValueChanged);
    }
  }

  @override
  void dispose() {
    widget.first.removeListener(_onFirstValueChanged);
    widget.second.removeListener(_onSecondValueChanged);
    widget.third.removeListener(_onThirdValueChanged);
    widget.fourth.removeListener(_onFourthValueChanged);
    super.dispose();
  }

  void _onFirstValueChanged() {
    setState(() {
      _firstValue = widget.first.value;
    });
  }

  void _onSecondValueChanged() {
    setState(() {
      _secondValue = widget.second.value;
    });
  }

  void _onThirdValueChanged() {
    setState(() {
      _thirdValue = widget.third.value;
    });
  }

  void _onFourthValueChanged() {
    setState(() {
      _fourthValue = widget.fourth.value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(
      context,
      _firstValue,
      _secondValue,
      _thirdValue,
      _fourthValue,
      widget.child,
    );
  }
}

/// 用于同时监听五个 ValueListenable 的 Builder 组件
class ValueListenableBuilder5<A, B, C, D, E> extends StatefulWidget {
  const ValueListenableBuilder5({
    super.key,
    required this.first,
    required this.second,
    required this.third,
    required this.fourth,
    required this.fifth,
    required this.builder,
    this.child,
  });

  final ValueListenable<A> first;
  final ValueListenable<B> second;
  final ValueListenable<C> third;
  final ValueListenable<D> fourth;
  final ValueListenable<E> fifth;
  final Widget Function(
    BuildContext context,
    A firstValue,
    B secondValue,
    C thirdValue,
    D fourthValue,
    E fifthValue,
    Widget? child,
  ) builder;
  final Widget? child;

  @override
  State<ValueListenableBuilder5<A, B, C, D, E>> createState() =>
      _ValueListenableBuilder5State<A, B, C, D, E>();
}

class _ValueListenableBuilder5State<A, B, C, D, E>
    extends State<ValueListenableBuilder5<A, B, C, D, E>> {
  late A _firstValue;
  late B _secondValue;
  late C _thirdValue;
  late D _fourthValue;
  late E _fifthValue;

  @override
  void initState() {
    super.initState();
    _firstValue = widget.first.value;
    _secondValue = widget.second.value;
    _thirdValue = widget.third.value;
    _fourthValue = widget.fourth.value;
    _fifthValue = widget.fifth.value;
    widget.first.addListener(_onFirstValueChanged);
    widget.second.addListener(_onSecondValueChanged);
    widget.third.addListener(_onThirdValueChanged);
    widget.fourth.addListener(_onFourthValueChanged);
    widget.fifth.addListener(_onFifthValueChanged);
  }

  @override
  void didUpdateWidget(ValueListenableBuilder5<A, B, C, D, E> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.first != widget.first) {
      oldWidget.first.removeListener(_onFirstValueChanged);
      _firstValue = widget.first.value;
      widget.first.addListener(_onFirstValueChanged);
    }
    if (oldWidget.second != widget.second) {
      oldWidget.second.removeListener(_onSecondValueChanged);
      _secondValue = widget.second.value;
      widget.second.addListener(_onSecondValueChanged);
    }
    if (oldWidget.third != widget.third) {
      oldWidget.third.removeListener(_onThirdValueChanged);
      _thirdValue = widget.third.value;
      widget.third.addListener(_onThirdValueChanged);
    }
    if (oldWidget.fourth != widget.fourth) {
      oldWidget.fourth.removeListener(_onFourthValueChanged);
      _fourthValue = widget.fourth.value;
      widget.fourth.addListener(_onFourthValueChanged);
    }
    if (oldWidget.fifth != widget.fifth) {
      oldWidget.fifth.removeListener(_onFifthValueChanged);
      _fifthValue = widget.fifth.value;
      widget.fifth.addListener(_onFifthValueChanged);
    }
  }

  @override
  void dispose() {
    widget.first.removeListener(_onFirstValueChanged);
    widget.second.removeListener(_onSecondValueChanged);
    widget.third.removeListener(_onThirdValueChanged);
    widget.fourth.removeListener(_onFourthValueChanged);
    widget.fifth.removeListener(_onFifthValueChanged);
    super.dispose();
  }

  void _onFirstValueChanged() {
    setState(() {
      _firstValue = widget.first.value;
    });
  }

  void _onSecondValueChanged() {
    setState(() {
      _secondValue = widget.second.value;
    });
  }

  void _onThirdValueChanged() {
    setState(() {
      _thirdValue = widget.third.value;
    });
  }

  void _onFourthValueChanged() {
    setState(() {
      _fourthValue = widget.fourth.value;
    });
  }

  void _onFifthValueChanged() {
    setState(() {
      _fifthValue = widget.fifth.value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(
      context,
      _firstValue,
      _secondValue,
      _thirdValue,
      _fourthValue,
      _fifthValue,
      widget.child,
    );
  }
}

/// 用于同时监听六个 ValueListenable 的 Builder 组件
class ValueListenableBuilder6<A, B, C, D, E, F> extends StatefulWidget {
  const ValueListenableBuilder6({
    super.key,
    required this.first,
    required this.second,
    required this.third,
    required this.fourth,
    required this.fifth,
    required this.sixth,
    required this.builder,
    this.child,
  });

  final ValueListenable<A> first;
  final ValueListenable<B> second;
  final ValueListenable<C> third;
  final ValueListenable<D> fourth;
  final ValueListenable<E> fifth;
  final ValueListenable<F> sixth;
  final Widget Function(
    BuildContext context,
    A firstValue,
    B secondValue,
    C thirdValue,
    D fourthValue,
    E fifthValue,
    F sixthValue,
    Widget? child,
  ) builder;
  final Widget? child;

  @override
  State<ValueListenableBuilder6<A, B, C, D, E, F>> createState() =>
      _ValueListenableBuilder6State<A, B, C, D, E, F>();
}

class _ValueListenableBuilder6State<A, B, C, D, E, F>
    extends State<ValueListenableBuilder6<A, B, C, D, E, F>> {
  late A _firstValue;
  late B _secondValue;
  late C _thirdValue;
  late D _fourthValue;
  late E _fifthValue;
  late F _sixthValue;

  @override
  void initState() {
    super.initState();
    _firstValue = widget.first.value;
    _secondValue = widget.second.value;
    _thirdValue = widget.third.value;
    _fourthValue = widget.fourth.value;
    _fifthValue = widget.fifth.value;
    _sixthValue = widget.sixth.value;
    widget.first.addListener(_onFirstValueChanged);
    widget.second.addListener(_onSecondValueChanged);
    widget.third.addListener(_onThirdValueChanged);
    widget.fourth.addListener(_onFourthValueChanged);
    widget.fifth.addListener(_onFifthValueChanged);
    widget.sixth.addListener(_onSixthValueChanged);
  }

  @override
  void didUpdateWidget(ValueListenableBuilder6<A, B, C, D, E, F> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.first != widget.first) {
      oldWidget.first.removeListener(_onFirstValueChanged);
      _firstValue = widget.first.value;
      widget.first.addListener(_onFirstValueChanged);
    }
    if (oldWidget.second != widget.second) {
      oldWidget.second.removeListener(_onSecondValueChanged);
      _secondValue = widget.second.value;
      widget.second.addListener(_onSecondValueChanged);
    }
    if (oldWidget.third != widget.third) {
      oldWidget.third.removeListener(_onThirdValueChanged);
      _thirdValue = widget.third.value;
      widget.third.addListener(_onThirdValueChanged);
    }
    if (oldWidget.fourth != widget.fourth) {
      oldWidget.fourth.removeListener(_onFourthValueChanged);
      _fourthValue = widget.fourth.value;
      widget.fourth.addListener(_onFourthValueChanged);
    }
    if (oldWidget.fifth != widget.fifth) {
      oldWidget.fifth.removeListener(_onFifthValueChanged);
      _fifthValue = widget.fifth.value;
      widget.fifth.addListener(_onFifthValueChanged);
    }
    if (oldWidget.sixth != widget.sixth) {
      oldWidget.sixth.removeListener(_onSixthValueChanged);
      _sixthValue = widget.sixth.value;
      widget.sixth.addListener(_onSixthValueChanged);
    }
  }

  @override
  void dispose() {
    widget.first.removeListener(_onFirstValueChanged);
    widget.second.removeListener(_onSecondValueChanged);
    widget.third.removeListener(_onThirdValueChanged);
    widget.fourth.removeListener(_onFourthValueChanged);
    widget.fifth.removeListener(_onFifthValueChanged);
    widget.sixth.removeListener(_onSixthValueChanged);
    super.dispose();
  }

  void _onFirstValueChanged() {
    setState(() {
      _firstValue = widget.first.value;
    });
  }

  void _onSecondValueChanged() {
    setState(() {
      _secondValue = widget.second.value;
    });
  }

  void _onThirdValueChanged() {
    setState(() {
      _thirdValue = widget.third.value;
    });
  }

  void _onFourthValueChanged() {
    setState(() {
      _fourthValue = widget.fourth.value;
    });
  }

  void _onFifthValueChanged() {
    setState(() {
      _fifthValue = widget.fifth.value;
    });
  }

  void _onSixthValueChanged() {
    setState(() {
      _sixthValue = widget.sixth.value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(
      context,
      _firstValue,
      _secondValue,
      _thirdValue,
      _fourthValue,
      _fifthValue,
      _sixthValue,
      widget.child,
    );
  }
}
