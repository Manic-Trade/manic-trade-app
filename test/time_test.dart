import 'package:flutter_test/flutter_test.dart';

void main() {
  group('time', () {
    test('should create valid time',
        () async {
      var time = DateTime.parse("2025-09-12T10:59:55.728Z");
      print("time: ${time.millisecondsSinceEpoch}");
    });

   
  });
}
