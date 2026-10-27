import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

import '../database_helper.dart';

class ReportWasteScreen extends StatefulWidget {
  final int userId;

  const ReportWasteScreen({
    super.key,
    required this.userId,
  });

  @override
  State<ReportWasteScreen> createState() => _ReportWasteScreenState();
}

class _ReportWasteScreenState extends State<ReportWasteScreen> {
  // ============================================================
  // VARIABLES
  // ============================================================

  String selectedCategory = "Plastic Waste";

  final List<String> categories = [
    "Plastic Waste",
    "Paper Waste",
    "Metal Waste",
    "Glass Waste",
    "Food Waste",
    "Electronic Waste",
  ];

  final TextEditingController descriptionController =
      TextEditingController();

  LatLng? selectedLocation;

  String selectedAddress = "";

  XFile? selectedImage;

  Uint8List? selectedImageBytes;

  bool isSubmitting = false;

  final ImagePicker imagePicker = ImagePicker();

  static const LatLng defaultLocation =
      LatLng(17.6868, 83.2185);

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    descriptionController.dispose();
    super.dispose();
  }

  // ============================================================
  // SELECT LOCATION
  // ============================================================

  Future<void> selectLocation() async {
    final result = await Navigator.push<LocationResult>(
      context,
      MaterialPageRoute(
        builder: (context) => MapLocationScreen(
          initialLocation:
              selectedLocation ?? defaultLocation,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        selectedLocation = result.location;
        selectedAddress = result.address;
      });
    }
  }

  // ============================================================
  // IMAGE OPTIONS
  // ============================================================

  Future<void> showImageOptions() async {
    await showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              // CAMERA
              ListTile(
                leading: const Icon(
                  Icons.camera_alt,
                  color: Colors.green,
                ),
                title: const Text("Take Photo"),
                onTap: () async {
                  Navigator.pop(context);

                  final image =
                      await imagePicker.pickImage(
                    source: ImageSource.camera,
                    imageQuality: 85,
                  );

                  if (image != null) {
                    final bytes =
                        await image.readAsBytes();

                    setState(() {
                      selectedImage = image;
                      selectedImageBytes = bytes;
                    });
                  }
                },
              ),

              // GALLERY
              ListTile(
                leading: const Icon(
                  Icons.photo_library,
                  color: Colors.green,
                ),
                title: const Text("Choose from Gallery"),
                onTap: () async {
                  Navigator.pop(context);

                  final image =
                      await imagePicker.pickImage(
                    source: ImageSource.gallery,
                    imageQuality: 85,
                  );

                  if (image != null) {
                    final bytes =
                        await image.readAsBytes();

                    setState(() {
                      selectedImage = image;
                      selectedImageBytes = bytes;
                    });
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // SUBMIT REPORT
  // ============================================================

  Future<void> submitReport() async {
    // ----------------------------------------------------------
    // DESCRIPTION CHECK
    // ----------------------------------------------------------

    if (descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Please enter a description of the waste.",
          ),
        ),
      );
      return;
    }

    // ----------------------------------------------------------
    // LOCATION CHECK
    // ----------------------------------------------------------

    if (selectedLocation == null ||
        selectedAddress.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Please select a waste location.",
          ),
        ),
      );
      return;
    }

    // ----------------------------------------------------------
    // IMAGE CHECK
    // ----------------------------------------------------------

    if (selectedImageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Please upload a picture of the waste.",
          ),
        ),
      );
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    try {
      // --------------------------------------------------------
      // SAVE REPORT TO SQLITE
      // --------------------------------------------------------

      await DatabaseHelper.instance.insertWasteReport(
        userId: widget.userId,
        category: selectedCategory,
        description:
            descriptionController.text.trim(),
        address: selectedAddress,
        latitude: selectedLocation!.latitude,
        longitude: selectedLocation!.longitude,
        image: selectedImageBytes,
      );

      if (!mounted) return;

      // --------------------------------------------------------
      // SUCCESS MESSAGE
      // --------------------------------------------------------

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Waste report submitted successfully!",
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );

      // --------------------------------------------------------
      // CLEAR FORM
      // --------------------------------------------------------

      setState(() {
        descriptionController.clear();

        selectedLocation = null;
        selectedAddress = "";

        selectedImage = null;
        selectedImageBytes = null;
      });

      // --------------------------------------------------------
      // RETURN TO PREVIOUS SCREEN
      // --------------------------------------------------------

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Could not submit report: $e",
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSubmitting = false;
        });
      }
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8F6),

      // ========================================================
      // APP BAR
      // ========================================================

      appBar: AppBar(
        title: const Text(
          "Report Waste",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
      ),

      // ========================================================
      // BODY
      // ========================================================

      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 800,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(22),

            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                // ==================================================
                // HEADER
                // ==================================================

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),

                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.green.shade700,
                        Colors.green.shade500,
                      ],
                    ),
                    borderRadius:
                        BorderRadius.circular(22),
                  ),

                  child: const Row(
                    children: [
                      Icon(
                        Icons.delete_outline,
                        color: Colors.white,
                        size: 40,
                      ),

                      SizedBox(width: 15),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Report Waste",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 23,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),

                            SizedBox(height: 5),

                            Text(
                              "Help keep your community clean.",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                // ==================================================
                // WASTE CATEGORY
                // ==================================================

                const Text(
                  "Waste Category",
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                DropdownButtonFormField<String>(
                  initialValue: selectedCategory,

                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,

                    prefixIcon: const Icon(
                      Icons.delete_outline,
                      color: Colors.green,
                    ),

                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),

                  items: categories.map((category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),

                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedCategory = value;
                      });
                    }
                  },
                ),

                const SizedBox(height: 24),

                // ==================================================
                // DESCRIPTION
                // ==================================================

                const Text(
                  "Description",
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                TextField(
                  controller: descriptionController,
                  maxLines: 4,

                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,

                    hintText:
                        "Describe the waste and its surroundings...",

                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),

                    alignLabelWithHint: true,
                  ),
                ),

                const SizedBox(height: 28),

                // ==================================================
                // LOCATION
                // ==================================================

                const Text(
                  "Waste Location",
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  "Choose the exact place where the waste is located.",
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 12),

                // SELECTED ADDRESS
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),

                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(14),

                    border: Border.all(
                      color: selectedLocation == null
                          ? Colors.grey.shade300
                          : Colors.green.shade300,
                    ),
                  ),

                  child: Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [
                      Icon(
                        Icons.location_on,
                        color: selectedLocation == null
                            ? Colors.grey
                            : Colors.green.shade700,
                        size: 28,
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,

                          children: [
                            Text(
                              selectedLocation == null
                                  ? "No location selected"
                                  : "Selected Location",

                              style: TextStyle(
                                fontWeight:
                                    FontWeight.bold,
                                color:
                                    selectedLocation ==
                                            null
                                        ? Colors.grey
                                            .shade600
                                        : Colors.green
                                            .shade700,
                              ),
                            ),

                            if (selectedAddress
                                .isNotEmpty) ...[
                              const SizedBox(height: 5),

                              Text(
                                selectedAddress,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight:
                                      FontWeight.w500,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // SELECT LOCATION BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 52,

                  child: ElevatedButton.icon(
                    onPressed: selectLocation,

                    icon: const Icon(
                      Icons.location_searching,
                      color: Colors.white,
                    ),

                    label: Text(
                      selectedLocation == null
                          ? "SELECT WASTE LOCATION"
                          : "CHANGE LOCATION",

                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor:
                          Colors.green.shade700,

                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(13),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // ==================================================
                // WASTE PICTURE
                // ==================================================

                const Text(
                  "Waste Picture",
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                GestureDetector(
                  onTap: showImageOptions,

                  child: Container(
                    height: 190,
                    width: double.infinity,

                    decoration: BoxDecoration(
                      color: Colors.white,

                      border: Border.all(
                        color: Colors.grey.shade300,
                      ),

                      borderRadius:
                          BorderRadius.circular(14),
                    ),

                    child: selectedImageBytes == null
                        ? Column(
                            mainAxisAlignment:
                                MainAxisAlignment
                                    .center,

                            children: [
                              Icon(
                                Icons
                                    .camera_alt_outlined,
                                size: 45,
                                color: Colors
                                    .green.shade600,
                              ),

                              const SizedBox(
                                height: 10,
                              ),

                              const Text(
                                "Upload Waste Picture",
                                style: TextStyle(
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),

                              const SizedBox(
                                height: 5,
                              ),

                              Text(
                                "Camera or Gallery",
                                style: TextStyle(
                                  color: Colors
                                      .grey.shade600,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          )
                        : ClipRRect(
                            borderRadius:
                                BorderRadius.circular(
                              14,
                            ),

                            child: Image.memory(
                              selectedImageBytes!,
                              width:
                                  double.infinity,
                              height: 190,
                              fit: BoxFit.cover,
                            ),
                          ),
                  ),
                ),

                // CHANGE PICTURE
                if (selectedImageBytes != null)
                  Align(
                    alignment:
                        Alignment.centerRight,

                    child: TextButton.icon(
                      onPressed:
                          showImageOptions,

                      icon: const Icon(
                        Icons.edit,
                      ),

                      label: const Text(
                        "Change Picture",
                      ),
                    ),
                  ),

                const SizedBox(height: 20),

                // ==================================================
                // SUBMIT BUTTON
                // ==================================================

                SizedBox(
                  width: double.infinity,
                  height: 55,

                  child: ElevatedButton.icon(
                    onPressed: isSubmitting
                        ? null
                        : submitReport,

                    icon: isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,

                            child:
                                CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(
                            Icons.send,
                            color: Colors.white,
                          ),

                    label: Text(
                      isSubmitting
                          ? "SUBMITTING..."
                          : "SUBMIT WASTE REPORT",

                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor:
                          Colors.green.shade700,

                      disabledBackgroundColor:
                          Colors.green.shade400,

                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 15),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ==================================================================
// LOCATION RESULT
// ==================================================================

class LocationResult {
  final LatLng location;
  final String address;

  LocationResult({
    required this.location,
    required this.address,
  });
}

// ==================================================================
// MAP LOCATION SCREEN
// ==================================================================

class MapLocationScreen extends StatefulWidget {
  final LatLng initialLocation;

  const MapLocationScreen({
    super.key,
    required this.initialLocation,
  });

  @override
  State<MapLocationScreen> createState() =>
      _MapLocationScreenState();
}

class _MapLocationScreenState
    extends State<MapLocationScreen> {
  late LatLng selectedLocation;

  String selectedAddress =
      "Location not selected";

  bool loadingLocation = false;

  final MapController mapController =
      MapController();

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    selectedLocation =
        widget.initialLocation;

    _getAddress(selectedLocation);
  }

  // ============================================================
  // GET ADDRESS
  // ============================================================

  Future<void> _getAddress(
    LatLng location,
  ) async {
    try {
      final placemarks =
          await placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;

        final parts = [
          place.name,
          place.subLocality,
          place.locality,
          place.administrativeArea,
          place.country,
        ];

        final address = parts
            .whereType<String>()
            .where(
              (part) =>
                  part.trim().isNotEmpty,
            )
            .map(
              (part) => part.trim(),
            )
            .toSet()
            .join(", ");

        if (!mounted) return;

        setState(() {
          selectedAddress =
              address.isEmpty
                  ? "Selected location"
                  : address;
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        selectedAddress =
            "Selected location";
      });
    }
  }

  // ============================================================
  // USE CURRENT LOCATION
  // ============================================================

  Future<void> _useCurrentLocation() async {
    setState(() {
      loadingLocation = true;
    });

    try {
      // --------------------------------------------------------
      // CHECK LOCATION SERVICE
      // --------------------------------------------------------

      final serviceEnabled =
          await Geolocator
              .isLocationServiceEnabled();

      if (!serviceEnabled) {
        throw Exception(
          "Please turn on location services.",
        );
      }

      // --------------------------------------------------------
      // CHECK PERMISSION
      // --------------------------------------------------------

      LocationPermission permission =
          await Geolocator.checkPermission();

      if (permission ==
          LocationPermission.denied) {
        permission =
            await Geolocator.requestPermission();
      }

      if (permission ==
              LocationPermission.denied ||
          permission ==
              LocationPermission
                  .deniedForever) {
        throw Exception(
          "Location permission was not granted.",
        );
      }

      // --------------------------------------------------------
      // GET CURRENT LOCATION
      // --------------------------------------------------------

      final position =
          await Geolocator.getCurrentPosition();

      final location = LatLng(
        position.latitude,
        position.longitude,
      );

      // --------------------------------------------------------
      // UPDATE MAP
      // --------------------------------------------------------

      setState(() {
        selectedLocation = location;
        selectedAddress =
            "Finding location...";
      });

      mapController.move(
        location,
        16,
      );

      // --------------------------------------------------------
      // GET ADDRESS
      // --------------------------------------------------------

      await _getAddress(location);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst(
                  "Exception: ",
                  "",
                ),
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          loadingLocation = false;
        });
      }
    }
  }

  // ============================================================
  // TAP MAP
  // ============================================================

  void _selectMapLocation(
    LatLng point,
  ) {
    setState(() {
      selectedLocation = point;
      selectedAddress =
          "Finding location...";
    });

    _getAddress(point);
  }

  // ============================================================
  // ACCEPT LOCATION
  // ============================================================

  void _acceptLocation() {
    Navigator.pop(
      context,
      LocationResult(
        location: selectedLocation,
        address: selectedAddress,
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF5F8F6),

      appBar: AppBar(
        title: const Text(
          "Select Waste Location",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        backgroundColor:
            Colors.green.shade700,

        foregroundColor: Colors.white,
      ),

      body: Stack(
        children: [
          // ======================================================
          // MAP
          // ======================================================

          FlutterMap(
            mapController: mapController,

            options: MapOptions(
              initialCenter:
                  widget.initialLocation,

              initialZoom: 15,

              onTap:
                  (tapPosition, point) {
                _selectMapLocation(point);
              },
            ),

            children: [
              TileLayer(
                urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',

                userAgentPackageName:
                    'com.example.flutter_application_1',
              ),

              MarkerLayer(
                markers: [
                  Marker(
                    point: selectedLocation,

                    width: 60,
                    height: 60,

                    child: const Icon(
                      Icons.location_pin,
                      size: 55,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // ======================================================
          // INSTRUCTION
          // ======================================================

          Positioned(
            top: 15,
            left: 15,
            right: 15,

            child: Container(
              padding:
                  const EdgeInsets.all(13),

              decoration: BoxDecoration(
                color: Colors.white,

                borderRadius:
                    BorderRadius.circular(14),

                boxShadow: const [
                  BoxShadow(
                    blurRadius: 8,
                    color: Colors.black26,
                  ),
                ],
              ),

              child: const Text(
                "Tap anywhere on the map to choose the waste location.",
                textAlign: TextAlign.center,

                style: TextStyle(
                  fontWeight:
                      FontWeight.w600,
                ),
              ),
            ),
          ),

          // ======================================================
          // BOTTOM PANEL
          // ======================================================

          Positioned(
            left: 12,
            right: 12,
            bottom: 12,

            child: Container(
              padding:
                  const EdgeInsets.all(16),

              decoration: BoxDecoration(
                color: Colors.white,

                borderRadius:
                    BorderRadius.circular(20),

                boxShadow: const [
                  BoxShadow(
                    blurRadius: 15,
                    color: Colors.black26,
                  ),
                ],
              ),

              child: Column(
                mainAxisSize:
                    MainAxisSize.min,

                children: [
                  // SELECTED ADDRESS
                  Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [
                      Icon(
                        Icons.location_on,
                        color:
                            Colors.green.shade700,
                        size: 28,
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,

                          children: [
                            const Text(
                              "Selected Location",
                              style: TextStyle(
                                fontWeight:
                                    FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),

                            const SizedBox(
                              height: 4,
                            ),

                            Text(
                              selectedAddress,
                              style:
                                  const TextStyle(
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // =================================================
                  // USE CURRENT LOCATION
                  // =================================================

                  SizedBox(
                    width: double.infinity,
                    height: 48,

                    child:
                        OutlinedButton.icon(
                      onPressed:
                          loadingLocation
                              ? null
                              : _useCurrentLocation,

                      icon: loadingLocation
                          ? const SizedBox(
                              width: 18,
                              height: 18,

                              child:
                                  CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(
                              Icons.my_location,
                            ),

                      label: Text(
                        loadingLocation
                            ? "Getting Current Location..."
                            : "USE CURRENT LOCATION",
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // =================================================
                  // ACCEPT LOCATION
                  // =================================================

                  SizedBox(
                    width: double.infinity,
                    height: 50,

                    child:
                        ElevatedButton.icon(
                      onPressed:
                          _acceptLocation,

                      icon: const Icon(
                        Icons.check,
                        color: Colors.white,
                      ),

                      label: const Text(
                        "ACCEPT LOCATION",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      style:
                          ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.green.shade700,

                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(
                            12,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}