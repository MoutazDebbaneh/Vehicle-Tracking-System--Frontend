import 'dart:async';

import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:open_street_map_search_and_pick/open_street_map_search_and_pick.dart';
import 'package:place_picker/place_picker.dart';
import 'package:vtracker/services/utils.dart';
import 'package:vtracker/models/ride.dart';
import 'package:vtracker/models/user.dart';
import 'package:vtracker/screens/location_picker_screen.dart';

class RideAddScreen extends StatefulWidget {
  static const routeName = "/addRoute";
  const RideAddScreen({Key? key}) : super(key: key);

  @override
  State<RideAddScreen> createState() => _RideAddScreenState();
}

class _RideAddScreenState extends State<RideAddScreen> {
  final rideTitleController = TextEditingController();
  final rideDateController = TextEditingController();
  final rideTimeController = TextEditingController();
  final rideStartingLocationController = TextEditingController();
  final rideEndingLocationController = TextEditingController();
  final repeatitionDaysController = TextEditingController();
  final repeatitionTimesController = TextEditingController();
  final keyPointsController = TextEditingController();

  final formKey = GlobalKey<FormState>();

  bool isLoading = false;

  bool visibilityDropDown = false;
  bool repeatitionDropDown = false;
  bool loopingDropDown = false;
  bool vehicleDropDown = false;

  String visibility = 'Private';
  String vehicle = 'Car';
  String repeatition = 'No';
  String looping = 'No';

  DateTime? rideDate;
  TimeOfDay? rideTime;

  LatLng? startingLocation;
  LatLng? endingLocation;
  String? startingLocationAdress;
  String? endingLocationAdress;

  final _daysOfWeek = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
  List _selectedDays = [];
  List _selectedTimes = [];

  final List _selectedKeyPoints = [];

  final List<DropdownMenuItem<String>> visibilityOptions = [
    const DropdownMenuItem(
      value: 'Private',
      child: Text('Private'),
    )
  ];

  void _handleRideAdd() async {
    final isValidForm = formKey.currentState!.validate();
    if (!isValidForm) return;

    Map rideData = {};
    rideData['title'] = rideTitleController.text;
    rideData['creator'] = User.ownUser!.id;
    rideData['is_public'] = (visibility == 'Private' ? false : true);
    rideData['vehicle'] = vehicle;
    rideData['is_repeatitive'] = (repeatition == 'No' ? false : true);

    rideData['start_point'] = {
      'longitude': startingLocation!.longitude,
      'latitude': startingLocation!.latitude,
      'address': startingLocationAdress,
    };

    rideData['end_point'] = {
      'longitude': endingLocation!.longitude,
      'latitude': endingLocation!.latitude,
      'address': endingLocationAdress,
    };

    if (_selectedKeyPoints.isNotEmpty) {
      rideData['key_points'] = [];
      for (var keyPoint in _selectedKeyPoints) {
        (rideData['key_points'] as List).add({
          'longitude': (keyPoint['latlng'] as LatLng).longitude,
          'latitude': (keyPoint['latlng'] as LatLng).latitude,
          'address': keyPoint['address'],
        });
      }
    }

    if (repeatition == 'No') {
      rideData['one_time_date'] =
          '${rideDateController.text.trim()} ${rideTimeController.text.trim()}';
    } else {
      rideData['repeatition'] = {
        'repeatition_per_day': {
          'is_looping': (looping == 'Yes' ? true : false),
          'repeatition_times': _selectedTimes,
        },
        'repeatition_per_week': {
          'repeatition_days': _selectedDays,
        }
      };
    }

    setState(() {
      isLoading = true;
    });

    try {
      Ride? addedRide = await Ride.addRide(rideData);
      if (addedRide == null) {
        throw Exception('Unexpected error');
      }

      Utils.showScaffoldMessage(
        context: context,
        msg: 'Ride added successfully',
        error: false,
      );

      _returnHome();
    } on TimeoutException {
      Utils.showScaffoldMessage(
        context: context,
        msg: 'Request timeout exceeded',
        error: true,
      );
    } catch (e) {
      Utils.showScaffoldMessage(
        context: context,
        msg: e.toString().substring(11),
        error: true,
      );
    }

    setState(() {
      isLoading = false;
    });
  }

