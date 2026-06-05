import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../../features/auth/services/auth_service.dart';
import '../../features/auth/logic/user_provider.dart';
import '../../features/notifications/services/notification_service.dart';
import '../../features/notifications/models/notification_model.dart';
import '../../features/notifications/widgets/notification_dropdown.dart';
import '../services/search_service.dart';
import 'search_overlay.dart';
import 'common/glass_container.dart';
import '../providers/theme_provider.dart';

class AdminHeader extends StatefulWidget implements PreferredSizeWidget {
  const AdminHeader({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  State<AdminHeader> createState() => _AdminHeaderState();
}

class _AdminHeaderState extends State<AdminHeader> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  final LayerLink _layerLink = LayerLink();
  int _notificationLimit = 5; // Mặc định hiện 5 cái
  
  OverlayEntry? _overlayEntry;
  Timer? _debounce;
  final SearchService _searchService = SearchService();
  
  bool _isSearching = false;
  List<SearchResult> _searchResults = [];

  @override
  void initState() {
    super.initState();
    _searchFocus.addListener(() {
      if (_searchFocus.hasFocus && _searchController.text.isNotEmpty) {
        _showOverlay();
      } else if (!_searchFocus.hasFocus) {
        // Need a slight delay to allow taps on the overlay to register
        Future.delayed(const Duration(milliseconds: 150), () {
          if (mounted) _hideOverlay();
        });
      }
    });

    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      _hideOverlay();
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      _showOverlay();
      setState(() => _isSearching = true);
      _overlayEntry?.markNeedsBuild();

      final results = await _searchService.searchGlobal(query);
      
      if (mounted) {
        setState(() {
          _searchResults = results;
          _isSearching = false;
        });
        _overlayEntry?.markNeedsBuild();
      }
    });
  }

  void _showOverlay() {
    if (_overlayEntry != null) return;

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Positioned(
          width: 400,
          child: CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            offset: const Offset(0, 50),
            child: SearchOverlay(
              isLoading: _isSearching,
              results: _searchResults,
              onClose: () {
                _hideOverlay();
                _searchFocus.unfocus();
                _searchController.clear();
              },
            ),
          ),
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _hideOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _searchFocus.dispose();
    _hideOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width <= 768;
    final userProvider = Provider.of<UserProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    // Get real user data
    final displayName = userProvider.displayName ?? 'Admin';
    final email = userProvider.email ?? 'admin@farmvista.com';
    final photoURL = userProvider.photoURL;

    return GlassContainer(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      borderRadius: BorderRadius.circular(100),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [

          // ── Feature 2: Search Bar ──────────────────────────────
          if (!isMobile)
            Expanded(
              flex: 5,
              child: CompositedTransformTarget(
                link: _layerLink,
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03), 
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 20),
                      Icon(
                        Icons.search_rounded,
                        size: 20,
                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          focusNode: _searchFocus,
                          decoration: InputDecoration(
                            hintText: 'Tìm kiếm đơn hàng, người dùng, chuyên gia...',
                            hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
                              fontWeight: FontWeight.w500,
                            ),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            hoverColor: Colors.transparent,
                            fillColor: Colors.transparent,
                            filled: false,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: isDark ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          const Spacer(flex: 3),

          // ── Feature 3: Actions Group ───────────────────────────
          StreamBuilder<List<AdminNotification>>(
            stream: NotificationService.getUnreadNotificationsStream(),
            builder: (context, unreadSnapshot) {
              final unreadCount = unreadSnapshot.data?.length ?? 0;

              return Row(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
                          shape: BoxShape.circle,
                        ),
                        child: PopupMenuButton<void>(
                          padding: EdgeInsets.zero,
                          tooltip: 'Thông báo',
                          offset: const Offset(0, 50),
                          icon: Icon(
                            unreadCount > 0 ? Icons.notifications_active_rounded : Icons.notifications_none_rounded,
                            color: unreadCount > 0 ? Theme.of(context).primaryColor : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                            size: 20,
                          ),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          itemBuilder: (context) => [
                            PopupMenuItem<void>(
                              enabled: false,
                              padding: EdgeInsets.zero,
                              child: NotificationDropdown(
                                onAction: () => Navigator.pop(context), 
                              ),
                            ),
                          ],
                        ),
                      ), // Container ends
                      if (unreadCount > 0)
                        Positioned(
                          right: -2,
                          top: -2,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                            child: Text(
                              unreadCount > 9 ? '9+' : '$unreadCount',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: Colors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              );
            },
          ),

          const SizedBox(width: 24),
          Container(height: 24, width: 1, color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1)),
          const SizedBox(width: 24),

          // Profile item
          PopupMenuButton<String>(
            offset: const Offset(0, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    const Icon(Icons.person_outline_rounded, size: 18),
                    const SizedBox(width: 10),
                    const Text('Tài khoản'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    const Icon(Icons.settings_outlined, size: 18),
                    const SizedBox(width: 10),
                    const Text('Cài đặt'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    const Icon(Icons.logout_rounded, size: 18, color: Colors.red),
                    const SizedBox(width: 10),
                    Text('Đăng xuất', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.red)),
                  ],
                ),
              ),
            ],
            onSelected: (value) async {
              if (value == 'logout') {
                await AuthService().logout();
                if (context.mounted) context.go('/login');
              } else if (value == 'settings') {
                context.go('/settings');
              } else if (value == 'profile') {
                context.go('/profile');
              }
            },
            child: Container(
              height: 44,
              padding: const EdgeInsets.only(left: 6, right: 20, top: 6, bottom: 6),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Theme.of(context).primaryColor, width: 1.5),
                    ),
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.white,
                      backgroundImage: photoURL != null ? NetworkImage(photoURL) : null,
                      child: photoURL == null
                          ? const Icon(Icons.person, size: 18, color: Color(0xFFF2994A))
                          : null,
                    ),
                  ),
                  if (!isMobile) ...[
                    const SizedBox(width: 12),
                    Text(
                      'Hồ sơ',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
