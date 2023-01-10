import 'package:flutter_qr_scan/flutter_qr_reader.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('getPlatformVersion', () {
    final controller = QrReaderViewController(42);
    expect(controller, isA<QrReaderViewController>());
  });
}
