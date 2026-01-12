import 'package:flutter/material.dart';

class WalletShortcutCard extends StatelessWidget {
  final VoidCallback onTap;
  const WalletShortcutCard({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFFFF7A45);
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: primary.withOpacity(0.08),
                blurRadius: 14,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: primary.withOpacity(0.12),
                child: const Icon(Icons.account_balance_wallet_outlined, color: primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Ví QTI', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                    SizedBox(height: 4),
                    Text('Nạp, rút, kiểm tra lịch sử, số dư', style: TextStyle(color: Colors.black54)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: primary),
            ],
          ),
        ),
      ),
    );
  }
}
