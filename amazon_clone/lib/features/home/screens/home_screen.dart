import 'package:amazon_clone/constants/theme.dart';
import 'package:amazon_clone/features/home/widgets/address_box.dart';
import 'package:amazon_clone/features/home/widgets/carousel_image.dart';
import 'package:amazon_clone/features/home/widgets/deal_of_day.dart';
import 'package:amazon_clone/features/home/widgets/product_list.dart';
import 'package:amazon_clone/features/home/widgets/top_categories.dart';
import 'package:amazon_clone/features/search/screens/search_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  static const String routeName = '/home';
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchFocused = false;

  void navigateToSearchScreen(String query) {
    if (query.trim().isNotEmpty) {
      Navigator.pushNamed(
        context,
        SearchScreen.routeName,
        arguments: query.trim(),
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: AppBar(
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: themeProvider.getAppBarGradient(context),
            ),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Container(
                  height: 45,
                  margin: const EdgeInsets.only(left: 10, right: 10),
                  child: Material(
                    borderRadius: BorderRadius.circular(10),
                    elevation: 2,
                    shadowColor: themeProvider.isDarkMode
                        ? Colors.black54
                        : Colors.black26,
                    color: Theme.of(context).inputDecorationTheme.fillColor,
                    child: Focus(
                      onFocusChange: (hasFocus) {
                        setState(() {
                          _isSearchFocused = hasFocus;
                        });
                      },
                      child: TextFormField(
                        controller: _searchController,
                        onFieldSubmitted: navigateToSearchScreen,
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                        decoration: InputDecoration(
                          prefixIcon: InkWell(
                            onTap: () {
                              navigateToSearchScreen(_searchController.text);
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: Icon(
                                Icons.search,
                                color: _isSearchFocused
                                    ? Theme.of(context).primaryColor
                                    : themeProvider.getTextSecondaryColor(
                                        context,
                                      ),
                                size: 24,
                              ),
                            ),
                          ),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {});
                                  },
                                  icon: Icon(
                                    Icons.clear,
                                    color: themeProvider.getTextSecondaryColor(
                                      context,
                                    ),
                                    size: 20,
                                  ),
                                )
                              : null,
                          filled: true,
                          fillColor: Theme.of(
                            context,
                          ).inputDecorationTheme.fillColor,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: themeProvider.getBorderColor(context),
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Theme.of(context).primaryColor,
                              width: 2,
                            ),
                          ),
                          hintText: 'Search products, brands & more...',
                          hintStyle: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 16,
                            color: themeProvider.getTextSecondaryColor(context),
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {});
                        },
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  color:
                      (themeProvider.isDarkMode ? Colors.black : Colors.white)
                          .withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  onPressed: () {
                    // TODO: Implement voice search
                  },
                  icon: Icon(
                    Icons.mic,
                    color: themeProvider.isDarkMode
                        ? Colors.white
                        : Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {});
          await Future.delayed(const Duration(seconds: 1));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: const [
              AddressBox(),
              SizedBox(height: 15),
              TopCategories(),
              SizedBox(height: 15),
              CarouselImage(),
              SizedBox(height: 20),
              DealOfDay(),
              SizedBox(height: 20),
              ProductList(),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
