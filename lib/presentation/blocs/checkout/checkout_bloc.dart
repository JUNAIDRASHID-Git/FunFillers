import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/datasources/app_data_source.dart';
import 'checkout_event.dart';
import 'checkout_state.dart';

class CheckoutBloc extends Bloc<CheckoutEvent, CheckoutState> {
  CheckoutBloc()
      : super(CheckoutState(
          addresses: AppDataSource.mockAddresses,
          selectedAddress: AppDataSource.mockAddresses.isNotEmpty ? AppDataSource.mockAddresses[0] : null,
          selectedPaymentMethod: 'card',
          currentStep: 1,
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
