import 'package:flutter/material.dart';

import 'provider/menu_inline_filter_provider.dart';
import 'widgets/current_selected_menu_item.dart';
import 'widgets/menu_category_app_bar_item.dart';
import 'widgets/menu_sub_category_app_bar_item.dart';
import 'widgets/vertical_divider.dart' as vd;

class MenuInlineFilter extends StatefulWidget {
  // callback used when category selected
  final Function? updateCategory;
  // callback used when category subcategory selected
  final Function? updateSubCategory;
  // list of categories
  final List<String> categories;
  // list of list of subcategories
  final List<List<String>> subcategories;
  // height of menu filter
  final double height;
  // horizontal padding of menu filter
  final double horizontalPadding;
  // background color of menu filter
  final Color backgroundColor;
  final Color textColor;
  final Color selectedCategoryColor;
  final Color? selectedSubcategoryColor;
  final Color unselectedCategoryColor;
  final Color unselectedSubcategoryColor;
  final double fontSize;
  final String fontFamily;
  final int animationDuration;

  const MenuInlineFilter({
    Key? key,
    this.updateCategory,
    required this.subcategories,
    required this.categories,
    this.updateSubCategory,
    this.height = 50,
    this.horizontalPadding = 15,
    required this.backgroundColor,
    this.fontSize = 13,
    this.selectedCategoryColor = Colors.red,
    this.textColor = Colors.grey,
    this.selectedSubcategoryColor,
    this.unselectedCategoryColor = Colors.grey,
    this.unselectedSubcategoryColor = Colors.grey,
    this.fontFamily = 'roboto',
    this.animationDuration = 800,
  })  : assert(categories.length == subcategories.length),
        super(key: key);

  @override
  _MenuInlineFilterState createState() => _MenuInlineFilterState();
}

