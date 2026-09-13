import 'package:flutter/material.dart';

class SstpManualProxyFields extends StatelessWidget {
  final String proxyType;
  final ValueChanged<String> onProxyTypeChanged;
  final String proxyIp;
  final ValueChanged<String> onProxyIpChanged;
  final int proxyPort;
  final ValueChanged<String> onProxyPortChanged;
  final String proxyUser;
  final ValueChanged<String> onProxyUserChanged;
  final String proxyPass;
  final ValueChanged<String> onProxyPassChanged;

  const SstpManualProxyFields({
    super.key,
    required this.proxyType,
    required this.onProxyTypeChanged,
    required this.proxyIp,
    required this.onProxyIpChanged,
    required this.proxyPort,
    required this.onProxyPortChanged,
    required this.proxyUser,
    required this.onProxyUserChanged,
    required this.proxyPass,
    required this.onProxyPassChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DropdownButtonFormField<String>(
          initialValue: proxyType,
          decoration: const InputDecoration(
            labelText: 'Proxy type',
            isDense: true,
          ),
          items: const [
            DropdownMenuItem(value: 'socks5', child: Text('SOCKS5')),
            DropdownMenuItem(value: 'socks5h', child: Text('SOCKS5h')),
            DropdownMenuItem(value: 'http', child: Text('HTTP')),
          ],
          onChanged: (v) => onProxyTypeChanged(v ?? 'socks5'),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              flex: 3,
              child: TextFormField(
                initialValue: proxyIp,
                decoration: const InputDecoration(
                  labelText: 'Proxy IP',
                  hintText: '127.0.0.1',
                  isDense: true,
                ),
                onChanged: onProxyIpChanged,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 1,
              child: TextFormField(
                initialValue: proxyPort.toString(),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Port',
                  isDense: true,
                ),
                onChanged: onProxyPortChanged,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                initialValue: proxyUser,
                decoration: const InputDecoration(
                  labelText: 'User (optional)',
                  isDense: true,
                ),
                onChanged: onProxyUserChanged,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextFormField(
                initialValue: proxyPass,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password (optional)',
                  isDense: true,
                ),
                onChanged: onProxyPassChanged,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
