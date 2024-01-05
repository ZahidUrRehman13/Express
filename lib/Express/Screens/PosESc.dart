import 'dart:convert';
import 'dart:typed_data';

import 'package:bluetooth_print/bluetooth_print.dart';
import 'package:bluetooth_print/bluetooth_print_model.dart';
import 'package:express/Express/Config/ConstantColor.dart';
import 'package:express/Express/Config/ConstantSize.dart';
import 'package:express/Express/Widgets/TextWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class PosEsc extends StatefulWidget {
  const PosEsc({super.key});

  @override
  State<PosEsc> createState() => _PosEscState();
}

class _PosEscState extends State<PosEsc> {
  BluetoothPrint bluetoothPrint = BluetoothPrint.instance;

  bool _connected = false;
  BluetoothDevice? _device;
  String tips = 'no device connect';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) => initBluetooth());
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initBluetooth() async {
    bluetoothPrint.startScan(timeout: const Duration(seconds: 4));

    bool isConnected = await bluetoothPrint.isConnected ?? false;

    bluetoothPrint.state.listen((state) {
      debugPrint('******************* cur device status: $state');

      switch (state) {
        case BluetoothPrint.CONNECTED:
          setState(() {
            _connected = true;
            tips = 'connect success';
          });
          break;
        case BluetoothPrint.DISCONNECTED:
          setState(() {
            _connected = false;
            tips = 'disconnect success';
          });
          break;
        default:
          break;
      }
    });

    if (!mounted) return;

    if (isConnected) {
      setState(() {
        _connected = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ConstantSize().init(context);
    var height = ConstantSize.height;
    var width = ConstantSize.width;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gym Data'),
      ),
      body: RefreshIndicator(
        onRefresh: () => bluetoothPrint.startScan(timeout: const Duration(seconds: 4)),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    height: height! * 0.06,
                    width: width! * 0.6,
                    margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(5.0), color: Colors.black12),
                    child: Center(
                        child:
                            TextWidget(text: tips, textStyle: GoogleFonts.almarai(color: Colors.black, fontSize: 20.0, fontWeight: FontWeight.w600))),
                  ),
                ],
              ),
              const Divider(),
              StreamBuilder<List<BluetoothDevice>>(
                stream: bluetoothPrint.scanResults,
                initialData: [],
                builder: (c, snapshot) => Column(
                  children: snapshot.data!
                      .map((d) => ListTile(
                            title: Text(d.name ?? ''),
                            subtitle: Text(d.address ?? ''),
                            onTap: () async {
                              setState(() {
                                _device = d;
                              });
                            },
                            trailing: _device != null && _device!.address == d.address
                                ? const Icon(
                                    Icons.check,
                                    color: Colors.green,
                                  )
                                : null,
                          ))
                      .toList(),
                ),
              ),
              const Divider(),
              Container(
                padding: const EdgeInsets.fromLTRB(20, 5, 20, 10),
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          child: TextButton(
                            style: ButtonStyle(
                              backgroundColor: MaterialStatePropertyAll(ConstantColor.colorOrangeTiger),
                              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0), // Adjust the radius as needed
                                ),
                              ),
                            ),
                            onPressed: _connected
                                ? null
                                : () async {
                                    if (_device != null && _device!.address != null) {
                                      setState(() {
                                        tips = 'connecting...';
                                      });
                                      await bluetoothPrint.connect(_device!);
                                    } else {
                                      setState(() {
                                        tips = 'please select device';
                                      });
                                      debugPrint('please select device');
                                    }
                                  },
                            child: TextWidget(
                                text: 'connect', textStyle: GoogleFonts.almarai(color: Colors.white, fontSize: 16.0, fontWeight: FontWeight.w600)),
                          ),
                        ),
                        const SizedBox(width: 10.0),
                        Expanded(
                          child: TextButton(
                            style: ButtonStyle(
                              backgroundColor: MaterialStatePropertyAll(ConstantColor.colorOrangeTiger),
                              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0), // Adjust the radius as needed
                                ),
                              ),
                            ),
                            onPressed: _connected
                                ? () async {
                                    setState(() {
                                      tips = 'disconnecting...';
                                    });
                                    await bluetoothPrint.disconnect();
                                  }
                                : null,
                            child: TextWidget(
                                text: 'disconnect', textStyle: GoogleFonts.almarai(color: Colors.white, fontSize: 16.0, fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ],
                    ),
                    const Divider(),
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(vertical: 30, horizontal: 16.0),
                      child: TextButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStatePropertyAll(ConstantColor.colorOrangeTiger),
                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0), // Adjust the radius as needed
                            ),
                          ),
                        ),
                        onPressed: _connected
                            ? () async {
                                Map<String, dynamic> config = {};
                                List<LineText> list = [];

                                list.add(LineText(
                                    type: LineText.TYPE_TEXT,
                                    content: '**********************************************',
                                    weight: 1,
                                    align: LineText.ALIGN_CENTER,
                                    linefeed: 1));
                                list.add(LineText(
                                    type: LineText.TYPE_TEXT,
                                    content: 'Jhony flex',
                                    weight: 1,
                                    align: LineText.ALIGN_CENTER,
                                    fontZoom: 2,
                                    linefeed: 1));
                                list.add(LineText(linefeed: 1));

                                list.add(LineText(type: LineText.TYPE_TEXT, content: 'DaTA ONE 123', align: LineText.ALIGN_LEFT, linefeed: 0));
                                list.add(LineText(type: LineText.TYPE_TEXT, content: 'fRESH', align: LineText.ALIGN_LEFT, linefeed: 0));
                                list.add(LineText(type: LineText.TYPE_TEXT, content: 'items', align: LineText.ALIGN_LEFT, linefeed: 1));

                                list.add(LineText(type: LineText.TYPE_TEXT, content: 'gym trips', align: LineText.ALIGN_LEFT, linefeed: 0));
                                list.add(LineText(type: LineText.TYPE_TEXT, content: 'wela botom', align: LineText.ALIGN_LEFT, linefeed: 0));
                                list.add(LineText(type: LineText.TYPE_TEXT, content: '12.0', align: LineText.ALIGN_LEFT, linefeed: 1));

                                list.add(LineText(
                                    type: LineText.TYPE_TEXT,
                                    content: '**********************************************',
                                    weight: 1,
                                    align: LineText.ALIGN_CENTER,
                                    linefeed: 1));
                                list.add(LineText(linefeed: 1));

                                ByteData data = await rootBundle.load("asset/png/app_icon.png");
                                List<int> imageBytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
                                String base64Image = base64Encode(imageBytes);
                                list.add(LineText(type: LineText.TYPE_IMAGE, content: base64Image, align: LineText.ALIGN_CENTER, linefeed: 1));

                                await bluetoothPrint.printReceipt(config, list);
                              }
                            : null,
                        child: TextWidget(
                            text: 'Proceed', textStyle: GoogleFonts.almarai(color: Colors.white, fontSize: 16.0, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    // OutlinedButton(
                    //   onPressed: _connected
                    //       ? () async {
                    //     Map<String, dynamic> config = Map();
                    //     config['width'] = 40; // 标签宽度，单位mm
                    //     config['height'] = 70; // 标签高度，单位mm
                    //     config['gap'] = 2; // 标签间隔，单位mm
                    //
                    //     // x、y坐标位置，单位dpi，1mm=8dpi
                    //     List<LineText> list = [];
                    //     list.add(LineText(type: LineText.TYPE_TEXT, x: 10, y: 10, content: 'A Title'));
                    //     list.add(LineText(type: LineText.TYPE_TEXT, x: 10, y: 40, content: 'this is content'));
                    //     list.add(LineText(type: LineText.TYPE_QRCODE, x: 10, y: 70, content: 'qrcode i\n'));
                    //     list.add(LineText(type: LineText.TYPE_BARCODE, x: 10, y: 190, content: 'qrcode i\n'));
                    //
                    //     List<LineText> list1 = [];
                    //     ByteData data = await rootBundle.load("assets/images/guide3.png");
                    //     List<int> imageBytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
                    //     String base64Image = base64Encode(imageBytes);
                    //     list1.add(LineText(
                    //       type: LineText.TYPE_IMAGE,
                    //       x: 10,
                    //       y: 10,
                    //       content: base64Image,
                    //     ));
                    //
                    //     await bluetoothPrint.printLabel(config, list);
                    //     await bluetoothPrint.printLabel(config, list1);
                    //   }
                    //       : null,
                    //   child: const Text('print label(tsc)'),
                    // ),
                    // OutlinedButton(
                    //   onPressed: _connected
                    //       ? () async {
                    //     await bluetoothPrint.printTest();
                    //   }
                    //       : null,
                    //   child: const Text('print self-test'),
                    // )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
      floatingActionButton: StreamBuilder<bool>(
        stream: bluetoothPrint.isScanning,
        initialData: false,
        builder: (c, snapshot) {
          if (snapshot.data == true) {
            return FloatingActionButton(
              onPressed: () => bluetoothPrint.stopScan(),
              backgroundColor: ConstantColor.colorOrangeTiger,
              child: const Icon(
                Icons.stop,
                color: Colors.white,
              ),
            );
          } else {
            return FloatingActionButton(
                backgroundColor: ConstantColor.colorWhite,
                foregroundColor: ConstantColor.colorWhite,
                child: const Icon(
                  Icons.bluetooth,
                  color: Colors.black,
                ),
                onPressed: () => bluetoothPrint.startScan(timeout: const Duration(seconds: 4)));
          }
        },
      ),
    );
  }
}
