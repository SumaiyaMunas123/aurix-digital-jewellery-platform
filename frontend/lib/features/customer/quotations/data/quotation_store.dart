import 'package:flutter/foundation.dart';

class QuotationRequest {
  final String id;
  final String productName;
  final String jewellerName;
  final String customerName;
  final String size;
  final String quantity;
  final String notes;
  final DateTime createdAt;
  final String status;

  const QuotationRequest({
    required this.id,
    required this.productName,
    required this.jewellerName,
    required this.customerName,
    required this.size,
    required this.quantity,
    required this.notes,
    required this.createdAt,
    this.status = 'Pending',
  });

  QuotationRequest copyWith({
    String? id,
    String? productName,
    String? jewellerName,
    String? customerName,
    String? size,
    String? quantity,
    String? notes,
    DateTime? createdAt,
    String? status,
  }) {
    return QuotationRequest(
      id: id ?? this.id,
      productName: productName ?? this.productName,
      jewellerName: jewellerName ?? this.jewellerName,
      customerName: customerName ?? this.customerName,
      size: size ?? this.size,
      quantity: quantity ?? this.quantity,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
    );
  }
}

class QuotationStore extends ChangeNotifier {
  final List<QuotationRequest> _requests = [
    QuotationRequest(
      id: 'q1',
      productName: 'Classic Gold Ring',
      jewellerName: 'Luxe Jewels',
      customerName: 'Achchu',
      size: 'Standard',
      quantity: '1',
      notes: 'Need delivery before month end.',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    QuotationRequest(
      id: 'q2',
      productName: 'Bridal Necklace',
      jewellerName: 'Aurora Gold',
      customerName: 'Ishara',
      size: 'Custom',
      quantity: '1',
      notes: 'Can you reduce weight slightly?',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  List<QuotationRequest> get requests => List.unmodifiable(_requests);

  List<QuotationRequest> requestsForJeweller(String jewellerName) {
    return _requests.where((e) => e.jewellerName == jewellerName).toList();
  }

  void addRequest(QuotationRequest request) {
    _requests.insert(0, request);
    notifyListeners();
  }

  void updateStatus(String id, String status) {
    final index = _requests.indexWhere((e) => e.id == id);
    if (index == -1) return;

    _requests[index] = _requests[index].copyWith(status: status);
    notifyListeners();
  }
}