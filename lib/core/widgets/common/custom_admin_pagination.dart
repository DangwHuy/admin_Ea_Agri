import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

class CustomAdminPagination extends StatelessWidget {
  final int totalItems;
  final int itemsPerPage;
  final int currentPage;
  final ValueChanged<int> onPageChanged;
  final String label;

  const CustomAdminPagination({
    super.key,
    required this.totalItems,
    required this.itemsPerPage,
    required this.currentPage,
    required this.onPageChanged,
    this.label = 'bản ghi',
  });

  @override
  Widget build(BuildContext context) {
    final totalPages = (totalItems / itemsPerPage).ceil();
    if (totalPages <= 1) return const SizedBox.shrink();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Hiển thị ${(currentPage - 1) * itemsPerPage + 1}-${currentPage * itemsPerPage > totalItems ? totalItems : currentPage * itemsPerPage} trong $totalItems $label',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontSize: 13, // Đảm bảo tính cân đối cho thanh phân trang
            color: AppColors.textMuted,
          ),
        ),
        Row(
          children: [
            IconButton(
              onPressed: currentPage > 1 ? () => onPageChanged(currentPage - 1) : null,
              icon: const Icon(Icons.chevron_left, size: 20),
            ),
            ...List.generate(totalPages, (index) {
              final pageNum = index + 1;
              
              // Standard ellipsis logic for many pages
              if (totalPages > 7) {
                 if (pageNum > 2 && pageNum < totalPages - 1 && (pageNum - currentPage).abs() > 1) {
                    if (pageNum == 3 || pageNum == totalPages - 2) return const Text('...');
                    return const SizedBox.shrink();
                 }
              }
              
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: InkWell(
                  onTap: () => onPageChanged(pageNum),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: currentPage == pageNum ? AppColors.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: currentPage == pageNum ? AppColors.primary : AppColors.border,
                      ),
                    ),
                    child: Text(
                      '$pageNum',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: currentPage == pageNum ? Colors.white : AppColors.textHeading,
                        fontWeight: currentPage == pageNum ? FontWeight.bold : FontWeight.normal,
                        fontSize: 13, // Giữ kích thước số trang đồng nhất
                      ),
                    ),
                  ),
                ),
              );
            }),
            IconButton(
              onPressed: currentPage < totalPages ? () => onPageChanged(currentPage + 1) : null,
              icon: const Icon(Icons.chevron_right, size: 20),
            ),
          ],
        ),
      ],
    );
  }
}
