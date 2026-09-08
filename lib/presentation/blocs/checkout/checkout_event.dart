import 'package:equatable/equatable.dart';
import '../../../domain/entities/address.dart';

abstract class CheckoutEvent extends Equatable {
  const CheckoutEvent();
  @override
  List<Object?> get props => [];
}

class SelectAddressRequested extends CheckoutEvent {
  final AddressEntity address;
  const SelectAddressRequested(this.address);

  @override
  List<Object?> get props => [address];
}

class SelectPaymentMethodRequested extends CheckoutEvent {
  final String paymentMethod;
  const SelectPaymentMethodRequested({required this.paymentMethod});

  @override
  List<Object?> get props => [paymentMethod];
}

class GoToStepRequested extends CheckoutEvent {
  final int step;
  const GoToStepRequested({required this.step});

  @override
  List<Object?> get props => [step];
}

typedef SelectPaymentMethod = SelectPaymentMethodRequested;
typedef GoToStep = GoToStepRequested;
