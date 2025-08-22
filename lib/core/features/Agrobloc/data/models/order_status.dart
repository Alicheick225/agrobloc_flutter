enum OrderStatus {
  waitingPlanteurConfirmation,
  waitingPayment,
  waitingDelivery,
  waitingReception, // <-- ajouté
  cancelled, // <-- ajouté
  completed,
}

class OrderTrackingData {
  final String orderId;
  final OrderStatus currentStatus;
  final DateTime createdAt;
  final DateTime? planteurConfirmedAt;
  final DateTime? paymentInitiatedAt;
  final DateTime? deliveredAt;
  final DateTime? receivedAt;
  final String planteurName;
  final String acheteurName;

  OrderTrackingData({
    required this.orderId,
    required this.currentStatus,
    required this.createdAt,
    required this.planteurName,
    required this.acheteurName,
    this.planteurConfirmedAt,
    this.paymentInitiatedAt,
    this.deliveredAt,
    this.receivedAt,
  });
}