  void _showMultiSelect(BuildContext context, String type) async {
    List<MultiSelectItem> dialogItems;
    List dialogInitialValues;

    if (type == 'Repeatition Days') {
      dialogItems =
          _daysOfWeek.map((day) => MultiSelectItem(day, day)).toList();
      dialogInitialValues = _selectedDays;
    } else if (type == 'Repeatition Times') {
      dialogItems =
          _selectedTimes.map((time) => MultiSelectItem(time, time)).toList();
      dialogInitialValues = _selectedTimes;
    } else {
      dialogItems = _selectedKeyPoints
          .map((keyPoint) =>
              MultiSelectItem(keyPoint['address'], keyPoint['address']))
          .toList();
      dialogInitialValues =
          _selectedKeyPoints.map((keyPoint) => keyPoint['address']).toList();
    }

    await showDialog(
      context: context,
      builder: (ctx) {
        return MultiSelectDialog(
          title: Text(type),
          height: MediaQuery.of(context).size.height * 30 / 100,
          items: dialogItems,
          initialValue: dialogInitialValues,
          onConfirm: (values) {
            setState(() {
              if (type == 'Repeatition Times') {
                _selectedTimes = values;
                repeatitionTimesController.text = _selectedTimes
                    .toString()
                    .substring(1, _selectedTimes.toString().length - 1);
              } else if (type == 'Repeatition Days') {
                _selectedDays = values;
                repeatitionDaysController.text = _selectedDays
                    .toString()
                    .substring(1, _selectedDays.toString().length - 1);
              } else {}
            });
          },
        );
      },
    );
  }

  void _returnHome() {
    Navigator.of(context).pop();
  }

  String _formatTime(TimeOfDay timeOfDay) {
    return timeOfDay.format(context).trim();
  }

  void showPlacePicker(String type) async {
    Location location = Location();
    setState(() {
      isLoading = true;
    });

    location.getLocation().then((currentLocation) async {
      setState(() {
        isLoading = false;
      });
      PickedData? result = await Navigator.of(context).push(
        MaterialPageRoute(
            builder: (context) => LocationPickerScreen(currentLocation)),
      );
      if (result == null) return;
      setState(() {
        if (type == 'start') {
          startingLocation =
              LatLng(result.latLong.latitude, result.latLong.longitude);
          startingLocationAdress = result.address;
          rideStartingLocationController.text = result.address;
        } else if (type == 'end') {
          endingLocation =
              LatLng(result.latLong.latitude, result.latLong.longitude);
          endingLocationAdress = result.address;
          rideEndingLocationController.text = result.address;
        } else {
          _selectedKeyPoints.add({
            'address': result.address,
            'latlng': LatLng(
              result.latLong.latitude,
              result.latLong.longitude,
            )
          });
          String keyPointsListString =
              _selectedKeyPoints.map((e) => e['address']).toList().toString();
          keyPointsController.text =
              keyPointsListString.substring(1, keyPointsListString.length - 1);
        }
      });
    });
  }

