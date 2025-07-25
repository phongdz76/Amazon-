import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/theme.dart';

class ThemeToggleWidget extends StatelessWidget {
  const ThemeToggleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).shadowColor,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.light_mode,
                color: themeProvider.isDarkMode
                    ? Colors.grey
                    : Theme.of(context).colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => themeProvider.toggleTheme(),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 50,
                  height: 25,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    color: themeProvider.isDarkMode
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey.shade300,
                  ),
                  child: AnimatedAlign(
                    duration: const Duration(milliseconds: 300),
                    alignment: themeProvider.isDarkMode
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      width: 21,
                      height: 21,
                      margin: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.dark_mode,
                color: themeProvider.isDarkMode
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey,
                size: 20,
              ),
            ],
          ),
        );
      },
    );
  }
}

class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return IconButton(
          icon: Icon(
            themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
          ),
          onPressed: () => themeProvider.toggleTheme(),
          tooltip: themeProvider.isDarkMode
              ? 'Switch to Light Mode'
              : 'Switch to Dark Mode',
        );
      },
    );
  }
}

class ThemeSettingTile extends StatelessWidget {
  const ThemeSettingTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.palette,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Theme Settings',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'App Theme',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    const ThemeToggleWidget(),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  themeProvider.isDarkMode
                      ? 'Dark mode is currently active'
                      : 'Light mode is currently active',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
