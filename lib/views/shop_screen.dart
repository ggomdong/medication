import 'package:flutter/material.dart';
import '../../views/widgets/common_app_bar.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  final List<String> categories = [
    '전체',
    '건강보조식품',
    '생활용품',
    '웰빙간식',
    '운동용품',
    '바우처',
  ];
  String selectedCategory = '전체';

  final List<Map<String, String>> products = [
    {
      'name': '오메가3',
      'category': '건강보조식품',
      'price': '300',
      'image': 'assets/images/shop_1.png',
    },
    {
      'name': '일주일 약통',
      'category': '생활용품',
      'price': '150',
      'image': 'assets/images/shop_2.png',
    },
    {
      'name': '단백질바',
      'category': '웰빙간식',
      'price': '400',
      'image': 'assets/images/shop_3.png',
    },
    {
      'name': '폼롤러',
      'category': '운동용품',
      'price': '1000',
      'image': 'assets/images/shop_4.png',
    },
    {
      'name': '체중계',
      'category': '생활용품',
      'price': '500',
      'image': 'assets/images/shop_5.png',
    },
    {
      'name': '비타민C',
      'category': '건강보조식품',
      'price': '250',
      'image': 'assets/images/shop_6.png',
    },
    {
      'name': '복약 알람시계',
      'category': '생활용품',
      'price': '800',
      'image': 'assets/images/shop_7.png',
    },
    {
      'name': '보온 물병',
      'category': '생활용품',
      'price': '350',
      'image': 'assets/images/shop_8.png',
    },
    {
      'name': '헬스장 1개월권',
      'category': '바우처',
      'price': '3000',
      'image': 'assets/images/shop_9.png',
    },
    {
      'name': '마그네슘 스프레이',
      'category': '건강보조식품',
      'price': '600',
      'image': 'assets/images/shop_10.png',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filtered =
        selectedCategory == '전체'
            ? products
            : products.where((p) => p['category'] == selectedCategory).toList();

    return Scaffold(
      appBar: CommonAppBar(),
      body: Column(
        children: [
          // 카테고리 선택 바
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children:
                  categories.map((cat) {
                    final isSelected = cat == selectedCategory;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ChoiceChip(
                        label: Text(cat),
                        selected: isSelected,
                        onSelected: (_) {
                          setState(() => selectedCategory = cat);
                        },
                      ),
                    );
                  }).toList(),
            ),
          ),

          // 제품 목록
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.65,
              ),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final item = filtered[index];
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                        child:
                            item['image']!.isNotEmpty
                                ? Image.asset(
                                  item['image']!,
                                  width: double.infinity,
                                  height: 150,
                                  fit: BoxFit.cover,
                                )
                                : Container(
                                  height: 150,
                                  color: Colors.grey[200],
                                  alignment: Alignment.center,
                                  child: Icon(Icons.image, color: Colors.grey),
                                ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          item['name']!,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          item['category']!,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${item['price']}P',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.teal,
                              ),
                            ),
                            GestureDetector(
                              onTap:
                                  () => ScaffoldMessenger.of(
                                    context,
                                  ).showSnackBar(
                                    SnackBar(
                                      content: Text("장바구니에 담았습니다."),
                                      duration: Duration(seconds: 2),
                                    ),
                                  ),
                              child: Icon(
                                Icons.shopping_cart,
                                color: Colors.teal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
