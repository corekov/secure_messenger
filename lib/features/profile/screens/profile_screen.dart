import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../l10n/app_localizations.dart';

import '../../auth/providers/auth_provider.dart';
import '../providers/profile_provider.dart';
import '../../../core/storage/secure_storage_service.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _bioController = TextEditingController();
  bool _isEditingBio = false;
  bool _isUploadingAvatar = false;

  @override
  void dispose() {
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadAvatar() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    setState(() => _isUploadingAvatar = true);
    try {
      await ref.read(profileProvider.notifier).uploadAvatar(File(image.path));
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.avatarUpdated)));
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.avatarUpdateFailed(e.toString())),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploadingAvatar = false);
    }
  }

  Future<void> _saveBio() async {
    try {
      await ref
          .read(profileProvider.notifier)
          .updateBio(_bioController.text.trim());
      setState(() => _isEditingBio = false);
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.bioUpdated)));
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.bioUpdateFailed(e.toString())),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(profileProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.profile)),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) =>
            const Center(child: Text('Failed to load profile')),
        data: (profile) {
          if (profile == null) return const SizedBox.shrink();

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 120),
            children: [
              Center(
                child: GestureDetector(
                  onTap: _pickAndUploadAvatar,
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [Colors.blueAccent, Colors.purpleAccent],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 56,
                          backgroundColor: Theme.of(context).cardColor,
                          child:
                              profile.avatarUrl != null &&
                                  profile.avatarUrl!.isNotEmpty
                              ? FutureBuilder<String?>(
                                  future: ref
                                      .read(secureStorageServiceProvider)
                                      .getAccessToken(),
                                  builder: (context, snapshot) {
                                    if (!snapshot.hasData) {
                                      return const CircularProgressIndicator();
                                    }
                                    return ClipOval(
                                      child: Image.network(
                                        'http://10.0.2.2:8080${profile.avatarUrl}',
                                        headers: {
                                          'Authorization':
                                              'Bearer ${snapshot.data}',
                                        },
                                        width: 112,
                                        height: 112,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                Icon(
                                                  Icons.person,
                                                  size: 60,
                                                  color: Theme.of(
                                                    context,
                                                  ).iconTheme.color,
                                                ),
                                      ),
                                    );
                                  },
                                )
                              : Icon(
                                  Icons.person,
                                  size: 60,
                                  color: Theme.of(context).iconTheme.color,
                                ),
                        ),
                      ),
                      if (_isUploadingAvatar)
                        const Positioned.fill(
                          child: Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          ),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Colors.blueAccent,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  profile.username,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Center(
                child: Text(
                  l10n.activeStatus,
                  style: const TextStyle(
                    color: Colors.greenAccent,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Bio Section
              Material(
                color: Theme.of(context).cardColor,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white.withAlpha(10)
                        : Colors.black.withAlpha(10),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.blueAccent.withAlpha(30),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.info_outline,
                              color: Colors.blueAccent,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            l10n.aboutMe,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          if (!_isEditingBio)
                            IconButton(
                              icon: const Icon(
                                Icons.edit_outlined,
                                color: Colors.blueAccent,
                              ),
                              onPressed: () {
                                _bioController.text = profile.bio ?? '';
                                setState(() => _isEditingBio = true);
                              },
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (_isEditingBio) ...[
                        TextField(
                          controller: _bioController,
                          maxLength: 150,
                          maxLines: 3,
                          style: const TextStyle(fontSize: 15),
                          decoration: InputDecoration(
                            hintText: l10n.tellUsAboutYourself,
                            filled: true,
                            fillColor: Theme.of(
                              context,
                            ).scaffoldBackgroundColor,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.all(16),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () =>
                                  setState(() => _isEditingBio = false),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.grey,
                              ),
                              child: Text(l10n.cancel),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: _saveBio,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                              ),
                              child: Text(
                                l10n.save,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ] else ...[
                        Text(
                          profile.bio?.isNotEmpty == true
                              ? profile.bio!
                              : l10n.noBioSet,
                          style: TextStyle(
                            fontSize: 15,
                            height: 1.5,
                            color: profile.bio?.isNotEmpty == true
                                ? Theme.of(context).textTheme.bodyLarge?.color
                                : Colors.grey,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),
              OutlinedButton.icon(
                onPressed: () {
                  ref.read(authProvider.notifier).logout();
                },
                icon: const Icon(Icons.logout, color: Colors.redAccent),
                label: Text(
                  l10n.logout,
                  style: const TextStyle(
                    color: Colors.redAccent,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.redAccent.withAlpha(100)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
