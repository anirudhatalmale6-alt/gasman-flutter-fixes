import 'dart:io';
import 'package:flutter/material.dart';

import '../services/attachment_service.dart';
import '../utils_class/any_file_pick.dart';
import '../utils_class/image_pick.dart';



class AttachmentSection extends StatefulWidget {
  final String parentType; // "invoice" or "bill"
  final int parentId;

  const AttachmentSection({
    super.key,
    required this.parentType,
    required this.parentId,
  });

  @override
  State<AttachmentSection> createState() => _AttachmentSectionState();
}

class _AttachmentSectionState extends State<AttachmentSection> {
  final AttachmentService _service = AttachmentService();
  bool _loading = false;
  List<dynamic> _items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final items = await _service.list(
        parentType: widget.parentType,
        parentId: widget.parentId,
      );
      setState(() => _items = items);
    } catch (_) {
      // keep silent; show snack on actions
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _upload(File file) async {
    setState(() => _loading = true);
    try {
      await _service.upload(
        parentType: widget.parentType,
        parentId: widget.parentId,
        file: file,
      );
      await _load();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Attachment uploaded.")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Upload failed: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _delete(int attachmentId) async {
    setState(() => _loading = true);
    try {
      await _service.deleteAttachment(attachmentId);
      await _load();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Attachment deleted.")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Delete failed: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _pickCamera() async {
    final file = await ImagePick.camera();
    if (file != null) await _upload(file);
  }

  Future<void> _pickGallery() async {
    final file = await ImagePick.gallery();
    if (file != null) await _upload(file);
  }

  Future<void> _pickAnyFile() async {
    // Use FilePicker directly for any file
    final file = await _pickAny();
    if (file != null) await _upload(file);
  }

  Future<File?> _pickAny() async {
    // lightweight local helper so you don’t need another util file
    // If you prefer, move this to core/utils/any_file_pick.dart
    final res = await AnyFilePick.pickAny();
    return res;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Attachments", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: _loading ? null : _pickCamera,
                  icon: const Icon(Icons.photo_camera),
                  label: const Text("Camera"),
                ),
                OutlinedButton.icon(
                  onPressed: _loading ? null : _pickGallery,
                  icon: const Icon(Icons.photo_library),
                  label: const Text("Gallery"),
                ),
                OutlinedButton.icon(
                  onPressed: _loading ? null : _pickAnyFile,
                  icon: const Icon(Icons.attach_file),
                  label: const Text("File"),
                ),
              ],
            ),

            const SizedBox(height: 12),

            if (_loading) const LinearProgressIndicator(),

            if (!_loading && _items.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text("No attachments yet."),
              ),

            if (_items.isNotEmpty) ...[
              const SizedBox(height: 8),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _items.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, i) {
                  final a = _items[i];
                  final id = a["id"];
                  final name = a["file_name"] ?? a["fileName"] ?? "Attachment";
                  final path = a["file_path"] ?? a["filePath"] ?? "";

                  return ListTile(
                    leading: const Icon(Icons.insert_drive_file),
                    title: Text(name),
                    subtitle: path.toString().isEmpty ? null : Text(path.toString(), maxLines: 1, overflow: TextOverflow.ellipsis),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: _loading ? null : () => _delete(id),
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}

