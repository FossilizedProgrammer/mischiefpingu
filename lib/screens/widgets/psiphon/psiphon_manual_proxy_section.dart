import 'package:flutter/material.dart';

class PsiphonManualProxySection extends StatelessWidget {
  const PsiphonManualProxySection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: 'socks5',
                decoration: const InputDecoration(
                  labelText: 'Proxy type',
                  isDense: true,
                ),
                items: const [
                  DropdownMenuItem(value: 'socks5', child: Text('SOCKS5')),
                  DropdownMenuItem(value: 'http', child: Text('HTTP')),
                ],
                onChanged: (v) {},
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextFormField(
                initialValue: '',
                decoration: const InputDecoration(
                  labelText: 'Proxy IP',
                  isDense: true,
                ),
                onChanged: (v) {},
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextFormField(
                initialValue: '1080',
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Port',
                  isDense: true,
                ),
                onChanged: (v) {},
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                initialValue: '',
                decoration: const InputDecoration(
                  labelText: 'User (optional)',
                  isDense: true,
                ),
                onChanged: (v) {},
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextFormField(
                initialValue: '',
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password (optional)',
                  isDense: true,
                ),
                onChanged: (v) {},
              ),
            ),
          ],
        ),
      ],
    );
  }
}
