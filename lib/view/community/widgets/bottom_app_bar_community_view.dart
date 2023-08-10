part of '../community_view.dart';

class BottomAppBarCommunityView extends StatefulWidget {
  BottomAppBarCommunityView({super.key, required this.names, this.onChanged})
      : assert(names.isNotEmpty);

  final List<String> names;
  final ValueChanged<int>? onChanged;

  @override
  State<BottomAppBarCommunityView> createState() =>
      _BottomAppBarCommunityViewState();
}

class _BottomAppBarCommunityViewState extends State<BottomAppBarCommunityView> {
  int _selectIndex = 0;
  Map<String, GlobalKey> globalKeys = {};
  @override
  void initState() {
    for (final s in widget.names) {
      globalKeys[s] = GlobalKey(debugLabel: 'BottomAppBarCommunityView:$s');
    }
    Future.delayed(const Duration(milliseconds: 300), () {
      updateScreen();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final appColors = context.watch<AmityUIConfiguration>();
    return Container(
      height: 35.0,
      alignment: Alignment.topLeft,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            top: 35.0 - 3,
            child: AnimatedContainer(
              margin: EdgeInsets.only(left: checkPosition(_selectIndex)),
              width: checkWidth(globalKeys[widget.names[_selectIndex]]!),
              height: 3,
              duration: const Duration(milliseconds: 200),
              color: appColors.secondaryColor,
            ),
          ),
          SingleChildScrollView(
            child: Row(
              children: List.generate(widget.names.length, (index) {
                String title = widget.names[index];
                return GestureDetector(
                  onTap: () {
                    _selectIndex = index;
                    if (widget.onChanged != null) {
                      widget.onChanged!(index);
                    }
                    updateScreen();
                  },
                  child: Container(
                    key: globalKeys[title],
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.only(left: 4),
                    child: Text(
                      title,
                      style: AppTextStyle.header1.copyWith(
                            color: _selectIndex == index
                                ? appColors.secondaryColor
                                : Colors.grey,
                          ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  double checkPosition(int index) {
    double position = 0;
    if (index == 0) {
      return position;
    }

    for (int i = 0; i < index; i++) {
      final k = globalKeys[widget.names[i]]!;
      position += checkWidth(k);
    }
    log('$position');
    return position;
  }

  double checkWidth(GlobalKey globalKey) {
    final renderBox =
        globalKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) {
      return 0;
    }
    return renderBox.size.width;
  }

  void updateScreen() {
    if (mounted) {
      setState(() {});
    }
  }
}
