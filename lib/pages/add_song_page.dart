import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

class AddSongPage extends StatefulWidget {
  const AddSongPage({super.key});

  @override
  State<AddSongPage> createState() => _AddSongPageState();
}

class _AddSongPageState extends State<AddSongPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _artistController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _sourceController = TextEditingController();

  File? _thumbnail;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickThumbnail() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _thumbnail = File(pickedFile.path);
      });
    }
  }

  Future<void> _submitSong() async {
    if (_formKey.currentState!.validate()) {
      final uri = Uri.parse(
        'https://learn.smktelkom-mlg.sch.id/ukl2/playlists/song',
      );
      final request = http.MultipartRequest('POST', uri);

      request.fields['title'] = _titleController.text;
      request.fields['artist'] = _artistController.text;
      request.fields['description'] = _descriptionController.text;
      request.fields['source'] = _sourceController.text;

      if (_thumbnail != null) {
        final mimeType = lookupMimeType(_thumbnail!.path);
        request.files.add(
          await http.MultipartFile.fromPath(
            'thumbnail',
            _thumbnail!.path,
            contentType: mimeType != null ? MediaType.parse(mimeType) : null,
          ),
        );
      }

      final response = await request.send();

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(
          context as BuildContext,
        ).showSnackBar(const SnackBar(content: Text('Song has been created')));
        Navigator.pop(context as BuildContext);
      } else {
        ScaffoldMessenger.of(
          context as BuildContext,
        ).showSnackBar(const SnackBar(content: Text('Failed to create song')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F5FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF9C6ADE),
        title: Text(
          'Tambah Lagu',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Judul",
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _titleController,
                decoration: _inputDecoration("Masukkan judul lagu"),
                validator:
                    (value) => value!.isEmpty ? 'Judul harus diisi' : null,
              ),
              const SizedBox(height: 16),

              Text(
                "Artis",
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _artistController,
                decoration: _inputDecoration("Masukkan nama artis"),
                validator:
                    (value) => value!.isEmpty ? 'Artis harus diisi' : null,
              ),
              const SizedBox(height: 16),

              Text(
                "Deskripsi",
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _descriptionController,
                decoration: _inputDecoration("Masukkan deskripsi"),
                maxLines: 2,
                validator:
                    (value) => value!.isEmpty ? 'Deskripsi harus diisi' : null,
              ),
              const SizedBox(height: 16),

              Text(
                "Sumber",
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _sourceController,
                decoration: _inputDecoration("Masukkan URL sumber"),
                validator:
                    (value) => value!.isEmpty ? 'Sumber harus diisi' : null,
              ),
              const SizedBox(height: 16),

              Text(
                "Thumbnail",
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: _pickThumbnail,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF2EBFF),
                      foregroundColor: const Color(0xFF6A3EA1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text('Pilih File', style: GoogleFonts.poppins()),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _thumbnail != null
                          ? basename(_thumbnail!.path)
                          : 'Belum ada file dipilih',
                      style: GoogleFonts.poppins(fontSize: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF6A3EA1)),
                      foregroundColor: const Color(0xFF6A3EA1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text('Batal', style: GoogleFonts.poppins()),
                  ),
                  ElevatedButton(
                    onPressed: _submitSong,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6A3EA1),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text('Simpan Lagu', style: GoogleFonts.poppins()),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.poppins(fontSize: 14),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF9C6ADE)),
      ),
    );
  }
}
