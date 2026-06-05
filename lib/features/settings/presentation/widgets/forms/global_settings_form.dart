import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../logic/settings_provider.dart';
import '../common/config_card.dart';
import '../common/logo_uploader_segment.dart';
import '../common/summary_action_card.dart';

import '../common/settings_form_footer.dart';
import 'package:admin_daklak_web/core/widgets/common/custom_admin_input.dart';
import 'package:admin_daklak_web/core/constants/app_colors.dart';
import 'package:admin_daklak_web/core/widgets/common/glass_container.dart';

class GlobalSettingsForm extends StatelessWidget {
  const GlobalSettingsForm({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SettingsProvider>();
    final config = provider.global;

    if (config == null) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Status Bar (Theme Aware)
        GlassContainer(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          borderRadius: BorderRadius.circular(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.statusSuccess,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Trạng thái hệ thống: ',
                    style: TextStyle(fontSize: 13, color: Theme.of(context).textTheme.bodySmall?.color),
                  ),
                  Text(
                    'Ổn định',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
                  ),
                ],
              ),
              Text(
                'Cập nhật lần cuối: ${config.lastUpdated}',
                style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodySmall?.color),
              ),
            ],
          ),
        ),

        const SizedBox(height: 32),

        // 3. Brand Information segment
        ConfigCard(
          title: 'Thông tin thương hiệu',
          icon: Icons.campaign_rounded,
          iconCircleColor: const Color(0xFFF0EAE0),
          children: [
            Row(
              children: [
                Expanded(
                  child: CustomAdminInput(
                    label: 'Tên thương hiệu hiển thị',
                    initialValue: config.appName,
                    onChanged: (val) => provider.updateGlobal(config.copyWith(appName: val)),
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: CustomAdminInput(
                    label: 'Slogan / Tagline',
                    initialValue: config.slogan,
                    onChanged: (val) => provider.updateGlobal(config.copyWith(slogan: val)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            LogoUploaderSegment(
              initialLogoUrl: config.logoUrl,
              appInitial: config.appName.isNotEmpty ? config.appName[0].toUpperCase() : 'T',
              onLogoChanged: (bytes) {
                // actual upload logic would go here
              },
            ),
          ],
        ),

        const SizedBox(height: 16),

        // 4. Contact Information segment
        ConfigCard(
          title: 'Thông tin liên hệ',
          icon: Icons.contact_support_rounded,
          iconCircleColor: const Color(0xFFE8ECEB),
          children: [
             Row(
              children: [
                Expanded(
                  child: CustomAdminInput(
                    label: 'Email hỗ trợ',
                    initialValue: config.contactEmail,
                    prefixIcon: Icons.mail_rounded,
                    onChanged: (val) => provider.updateGlobal(config.copyWith(contactEmail: val)),
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: CustomAdminInput(
                    label: 'Số điện thoại',
                    initialValue: config.contactPhone,
                    prefixIcon: Icons.phone_rounded,
                    onChanged: (val) => provider.updateGlobal(config.copyWith(contactPhone: val)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            CustomAdminInput(
              label: 'Địa chỉ văn phòng chính',
              initialValue: config.address,
              prefixIcon: Icons.location_pin,
              maxLines: 1,
              onChanged: (val) => provider.updateGlobal(config.copyWith(address: val)),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // 5. Action Summary Grid
        Row(
          children: [
            SummaryActionCard(
              icon: Icons.public_rounded,
              label: 'WEBSITE',
              value: config.websiteUrl.isEmpty ? 'Chưa cấu hình' : config.websiteUrl,
              onTap: () {},
            ),
            const SizedBox(width: 16),
            SummaryActionCard(
              icon: Icons.share_rounded,
              label: 'MẠNG XÃ HỘI',
              value: config.socialAccountCount,
              onTap: () {},
            ),
            const SizedBox(width: 16),
            SummaryActionCard(
              icon: Icons.map_rounded,
              label: 'BẢN ĐỒ',
              value: config.mapStatus,
              onTap: () {},
            ),
          ],
        ),

        // 6. Premium Footer
        SettingsFormFooter(
          isLoading: provider.isLoading,
          onSave: () => provider.saveGlobal(),
          onDiscard: () => provider.discardChanges(),
        ),
      ],
    );
  }
}
