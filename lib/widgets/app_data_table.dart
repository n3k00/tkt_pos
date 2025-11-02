import 'package:flutter/material.dart';
import 'package:tkt_pos/resources/colors.dart';

class AppDataTable extends StatefulWidget {
  const AppDataTable({super.key, required this.table});

  final DataTable table;

  @override
  State<AppDataTable> createState() => _AppDataTableState();
}

class _AppDataTableState extends State<AppDataTable> {
  final ScrollController _vCtrl = ScrollController();
  final ScrollController _hCtrl = ScrollController();

  @override
  void dispose() {
    _vCtrl.dispose();
    _hCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      controller: _vCtrl,
      thumbVisibility: true,
      child: SingleChildScrollView(
        controller: _vCtrl,
        scrollDirection: Axis.vertical,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Scrollbar(
              controller: _hCtrl,
              thumbVisibility: true,
              scrollbarOrientation: ScrollbarOrientation.bottom,
              child: SingleChildScrollView(
                controller: _hCtrl,
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
                  child: Card(
                    color: AppColor.white,
                    clipBehavior: Clip.antiAlias,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        color: Colors.black12.withValues(alpha: 0.08),
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: widget.table,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

