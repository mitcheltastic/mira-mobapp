import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Import sesuai path project Anda
import '../../../core/constant/app_colors.dart';

// --- DATA MODEL ---
enum Quadrant {
  doFirst, // Q1: Urgent & Important
  schedule, // Q2: Not Urgent & Important
  delegate, // Q3: Urgent & Not Important
  delete // Q4: Not Urgent & Not Important
}

class EisenhowerTask {
  String id;
  String title;
  String description;
  Quadrant quadrant;
  bool isCompleted;

  EisenhowerTask({
    required this.id,
    required this.title,
    required this.description,
    required this.quadrant,
    this.isCompleted = false,
  });
}

class EisenhowerScreen extends StatefulWidget {
  const EisenhowerScreen({super.key});

  @override
  State<EisenhowerScreen> createState() => _EisenhowerScreenState();
}

class _EisenhowerScreenState extends State<EisenhowerScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _entryAnimController;

  // --- STATE DATA (RAM Only) ---
  List<EisenhowerTask> tasks = [
    EisenhowerTask(
        id: '1',
        title: 'Urgent Bug Fix',
        description: 'Critical production issue',
        quadrant: Quadrant.doFirst),
    EisenhowerTask(
        id: '2',
        title: 'Learn State Management',
        description: 'For better architecture',
        quadrant: Quadrant.schedule),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    // Animasi Masuk
    _entryAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    // Listener Tab
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });

    // Intro guide muncul saat awal buka
    WidgetsBinding.instance.addPostFrameCallback((_) => _showIntroGuide());
  }

  @override
  void dispose() {
    _tabController.dispose();
    _entryAnimController.dispose();
    super.dispose();
  }

  // --- LOGIC CRUD ---

  void _addTask(String title, String desc, Quadrant q) {
    setState(() {
      tasks.add(EisenhowerTask(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        description: desc,
        quadrant: q,
      ));
    });
    HapticFeedback.mediumImpact();
  }

  void _editTask(String id, String newTitle, String newDesc, Quadrant newQ) {
    setState(() {
      final index = tasks.indexWhere((t) => t.id == id);
      if (index != -1) {
        tasks[index].title = newTitle;
        tasks[index].description = newDesc;
        tasks[index].quadrant = newQ;
      }
    });
    HapticFeedback.lightImpact();
  }

  void _deleteTask(String id) {
    setState(() {
      tasks.removeWhere((t) => t.id == id);
    });
    HapticFeedback.mediumImpact();
  }

  void _toggleTask(String id) {
    setState(() {
      final index = tasks.indexWhere((t) => t.id == id);
      if (index != -1) {
        tasks[index].isCompleted = !tasks[index].isCompleted;
      }
    });
    HapticFeedback.selectionClick();
  }

  // --- HELPERS WARNA (MENGGUNAKAN APPCOLORS) ---

  Color _getQuadrantColor(Quadrant q) {
    switch (q) {
      case Quadrant.doFirst:
        return AppColors.eisenhowerDo;
      case Quadrant.schedule:
        return AppColors.eisenhowerPlan;
      case Quadrant.delegate:
        return AppColors.eisenhowerDelegate;
      case Quadrant.delete:
        return AppColors.eisenhowerDrop;
    }
  }

  String _getQuadrantLabel(Quadrant q) {
    switch (q) {
      case Quadrant.doFirst:
        return "Do First";
      case Quadrant.schedule:
        return "Schedule";
      case Quadrant.delegate:
        return "Delegate";
      case Quadrant.delete:
        return "Eliminate";
    }
  }

  // --- INTRO GUIDE (Konsisten) ---

  void _showIntroGuide() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          padding: const EdgeInsets.fromLTRB(32, 12, 32, 0),
          child: Column(
            children: [
              Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 24),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      const Text("Eisenhower Matrix",
                          style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textMain,
                              letterSpacing: -0.5)),
                      const SizedBox(height: 8),
                      const Text(
                        "Prioritize tasks by urgency and importance to boost productivity.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 15,
                            height: 1.4),
                      ),
                      const SizedBox(height: 30),
                      _buildGuideItem(
                          Icons.flash_on_rounded,
                          AppColors.eisenhowerDo,
                          "Do First",
                          "Urgent & Important. Do it now."),
                      _buildGuideItem(
                          Icons.calendar_month_rounded,
                          AppColors.eisenhowerPlan,
                          "Schedule",
                          "Not Urgent but Important. Plan a time."),
                      _buildGuideItem(
                          Icons.people_alt_rounded,
                          AppColors.eisenhowerDelegate,
                          "Delegate",
                          "Urgent but Not Important. Can someone else do it?"),
                      _buildGuideItem(
                          Icons.delete_outline_rounded,
                          AppColors.eisenhowerDrop,
                          "Drop",
                          "Neither Urgent nor Important. Eliminate it."),
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
                      backgroundColor: AppColors.eisenhowerPlan,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Start Prioritizing",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGuideItem(
      IconData icon, Color color, String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 25),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16)),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.textMain)),
                const SizedBox(height: 4),
                Text(desc,
                    style: const TextStyle(
                        color: AppColors.textMuted, fontSize: 13, height: 1.4)),
              ],
            ),
          )
        ],
      ),
    );
  }

  // --- UI FORMS ---

  void _showTaskSheet({EisenhowerTask? task}) {
    final titleController = TextEditingController(text: task?.title ?? "");
    final descController = TextEditingController(text: task?.description ?? "");
    Quadrant selectedQuadrant =
        task?.quadrant ?? Quadrant.values[_tabController.index];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(builder: (context, setSheetState) {
        return Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                    child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(10)))),
                const SizedBox(height: 24),
                Text(task == null ? "New Task" : "Edit Task",
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textMain)),
                const SizedBox(height: 20),

                // Title
                TextField(
                  controller: titleController,
                  autofocus: true,
                  textCapitalization: TextCapitalization.sentences,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, color: AppColors.textMain),
                  decoration: InputDecoration(
                    labelText: "Title",
                    hintText: "What needs to be done?",
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                  ),
                ),
                const SizedBox(height: 16),

                // Desc
                TextField(
                  controller: descController,
                  textCapitalization: TextCapitalization.sentences,
                  style: const TextStyle(color: AppColors.textMain),
                  decoration: InputDecoration(
                    labelText: "Description (Optional)",
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                  ),
                ),
                const SizedBox(height: 24),

                // Category Selector
                const Text("Category",
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMuted,
                        fontSize: 13)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: Quadrant.values.map((q) {
                    final isSelected = selectedQuadrant == q;
                    final color = _getQuadrantColor(q);
                    return GestureDetector(
                      onTap: () => setSheetState(() => selectedQuadrant = q),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? color : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: isSelected
                                  ? color
                                  : Colors.grey.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          _getQuadrantLabel(q),
                          style: TextStyle(
                            color:
                                isSelected ? Colors.white : AppColors.textMuted,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.textMain,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 0,
                    ),
                    onPressed: () {
                      if (titleController.text.trim().isNotEmpty) {
                        if (task == null) {
                          _addTask(titleController.text, descController.text,
                              selectedQuadrant);
                        } else {
                          _editTask(task.id, titleController.text,
                              descController.text, selectedQuadrant);
                        }
                        Navigator.pop(context);
                      }
                    },
                    child: const Text("Save Task",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
                  ),
                )
              ],
            ),
          ),
        );
      }),
    );
  }

  // --- MAIN UI ---

  @override
  Widget build(BuildContext context) {
    // Warna aktif berdasarkan tab saat ini
    final activeColor =
        _getQuadrantColor(Quadrant.values[_tabController.index]);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 20, color: AppColors.textMain),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Priorities",
            style: TextStyle(
                fontWeight: FontWeight.w800, color: AppColors.textMain)),
        actions: [
          IconButton(
            onPressed: _showIntroGuide,
            icon: const Icon(Icons.help_outline_rounded,
                color: AppColors.textMuted),
          )
        ],
        // --- CUSTOM MODERN TAB BAR ---
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: Container(
            margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(25), // Full rounded capsule
            ),
            child: TabBar(
              controller: _tabController,
              overlayColor: WidgetStateProperty.all(Colors.transparent),
              dividerColor: Colors.transparent,

              // Style Indikator: Kapsul melayang
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorPadding: const EdgeInsets.all(4),
              indicator: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2))
                ],
              ),

              labelColor: activeColor,
              unselectedLabelColor: AppColors.textMuted,
              labelStyle:
                  const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
              unselectedLabelStyle:
                  const TextStyle(fontWeight: FontWeight.w400, fontSize: 12),

              tabs: const [
                Tab(text: "DO"),
                Tab(text: "PLAN"),
                Tab(text: "DELEGATE"),
                Tab(text: "DROP"),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
            .animate(_entryAnimController),
        child: FloatingActionButton.extended(
          onPressed: () => _showTaskSheet(),
          backgroundColor: activeColor,
          elevation: 3,
          icon: const Icon(Icons.add_rounded, color: Colors.white),
          label: const Text("New Task",
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: Quadrant.values.map((q) => _buildTaskList(q)).toList(),
      ),
    );
  }

  Widget _buildTaskList(Quadrant quadrant) {
    // Filter data sesuai kuadran
    final qTasks = tasks.where((t) => t.quadrant == quadrant).toList();
    final color = _getQuadrantColor(quadrant);

    if (qTasks.isEmpty) {
      // EMPTY STATE
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.assignment_add,
                  size: 48, color: color.withValues(alpha: 0.5)),
            ),
            const SizedBox(height: 16),
            Text(
              "No tasks in ${_getQuadrantLabel(quadrant)}",
              style: TextStyle(
                  color: AppColors.textMuted.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 80),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      itemCount: qTasks.length,
      // Use __ for the second parameter to make it unique
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final task = qTasks[index];

        // --- TASK CARD ---
        return SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
              .animate(
            CurvedAnimation(
                parent: _entryAnimController,
                curve: Interval(index * 0.1, 1.0, curve: Curves.easeOut)),
          ),
          child: Dismissible(
            key: Key(task.id),
            direction: DismissDirection.endToStart,
            onDismissed: (_) => _deleteTask(task.id),
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              decoration: BoxDecoration(
                color: AppColors.error, // Menggunakan warna error untuk delete
                borderRadius: BorderRadius.circular(16),
              ),
              child:
                  const Icon(Icons.delete_outline_rounded, color: Colors.white),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4))
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _showTaskSheet(task: task),
                    child: Row(
                      children: [
                        // Color Indicator Strip (Kiri)
                        Container(
                          width: 6,
                          height: 80,
                          color: task.isCompleted ? Colors.grey[300] : color,
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                            child: Row(
                              children: [
                                // Checkbox Custom
                                GestureDetector(
                                  onTap: () => _toggleTask(task.id),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: task.isCompleted
                                          ? Colors.grey[300]
                                          : color.withValues(alpha: 0.1),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: task.isCompleted
                                              ? Colors.grey[400]!
                                              : color,
                                          width: 2),
                                    ),
                                    child: task.isCompleted
                                        ? const Icon(Icons.check,
                                            size: 16, color: Colors.white)
                                        : null,
                                  ),
                                ),
                                const SizedBox(width: 16),

                                // Texts
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        task.title,
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: task.isCompleted
                                              ? AppColors.textMuted
                                              : AppColors.textMain,
                                          decoration: task.isCompleted
                                              ? TextDecoration.lineThrough
                                              : null,
                                        ),
                                      ),
                                      if (task.description.isNotEmpty) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          task.description,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              fontSize: 13,
                                              color: AppColors.textMuted
                                                  .withValues(alpha: 0.7)),
                                        ),
                                      ]
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
