import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pothole_detector_flutter/screens/home/live_detector_view.dart';
import 'package:pothole_detector_flutter/shared/constants.dart';
import 'package:pothole_detector_flutter/shared/supabase_service.dart';
import 'package:pothole_detector_flutter/shared/widgets/button.dart';
import 'package:pothole_detector_flutter/shared/yolo_fastapi_service.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  Map<String, num> _recognitions = {};
  XFile? _recognitionImage;
  bool _loading = false;

  final ImagePicker _picker = ImagePicker();

  _loadImage({required bool isCamera}) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: isCamera ? ImageSource.camera : ImageSource.gallery,
        maxWidth: 640,
        maxHeight: 640,
      );
      if (image == null) {
        return;
      }
      setState(() {
        _recognitionImage = image;
        _loading = true;
        _recognitions = {};
      });
      _detectImage(image);
    } catch (e) {
      checkPermissions(context);
    }
  }

  _detectImage(XFile image) async {
    final json = yoloFastApiService.objectDetectionJson(image.path);
    final file = yoloFastApiService.objectDetectionFile(image.path);

    try {
      final results = await Future.wait([json, file]);
      _recognitions = results.first as Map<String, num>;
      _recognitionImage = results.last as XFile;

      recordDataToSupabase();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }

    setState(() {
      _loading = false;
    });
  }

  // Fungsi untuk mendapatkan lokasi pengguna
  Future<String> getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      return '${position.latitude},${position.longitude}';
    } catch (e) {
      debugPrint('Error getting location: $e');
      return 'Unknown Location';
    }
  }

  _reset() {
    setState(() {
      _loading = false;
      _recognitionImage = null;
      _recognitions = {};
    });
  }

  // Fungsi untuk merekam data ke Supabase
  void recordDataToSupabase() async {
    if (_recognitions.isNotEmpty) {
      String location = await getCurrentLocation();
      String damageType = recognitionResult(_recognitions.entries.first);

      // Catat data ke Supabase
      await supabaseService.recordData(location, damageType);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    checkPermissions(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff3f5f6),
      appBar: AppBar(
        title: const Text("Pothole Detector"),
        actions: [
          if (_loading)
            IconButton(
              onPressed: () => _reset(),
              icon: const FaIcon(FontAwesomeIcons.trash),
            )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppButton(
              color: Colors.white,
              width: kWidth,
              height: kHeight * 0.08,
              backgroundColor: Colors.blueAccent,
              text: "Open camera",
              onTap: _loading ? null : () => _loadImage(isCamera: true),
            ),
            const SizedBox(height: 16),
            AppButton(
              color: Colors.white,
              width: kWidth,
              height: kHeight * 0.08,
              backgroundColor: Colors.blueAccent,
              text: "Open gallery",
              onTap: _loading ? null : () => _loadImage(isCamera: false),
            ),
            const SizedBox(height: 16),
            AppButton(
              color: Colors.white,
              width: kWidth,
              height: kHeight * 0.08,
              backgroundColor: Colors.blueAccent,
              text: "Live Detection",
              onTap: _loading
                  ? null
                  : () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LiveDetectorView(),
                        ),
                      ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blueAccent, width: 3),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    !_loading ? const SizedBox(height: 10) : const Spacer(),
                    _recognitionImage == null
                        ? Image.asset(noImage)
                        : FutureBuilder<Uint8List>(
                            future: _recognitionImage!.readAsBytes(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return Image.asset(noImage);
                              }
                              return Image.memory(snapshot.data!);
                            },
                          ),
                    const Spacer(),
                    if (!_loading && _recognitions.isNotEmpty) ...{
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ..._recognitions.keys.map((r) {
                            return Text(
                              '$r : ${(_recognitions[r]! * 100).toStringAsFixed(2)}%',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge!
                                  .copyWith(
                                    color: Colors.blueAccent,
                                  ),
                            );
                          }),
                        ],
                      )
                    } else if (_loading)...{
                      const CircularProgressIndicator(),
                    } else ...{
                      Text(
                        "Detect your Image Now.",
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                              color: Colors.blueAccent,
                            ),
                      ),
                    },
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
