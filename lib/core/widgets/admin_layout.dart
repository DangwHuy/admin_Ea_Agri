import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'admin_sidebar.dart';
import 'admin_header.dart';
import '../constants/app_colors.dart';
import '../providers/theme_provider.dart';
import '../providers/menu_provider.dart';
import 'common/glass_container.dart';

class AdminLayout extends StatelessWidget {
  final Widget child;
  const AdminLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          color: isDark ? Colors.black : Colors.white,
          image: DecorationImage(
            image: const AssetImage('assets/images/bg_light.jpg'),
            fit: BoxFit.cover,
            colorFilter: isDark
                ? const ColorFilter.matrix(<double>[
                    0, -1, 0, 0, 255, // Red output uses inverted Green (kills red)
                    -1, 0, 0, 0, 255, // Green output uses inverted Red (boosts green)
                    0, 0, -1, 0, 255, // Invert Blue normally
                    0, 0, 0, 1, 0, // Keep Alpha
                  ])
                : null,
          ),
        ),
        // Hiển thị Drawer trên Mobile
        child: MediaQuery.of(context).size.width <= 768
            ? Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        const Padding(
                          padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                          child: AdminHeader(),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: GlassContainer(
                              borderRadius: BorderRadius.circular(24),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(24),
                                child: child,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : Consumer<MenuProvider>(
                builder: (context, menuProvider, _) {
                  final sidebarWidth = menuProvider.isExpanded ? 260.0 : 88.0;
                  final totalSidebarSpace = sidebarWidth + 24.0;

                  return Stack(
                    children: [
                      // 1. Right Content Area (Bottom Layer)
                      Positioned.fill(
                        left: totalSidebarSpace,
                        child: Column(
                          children: [
                            const Padding(
                              padding: EdgeInsets.fromLTRB(24, 24, 24, 0),
                              child: AdminHeader(),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  24,
                                  24,
                                  24,
                                  24,
                                ),
                                child: GlassContainer(
                                  borderRadius: BorderRadius.circular(32),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(32),
                                    child: child,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // 2. Sidebar Floating (Top Layer / High Z-Index)
                      Positioned(
                        left: 24,
                        top: 24,
                        bottom: 24,
                        width: sidebarWidth,
                        child: const AdminSidebar(),
                      ),
                    ],
                  );
                },
              ),
      ),
      drawer: MediaQuery.of(context).size.width <= 768
          ? const AdminSidebar()
          : null,
    );
  }
}
