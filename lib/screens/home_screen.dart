import 'package:flutter/material.dart';
import '../data/students_data.dart';
import '../models/student.dart';
import '../widgets/student_card.dart';
import 'add_student_screen.dart';
import 'student_detail_screen.dart';
import '../csv_export.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late List<Student> _students;
  List<Student> _filtered = [];
  final TextEditingController _searchController = TextEditingController();
  String _selectedLevel = 'All';

  final List<String> _levels = ['All', '100', '200', '300', '400', '500'];

  @override
  void initState() {
    super.initState();
    _students = List.from(sampleStudents);
    _filtered = _students;
    _searchController.addListener(_applyFilters);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filtered = _students.where((s) {
        final matchesSearch =
            s.name.toLowerCase().contains(query) ||
            s.studentNumber.toLowerCase().contains(query) ||
            s.department.toLowerCase().contains(query);
        final matchesLevel =
            _selectedLevel == 'All' || s.level == _selectedLevel;
        return matchesSearch && matchesLevel;
      }).toList();
    });
  }

  void _onLevelChanged(String? level) {
    if (level == null) return;
    _selectedLevel = level;
    _applyFilters();
  }

  void _addStudent(Student student) {
    setState(() {
      _students.add(student);
      _applyFilters();
    });
  }

  void _deleteStudent(String id) {
    setState(() {
      _students.removeWhere((s) => s.id == id);
      _applyFilters();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MIS424 — Student Records'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: Text(
                '${_filtered.length} student${_filtered.length == 1 ? '' : 's'}',
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Export to CSV',
            onPressed: () {
              exportAndShareStudents(_filtered);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildLevelFilter(),
          Expanded(
            child: _filtered.isEmpty
                ? const Center(
                    child: Text(
                      'No students found.',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: _filtered.length,
                    itemBuilder: (context, index) {
                      final student = _filtered[index];
                      return StudentCard(
                        student: student,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => StudentDetailScreen(
                              student: student,
                              onDelete: () => _deleteStudent(student.id),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push<Student>(
            context,
            MaterialPageRoute(builder: (_) => const AddStudentScreen()),
          );
          if (result != null) _addStudent(result);
        },
        icon: const Icon(Icons.person_add),
        label: const Text('Add Student'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search by name, number, or department…',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => _searchController.clear(),
                )
              : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
      ),
    );
  }

  Widget _buildLevelFilter() {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        itemCount: _levels.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final level = _levels[index];
          final selected = level == _selectedLevel;
          return ChoiceChip(
            label: Text(level == 'All' ? 'All Levels' : 'Level $level'),
            selected: selected,
            onSelected: (_) => _onLevelChanged(level),
            selectedColor: Colors.indigo,
            labelStyle: TextStyle(
              color: selected ? Colors.white : Colors.black87,
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            ),
          );
        },
      ),
    );
  }
}
