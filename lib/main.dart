import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:pdf/mobile.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';

var filter;
var entities;
var text;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // @override
  // Widget build(BuildContext context) {
  //   // TODO: implement build
  //   return Scaffold(
  //     body: Center(
  //       child: ElevatedButton(
  //         child: Text('Create PDF'),
  //         onPressed: _createPDF,
  //       ),
  //     ),
  //   );
  // }
  final keySignaturePad = GlobalKey<SfSignaturePadState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SfSignaturePad(
              key: keySignaturePad,
              backgroundColor: Colors.grey[200],
              strokeColor: Colors.black,
              minimumStrokeWidth: 1,
              maximumStrokeWidth: 4,
            ),
            ElevatedButton(child: Text('Create PDF'), onPressed: _createPDF),
          ],
        ),
      ),
    );
  }

  Future<Uint8List> _readImageData(String name) async {
    final data = await rootBundle.load('images/$name');
    return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  }

  Future<void> _createPDF() async {
    String audioasset = "audio/file.wav";

    ByteData bytes2 =
        await rootBundle.load(audioasset); //load audio from assets
    Uint8List audioFile =
        bytes2.buffer.asUint8List(bytes2.offsetInBytes, bytes2.lengthInBytes);

    var url = 'http://127.0.0.1:5000/transcribe';
    //var audioFile =
    var request = http.MultipartRequest('POST', Uri.parse(url));
    print("Flutter app ke andar hun");
    //request.files.add(await http.MultipartFile.fromPath('file', audioFile));
    request.files.add(
        http.MultipartFile.fromBytes('file', audioFile, filename: 'file.wav'));

    var response = await request.send();
    if (response.statusCode == 200) {
      var jsonResponse = await response.stream.bytesToString();
      var data = json.decode(jsonResponse);
      print(data);
      text = data['text'];
      filter = data['filter'];
      entities = data['entities'];
      // do something with the response data
    } else {
      // handle error
    }

    final image = await keySignaturePad.currentState?.toImage();
    final imageSignature =
        await image!.toByteData(format: ui.ImageByteFormat.png);
    PdfDocument document = PdfDocument();
    final page = document.pages.add();

    // Add logo image
    page.graphics.drawImage(PdfBitmap(await _readImageData('fyp.jpg')),
        Rect.fromLTWH(440, 0, 75, 75));
    page.graphics.drawString(
      'Speech 2 Contract',
      PdfStandardFont(PdfFontFamily.helvetica, 10),
      bounds: Rect.fromLTWH(0, 0, page.getClientSize().width, 50),
      format: PdfStringFormat(
        //alignment: PdfTextAlignment.right,
        lineAlignment: PdfVerticalAlignment.middle,
      ),
    );
    // Add title
    page.graphics.drawString(
      'Sale/Purchase Agreement',
      PdfStandardFont(PdfFontFamily.helvetica, 20, style: PdfFontStyle.bold),
      bounds: Rect.fromLTWH(0, 20, page.getClientSize().width, 50),
      format: PdfStringFormat(
        alignment: PdfTextAlignment.center,
        lineAlignment: PdfVerticalAlignment.middle,
      ),
    );

    // Add agreement details
    final sellerName = 'John Doe';
    final sellerPhoneNo = '1234567890';
    final sellerCNIC = '12345-6789012-3';
    final sellerLicense = 'ABC-1234';

    page.graphics.drawString(
      'Seller Information\nName: $sellerName\nPhone no: $sellerPhoneNo\nCNIC no: $sellerCNIC\nDriver license: $sellerLicense \n\nBuyer Information\nName: $sellerName\nPhone no: $sellerPhoneNo\nCNIC no: $sellerCNIC\nDriver license: $sellerLicense\n\nThis Agreement is made and entered into on $entities["RENTAL_PERIOD"]\rnProduct Detail: $entities\nPrice: $entities["PRICE"]\nAdvance Amount: $entities["PRICE"]',
      PdfStandardFont(PdfFontFamily.helvetica, 14),
      bounds: Rect.fromLTWH(
        50,
        100,
        page.getClientSize().width - 100,
        page.getClientSize().height - 200,
      ),
      format: PdfStringFormat(lineSpacing: 1.5),
    );

    page.graphics.drawString(
      'Terms and Conditions:\n1. The Product(s) shall be delivered to the Buyer in the condition as described by the Sell and agreed upon by the Buyer.\n2. The Product(s) shall be delivered to the Buyer in the condition as described by the Seller and agreed upon by the Buyer.\n3. In case the Buyer fails to make payment for the Product(s) as agreed, the Seller reservesthe right to terminate this contract and to retain any deposit made by the Buyer asliquidated damages.\n4. The Buyer shall inspect the Product(s) immediately upon delivery and shall inform theSeller of any defects or damages within 5 days of delivery.\n5. The Seller warrants that the Product(s) are free from defects in material and workmanshipfor a period of 2 months from the date of delivery. If the Product(s) are found to bedefective within the warranty period, the Seller will repair or replace the defectiveProduct(s) at no additional cost to the Buyer.',
      PdfStandardFont(PdfFontFamily.helvetica, 10),
      bounds: Rect.fromLTWH(
        50,
        450,
        page.getClientSize().width - 100,
        page.getClientSize().height - 200,
      ),
      format: PdfStringFormat(lineSpacing: 1.5),
    );

    // Add signature lines
    page.graphics.drawString(
      'Seller Signature: ________________________________________________________',
      PdfStandardFont(PdfFontFamily.helvetica, 12, style: PdfFontStyle.bold),
      bounds: Rect.fromLTWH(
        50,
        page.getClientSize().height - 100,
        page.getClientSize().width / 2 - 75,
        50,
      ),
    );

    page.graphics.drawString(
      'Buyer Signature: ',
      PdfStandardFont(PdfFontFamily.helvetica, 12, style: PdfFontStyle.bold),
      bounds: Rect.fromLTWH(
        page.getClientSize().width / 2 + 25,
        page.getClientSize().height - 100,
        page.getClientSize().width / 2 - 75,
        50,
      ),
    );

    drawSignature(page, imageSignature!);

    List<int> bytes = document.save();
    document.dispose();
    saveAndLaunchFile(bytes, 'Output.pdf');
  }

  static void drawSignature(PdfPage page, ByteData imageSignature) {
    final pageSize = page.getClientSize();
    final PdfBitmap image = PdfBitmap(imageSignature.buffer.asUint8List());
    page.graphics.drawImage(image,
        Rect.fromLTWH(pageSize.width / 2 + 50, pageSize.height - 80, 150, 50));
  }

  Future<Uint8List> _loadLogoImage() async {
    final ByteData data = await rootBundle.load('assets/fyp.jpg');
    return data.buffer.asUint8List();
  }
}
