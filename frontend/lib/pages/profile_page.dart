import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:schedula/models/user.dart';
import 'package:schedula/services/user_service.dart';
import 'package:schedula/widgets/set_profile_button.dart';

class ProfilePage extends StatefulWidget {
  final int userId;
  final VoidCallback onLogout;
  final Function(int)? onNavigateToTab;

  const ProfilePage({
    super.key,
    required this.userId,
    required this.onLogout,
    this.onNavigateToTab,
  });

  @override
  ProfilePageState createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  late User user;
  bool isLoading = true;

  final UserService userService = UserService();
  int? userId;

  @override
  void initState() {
    super.initState();
    _loadLocalUserId();
  }

  void _loadLocalUserId() async {
    final id = await userService.getUserId();
    if (!mounted) return;
    setState(() {
      userId = id != null ? int.parse(id) : null;
      isLoading = false;
    });
  }

  Future<void> _changeProfileImage() async {
    final ImagePicker picker = ImagePicker();

    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (pickedFile == null) return;

    setState(() {
      isLoading = true;
    });

    try {
      final File imageFile = File(pickedFile.path);
      final User updatedUser =
          await userService.uploadProfileImage(widget.userId, imageFile);

      if (!mounted) return;
      setState(() {
        user = updatedUser;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Errore nel caricamento dell'immagine: $e"),
        ),
      );
    }
  }

