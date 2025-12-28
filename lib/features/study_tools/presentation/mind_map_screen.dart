import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Import sesuai path project Anda
import '../../../core/constant/app_colors.dart';

// --- DATA MODEL ---
class MindNode {
  String id;
  String label;
  Offset position;
  String? parentId;
  Color color;
  int level; 

  MindNode({
    required this.id,
    required this.label,
    required this.position,
    this.parentId,
    required this.color,
    this.level = 0,
  });
}

class MindMapScreen extends StatefulWidget {
  const MindMapScreen({super.key});

  @override
  State<MindMapScreen> createState() => _MindMapScreenState();
}

class _MindMapScreenState extends State<MindMapScreen> with TickerProviderStateMixin {
  // --- Constants ---
  final double _canvasSize = 4000.0;
  final TransformationController _transformController = TransformationController();
  
  List<MindNode> nodes = [];
  int _idCounter = 0;

  @override
  void initState() {
    super.initState();
    _initializeRootNode();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _centerView(animate: false);
      _showIntroGuide(); // Memanggil Intro Guide saat pertama kali
    });
  }

  void _initializeRootNode() {
    _addNode(
      label: "Central Idea",
      position: Offset(_canvasSize / 2, _canvasSize / 2),
      isRoot: true,
    );
  }

  void _centerView({bool animate = true}) {
    final size = MediaQuery.of(context).size;
    final x = -(_canvasSize / 2) + (size.width / 2);
    final y = -(_canvasSize / 2) + (size.height / 2);

    final targetMatrix = Matrix4.translationValues(x, y, 0.0);

    if (animate) {
      final animation = Matrix4Tween(
        begin: _transformController.value,
        end: targetMatrix,
      ).animate(CurvedAnimation(
        parent: AnimationController(vsync: this, duration: const Duration(milliseconds: 500))..forward(),
        curve: Curves.easeOutExpo,
      ));
      
      animation.addListener(() {
        _transformController.value = animation.value;
      });
    } else {
      _transformController.value = targetMatrix;
    }
  }

  // --- LOGIC ---

  void _addNode({
    required String label,
    required Offset position,
    String? parentId,
    bool isRoot = false,
    int level = 0,
  }) {
    setState(() {
      _idCounter++;

      // Warna node mengikuti tema AppColors.third (Emerald)
      Color nodeColor = isRoot 
          ? AppColors.third 
          : AppColors.third.withValues(alpha: 1.0 - (level * 0.15).clamp(0.0, 0.6));

      nodes.add(
        MindNode(
          id: _idCounter.toString(),
          label: label,
          position: position,
          parentId: parentId,
          color: nodeColor,
          level: level,
        ),
      );
    });
    HapticFeedback.mediumImpact();
  }

  void _deleteNodeRecursively(String nodeId) {
    setState(() {
      final children = nodes.where((n) => n.parentId == nodeId).toList();
      for (var child in children) {
        _deleteNodeRecursively(child.id);
      }
      nodes.removeWhere((n) => n.id == nodeId);
    });
    HapticFeedback.heavyImpact();
  }

  // --- UI DIALOGS ---

  void _showNodeOptions(MindNode node) {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)))),
            const SizedBox(height: 24),
            Text(
              "Edit Node",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textMuted.withValues(alpha: 0.8), letterSpacing: 1),
            ),
            const SizedBox(height: 8),
            Text(
              node.label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: AppColors.textMain),
              maxLines: 2, overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 32),
            
            // Add Branch
            _buildOptionTile(
              icon: Icons.add_circle_outline_rounded,
              color: AppColors.third,
              title: "Add Branch",
              subtitle: "Create a new sub-topic",
              onTap: () {
                Navigator.pop(context);
                _promptLabelDialog("New Branch", (val) {
                  double angle = (nodes.length * 0.5) + node.level;
                  double distance = 180.0;
                  double offsetX = math.cos(angle) * distance;
                  double offsetY = math.sin(angle) * distance;

                  if (node.level > 0) {
                     offsetX = (node.level % 2 == 0) ? 150 : -150;
                     offsetY = 100.0;
                  }

                  _addNode(
                    label: val,
                    position: node.position + Offset(offsetX, offsetY),
                    parentId: node.id,
                    level: node.level + 1,
                  );
                });
              },
            ),
            
            // Rename
            _buildOptionTile(
              icon: Icons.edit_outlined,
              color: Colors.blueAccent,
              title: "Rename",
              subtitle: "Change text label",
              onTap: () {
                Navigator.pop(context);
                _promptLabelDialog("Rename", (val) {
                  setState(() => node.label = val);
                }, initialValue: node.label);
              },
            ),

            // Delete (If not root)
            if (node.parentId != null)
              _buildOptionTile(
                icon: Icons.delete_outline_rounded,
                color: AppColors.error,
                title: "Delete",
                subtitle: "Remove this branch",
                onTap: () {
                  Navigator.pop(context);
                  _deleteNodeRecursively(node.id);
                },
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile({required IconData icon, required Color color, required String title, required String subtitle, required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textMain, fontSize: 16)),
        subtitle: Text(subtitle, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
        trailing: Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
      ),
    );
  }

  void _promptLabelDialog(String title, Function(String) onConfirm, {String? initialValue}) {
    final controller = TextEditingController(text: initialValue);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textMain)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: AppColors.textMain),
          decoration: InputDecoration(
            hintText: "Type something...",
            hintStyle: TextStyle(color: Colors.grey.shade400),
            filled: true,
            fillColor: AppColors.background,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          onSubmitted: (val) {
             if (val.isNotEmpty) {
                onConfirm(val);
                Navigator.pop(context);
              }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.third,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            onPressed: () {
              if (controller.text.isNotEmpty) {
                onConfirm(controller.text);
                Navigator.pop(context);
              }
            },
            child: const Text("Save", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // --- INTRO GUIDE (Baru) ---
  void _showIntroGuide() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.70, 
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          padding: const EdgeInsets.fromLTRB(32, 12, 32, 0), 
          child: Column(
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 24),
              
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      const Text("Mind Mapping", 
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.textMain, letterSpacing: -0.5)),
                      const SizedBox(height: 8),
                      const Text(
                        "Visualize your thoughts and connect ideas intuitively.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textMuted, fontSize: 15, height: 1.4),
                      ),
                      const SizedBox(height: 30),
                      
                      _buildGuideItem(Icons.hub_rounded, AppColors.third, "Central Idea", "Start with the main topic in the center."),
                      _buildGuideItem(Icons.account_tree_rounded, Colors.blueAccent, "Branches", "Create sub-topics to expand your ideas."),
                      _buildGuideItem(Icons.touch_app_rounded, Colors.orange, "Interact", "Tap to edit, drag to move, pinch to zoom."),
                    ],
                  ),
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 24),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.third,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Start Mapping", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGuideItem(IconData icon, Color color, String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 25),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textMain)),
                const SizedBox(height: 4),
                Text(desc, style: const TextStyle(color: AppColors.textMuted, fontSize: 13, height: 1.4)),
              ],
            ),
          )
        ],
      ),
    );
  }

  // --- MAIN BUILD ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Mind Map", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textMain)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: AppColors.textMain),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.center_focus_strong_rounded, color: AppColors.textMuted),
            onPressed: () => _centerView(),
            tooltip: "Center View",
          ),
          // Tambahan: Tombol bantuan di AppBar
          IconButton(
            icon: const Icon(Icons.help_outline_rounded, color: AppColors.textMuted),
            onPressed: _showIntroGuide,
            tooltip: "Help",
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey.shade200, height: 1),
        ),
      ),
      
      body: InteractiveViewer(
        transformationController: _transformController,
        boundaryMargin: const EdgeInsets.all(2000), 
        minScale: 0.2,
        maxScale: 2.5,
        constrained: false, 
        child: Container(
          width: _canvasSize,
          height: _canvasSize,
          decoration: const BoxDecoration(
            color: AppColors.background,
          ),
          child: Stack(
            children: [
              // 1. Grid Background
              Positioned.fill(
                child: RepaintBoundary( 
                  child: CustomPaint(
                    painter: GridPainter(color: Colors.grey.withValues(alpha: 0.15)),
                  ),
                ),
              ),

              // 2. Lines
              Positioned.fill(
                child: CustomPaint(
                  painter: NodeLinePainter(nodes: nodes, themeColor: AppColors.third),
                ),
              ),

              // 3. Nodes
              ...nodes.map((node) => Positioned(
                left: node.position.dx,
                top: node.position.dy,
                child: DraggableNode(
                  key: ValueKey(node.id),
                  node: node,
                  isRoot: node.parentId == null,
                  onDragUpdate: (delta) {
                     setState(() {
                       node.position += delta;
                     });
                  },
                  onTap: () => _showNodeOptions(node),
                ),
              )),
            ],
          ),
        ),
      ),
      
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (nodes.isNotEmpty) {
             _showNodeOptions(nodes.first);
          }
        },
        backgroundColor: AppColors.third,
        elevation: 4,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text("Add Idea", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

// --- PAINTERS & WIDGETS ---

class GridPainter extends CustomPainter {
  final Color color;
  GridPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    const spacing = 40.0; 
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 2, paint);
      }
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class NodeLinePainter extends CustomPainter {
  final List<MindNode> nodes;
  final Color themeColor;

  NodeLinePainter({required this.nodes, required this.themeColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    const rootSize = Size(160, 70); 
    const branchSize = Size(140, 60);

    for (var node in nodes) {
      if (node.parentId != null) {
        try {
          final parent = nodes.firstWhere((n) => n.id == node.parentId);
          
          paint.color = node.color.withValues(alpha: 0.4);

          final pSize = parent.parentId == null ? rootSize : branchSize;
          final cSize = branchSize;

          final start = Offset(parent.position.dx + pSize.width / 2, parent.position.dy + pSize.height / 2);
          final end = Offset(node.position.dx + cSize.width / 2, node.position.dy + cSize.height / 2);

          final path = Path();
          path.moveTo(start.dx, start.dy);
          
          final dx = (end.dx - start.dx).abs();
          
          double controlOffset = dx * 0.5;
          if (dx < 50) controlOffset = 50; 

          if (end.dx > start.dx) {
             path.cubicTo(start.dx + controlOffset, start.dy, end.dx - controlOffset, end.dy, end.dx, end.dy);
          } else {
             path.cubicTo(start.dx - controlOffset, start.dy, end.dx + controlOffset, end.dy, end.dx, end.dy);
          }
          
          canvas.drawPath(path, paint);
        } catch (_) {}
      }
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true; 
}

class DraggableNode extends StatelessWidget {
  final MindNode node;
  final bool isRoot;
  final Function(Offset) onDragUpdate;
  final VoidCallback onTap;

  const DraggableNode({
    super.key,
    required this.node,
    required this.isRoot,
    required this.onDragUpdate,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (details) {
        onDragUpdate(details.delta);
      },
      onTap: onTap,
      child: Container(
        width: isRoot ? 160 : 140, 
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(isRoot ? 24 : 16),
          border: Border.all(
            color: isRoot ? AppColors.third : AppColors.third.withValues(alpha: 0.3),
            width: isRoot ? 3 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            node.label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: isRoot ? FontWeight.w900 : FontWeight.w600,
              fontSize: isRoot ? 16 : 14,
              color: AppColors.textMain,
              height: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}