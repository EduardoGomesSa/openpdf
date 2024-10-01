import 'package:openpdf/src/models/pdf_viewer_model.dart';
import 'package:openpdf/src/repositories/last_pdf_repository.dart';

class LastPdfController {
  final repository = LastPdfRepository();

  Future<void> addPdf(String pathPdf) async {
    await repository.insert(pathPdf);
  }

  Future<List<PdfViewerModel>> getAllPdfs() async {
    var result = await repository.getAll();

    return result;
  }
}
