import 'package:flutter_bloc/flutter_bloc.dart';
import 'checkout_event.dart';
import 'checkout_state.dart';

class CheckoutBloc extends Bloc<CheckoutEvent, CheckoutState> {
  CheckoutBloc()
      : super(const CheckoutState(
          addresses: [],
          selectedAddress: null,
          selectedPaymentMethod: 'upi',
          currentStep: 2,
        )) {
    on<SelectAddressRequested>((event, emit) {
      emit(state.copyWith(selectedAddress: event.address));
    });

    on<SelectPaymentMethodRequested>((event, emit) {
      emit(state.copyWith(selectedPaymentMethod: event.paymentMethod));
    });

    on<GoToStepRequested>((event, emit) {
      emit(state.copyWith(currentStep: event.step));
    });
  }
}
