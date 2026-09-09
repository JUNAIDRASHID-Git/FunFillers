import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/address.dart';
import '../blocs/address/address_cubit.dart';
import '../blocs/address/address_state.dart';
import '../screens/address_selection_screen.dart';

class LocationHeaderWidget extends StatelessWidget {
  const LocationHeaderWidget({super.key});

  Future<void> _handleAddressTap(BuildContext context, AddressEntity? currentAddress) async {
    Address? addressModel;
    if (currentAddress != null) {
      addressModel = Address(
        id: currentAddress.id,
        title: currentAddress.name,
        label: currentAddress.label,
        fullAddress: currentAddress.fullAddress,
        city: currentAddress.city,
        state: currentAddress.state,
        country: currentAddress.country,
        pincode: currentAddress.pincode,
        latitude: currentAddress.latitude,
        longitude: currentAddress.longitude,
        isDefault: currentAddress.isDefault,
      );
    }

    final cubit = context.read<AddressCubit>();

    final Address? selected = await Navigator.push<Address>(
      context,
      MaterialPageRoute(
        builder: (_) => AddressSelectionScreen(initialAddress: addressModel),
      ),
    );

    if (selected != null) {
      final newEntity = AddressEntity(
        id: selected.id,
        name: selected.title,
        fullAddress: selected.fullAddress,
        city: selected.city,
        state: selected.state,
        pincode: selected.pincode,
        label: selected.label,
        isDefault: true,
        country: selected.country,
        latitude: selected.latitude,
        longitude: selected.longitude,
      );
      await cubit.saveAddress(newEntity);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AddressCubit, AddressState>(
      builder: (context, state) {
        final active = state.activeAddress;
        final hasAddress = active != null && active.fullAddress.trim().isNotEmpty;

        String line1 = 'Select Delivery address';
        String line2 = 'Tap to choose location';

        if (hasAddress) {
          final full = active.fullAddress.trim();
          final parts = full.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();

          if (parts.length >= 3) {
            line1 = '${parts[0]}, ${parts[1]},';
            line2 = parts.sublist(2).join(' – ');
          } else if (parts.length == 2) {
            line1 = '${parts[0]},';
            line2 = parts[1];
          } else {
            line1 = full;
            line2 = [
              if (active.city.isNotEmpty) active.city,
              if (active.state.isNotEmpty) active.state,
              if (active.pincode.isNotEmpty) active.pincode,
            ].join(' – ');
            if (line2.isEmpty) {
              line2 = 'Default Address';
            }
          }
        }

        return InkWell(
          onTap: () => _handleAddressTap(context, active),
          borderRadius: BorderRadius.circular(30),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.35),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Teardrop white location icon
                    const Icon(
                      Icons.location_on_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                    const SizedBox(width: 12),
                    // Address Text (2 lines)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            line1,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              height: 1.2,
                              shadows: [
                                Shadow(
                                  offset: Offset(0, 1),
                                  blurRadius: 3,
                                  color: Colors.black38,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            line2,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withValues(alpha: 0.95),
                              height: 1.2,
                              shadows: const [
                                Shadow(
                                  offset: Offset(0, 1),
                                  blurRadius: 3,
                                  color: Colors.black38,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Right Chevron Arrow
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
