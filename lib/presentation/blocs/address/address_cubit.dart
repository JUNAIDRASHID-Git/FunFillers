import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/address.dart';
import '../../../domain/repositories/app_repository.dart';
import 'address_state.dart';

class AddressCubit extends Cubit<AddressState> {
  final AppRepository repository;

  AddressCubit({required this.repository}) : super(const AddressState());

  Future<void> loadAddresses() async {
    emit(state.copyWith(isLoading: true));
    try {
      final list = await repository.getAddresses();
      if (list.isEmpty) {
        emit(state.copyWith(
          addresses: [],
          clearActiveAddress: true,
          isLoading: false,
        ));
      } else {
        final defaultAddress = list.firstWhere(
          (a) => a.isDefault,
          orElse: () => list.first,
        );
        emit(state.copyWith(
          addresses: list,
          activeAddress: defaultAddress,
          isLoading: false,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    }
  }

  Future<void> saveAddress(AddressEntity address) async {
    emit(state.copyWith(isLoading: true));
    try {
      final saved = await repository.addAddress(address);
      final updatedList = await repository.getAddresses();
      emit(state.copyWith(
        addresses: updatedList,
        activeAddress: saved,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    }
  }

  Future<void> selectAddress(AddressEntity address) async {
    try {
      await repository.setDefaultAddress(address.id);
      final updatedList = await repository.getAddresses();
      emit(state.copyWith(
        addresses: updatedList,
        activeAddress: address,
      ));
    } catch (e) {
      emit(state.copyWith(activeAddress: address));
    }
  }

  Future<void> deleteAddress(String addressId) async {
    emit(state.copyWith(isLoading: true));
    try {
      await repository.deleteAddress(addressId);
      final updatedList = await repository.getAddresses();
      AddressEntity? newActive = state.activeAddress;
      if (newActive?.id == addressId) {
        newActive = updatedList.isNotEmpty ? updatedList.first : null;
      }
      emit(state.copyWith(
        addresses: updatedList,
        activeAddress: newActive,
        clearActiveAddress: newActive == null,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  void clearAddresses() {
    emit(const AddressState());
  }
}
