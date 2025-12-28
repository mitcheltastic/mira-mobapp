import 'package:flutter/material.dart';
import '../../../core/constant/app_colors.dart';

class StudyToolsGrid extends StatelessWidget {
  final List<Map<String, dynamic>> tools;

  const StudyToolsGrid({super.key, required this.tools});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double aspectRatio = screenWidth < 380 ? 0.72 : 0.80; 

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 120), 
      physics: const BouncingScrollPhysics(), 
      
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: aspectRatio,
      ),
      itemCount: tools.length,
      itemBuilder: (context, index) {
        final tool = tools[index];
        return _buildCard(context, tool);
      },
    );
  }

  Widget _buildCard(BuildContext context, Map<String, dynamic> tool) {
    final Color toolColor = tool['color'] as Color? ?? AppColors.primary;
    final bool isComingSoon = tool['screen'] == null;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: () {
            if (!isComingSoon) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => tool['screen']),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("${tool['title']} is coming soon!"),
                  backgroundColor: AppColors.textMain,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  margin: const EdgeInsets.all(20),
                ),
              );
            }
          },
          borderRadius: BorderRadius.circular(24),
          splashColor: toolColor.withValues(alpha: 0.1),
          highlightColor: toolColor.withValues(alpha: 0.05),
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              // 1. Watermark Icon (Artistic)
              Positioned(
                bottom: -20,
                right: -20,
                child: Transform.rotate(
                  angle: -0.2,
                  child: Icon(
                    tool['icon'] as IconData,
                    size: 90,
                    color: toolColor.withValues(alpha: 0.05),
                  ),
                ),
              ),

              // 2. Main Content
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header: Icon & Category
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Icon Circle
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: toolColor.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            tool['icon'] as IconData,
                            color: toolColor,
                            size: 22,
                          ),
                        ),
                        // Category Pill
                        if (tool['category'] != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
                            ),
                            child: Text(
                              tool['category'],
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ),
                      ],
                    ),

                    const Spacer(),

                    // Title
                    Text(
                      tool['title'],
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textMain,
                        letterSpacing: -0.5,
                        height: 1.2,
                      ),
                    ),
                    
                    const SizedBox(height: 6),
                    
                    Expanded(
                      flex: 0,
                      child: Text(
                        tool['desc'],
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted.withValues(alpha: 0.8),
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 24,
                          height: 4,
                          decoration: BoxDecoration(
                            color: isComingSoon 
                                ? AppColors.freeBorder
                                : toolColor,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),

                        if (!isComingSoon)
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: 20,
                            color: toolColor.withValues(alpha: 0.8),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}