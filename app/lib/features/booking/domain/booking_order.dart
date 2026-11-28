/// Master Booking and Booking Item domain models
class BookingOrder {
  final String id;
  final String bookingCode;
  final String orderType; // 'B2C_RETAIL', 'B2B_CORPORATE'
  final String? customerId;
  final String status;
  final double totalAmount;
  final double securityDepositAmount;
  final double downPaymentAmount;
  final DateTime createdAt;

  const BookingOrder({
    required this.id,
    required this.bookingCode,
    required this.orderType,
    this.customerId,
    required this.status,
    required this.totalAmount,
    required this.securityDepositAmount,
    required this.downPaymentAmount,
    required this.createdAt,
  });

  factory BookingOrder.fromJson(Map<String, dynamic> json) {
    return BookingOrder(
      id: json['id'] as String,
      bookingCode: json['booking_code'] as String,
      orderType: json['order_type'] as String? ?? 'B2C_RETAIL',
      customerId: json['customer_id'] as String?,
      status: json['status'] as String? ?? 'DRAFT',
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
      securityDepositAmount: (json['security_deposit_amount'] as num?)?.toDouble() ?? 0.0,
      downPaymentAmount: (json['down_payment_amount'] as num?)?.toDouble() ?? 0.0,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
    );
  }

  bool get isB2C => orderType == 'B2C_RETAIL';
  bool get isB2B => orderType == 'B2B_CORPORATE';
  bool get isPending => status == 'PENDING_PAYMENT' || status == 'PENDING_VERIFICATION';
}
