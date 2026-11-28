import 'package:flutter_test/flutter_test.dart';
import 'package:afos_app/features/booking/domain/booking_order.dart';

void main() {
  group('BookingOrder Domain Tests', () {
    test('parses BookingOrder from json correctly', () {
      final json = {
        'id': 'b-uuid-999',
        'booking_code': 'AFOS-B2C-1234567',
        'order_type': 'B2C_RETAIL',
        'customer_id': 'cust-uuid-1',
        'corporate_account_id': null,
        'status': 'PENDING_PAYMENT',
        'total_amount': 700000.0,
        'security_deposit_amount': 500000.0,
        'down_payment_amount': 210000.0,
        'created_at': '2026-11-28T07:00:00Z',
      };

      final order = BookingOrder.fromJson(json);

      expect(order.id, 'b-uuid-999');
      expect(order.bookingCode, 'AFOS-B2C-1234567');
      expect(order.orderType, 'B2C_RETAIL');
      expect(order.isB2C, isTrue);
      expect(order.isB2B, isFalse);
      expect(order.totalAmount, 700000.0);
      expect(order.downPaymentAmount, 210000.0);
      expect(order.isPending, isTrue);
    });
  });
}
