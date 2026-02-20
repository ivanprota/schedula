import 'package:flutter/material.dart';
import 'package:schedula/models/business.dart';
import 'package:schedula/services/business_service.dart';
import 'package:schedula/widgets/activity_container.dart';

class HomePage extends StatefulWidget {
  final Function(Widget) onOpenExtraPage;
  final VoidCallback onCloseExtraPage;
  final int userId;

  const HomePage({
    super.key,
    required this.onOpenExtraPage,
    required this.onCloseExtraPage,
    required this.userId,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final BusinessService businessService = BusinessService();
  final TextEditingController _searchController = TextEditingController();

  List<Business> businesses = [];
  bool isLoading = true;
  String? _errorMessage;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadAllBusinesses();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAllBusinesses() async {
    setState(() {
      isLoading = true;
      _errorMessage = null;
    });

    try {
      final list = await businessService.getAllBusiness();
      setState(() {
        businesses = list;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        _errorMessage = 'Errore nel caricamento delle attività';
      });
    }
  }

  Future<void> _searchBusinesses(String query) async {
    final trimmed = query.trim();
    setState(() {
      _searchQuery = trimmed;
    });

    // Se la query è vuota → ricarico tutte le attività
    if (trimmed.isEmpty) {
      await _loadAllBusinesses();
      return;
    }

    setState(() {
      isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await businessService.searchBusinesses(trimmed);
      setState(() {
        businesses = results;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        _errorMessage = 'Errore nella ricerca delle attività';
      });
    }
  }

  // 🔍 Search bar bella, ricerca solo su invio/icona search
  Widget buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        textInputAction: TextInputAction.search,
        onSubmitted: (value) {
          _searchBusinesses(value); // 🔹 ricerca parte solo qui
        },
        decoration: InputDecoration(
          hintText: 'Cerca attività...',
          hintStyle: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 16,
          ),
          prefixIcon: const Icon(Icons.search, color: Colors.indigo),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () {
                    _searchController.clear();
                    _searchBusinesses(''); // reset: ricarica tutte
                  },
                )
              : IconButton(
                  icon: const Icon(Icons.search, color: Colors.indigo),
                  onPressed: () {
                    _searchBusinesses(_searchController.text);
                  },
                ),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
        // NON usiamo onChanged per evitare richieste ad ogni carattere
        onChanged: (_) {
          // serve solo a far ridisegnare la suffixIcon (X / lente)
          setState(() {});
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            buildSearchBar(),

            const SizedBox(height: 16),

            Expanded(
              child: Builder(
                builder: (context) {
                  if (isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (_errorMessage != null) {
                    return Center(child: Text(_errorMessage!));
                  }

                  if (businesses.isEmpty) {
                    return const Center(child: Text("Nessuna attività trovata"));
                  }

                  return ListView.builder(
                    itemCount: businesses.length,
                    itemBuilder: (context, index) {
                      return ActivityContainer(
                        business: businesses[index],
                        onOpenExtraPage: widget.onOpenExtraPage,
                        onCloseExtraPage: widget.onCloseExtraPage,
                        wasCalledByHomePage: true,
                        wasCalledByActivitiesPage: false,
                        userId: widget.userId,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
