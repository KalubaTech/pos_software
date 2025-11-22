import 'package:flutter/material.dart';
import 'package:pos_software/utils/colors.dart';

class SidebarButtonItem extends StatelessWidget {
  const SidebarButtonItem({
    super.key,
    required this.title,
    required this.icon,
    this.onTap,
    this.isSelected = false,
    required this.isExpanded,
    this.trailingIcon, // Optional trailing icon (e.g., expand/collapse arrow)
  });

  final String title;
  final IconData icon;
  final VoidCallback? onTap;
  final bool isSelected;
  final bool isExpanded;
  final IconData? trailingIcon;

  @override
  Widget build(BuildContext context) {
    // Use withAlpha instead of withOpacity to avoid deprecation warning.
    Color selectedColor = AppColors.primary;
    final backgroundColor = isSelected
        ? selectedColor.withAlpha((0.1 * 255).round())
        : Colors.transparent;

    final item = Material(
      color: backgroundColor,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Reserve space for icon + padding, compute max width for the title
              const iconAreaWidth = 23.0; // icon size
              const gapWidth = 4.0; // sized box between icon and title
              final availableForTitle =
                  (constraints.maxWidth - iconAreaWidth - gapWidth - 32.0)
                      .clamp(0.0, double.infinity);

              // When collapsed, titleWidth is zero; when expanded use available width.
              final titleWidth = isExpanded ? availableForTitle : 0.0;

              return Row(
                children: [
                  Icon(icon, color: isSelected ? selectedColor : null),
                  // Animated gap + title width to avoid sudden layout overflow during animation
                  SizedBox(width: gapWidth),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    width: titleWidth,
                    // prevent the container from forcing a min height change
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 180),
                      opacity: isExpanded ? 1.0 : 0.0,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          title,
                          style: Theme.of(context).textTheme.titleMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          softWrap: false,
                        ),
                      ),
                    ),
                  ),
                  // Add trailing icon if provided (e.g., expand/collapse arrow)
                  if (trailingIcon != null && isExpanded)
                    Padding(
                      padding: const EdgeInsets.only(left: 4.0),
                      child: Icon(
                        trailingIcon,
                        size: 18,
                        color: isSelected ? selectedColor : null,
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );

    // When collapsed (icons-only) wrap with a Tooltip so users can see the title on hover/tap-and-hold.
    return isExpanded ? item : Tooltip(message: title, child: item);
  }
}
