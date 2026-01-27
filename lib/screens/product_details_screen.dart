import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/quantity_selector.dart';
import '../widgets/photographer_card.dart';
import '../widgets/product_card.dart';
import '../widgets/bottom_nav_bar.dart';

class ProductDetailsScreen extends StatefulWidget {
  final String title, category, author, price, imageUrl;

  const ProductDetailsScreen({super.key, required this.title, required this.category, required this.author, required this.price, required this.imageUrl});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  String _selectedSize = '12 x 18 in';
  int _quantity = 1;
  bool _isLiked = false;
  final List<String> _sizes = ['12 x 18 in', '18 x 24 in', '24 x 36 in', '40 x 60 in'];

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = isDarkMode ? Colors.white : const Color(0xFF1B4332);

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF121212) : const Color(0xFFF9FBF9),
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, leading: IconButton(icon: Icon(Icons.arrow_back_ios_new_rounded, color: textColor), onPressed: () => Navigator.pop(context))),
      extendBodyBehindAppBar: true, bottomNavigationBar: const WildTraceBottomNavBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 100, 24, 40),
        child: Column(
          children: [
            _buildHeading(textColor), // Title and Category
            const SizedBox(height: 48),
            _buildMainImage(), // Artwork Preview
            const SizedBox(height: 48),
            _buildPurchaseOptions(isDarkMode, textColor), // Price and Cart
            const SizedBox(height: 48),
            _buildStory(textColor), // Behind the scene
            const SizedBox(height: 48),
            _buildPhotographerProfile(), // Author Info
            const SizedBox(height: 60),
            _buildSimilarWorks(textColor), // Related Items
          ],
        ),
      ),
    );
  }

  Widget _buildHeading(Color textColor) {
    return Column(
      children: [
        Text(widget.category.toUpperCase(), style: GoogleFonts.inter(color: const Color(0xFF2ECC71), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 3.0)),
        const SizedBox(height: 16),
        Text(widget.title, textAlign: TextAlign.center, style: GoogleFonts.playfairDisplay(color: textColor, fontSize: 48, fontStyle: FontStyle.italic, height: 1.1)),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _meta('BY ${widget.author.toUpperCase()}'),
            const SizedBox(width: 16),
            Container(width: 4, height: 4, decoration: const BoxDecoration(color: Color(0xFF2ECC71), shape: BoxShape.circle)),
            const SizedBox(width: 16),
            _meta('AFRICA WILDERNESS'),
          ],
        ),
      ],
    );
  }

  Widget _meta(String text) => Text(text, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Colors.grey.shade500));

  Widget _buildMainImage() {
    return Container(
      height: 400,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(32), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 30, offset: const Offset(0, 15))]),
      child: ClipRRect(borderRadius: BorderRadius.circular(32), child: Image.asset(widget.imageUrl, fit: BoxFit.cover, errorBuilder: (_,__,___) => Container(color: Colors.grey[900]))),
    );
  }

  Widget _buildPurchaseOptions(bool isDarkMode, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white, borderRadius: BorderRadius.circular(32), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('MUSEUM GRADE PRINT', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey.shade500)),
          const SizedBox(height: 8),
          Text(widget.price, style: GoogleFonts.inter(fontSize: 36, fontWeight: FontWeight.bold, color: textColor)),
          const SizedBox(height: 32),
          Text('SELECT SIZE', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey.shade500)),
          const SizedBox(height: 12),
          GridView.count(
            padding: EdgeInsets.zero, crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 2.5, mainAxisSpacing: 12, crossAxisSpacing: 12,
            children: _sizes.map((s) => _sizeBtn(s, isDarkMode)).toList(),
          ),
          const SizedBox(height: 32),
          Text('QUANTITY', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey.shade500)),
          const SizedBox(height: 16),
          Row(children: [
            QuantitySelector(quantity: _quantity, onIncrement: () => setState(() => _quantity++), onDecrement: () { if (_quantity > 1) setState(() => _quantity--); }),
            const SizedBox(width: 24),
            Text('$_quantity Items', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: textColor)),
          ]),
          const SizedBox(height: 32),
          Row(children: [
            Expanded(child: _actionBtn('ADD TO CART', () {})),
            const SizedBox(width: 16),
            _favBtn(),
          ]),
        ],
      ),
    );
  }

  Widget _sizeBtn(String size, bool isDarkMode) {
    final bool sel = size == _selectedSize;
    return InkWell(
      onTap: () => setState(() => _selectedSize = size),
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(color: sel ? const Color(0xFF2ECC71).withOpacity(0.1) : Colors.transparent, border: Border.all(color: sel ? const Color(0xFF2ECC71) : Colors.grey.withOpacity(0.2)), borderRadius: BorderRadius.circular(12)),
        child: Text(size, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: sel ? const Color(0xFF2ECC71) : (isDarkMode ? Colors.white : Colors.black))),
      ),
    );
  }

  Widget _actionBtn(String label, VoidCallback onTap) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2ECC71), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
      child: Text(label, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }

  Widget _favBtn() {
    return InkWell(
      onTap: () => setState(() => _isLiked = !_isLiked),
      child: Container(width: 56, height: 56, decoration: BoxDecoration(border: Border.all(color: Colors.grey.withOpacity(0.2)), borderRadius: BorderRadius.circular(16)), child: Icon(_isLiked ? Icons.favorite : Icons.favorite_border, color: _isLiked ? const Color(0xFFE11D48) : Colors.grey.shade400)),
    );
  }

  Widget _buildStory(Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [Container(width: 4, height: 24, color: const Color(0xFF2ECC71)), const SizedBox(width: 16), Text('Behind the Lens', style: GoogleFonts.playfairDisplay(fontSize: 32, fontStyle: FontStyle.italic, color: textColor))]),
        const SizedBox(height: 24),
        Text("Every photograph in our collection is a testament to the untamed beauty of the natural world, captured with patience and respect.", style: GoogleFonts.inter(fontSize: 14, height: 1.8, color: Colors.grey.shade600)),
        const SizedBox(height: 24),
        GridView.count(
          padding: EdgeInsets.zero, crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), childAspectRatio: 3.0,
          children: [_stat('APERTURE', 'f/5.6', textColor), _stat('SHUTTER', '1/4000s', textColor), _stat('ISO', '800', textColor), _stat('FOCAL', '85mm', textColor)],
        ),
      ],
    );
  }

  Widget _stat(String l, String v, Color c) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(l, style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey.shade400)), Text(v, style: GoogleFonts.playfairDisplay(fontSize: 20, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic, color: c))]);

  Widget _buildPhotographerProfile() => PhotographerCard(imagePath: 'assets/images/teammember1.jpg', name: widget.author, role: 'FOUNDER & LEAD', quote: 'Nature doesn\'t need a filter, it just needs a witness.');

  Widget _buildSimilarWorks(Color textColor) {
    final list = [
      {'title': 'Owl in Twilight', 'category': 'BIRDS', 'price': '\$140.00', 'image': 'assets/images/owl.jpg'},
      {'title': 'Clownfish Haven', 'category': 'AQUATICS', 'price': '\$120.00', 'image': 'assets/images/product2.jpg'},
    ];
    return Column(
      children: [
        Text('Similar Artifacts', style: GoogleFonts.playfairDisplay(fontSize: 26, fontStyle: FontStyle.italic, color: textColor)),
        const SizedBox(height: 32),
        GridView.builder(
          padding: EdgeInsets.zero, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 24, crossAxisSpacing: 16, childAspectRatio: 0.7),
          itemCount: list.length,
          itemBuilder: (context, index) => ProductCard(imageUrl: list[index]['image']!, category: list[index]['category']!, title: list[index]['title']!, author: widget.author, price: list[index]['price']!, type: ProductCardType.minimal, onTap: () {}),
        ),
      ],
    );
  }
}