class _MenuInlineFilterState extends State<MenuInlineFilter>
    with TickerProviderStateMixin {
  // horizontal offset of menu filter
  double _horizontalOffset = 0;
  // animation controller
  late AnimationController _controller;
  // animation
  late Animation<double> _animation;
  // menu items global keys
  late List<GlobalKey> _globalKeys;
  // MenuCategoryAppBarItemExpandable global key
  final _menuFilterKey = GlobalKey();
  // size of MenuCategoryAppBarItemExpandable widget
  double _filterSizeWidth = 0;
  // size of individual menu item
  double _menuItemSize = 0;
  // scroll controller
  final _scrollController = ScrollController();
  // current category index
  int _selectedCategoryIndex = 0;
  // current subcategory index
  int _selectedSubCategoryIndex = 0;
  // current selected subcategory
  String _selectedSubcategory = '';
  // check if any item from menu filter is selected
  bool _isCurrentItemShown = false;

  @override
  void initState() {
    super.initState();
    _globalKeys = widget.categories
        .map((value) => GlobalKey(debugLabel: value.toString()))
        .toList();
    WidgetsBinding.instance!.addPostFrameCallback(_getMenuFilterSize);
    _controller = AnimationController(
      duration: Duration(milliseconds: widget.animationDuration),
      vsync: this,
    );
    _animation =
        Tween(begin: 1.0, end: 1 / _horizontalOffset).animate(_controller);
    _changeSelectedCategoryIndex(0);
  }

  // change category index
  void _changeSelectedCategoryIndex(int value) {
    setState(() {
      _selectedCategoryIndex = value;
    });
    _changeSelectedSubCategoryIndex(0);
    _changeSelectedSubCategory(widget.subcategories[_selectedCategoryIndex][0]);
  }

  // change subcategory index
  void _changeSelectedSubCategoryIndex(int value) {
    setState(() {
      _selectedSubCategoryIndex = value;
    });
  }

  // change subcategory
  void _changeSelectedSubCategory(String value) {
    setState(() {
      _selectedSubcategory = value;
    });
  }

  // get total width of expandable menu filter
  void _getMenuFilterSize(Duration _) {
    final RenderBox? box =
        _menuFilterKey.currentContext!.findRenderObject() as RenderBox?;
    setState(() {
      _filterSizeWidth = box!.size.width;
    });
  }

  // change menu filter horizontal offset
  void _changeHorizontalOffset() {
    final RenderBox box = _globalKeys[_selectedCategoryIndex]
        .currentContext!
        .findRenderObject()! as RenderBox;
    final position = box.localToGlobal(Offset.zero);

    setState(() {
      _horizontalOffset = -position.dx +
          widget.horizontalPadding -
          _scrollController.position.pixels;
    });

    // scroll menu filter to beginning of scroll
    _scrollController.animateTo(
      0.0,
      duration: Duration(milliseconds: widget.animationDuration),
      curve: Curves.linear,
    );

    _controller.forward().then((_) => {
          setState(() {
            // show static current menu item
            _isCurrentItemShown = true;
          }),
        });
  }

  // get size of individual menu item
  void _getItemSize(String category) {
    final RenderBox? box = _globalKeys[_selectedCategoryIndex]
        .currentContext!
        .findRenderObject() as RenderBox?;

    setState(() {
      _menuItemSize = box!.size.width;
      _animation = Tween(begin: 1.0, end: _menuItemSize / _filterSizeWidth)
          .animate(_controller);
    });
  }

  // reset menu filter to original position
  void _resetOffset() {
    // make current main category invisible when selecting new main cate
    setState(() {
      _isCurrentItemShown = false;
    });

    setState(() {
      _horizontalOffset = 0;
    });
    _controller.reverse();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
    _scrollController.dispose();
  }

  // get subcategory text color based on menu filter state
  Color _getSubCategoryTextColor(String subCategory) {
    return _selectedSubcategory == ''
        ? widget.unselectedCategoryColor
        : widget.subcategories[_selectedCategoryIndex].indexOf(subCategory) ==
                _selectedSubCategoryIndex
            ? widget.selectedSubcategoryColor ??
                Theme.of(context).indicatorColor
            : widget.unselectedSubcategoryColor;
  }

  // get category text color based on menu filter state
  Color _getCategoryTextColor(String category) {
    return widget.categories.indexOf(category) == _selectedCategoryIndex
        ? widget.selectedCategoryColor
        : widget.unselectedCategoryColor;
  }

  @override
  Widget build(BuildContext context) {
    return MenuInlineFilterProvider(
      fontFamily: widget.fontFamily,
      fontSize: widget.fontSize,
      height: widget.height,
      child: Container(
        height: widget.height,
        padding: EdgeInsets.symmetric(horizontal: widget.horizontalPadding),
        margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
        child: Stack(
          children: [
            SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  SizeTransition(
                    axis: Axis.horizontal,
                    sizeFactor: _animation,
                    axisAlignment: -1,
                    child: Stack(
                      children: [
                        Container(
                          width: _filterSizeWidth,
                        ),
                        AnimatedPositioned(
                          duration:
                              Duration(milliseconds: widget.animationDuration),
                          left: _horizontalOffset,
                          child: Row(
                            key: _menuFilterKey,
                            children: [
                              Row(
                                  children: widget.categories
                                      .map(
                                        (category) => MenuCategoryAppBarItem(
                                          index: widget.categories
                                              .indexOf(category),
                                          changeSelectedCategoryIndex:
                                              _changeSelectedCategoryIndex,
                                          key: _globalKeys[widget.categories
                                              .indexOf(category)],
                                          getItemSize: _getItemSize,
                                          selectedCategory: widget.categories[
                                              _selectedCategoryIndex],
                                          resetHorizontalOffset: _resetOffset,
                                          changeMenuFilterOffset:
                                              _changeHorizontalOffset,
                                          title: category,
                                          updateCategory: widget.updateCategory,
                                          textColor:
                                              _getCategoryTextColor(category),
                                          menuItemCategory: category,
                                        ),
                                      )
                                      .toList()),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const vd.VerticalDivider(),
                  // SUBCATEGORIES
                  Row(
                    children: widget.subcategories[_selectedCategoryIndex]
                        .map(
                          (subcategory) => MenuSubCategoryAppBarItem(
                              index: widget
                                  .subcategories[_selectedCategoryIndex]
                                  .indexOf(subcategory),
                              title: subcategory,
                              textColor: _getSubCategoryTextColor(subcategory),
                              updateSubCategory: widget.updateSubCategory,
                              selectedSubCategory: subcategory,
                              changeSelectedSubCategoryIndex:
                                  _changeSelectedSubCategoryIndex,
                              changeSelectedSubCategory:
                                  _changeSelectedSubCategory),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
            CurrentSelectedMenuItem(
              backgroundColor: widget.backgroundColor,
              isCurrentItemShown: _isCurrentItemShown,
              categories: widget.categories,
              selectedCategoryColor: widget.selectedCategoryColor,
              selectedCategoryIndex: _selectedCategoryIndex,
              onTapFunction: () {
                _scrollController
                    .animateTo(0.0,
                        duration:
                            Duration(milliseconds: widget.animationDuration),
                        curve: Curves.linear)
                    .then((value) => _resetOffset());
                // remove selection from subcategory when menu filter closed
                setState(() {
                  _selectedSubcategory = '';
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
