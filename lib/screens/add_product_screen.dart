import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/api_service.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descController = TextEditingController();
  bool _isLoading = false;

  String _selectedGenre = 'Action';
  final List<String> _genres = [
    'Action', 'Romance', 'Fantasy', 'Horror',
    'Comedy', 'Sci-Fi', 'Slice of Life', 'Sports',
  ];

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    final priceText = _priceController.text.trim();
    final desc = _descController.text.trim();

    if (name.isEmpty || priceText.isEmpty || desc.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Semua field harus diisi!'),
            backgroundColor: Colors.red),
      );
      return;
    }

    final price = int.tryParse(priceText);
    if (price == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Harga harus berupa angka!'),
            backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);

    final success = await ApiService.addProduct(
      name: name,
      price: price,
      description: desc,
    );

    setState(() => _isLoading = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Komik berhasil ditambahkan!'),
            backgroundColor: Colors.green),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Gagal menambahkan komik!'),
            backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0f3460),
        foregroundColor: Colors.white,
        title: const Text('Tambah Komik'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 120,
                height: 160,
                decoration: BoxDecoration(
                  color: const Color(0xFF0f3460),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.menu_book_rounded,
                        size: 48, color: Colors.white),
                    Text('Cover',
                        style: TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            _buildLabel('Judul Komik / Manga / Manhwa'),
            TextField(
              controller: _nameController,
              decoration: _inputDecoration('Contoh: One Piece Vol. 1'),
            ),
            const SizedBox(height: 16),

            _buildLabel('Harga (Rp)'),
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: _inputDecoration('Contoh: 35000'),
            ),
            const SizedBox(height: 16),

            _buildLabel('Genre'),
            DropdownButtonFormField<String>(
              value: _selectedGenre,
              decoration: _inputDecoration('Pilih genre'),
              items: _genres
                  .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                  .toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedGenre = val);
              },
            ),
            const SizedBox(height: 16),

            _buildLabel('Deskripsi'),
            TextField(
              controller: _descController,
              maxLines: 4,
              decoration: _inputDecoration(
                  'Sinopsis singkat komik...\n(Genre: $_selectedGenre)'),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _submit,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.save_rounded),
                label:
                    Text(_isLoading ? 'Menyimpan...' : 'Simpan ke Draft'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0f3460),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: Color(0xFF0f3460), width: 1.5)),
    );
  }
}