  Future<void> onSave(Map<String, String> userData) async {
    setState(() {
      isLoading = true;
    });

    final User toUpdateUser = User(
      id: widget.userId,
      email: userData['email'] ?? user.email,
      password: (userData['password'] != null &&
              userData['password']!.isNotEmpty)
          ? userData['password']!
          : user.password,
      firstName: userData['firstName'] ?? user.firstName,
      lastName: userData['lastName'] ?? user.lastName,
      profileImage: userData['profileImage'] ?? user.profileImage,
    );

    final User updatedUser =
        await userService.updateUser(widget.userId, toUpdateUser);

    if (!mounted) return;
    setState(() {
      user = updatedUser;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final size = media.size;
    final orientation = media.orientation;

    // Breakpoint
    final bool isSmallPhone = size.shortestSide < 360;
    final bool isTablet =
        size.shortestSide >= 600 && size.shortestSide < 1024;
    final bool isDesktop = size.shortestSide >= 1024;

    // Header responsive (più grande su tablet)
    final double headerHeight = size.height *
        (isDesktop
            ? 0.38
            : isTablet
                ? (orientation == Orientation.portrait ? 0.45 : 0.40)
                : (orientation == Orientation.portrait ? 0.30 : 0.26));

    // Avatar grande su tablet
    final double avatarSize = isDesktop
        ? 230
        : isTablet
            ? 200
            : (isSmallPhone ? 110 : 140);

    // Font responsive
    final double nameFontSize = isDesktop
        ? 32
        : isTablet
            ? 30
            : (isSmallPhone ? 18 : 22);

    final double emailFontSize = isDesktop
        ? 20
        : isTablet
            ? 18
            : 14;

    final double headerHorizontalPadding = isDesktop
        ? 48
        : isTablet
            ? 24
            : 16;

    // Su desktop restringo un po' il layout, su tablet e telefoni NO (usa tutta la larghezza)
    final double contentMaxWidth = isDesktop ? 900 : double.infinity;

    return FutureBuilder<User>(
      future: userService.getUserById(widget.userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Errore: ${snapshot.error}"));
        } else if (!snapshot.hasData) {
          return const Center(child: Text("Nessun utente trovato"));
        }

        user = snapshot.data!;

        return Stack(
          children: [
            SafeArea(
              child: Center(
                // SOLO desktop viene centrato e ristretto
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: contentMaxWidth),
                  child: Column(
                    children: [
                      // HEADER
                      Container(
                        width: double.infinity,
                        height: headerHeight,
                        padding: EdgeInsets.only(
                          top: size.height * 0.02,
                          left: headerHorizontalPadding,
                          right: headerHorizontalPadding,
                        ),
                        decoration: const BoxDecoration(
                          color: Colors.indigo,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(60),
                            bottomRight: Radius.circular(60),
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ClipOval(
                              child: CachedNetworkImage(
                                imageUrl: user.profileImage,
                                fit: BoxFit.cover,
                                width: avatarSize,
                                height: avatarSize,
                                placeholder: (context, url) =>
                                    const CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                                errorWidget: (context, url, error) =>
                                    const Icon(
                                  Icons.person,
                                  size: 80,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              "${user.firstName} ${user.lastName}",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: nameFontSize,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              user.email,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: emailFontSize,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),

                      // CONTENUTO
                      Expanded(
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              children: [
                                const SizedBox(height: 8),
                                SetProfileButton(
                                  iconForSettings: Icons.edit,
                                  textForSettings: "Nome",
                                  action: () {
                                    showEditDialog(
                                      context: context,
                                      title: "Modifica Nome",
                                      fields: [
                                        FieldData(
                                          key: 'firstName',
                                          label: 'Nome',
                                          initialValue: user.firstName,
                                        ),
                                        FieldData(
                                          key: 'lastName',
                                          label: 'Cognome',
                                          initialValue: user.lastName,
                                        ),
                                      ],
                                      onSave: onSave,
                                    );
                                  },
                                ),
                                SetProfileButton(
                                  iconForSettings: Icons.email,
                                  textForSettings: "Email",
                                  action: () {
                                    showEditDialog(
                                      context: context,
                                      title: "Modifica Email",
                                      fields: [
                                        FieldData(
                                          key: 'email',
                                          label: 'Email',
                                          initialValue: user.email,
                                        ),
                                      ],
                                      onSave: onSave,
                                    );
                                  },
                                ),
                                SetProfileButton(
                                  iconForSettings: Icons.password,
                                  textForSettings: "Password",
                                  action: () {
                                    showEditDialog(
                                      context: context,
                                      title: "Modifica Password",
                                      fields: [
                                        FieldData(
                                          key: 'password',
                                          label: 'Nuova password',
                                          initialValue: "",
                                        ),
                                        FieldData(
                                          key: 'confirmPassword',
                                          label: 'Conferma password',
                                          initialValue: "",
                                        ),
                                      ],
                                      onSave: onSave,
                                    );
                                  },
                                ),
                                SetProfileButton(
                                  iconForSettings: Icons.image,
                                  textForSettings: "Immagine del profilo",
                                  action: _changeProfileImage,
                                ),
                                SetProfileButton(
                                  iconForSettings: Icons.store,
                                  textForSettings: "Modifica attività",
                                  action: () {
                                    widget.onNavigateToTab?.call(2);
                                  },
                                ),
                                SetProfileButton(
                                  iconForSettings: Icons.logout,
                                  textForSettings: "Logout",
                                  action: widget.onLogout,
                                ),
                                const SizedBox(height: 20),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // OVERLAY CARICAMENTO
            if (isLoading)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.25),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Future<void> showEditDialog({
    required BuildContext context,
    required String title,
    required List<FieldData> fields,
    required Function(Map<String, String>) onSave,
  }) async {
    final formKey = GlobalKey<FormState>();
    final Map<String, String> newValues = {
      for (var f in fields) f.key: f.initialValue,
    };

    final Map<String, bool> obscureStates = {
      for (var f in fields)
        f.key: (f.key == 'password' || f.key == 'confirmPassword'),
    };

    await showDialog(
      context: context,
      builder: (context) {
        final size = MediaQuery.of(context).size;
        final bool isSmallHeight = size.height < 600;

        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text(title),
              content: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 400,
                  maxHeight:
                      isSmallHeight ? size.height * 0.5 : size.height * 0.6,
                ),
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: fields.map((field) {
                        final isPasswordField =
                            field.key == 'password' ||
                                field.key == 'confirmPassword';

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6.0),
                          child: TextFormField(
                            initialValue: field.initialValue,
                            decoration: InputDecoration(
                              labelText: field.label,
                              suffixIcon: isPasswordField
                                  ? IconButton(
                                      icon: Icon(
                                        (obscureStates[field.key] ?? true)
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                      ),
                                      onPressed: () {
                                        setStateDialog(() {
                                          obscureStates[field.key] =
                                              !(obscureStates[field.key] ??
                                                  true);
                                        });
                                      },
                                    )
                                  : null,
                            ),
                            obscureText: isPasswordField
                                ? (obscureStates[field.key] ?? true)
                                : false,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Questo campo non può essere vuoto';
                              }

                              final text = value.trim();

                              switch (field.key) {
                                case 'firstName':
                                case 'lastName':
                                  if (!RegExp(r"^[a-zA-ZàèìòùÀÈÌÒÙ\s']+$")
                                      .hasMatch(text)) {
                                    return "Inserisci un nome valido";
                                  }
                                  break;
                                case 'email':
                                  if (!RegExp(
                                          r"^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$")
                                      .hasMatch(text)) {
                                    return "Inserisci un'email valida";
                                  }
                                  break;
                                case 'password':
                                  if (text.length < 6) {
                                    return "La password deve contenere almeno 6 caratteri";
                                  }
                                  break;
                                case 'confirmPassword':
                                  final pwd = newValues['password'] ?? '';
                                  if (text != pwd) {
                                    return "Le password non coincidono";
                                  }
                                  break;
                                case 'profileImage':
                                  if (!text.startsWith("http://") &&
                                      !text.startsWith("https://")) {
                                    return "Inserisci un URL valido";
                                  }
                                  break;
                              }

                              return null;
                            },
                            onChanged: (value) {
                              newValues[field.key] = value.trim();
                            },
                            onSaved: (value) {
                              newValues[field.key] = value?.trim() ?? '';
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Annulla'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      formKey.currentState!.save();
                      newValues.remove('confirmPassword');
                      onSave(newValues);
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text('Salva'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class FieldData {
  final String key;
  final String label;
  final String initialValue;

  FieldData({
    required this.key,
    required this.label,
    required this.initialValue,
  });
}
