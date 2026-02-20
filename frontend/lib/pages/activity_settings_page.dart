import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:schedula/models/business.dart';
import 'package:schedula/models/business_service.dart' as bs;

import 'package:schedula/services/business_service.dart';
import 'package:schedula/services/service_service.dart';

class ActivitySettingsPage extends StatefulWidget {
  final Business? business;
  final VoidCallback onCloseExtraPage;
  final int ownerId;

  const ActivitySettingsPage({
    super.key,
    required this.onCloseExtraPage,
    required this.ownerId,
    this.business,
  });

  @override
  State<ActivitySettingsPage> createState() => _ActivitySettingsPageState();
}

class _ActivitySettingsPageState extends State<ActivitySettingsPage> {
  final _formKey = GlobalKey<FormState>();

  final BusinessService _businessApi = BusinessService();
  final ServiceService _serviceApi = ServiceService();

  late final TextEditingController _nameController;
  late final TextEditingController _addressController;

  File? _selectedImageFile;
  bool _isSubmitting = false;

  bool get _isEditMode => widget.business != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.business?.name ?? "");
    _addressController = TextEditingController(text: widget.business?.address ?? "");
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);

    if (picked != null) {
      setState(() {
        _selectedImageFile = File(picked.path);
      });
    }
  }

  Future<void> _deleteBusiness() async {
    setState(() => _isSubmitting = true);
    try {
      await _businessApi.deleteBusiness(widget.business!.id);
      widget.onCloseExtraPage();
    } catch (e) {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Errore: $e")));
    }
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Elimina attività"),
          content: const Text(
              "Sei sicuro di voler eliminare questa attività? L'operazione è irreversibile."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Annulla"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await _deleteBusiness();
              },
              child: const Text("Elimina", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveBusiness() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      Business business;

      if (_isEditMode) {
        business = await _businessApi.updateBusiness(
          id: widget.business!.id,
          name: _nameController.text.trim(),
          address: _addressController.text.trim(),
        );
      } else {
        business = await _businessApi.createBusiness(
          name: _nameController.text.trim(),
          address: _addressController.text.trim(),
          ownerId: widget.ownerId,
        );
      }

      // UPLOAD IMMAGINE solo se selezionata
      if (_selectedImageFile != null) {
        await _businessApi.uploadBusinessImage(
          business.id,
          _selectedImageFile!,
        );
      }

      widget.onCloseExtraPage();
    } catch (e) {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Errore: $e")));
    }
  }

  Future<void> _deleteService(int id) async {
    await _serviceApi.deleteService(id);
    if (mounted) setState(() {});
  }

  void _openServiceDialog({bs.BusinessService? service}) {
    final nameController = TextEditingController(text: service?.name ?? "");
    final priceController =
        TextEditingController(text: service?.price?.toString() ?? "");
    final durationController =
        TextEditingController(text: service?.durationMinutes?.toString() ?? "");

    final _serviceFormKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(service == null ? "Nuovo servizio" : "Modifica servizio"),
          content: SingleChildScrollView(
            child: Form(
              key: _serviceFormKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration:
                        const InputDecoration(labelText: "Nome servizio"),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Inserisci il nome del servizio";
                      }
                      if (!RegExp(r"^[a-zA-Z0-9àèìòùÀÈÌÒÙ\s']+$")
                          .hasMatch(value.trim())) {
                        return "Nome non valido";
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: priceController,
                    decoration:
                        const InputDecoration(labelText: "Prezzo (€)"),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Inserisci il prezzo";
                      }
                      final normalized =
                          value.trim().replaceAll(',', '.'); // gestiamo la virgola
                      final price = double.tryParse(normalized);
                      if (price == null || price <= 0) {
                        return "Inserisci un prezzo valido (> 0)";
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: durationController,
                    decoration:
                        const InputDecoration(labelText: "Durata (minuti)"),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Inserisci la durata";
                      }
                      final duration = int.tryParse(value.trim());
                      if (duration == null || duration <= 0) {
                        return "Inserisci una durata valida (> 0)";
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Annulla"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (!_serviceFormKey.currentState!.validate()) return;

                final name = nameController.text.trim();
                final priceText =
                    priceController.text.trim().replaceAll(',', '.');
                final price = double.tryParse(priceText) ?? 0.0;
                final duration =
                    int.tryParse(durationController.text.trim()) ?? 30;

                if (service == null) {
                  await _serviceApi.createService(
                    businessId: widget.business!.id,
                    name: name,
                    price: price,
                    durationMinutes: duration, 
                    iconUrl: '',
                  );
                } else {
                  await _serviceApi.updateService(
                    id: service.id,
                    name: name,
                    price: price,
                    durationMinutes: duration, 
                    iconUrl: '',
                  );
                }

                if (mounted) setState(() {});
                Navigator.pop(context);
              },
              child: Text(service == null ? "Crea" : "Salva"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final existingPhotoUrl = widget.business?.photoUrl ?? "";

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: _isSubmitting ? null : widget.onCloseExtraPage,
        ),
        title: Text(_isEditMode ? "Modifica attività" : "Crea attività"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ---------------- IMMAGINE ----------------
            GestureDetector(
              onTap: _isSubmitting ? null : _pickImage,
              child: Container(
                height: 160,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                  image: _selectedImageFile != null
                      ? DecorationImage(
                          image: FileImage(_selectedImageFile!),
                          fit: BoxFit.cover,
                        )
                      : (existingPhotoUrl.isNotEmpty
                          ? DecorationImage(
                              image: NetworkImage(existingPhotoUrl),
                              fit: BoxFit.cover,
                            )
                          : null),
                ),
                child: (_selectedImageFile == null && existingPhotoUrl.isEmpty)
                    ? const Center(
                        child: Icon(Icons.add_a_photo,
                            size: 40, color: Colors.grey),
                      )
                    : null,
              ),
            ),

            const SizedBox(height: 20),

            // ---------------- FORM ----------------
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: "Nome attività",
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => v == null || v.trim().isEmpty
                        ? "Inserisci il nome"
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _addressController,
                    decoration: const InputDecoration(
                      labelText: "Indirizzo",
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => v == null || v.trim().isEmpty
                        ? "Inserisci l'indirizzo"
                        : null,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ---------------- SERVIZI ----------------
            if (_isEditMode) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Servizi dell'attività",
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),

              FutureBuilder<List<bs.BusinessService>>(
                future: _serviceApi.getServicesOfBusiness(widget.business!.id),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Text(
                      "Errore nel caricamento dei servizi: ${snapshot.error}",
                    );
                  }

                  final services = snapshot.data ?? [];

                  if (services.isEmpty) {
                    return const Text("Nessun servizio presente");
                  }

                  return Column(
                    children: [
                      for (final s in services)
                        Card(
                          child: ListTile(
                            title: Text(s.name),
                            subtitle: Text(
                              "€ ${s.price?.toStringAsFixed(2) ?? "N/D"} • ${s.durationMinutes ?? 0} min",
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () =>
                                      _openServiceDialog(service: s),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () => _deleteService(s.id),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: () => _openServiceDialog(),
                  icon: const Icon(Icons.add),
                  label: const Text("Aggiungi servizio"),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // ---------------- ELIMINA ATTIVITÀ ----------------
            if (_isEditMode)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _confirmDelete,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text("Elimina attività"),
                ),
              ),

            const SizedBox(height: 16),

            // ---------------- SALVA ----------------
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _saveBusiness,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(_isEditMode ? "Salva modifiche" : "Crea attività"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
