import 'package:flutter/material.dart';

// ════════════════════════════════════════════════════════════
// REUSABLE WIDGETS FOR SCHEDULE PICKUP SCREEN
// ════════════════════════════════════════════════════════════

/// Section header with optional badge
class SectionHeader extends StatelessWidget {
  final String title;
  final String? badge;

  const SectionHeader(this.title, {super.key, this.badge});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A2E))),
          if (badge != null) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFF3E8FF),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(badge!,
                  style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF6B21A8),
                      fontWeight: FontWeight.w600)),
            ),
          ],
        ],
      ),
    );
  }
}

/// Counter button (+ / -)
class CounterButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final bool active;

  const CounterButton({
    super.key,
    required this.icon,
    required this.onTap,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 30,
        height: 30,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color:
              active ? const Color(0xFF6B21A8) : const Color(0xFFE5E7EB),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon,
            size: 16, color: active ? Colors.white : Colors.grey[400]),
      ),
    );
  }
}

/// Item counter row (- value +)
class ItemCounter extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;

  const ItemCounter({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CounterButton(
          icon: Icons.remove,
          onTap: value > 0 ? () => onChanged(value - 1) : null,
          active: value > 0,
        ),
        SizedBox(
          width: 36,
          child: Text(value.toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF1A1A2E))),
        ),
        CounterButton(
          icon: Icons.add,
          onTap: () => onChanged(value + 1),
          active: true,
        ),
      ],
    );
  }
}

/// Item row with icon, label, optional subtitle, and counter
class ItemRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final int value;
  final ValueChanged<int> onChanged;

  const ItemRow({
    super.key,
    required this.icon,
    required this.label,
    this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: const Color.fromRGBO(0, 0, 0, 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFF3E8FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF6B21A8), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Color(0xFF1A1A2E))),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(subtitle!,
                      style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B21A8),
                          fontWeight: FontWeight.w500)),
                ],
              ],
            ),
          ),
          ItemCounter(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

/// Date/Time selector card
class DateTimeCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;
  final bool isSelected;

  const DateTimeCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color:
              isSelected ? const Color(0xFF6B21A8) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF6B21A8)
                : const Color(0xFFE5E7EB),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? const Color.fromRGBO(107, 33, 168, 0.25)
                  : const Color.fromRGBO(0, 0, 0, 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon,
                size: 20,
                color: isSelected
                    ? Colors.white70
                    : const Color(0xFF9CA3AF)),
            const SizedBox(height: 8),
            Text(label,
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? Colors.white70
                        : const Color(0xFF9CA3AF),
                    letterSpacing: 0.05)),
            const SizedBox(height: 2),
            Text(value,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? Colors.white
                        : const Color(0xFF1A1A2E))),
          ],
        ),
      ),
    );
  }
}