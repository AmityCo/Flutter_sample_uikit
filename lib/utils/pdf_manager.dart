import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf_render/pdf_render.dart';

class PdfImage extends StatefulWidget {
  final String pdfAssetPath;

  PdfImage(this.pdfAssetPath);

  @override
  _PdfImageState createState() => _PdfImageState();
}

class _PdfImageState extends State<PdfImage> {
  late File _pdfFile;
  PdfDocument? _pdfDocument;
  PdfPageImage? _pdfImage;

  @override
  void initState() {
    super.initState();
    _loadPdf(widget.pdfAssetPath);
  }

  Future<void> _loadPdf(String assetPath) async {
    final ByteData data = await rootBundle.load(assetPath);
    final List<int> bytes = data.buffer.asUint8List();
    final Directory dir = await getApplicationDocumentsDirectory();
    _pdfFile = File('${dir.path}/temp.pdf');
    _pdfFile.writeAsBytesSync(bytes);
    _pdfDocument = await PdfDocument.openFile(_pdfFile.path);
    _loadPage();
  }

  Future<void> _loadPage() async {
    if (_pdfDocument == null) return;
    final PdfPage page = await _pdfDocument!.getPage(1);
    if (page == null) return;
    final PdfPageImage pageImage = await page.render(
      width: (page.width * 2).toInt(),
      height: (page.height * 2).toInt(),
    );
    setState(() {
      _pdfImage = pageImage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _pdfImage == null
        ? const CircularProgressIndicator()
        : Image.memory(_pdfImage!.pixels);
  }

  @override
  void dispose() {
    _pdfDocument?.dispose();
    super.dispose();
  }
}
