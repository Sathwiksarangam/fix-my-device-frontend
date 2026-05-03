import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../core/layouts/app_scaffold.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../data/models/device.dart';
import '../../data/services/api_device_service.dart';

class DevicesListScreen extends StatelessWidget {
  const DevicesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Devices',
      currentRoute: AppRoutes.devices,
      subtitle: 'Browse connected Windows devices and view their system details.',
      body: FutureBuilder<List<dynamic>>(
        future: ApiDeviceService().getDevices(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Could not load devices: ${snapshot.error}'),
              ),
            );
          }

          final devices = snapshot.data ?? [];

          if (devices.isEmpty) {
            return const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('No devices connected yet.'),
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: devices.map((device) {
              final deviceName = device['deviceName'] ?? 'Unknown Device';
              final systemType = device['systemType'] ?? 'Windows';
              final lastSeen = device['lastSeenAt'] ?? 'Not available';
              final status = device['status'] ?? 'Online';
              final deviceId = device['id'] ?? '';

              final processor = device['processor'] ?? 'Processor not available';
              final installedRam = device['installedRam'] ?? 'RAM not available';
              final totalStorage = device['totalStorage'] ?? 'Storage not available';
              final windowsVersion = device['windowsVersion'] ?? systemType;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                      child: Icon(
                        Icons.laptop_windows_rounded,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    title: Text(
                      deviceName,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        '$windowsVersion\n$processor\nRAM: $installedRam • Storage: $totalStorage',
                      ),
                    ),
                    trailing: SizedBox(
                      width: 130,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          StatusChip(
                            status: status.toString().toLowerCase() == 'online'
                                ? DeviceStatus.healthy
                                : DeviceStatus.offline,
                          ),
                          const SizedBox(height: 4),
                          Flexible(
                            child: Text(
                              lastSeen.toString(),
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.black54,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    onTap: () => context.go(
                      '${AppRoutes.deviceDetails}?id=$deviceId',
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