  @override
  void initState() {
    if (User.ownUser!.type == "admin") {
      visibilityOptions.add(
        const DropdownMenuItem(
          value: 'Public',
          child: Text('Public'),
        ),
      );
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Ride'),
        actions: isLoading
            ? []
            : [
                IconButton(
                  onPressed: _handleRideAdd,
                  icon: const Icon(Icons.done),
                ),
              ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                child: Container(
                  margin: const EdgeInsets.only(top: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Form(
                        key: formKey,
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              TextFormField(
                                decoration: const InputDecoration(
                                  border: UnderlineInputBorder(),
                                  labelText: 'Ride Title',
                                ),
                                controller: rideTitleController,
                                validator: (rideTitle) {
                                  return rideTitle!.isNotEmpty &&
                                          rideTitle.trim().length >= 3
                                      ? null
                                      : "Ride Title length is too short";
                                },
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: visibilityDropDown
                                          ? Colors.purple
                                          : Colors.grey,
                                      width: 1,
                                      style: BorderStyle.solid,
                                    ),
                                  ),
                                ),
                                child: DropdownButton(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(1)),
                                  isExpanded: true,
                                  value: visibility,
                                  underline: Container(),
                                  onChanged: (value) {
                                    setState(() {
                                      visibility = value.toString();
                                      visibilityDropDown = false;
                                    });
                                  },
                                  onTap: () => setState(() {
                                    visibilityDropDown = true;
                                  }),
                                  items: visibilityOptions,
                                ),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: visibilityDropDown
                                          ? Colors.purple
                                          : Colors.grey,
                                      width: 1,
                                      style: BorderStyle.solid,
                                    ),
                                  ),
                                ),
                                child: DropdownButton(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(1)),
                                  isExpanded: true,
                                  value: vehicle,
                                  underline: Container(),
                                  onChanged: (value) {
                                    setState(() {
                                      vehicle = value.toString();
                                      vehicleDropDown = false;
                                    });
                                  },
                                  onTap: () => setState(() {
                                    vehicleDropDown = true;
                                  }),
                                  items: const [
                                    DropdownMenuItem(
                                      value: 'Car',
                                      child: Text('Car'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'Bus',
                                      child: Text('Bus'),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: repeatitionDropDown
                                          ? Colors.purple
                                          : Colors.grey,
                                      width: 1,
                                      style: BorderStyle.solid,
                                    ),
                                  ),
                                ),
                                child: DropdownButton(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(1)),
                                  isExpanded: true,
                                  value: repeatition,
                                  underline: Container(),
                                  onChanged: (value) {
                                    setState(() {
                                      repeatition = value.toString();
                                      repeatitionDropDown = false;
                                    });
                                  },
                                  onTap: () => setState(() {
                                    repeatitionDropDown = true;
                                  }),
                                  items: const [
                                    DropdownMenuItem(
                                      value: 'No',
                                      child: Text('Non-Repeatitive'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'Yes',
                                      child: Text('Repeatitive'),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              Container(
                                child: repeatition == 'No'
                                    ? Column(
                                        children: [
                                          TextFormField(
                                            decoration: const InputDecoration(
                                              border: UnderlineInputBorder(),
                                              labelText: 'Ride Date',
                                            ),
                                            controller: rideDateController,
                                            readOnly: true,
                                            validator: (dateText) {
                                              if (repeatition == 'Yes') {
                                                return null;
                                              }
                                              if (dateText != null &&
                                                  dateText.isNotEmpty) {
                                                return null;
                                              } else {
                                                return 'Date is required';
                                              }
                                            },
                                            onTap: () async {
                                              DateTime? newDate =
                                                  await showDatePicker(
                                                context: context,
                                                initialDate: DateTime.now(),
                                                firstDate: DateTime.now(),
                                                lastDate: DateTime.now().add(
                                                    const Duration(days: 360)),
                                              );

                                              if (newDate == null) {
                                                return;
                                              }
                                              setState(() {
                                                rideDate = newDate;
                                                rideDateController.text =
                                                    rideDate!
                                                        .toString()
                                                        .substring(0, 10);
                                              });
                                            },
                                          ),
                                          const SizedBox(
                                            height: 20,
                                          ),
                                          TextFormField(
                                            decoration: const InputDecoration(
                                              border: UnderlineInputBorder(),
                                              labelText: 'Ride Time',
                                            ),
                                            controller: rideTimeController,
                                            readOnly: true,
                                            validator: (timeText) {
                                              if (repeatition == 'Yes') {
                                                return null;
                                              }
                                              if (timeText != null &&
                                                  timeText.isNotEmpty) {
                                                return null;
                                              } else {
                                                return 'Time is required';
                                              }
                                            },
                                            onTap: () async {
                                              TimeOfDay? newTime =
                                                  await showTimePicker(
                                                initialTime: TimeOfDay.now(),
                                                context: context,
                                              );
                                              if (newTime == null) {
                                                return;
                                              }

                                              setState(() {
                                                rideTime = newTime;
                                                rideTimeController.text =
                                                    rideTime!.format(context);
                                                if (rideTimeController.text
                                                        .trim()[1] ==
                                                    ':') {
                                                  rideTimeController.text =
                                                      '0${rideTimeController.text}';
                                                }
                                              });
                                            },
                                          ),
                                          const SizedBox(
                                            height: 20,
                                          ),
                                        ],
                                      )
                                    : Column(
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                              border: Border(
                                                bottom: BorderSide(
                                                  color: repeatitionDropDown
                                                      ? Colors.purple
                                                      : Colors.grey,
                                                  width: 1,
                                                  style: BorderStyle.solid,
                                                ),
                                              ),
                                            ),
                                            child: DropdownButton(
                                              borderRadius:
                                                  const BorderRadius.all(
                                                      Radius.circular(1)),
                                              isExpanded: true,
                                              value: looping,
                                              underline: Container(),
                                              onChanged: (value) {
                                                setState(() {
                                                  looping = value.toString();
                                                  loopingDropDown = false;
                                                });
                                              },
                                              onTap: () => setState(() {
                                                loopingDropDown = true;
                                              }),
                                              items: const [
                                                DropdownMenuItem(
                                                  value: 'No',
                                                  child: Text('Non-Looping'),
                                                ),
                                                DropdownMenuItem(
                                                  value: 'Yes',
                                                  child: Text('Looping'),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 20,
                                          ),
                                          TextFormField(
                                            decoration: const InputDecoration(
                                              border: UnderlineInputBorder(),
                                              labelText: 'Repeatition Days',
                                            ),
                                            controller:
                                                repeatitionDaysController,
                                            readOnly: true,
                                            validator: (daysText) {
                                              if (repeatition == 'No') {
                                                return null;
                                              }
                                              if (daysText != null &&
                                                  daysText.isNotEmpty) {
                                                return null;
                                              } else {
                                                return 'At least one repeatition day is required';
                                              }
                                            },
                                            onTap: () => _showMultiSelect(
                                                context, 'Repeatition Days'),
                                          ),
                                          const SizedBox(
                                            height: 20,
                                          ),
                                          Stack(
                                            alignment:
                                                AlignmentDirectional.centerEnd,
                                            children: [
                                              TextFormField(
                                                decoration:
                                                    const InputDecoration(
                                                  border:
                                                      UnderlineInputBorder(),
                                                  labelText:
                                                      'Repeatition Times',
                                                ),
                                                controller:
                                                    repeatitionTimesController,
                                                readOnly: true,
                                                validator: (timesText) {
                                                  if (repeatition == 'No') {
                                                    return null;
                                                  }
                                                  if (timesText != null &&
                                                      timesText.isNotEmpty) {
                                                    return null;
                                                  } else {
                                                    return 'At least one repeatition time is required';
                                                  }
                                                },
                                                onTap: () => _showMultiSelect(
                                                    context,
                                                    'Repeatition Times'),
                                              ),
                                              IconButton(
                                                onPressed: () async {
                                                  TimeOfDay? newTime =
                                                      await showTimePicker(
                                                    initialTime:
                                                        TimeOfDay.now(),
                                                    context: context,
                                                  );
                                                  if (newTime == null) {
                                                    return;
                                                  }
                                                  String timeText =
                                                      _formatTime(newTime);

                                                  if (timeText[1] == ':') {
                                                    timeText = '0$timeText';
                                                  }
                                                  setState(() {
                                                    _selectedTimes
                                                        .add(timeText);
                                                    repeatitionTimesController
                                                            .text =
                                                        _selectedTimes
                                                            .toString()
                                                            .substring(
                                                                1,
                                                                _selectedTimes
                                                                        .toString()
                                                                        .length -
                                                                    1);
                                                  });
                                                },
                                                icon: const Icon(
                                                    Icons.add_box_rounded),
                                                iconSize: 26,
                                                color: Colors.green[700],
                                              ),
                                            ],
                                          ),
                                          const SizedBox(
                                            height: 20,
                                          ),
                                        ],
                                      ),
                              ),
                              TextFormField(
                                decoration: const InputDecoration(
                                  border: UnderlineInputBorder(),
                                  labelText: 'Ride Starting Location',
                                ),
                                controller: rideStartingLocationController,
                                readOnly: true,
                                validator: (startingLocationText) {
                                  if (repeatition == 'No') {
                                    return null;
                                  }
                                  if (startingLocationText != null &&
                                      startingLocationText.isNotEmpty) {
                                    return null;
                                  } else {
                                    return 'Starting Location is required';
                                  }
                                },
                                onTap: () => showPlacePicker('start'),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              TextFormField(
                                decoration: const InputDecoration(
                                  border: UnderlineInputBorder(),
                                  labelText: 'Ride Ending Location',
                                ),
                                controller: rideEndingLocationController,
                                readOnly: true,
                                validator: (endingLocationText) {
                                  if (repeatition == 'No') {
                                    return null;
                                  }
                                  if (endingLocationText != null &&
                                      endingLocationText.isNotEmpty) {
                                    return null;
                                  } else {
                                    return 'Ending Location is required';
                                  }
                                },
                                onTap: () => showPlacePicker('end'),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              Stack(
                                alignment: AlignmentDirectional.centerEnd,
                                children: [
                                  TextFormField(
                                    decoration: const InputDecoration(
                                      border: UnderlineInputBorder(),
                                      labelText: 'In-between Locations',
                                    ),
                                    controller: keyPointsController,
                                    readOnly: true,
                                    onTap: () => _showMultiSelect(
                                        context, 'In-between Locations'),
                                  ),
                                  IconButton(
                                    onPressed: () =>
                                        showPlacePicker('keyPoints'),
                                    icon: const Icon(Icons.add_box_rounded),
                                    iconSize: 26,
                                    color: Colors.green[700],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
