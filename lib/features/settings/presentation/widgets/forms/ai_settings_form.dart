import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../logic/settings_provider.dart';
import '../common/config_card.dart';
import '../common/secure_text_field.dart';

import '../common/settings_form_footer.dart';
import 'package:admin_daklak_web/core/widgets/common/custom_admin_input.dart';
import 'package:admin_daklak_web/core/constants/app_colors.dart';

class AISettingsForm extends StatelessWidget {
  const AISettingsForm({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SettingsProvider>();
    final config = provider.ai;

    if (config == null) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Gemini & LLM Config
        ConfigCard(
          title: 'Cấu hình Gemini & LLM',
          icon: Icons.auto_awesome_rounded,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Model AI chính', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: config.selectedModel,
                  decoration: _dropdownDecoration(context, isDark),
                  items: ['gemini-1.5-pro', 'gemini-1.5-flash', 'gpt-4o', 'gpt-4o-mini']
                      .map((m) => DropdownMenuItem(value: m, child: Text(m, style: Theme.of(context).textTheme.bodyMedium)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) provider.updateAI(config.copyWith(selectedModel: val));
                  },
                ),
              ],
            ),
            const SizedBox(height: 32),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Nhiệt độ (Temperature)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface)),
                    Text(config.temperature.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                  ],
                ),
                const SizedBox(height: 12),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: AppColors.primary,
                    inactiveTrackColor: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border,
                    thumbColor: AppColors.primary,
                    overlayColor: AppColors.primary.withValues(alpha: 0.1),
                    trackHeight: 4,
                  ),
                  child: Slider(
                    value: config.temperature,
                    min: 0,
                    max: 1.0,
                    divisions: 10,
                    onChanged: (val) => provider.updateAI(config.copyWith(temperature: val)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            CustomAdminInput(
              label: 'System Prompt (Hướng dẫn hệ thống cho chatbot & chuyên gia)',
              initialValue: config.systemPrompt,
              maxLines: 4,
              onChanged: (val) => provider.updateAI(config.copyWith(systemPrompt: val)),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // 2. API Keys & Secrets
        ConfigCard(
          title: 'Khóa API & Bảo mật',
          icon: Icons.vpn_key_rounded,
          subtitle: 'Các khóa bí mật dùng để kết nối với các dịch vụ bên thứ ba.',
          children: [
            SecureTextField(
              label: 'Khóa API Gemini',
              initialValue: config.apiKey,
              onChanged: (val) => provider.updateAI(config.copyWith(apiKey: val)),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: SecureTextField(
                    label: 'Khóa API Thời tiết (OpenWeather)',
                    initialValue: config.weatherApiKey,
                    onChanged: (val) => provider.updateAI(config.copyWith(weatherApiKey: val)),
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: SecureTextField(
                    label: 'Khóa API Email (SendGrid/Mailgun)',
                    initialValue: config.emailApiKey,
                    onChanged: (val) => provider.updateAI(config.copyWith(emailApiKey: val)),
                  ),
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 16),

        // 3. AI Governance
        ConfigCard(
          title: 'Quản trị AI',
          icon: Icons.gavel_rounded,
          children: [
            Row(
              children: [
                Expanded(
                  child: CustomAdminInput(
                    label: 'Hạn mức sử dụng hàng ngày (Request)',
                    initialValue: config.governance.dailyUsageLimit.toString(),
                    keyboardType: TextInputType.number,
                    onChanged: (val) {
                      final limit = int.tryParse(val) ?? 0;
                      provider.updateAI(config.copyWith(
                        governance: config.governance.copyWith(dailyUsageLimit: limit),
                      ));
                    },
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Model dự phòng', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: config.governance.fallbackModel,
                        decoration: _dropdownDecoration(context, isDark),
                        items: ['gpt-4o-mini', 'claude-3-haiku', 'gemini-1.5-flash']
                            .map((m) => DropdownMenuItem(value: m, child: Text(m, style: Theme.of(context).textTheme.bodyMedium)))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) {
                            provider.updateAI(config.copyWith(
                              governance: config.governance.copyWith(fallbackModel: val),
                            ));
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withValues(alpha: 0.05) : AppColors.surfaceVariant.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: SwitchListTile(
                title: Text('Bật bộ lọc an toàn (Safety Filters)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface)),
                subtitle: Text('Tự động chặn các phản hồi không phù hợp hoặc nguy hiểm.', style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodySmall?.color)),
                value: config.governance.enableSafetyFilters,
                activeColor: AppColors.primary,
                onChanged: (val) {
                  provider.updateAI(config.copyWith(
                    governance: config.governance.copyWith(enableSafetyFilters: val),
                  ));
                },
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),

        // 4. Premium Footer
        SettingsFormFooter(
          isLoading: provider.isLoading,
          onSave: () => provider.saveAI(),
          onDiscard: () => provider.discardChanges(),
        ),
      ],
    );
  }

  InputDecoration _dropdownDecoration(BuildContext context, bool isDark) => InputDecoration(
    filled: true,
    fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : AppColors.surfaceVariant.withValues(alpha: 0.4),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border)),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border)),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
  );
}
