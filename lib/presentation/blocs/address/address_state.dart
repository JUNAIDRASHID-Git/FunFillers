import 'package:equatable/equatable.dart';
import '../../../domain/entities/address.dart';

class AddressState extends Equatable {
  final List<AddressEntity> addresses;
  final AddressEntity? activeAddress;
  final bool isLoading;
  final String? error;

  const AddressState({
    this.addresses = const [],
    this.activeAddress,
    this.isLoading = false,
    this.error,
  });

  AddressState copyWith({
    List<AddressEntity>? addresses,
    AddressEntity? activeAddress,
    bool clearActiveAddress = false,
    bool? isLoading,
    String? error,
  }) {
    return AddressState(
      addresses: addresses ?? this.addresses,
      activeAddress: clearActiveAddress ? null : (activeAddress ?? this.activeAddress),
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [addresses, activeAddress, isLoading, error];
}
