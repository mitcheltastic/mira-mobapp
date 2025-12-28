import 'package:flutter/material.dart';
import '../../../core/constant/app_colors.dart';

class MindNode {
  String id;
  String label;
  Offset position;
  String? parentId;
  Color color;

  MindNode({
    required this.id,
    required this.label,
    required this.position,
    this.parentId,
    required this.color,
  });
}

class MindMapScreen extends StatefulWidget {
  const MindMapScreen({super.key});

  @override
  State<MindMapScreen> createState() => _MindMapScreenState();
}

class _MindMapScreenState extends State<MindMapScreen> {
  final double _canvasSize = 4000.0;
  final TransformationController _transformController = TransformationController();

  // Data State
  List<MindNode> nodes = [];
  int _idCounter = 0;

  @override
  void initState() {
    super.initState();

    _addNode(
      label: "Central Idea",
      position: Offset(_canvasSize / 2, _canvasSize / 2),
      isRoot: true,
    );
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final size = MediaQuery.of(context).size;
      final x = -(_canvasSize / 2) + (size.width / 2);
      final y = -(_canvasSize / 2) + (size.height / 2);
      
      _transformController.value = Matrix4.translationValues(x, y, 0.0);
    });
  }

  @override
  void dispose() {
    _transformController.dispose();
    super.dispose();
  }


  void _addNode({required String label, required Offset position, String? parentId, bool isRoot = false}) {
    setState(() {
      _idCounter++;
      nodes.add(MindNode(
        id: _idCounter.toString(),
        label: label,
        position: position,
        parentId: parentId,
        color: isRoot ? AppColors.primary : _getLevelColor(parentId),
      ));
    });
  }

  void _updateNodePosition(String id, Offset newPos) {
    setState(() {
      final index = nodes.indexWhere((n) => n.id == id);
      if (index != -1) {
        nodes[index].position = newPos;
      }
    });
  }

  void _editNodeLabel(String id, String newLabel) {
    setState(() {
      final index = nodes.indexWhere((n) => n.id == id);
      if (index != -1) {
        nodes[index].label = newLabel;
      }
    });
  }

  void _deleteNode(String id) {
    // Mencegah penghapusan Root Node
    if (nodes.firstWhere((n) => n.id == id).parentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cannot delete the Central Idea!")),
      );
      return;
    }

    setState(() {
      _deleteRecursive(id);
    });
  }

  void _deleteRecursive(String parentId) {
    final children = nodes.where((n) => n.parentId == parentId).toList();
    for (var child in children) {
      _deleteRecursive(child.id);
    }
    nodes.removeWhere((n) => n.id == parentId);
  }

  // Generator warna sederhana
  Color _getLevelColor(String? parentId) {
    if (parentId == null) return AppColors.primary;
    final colors = [
      Colors.orange,
      Colors.blue,
      Colors.green,
      Colors.purple,
      Colors.pink,
      Colors.teal,
    ];
    return colors[_idCounter % colors.length];
  }


  void _showNodeOptions(MindNode node) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Actions for '${node.label}'",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.add_circle_outline, color: Colors.green),
                title: const Text("Add Branch"),
                onTap: () {
                  Navigator.pop(context);
                  _showTextInputDialog(
                    title: "New Idea",
                    hint: "Enter topic...",
                    onConfirm: (text) {
                      _addNode(
                        label: text,
                        position: node.position + const Offset(120, 80),
                        parentId: node.id,
                      );
                    },
                  );
                },
              ),
              // Opsi Rename
              ListTile(
                leading: const Icon(Icons.edit_outlined, color: Colors.blue),
                title: const Text("Rename"),
                onTap: () {
                  Navigator.pop(context);
                  _showTextInputDialog(
                    title: "Rename",
                    hint: "Enter new label...",
                    initialValue: node.label,
                    onConfirm: (text) => _editNodeLabel(node.id, text),
                  );
                },
              ),
              // Opsi Delete (Kecuali Root)
              if (node.parentId != null)
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.red),
                  title: const Text("Delete Branch"),
                  onTap: () {
                    Navigator.pop(context);
                    _deleteNode(node.id);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  void _showTextInputDialog({
    required String title,
    required String hint,
    String? initialValue,
    required Function(String) onConfirm,
  }) {
    final controller = TextEditingController(text: initialValue);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(hintText: hint),
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
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                onConfirm(controller.text);
                Navigator.pop(context);
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        title: const Text(
          "Mind Map", 
          style: TextStyle(color: AppColors.textMain, fontWeight: FontWeight.bold)
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textMain),
        actions: [
          IconButton(
            icon: const Icon(Icons.center_focus_strong),
            tooltip: "Reset View",
            onPressed: () {
              // --- PERBAIKAN ERROR (Reset Button) ---
              final size = MediaQuery.of(context).size;
              final x = -(_canvasSize / 2) + (size.width / 2);
              final y = -(_canvasSize / 2) + (size.height / 2);
              
              _transformController.value = Matrix4.translationValues(x, y, 0.0);
            },
          ),
        ],
      ),
      body: InteractiveViewer(
        transformationController: _transformController,
        boundaryMargin: const EdgeInsets.all(double.infinity),
        minScale: 0.1,
        maxScale: 2.5,
        constrained: false,
        child: Container(
          width: _canvasSize,
          height: _canvasSize,
          color: const Color(0xFFF0F4F8),
          child: Stack(
            children: [
              CustomPaint(
                size: Size(_canvasSize, _canvasSize),
                painter: MindMapPainter(nodes: nodes),
              ),

              ...nodes.map((node) {
                return Positioned(
                  left: node.position.dx,
                  top: node.position.dy,
                  child: DraggableNode(
                    key: ValueKey(node.id),
                    node: node,
                    onDragEnd: (offset) {
                      _updateNodePosition(node.id, offset);
                    },
                    onTap: () {
                      _showNodeOptions(node);
                    },
                  ),
                );
              }), 
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Tap a node to add a branch!"))
            );
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.tips_and_updates),
        label: const Text("Tips"),
      ),
    );
  }
}

class DraggableNode extends StatelessWidget {
  final MindNode node;
  final Function(Offset) onDragEnd;
  final VoidCallback onTap;

  const DraggableNode({
    super.key,
    required this.node,
    required this.onDragEnd,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (details) {
        // Update posisi visual saat digeser
        onDragEnd(node.position + details.delta);
      },
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: node.color,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: node.color.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Indikator Warna
            Container(
              width: 8, 
              height: 8, 
              decoration: BoxDecoration(color: node.color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            // Teks Label
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 200),
              child: Text(
                node.label,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: AppColors.textMain,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MindMapPainter extends CustomPainter {
  final List<MindNode> nodes;

  MindMapPainter({required this.nodes});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    for (var node in nodes) {
      if (node.parentId != null) {
        try {
          // Cari parent node
          final parent = nodes.firstWhere((n) => n.id == node.parentId);
          
          paint.color = node.color.withValues(alpha: 0.5);

          final startX = parent.position.dx + 50; 
          final startY = parent.position.dy + 20;
          
          final endX = node.position.dx + 50;
          final endY = node.position.dy + 20;

          final path = Path();
          path.moveTo(startX, startY);
          path.cubicTo(
            startX + (endX - startX) / 2, startY,
            startX + (endX - startX) / 2, endY,
            endX, endY
          );

          canvas.drawPath(path, paint);

        } catch (e) {
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}