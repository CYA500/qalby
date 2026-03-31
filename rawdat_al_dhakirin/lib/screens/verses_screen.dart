// lib/screens/verses_screen.dart
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../data/app_data.dart';
import '../widgets/widgets.dart';

class VersesScreen extends StatefulWidget {
  const VersesScreen({Key? key}) : super(key: key);

  @override
  State<VersesScreen> createState() => _VersesScreenState();
}

class _VersesScreenState extends State<VersesScreen> {
  String? _selectedCategory;

  final List<String> categories = ['الكل', 'الصبر', 'التقوى', 'التوحيد', 'الدعاء', 'التوكل', 'الطمأنينة'];

  List<VerseModel> get filteredVerses {
    if (_selectedCategory == null || _selectedCategory == 'الكل') {
      return AppData.quranVerses;
    }
    return AppData.quranVerses
        .where((v) => v.category == _selectedCategory)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IslamicBackground(
        child: SafeArea(
          child: Column(
            children: [
              // شريط الفلاتر
              Container(
                height: 60,
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final cat = categories[index];
                    final isSelected = (_selectedCategory ?? 'الكل') == cat;
                    return Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: FilterChip(
                        selected: isSelected,
                        onSelected: (_) {
                          setState(() {
                            _selectedCategory = cat == 'الكل' ? null : cat;
                          });
                        },
                        label: ArabicText(
                          text: cat,
                          size: 14,
                          color: isSelected ? Colors.white : null,
                        ),
                        selectedColor: Theme.of(context).colorScheme.primary,
                        backgroundColor: Theme.of(context).colorScheme.surface,
                        checkmarkColor: Colors.white,
                      ),
                    );
                  },
                ),
              ),
              // قائمة الآيات
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredVerses.length,
                  itemBuilder: (context, index) {
                    final verse = filteredVerses[index];
                    return _VerseCard(verse: verse);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VerseCard extends StatefulWidget {
  final VerseModel verse;

  const _VerseCard({required this.verse});

  @override
  State<_VerseCard> createState() => _VerseCardState();
}

class _VerseCardState extends State<_VerseCard> {
  bool _showDetails = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 16),
      child: IslamicCard(
        onTap: () => setState(() => _showDetails = !_showDetails),
        child: Column(
          children: [
            // الآية
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  QuranText(
                    text: widget.verse.text,
                    size: 24,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 8),
                  ArabicText(
                    text: 'سورة ${widget.verse.surah} - آية ${widget.verse.ayah}',
                    size: 14,
                    color: Colors.grey[600],
                  ),
                ],
              ),
            ),
            if (_showDetails) ...[
              const SizedBox(height: 16),
              // التصنيف
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: ArabicText(
                  text: widget.verse.category,
                  size: 12,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              const SizedBox(height: 12),
              // التفسير
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ArabicText(
                      text: 'التفسير:',
                      size: 14,
                      weight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                    const SizedBox(height: 4),
                    ArabicText(
                      text: widget.verse.tafsir,
                      size: 13,
                      color: Colors.grey[600],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // الدرس
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.tertiary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ArabicText(
                      text: 'الدرس المستفاد:',
                      size: 14,
                      weight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                    const SizedBox(height: 4),
                    ArabicText(
                      text: widget.verse.lesson,
                      size: 13,
                      color: Colors.grey[700],
                    ),
                  ],
                ),
              ),
            ],
            // مؤشر التوسيع
            Icon(
              _showDetails ? Icons.expand_less : Icons.expand_more,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
