import 'package:equatable/equatable.dart';
import '../../../domain/entities/address.dart';

class CheckoutState extends Equatable {
  final List<AddressEntity> addresses;
  final AddressEntity? selectedAddress;
  final String selectedPaymentMethod;
  final int currentStep;

  const CheckoutState({
    required this.addresses,
    this.selectedAddress,
    this.selectedPaymentMethod = 'UPI',
    this.currentStep = 1,
  });

  CheckoutState copyWith({
    List<AddressEntity>? addresses,
    AddressEntity? selectedAddress,
    String? selectedPaymentMethod,
    int? currentStep,
  }) {
    return CheckoutState(
      addresses: addresses ?? this.addresses,
      selectedAddress: selectedAddress ?? this.selectedAddress,
      selectedPaymentMethod: selectedPaymentMethod ?? this.selectedPaymentMethod,
      currentStep: currentStep ?? this.currentStep,
    );
  }

  @override
  List<Object?> get props => [
        addresses,
        selectedAddress,
        selectedPaymentMethod,
        currentStep,
      ];
}
