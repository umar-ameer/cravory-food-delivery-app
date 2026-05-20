import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../providers/review_provider.dart';

class AddReviewScreen extends ConsumerStatefulWidget {
  final String restaurantId;

  const AddReviewScreen({
    super.key,
    required this.restaurantId,
  });

  @override
  ConsumerState<AddReviewScreen> createState() => _AddReviewScreenState();
}

class _AddReviewScreenState extends ConsumerState<AddReviewScreen> {
  final commentController = TextEditingController();

  double selectedRating = 5;
  bool isSubmitting = false;

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  Future<void> submitReview() async {
    final comment = commentController.text.trim();

    if (comment.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please write a short review'),
          backgroundColor: AppTheme.danger,
        ),
      );
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    try {
      await ref.read(reviewServiceProvider).addReview(
            restaurantId: widget.restaurantId,
            rating: selectedRating,
            comment: comment,
          );

      ref.invalidate(restaurantReviewsProvider(widget.restaurantId));

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Review submitted successfully'),
          backgroundColor: AppTheme.primary,
        ),
      );

      Navigator.pop(context);
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString()),
          backgroundColor: AppTheme.danger,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        foregroundColor: AppTheme.darkText,
        title: const Text(
          'Write Review',
          style: TextStyle(
            color: AppTheme.darkText,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: AppTheme.borderColor,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'How was your food?',
                  style: TextStyle(
                    color: AppTheme.darkText,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Rate your experience and help others choose better.',
                  style: TextStyle(
                    color: AppTheme.lightText,
                    fontSize: 14,
                    height: 1.4,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 26),

                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      final starValue = index + 1;
                      final isSelected = selectedRating >= starValue;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedRating = starValue.toDouble();
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Icon(
                            isSelected
                                ? Icons.star_rounded
                                : Icons.star_border_rounded,
                            color: const Color(0xFFFFC542),
                            size: 42,
                          ),
                        ),
                      );
                    }),
                  ),
                ),

                const SizedBox(height: 10),

                Center(
                  child: Text(
                    '${selectedRating.toStringAsFixed(0)} / 5',
                    style: const TextStyle(
                      color: AppTheme.primary,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                TextField(
                  controller: commentController,
                  maxLines: 5,
                  style: const TextStyle(
                    color: AppTheme.darkText,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Write your review...',
                    alignLabelWithHint: true,
                    filled: true,
                    fillColor: AppTheme.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(
                        color: AppTheme.borderColor,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(
                        color: AppTheme.borderColor,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(
                        color: AppTheme.primary,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 26),

                ElevatedButton(
                  onPressed: isSubmitting ? null : submitReview,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: isSubmitting
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Submit Review',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}