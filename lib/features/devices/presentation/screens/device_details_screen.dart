import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../core/layouts/app_scaffold.dart';
import '../../../../core/widgets/action_button.dart';
import '../../../../core/widgets/device_detail_row.dart';
import '../../../../core/widgets/info_card.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../data/models/device.dart';
import '../../data/services/api_device_service.dart';

class DeviceDetailsScreen extends StatelessWidget {
  const DeviceDetailsScreen({
    super.key,
    this.deviceId,
  });

  final String? deviceId;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Device Details',
      currentRoute: AppRoutes.devices,
      subtitle:
          'Review live system metrics, storage details, and connected drive information for this device.',
      body: FutureBuilder<List<dynamic>>(
        future: ApiDeviceService().getDevices(),
        builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Text('Could not load device details: ${snapshot.error}'),
              ),
            );
          }

          final List<dynamic> devices = snapshot.data ?? <dynamic>[];
          final dynamic device = devices.cast<dynamic?>().firstWhere(
                (dynamic item) =>
                    item != null &&
                    '${item['id'] ?? item['deviceId'] ?? ''}' == '${deviceId ?? ''}',
                orElse: () => devices.isNotEmpty ? devices.first : null,
              );

          if (device == null) {
            return const Card(
              child: Padding(
                padding: EdgeInsets.all(18),
                child: Text('No device details available.'),
              ),
            );
          }

          final String resolvedDeviceId =
              '${device['id'] ?? device['deviceId'] ?? ''}';
          final String deviceName =
              '${device['deviceName'] ?? 'Unknown Device'}';
          final String processor =
              '${device['processor'] ?? 'Processor not available'}';
          final String installedRam =
              '${device['installedRam'] ?? device['ram'] ?? 'RAM not available'}';
          final String graphicsCard =
              '${device['graphicsCard'] ?? device['graphics'] ?? 'Graphics not available'}';
          final String totalStorage =
              '${device['totalStorage'] ?? device['storage'] ?? 'Storage not available'}';
          final String freeStorage =
              '${device['freeStorage'] ?? 'Free storage not available'}';
          final String systemType =
              '${device['systemType'] ?? 'System type not available'}';
          final String windowsVersion =
              '${device['windowsVersion'] ?? 'Windows version not available'}';
          final String lastSeenAt =
              '${device['lastSeenAt'] ?? 'Not available'}';
          final String status = '${device['status'] ?? 'Online'}';
          final List<dynamic> drives =
              (device['drives'] as List<dynamic>?) ?? <dynamic>[];

          final DeviceStatus deviceStatus =
              status.toLowerCase() == 'online'
                  ? DeviceStatus.healthy
                  : DeviceStatus.offline;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      windowsVersion,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.black54,
                          ),
                    ),
                  ),
                  StatusChip(status: deviceStatus),
                ],
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: <Widget>[
                  SizedBox(
                    width: 260,
                    child: InfoCard(
                      title: 'Device Name',
                      value: deviceName,
                      subtitle: 'Last seen $lastSeenAt',
                      icon: Icons.computer_rounded,
                    ),
                  ),
                  SizedBox(
                    width: 260,
                    child: InfoCard(
                      title: 'Storage',
                      value: totalStorage,
                      subtitle: 'Free space: $freeStorage',
                      icon: Icons.sd_storage_rounded,
                    ),
                  ),
                  SizedBox(
                    width: 260,
                    child: InfoCard(
                      title: 'Graphics',
                      value: graphicsCard,
                      subtitle: systemType,
                      icon: Icons.memory_rounded,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                deviceName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    children: <Widget>[
                      DeviceDetailRow(label: 'Device ID', value: resolvedDeviceId),
                      DeviceDetailRow(label: 'Processor', value: processor),
                      DeviceDetailRow(label: 'Installed RAM', value: installedRam),
                      DeviceDetailRow(label: 'Graphics Card', value: graphicsCard),
                      DeviceDetailRow(label: 'Total Storage', value: totalStorage),
                      DeviceDetailRow(label: 'Free Storage', value: freeStorage),
                      DeviceDetailRow(label: 'System Type', value: systemType),
                      DeviceDetailRow(
                        label: 'Windows Version',
                        value: windowsVersion,
                      ),
                      DeviceDetailRow(label: 'Last Seen', value: lastSeenAt),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Drives',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    children: drives.isEmpty
                        ? const <Widget>[
                            DeviceDetailRow(
                              label: 'Drives',
                              value: 'No drive information available',
                            ),
                          ]
                        : drives.map<Widget>((dynamic drive) {
                            final String driveLetter =
                                '${drive['driveLetter'] ?? 'Unknown'}';
                            final String totalSize =
                                '${drive['totalSize'] ?? 'Unknown'}';
                            final String freeSpace =
                                '${drive['freeSpace'] ?? 'Unknown'}';

                            return DeviceDetailRow(
                              label: driveLetter,
                              value:
                                  'Total: $totalSize • Free: $freeSpace',
                            );
                          }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: <Widget>[
                  SizedBox(
                    width: 210,
                    child: ActionButton(
                      label: 'Browse Files',
                      icon: Icons.folder_open_rounded,
                      onPressed: () => context.go(
                        '${AppRoutes.fileBrowser}?id=$resolvedDeviceId',
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 210,
                    child: ActionButton(
                      label: 'Transfer Files',
                      icon: Icons.upload_file_rounded,
                      onPressed: () => context.go(
                        '${AppRoutes.fileTransfer}?id=$resolvedDeviceId',
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 210,
                    child: ActionButton(
                      label: 'Troubleshoot',
                      icon: Icons.build_rounded,
                      onPressed: () => context.go(
                        '${AppRoutes.troubleshooting}?id=$resolvedDeviceId',
                      ),
                      isPrimary: false,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
