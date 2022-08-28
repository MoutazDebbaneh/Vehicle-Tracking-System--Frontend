import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:vtracker/Services/utils.dart';
import 'package:vtracker/models/instance.dart';
import 'package:vtracker/models/ride.dart';
import 'package:vtracker/models/user.dart';
import 'package:vtracker/screens/add_driver_screen.dart';
import 'package:vtracker/screens/drive_screen.dart';
import 'package:vtracker/screens/instances_screen.dart';
import 'package:vtracker/widgets/iconed_text_field.dart';

class RideScreen extends StatefulWidget {
  static const routeName = "/ride";
  final Ride ride;
  const RideScreen(this.ride, {Key? key}) : super(key: key);

  @override
  State<RideScreen> createState() => _RideScreenState();
}

class _RideScreenState extends State<RideScreen> {
  Future _openDialog(String titleText, List items) => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(titleText),
          content: SizedBox(
            height: 300,
            width: 300,
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(items[index]),
                  leading: const Icon(
                    Icons.arrow_right,
                    color: Colors.blue,
                    size: 40,
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Okay'))
          ],
        ),
      );

  void _viewInstancesHandler() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: ((context) => InstancesScreen(widget.ride)),
      ),
    );
  }

  void _assignDriverHandler() {
    Navigator.of(context).push(MaterialPageRoute(
        builder: ((context) => AddDriverScreen(widget.ride.id))));
  }

  void _handleStartRide() async {
    String curDate = DateFormat("yyyy-MM-dd hh:mm a").format(DateTime.now());

    if (User.currentInstance != null &&
        User.currentInstance!.rideId == widget.ride.id) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: ((context) =>
              DriveScreen(widget.ride, User.currentInstance!))));
      return;
    }

    try {
      RideInstance? instance = await RideInstance.startInstance(
        {'start_date': curDate},
        widget.ride.id,
      );

      if (instance != null) {
        User.ownUser!.currentDrivingInstance = instance.id;
        User.currentInstance = instance;
        widget.ride.isActive = true;
      }

      _pushDriveScreen(instance!);
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
  }

  void _pushDriveScreen(RideInstance instance) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: ((context) => DriveScreen(widget.ride, instance)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ride Info'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.only(top: 10),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  IconedTextField(
                    text: widget.ride.title,
                    label: 'Ride Title',
                    icon: const Icon(Icons.title),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  IconedTextField(
                    text: widget.ride.isActive != null && widget.ride.isActive!
                        ? 'Online'
                        : 'Offline',
                    label: 'Ride Status',
                    icon: Icon(
                        widget.ride.isActive != null && widget.ride.isActive!
                            ? Icons.location_on
                            : Icons.location_off),
                  ),
                  widget.ride.creator == User.ownUser!.id &&
                          widget.ride.isPublic != null &&
                          !widget.ride.isPublic!
                      ? Column(
                          children: [
                            InkWell(
                              onTap: () {
                                Clipboard.setData(ClipboardData(
                                        text: widget.ride.accessKey ?? ''))
                                    .then((_) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              "Access Key copied to clipboard")));
                                });
                              },
                              child: IconedTextField(
                                text: widget.ride.accessKey ?? '',
                                label: 'Ride Access Key',
                                icon: const Icon(Icons.password),
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                          ],
                        )
                      : const SizedBox(
                          height: 20,
                        ),
                  IconedTextField(
                    text: widget.ride.isPublic! ? 'Public' : 'Private',
                    label: 'Ride Visibility',
                    icon: const Icon(Icons.visibility),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  IconedTextField(
                    text: widget.ride.vehicle!,
                    label: 'Ride Vehicle',
                    icon: const Icon(Icons.drive_eta),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  IconedTextField(
                    text: widget.ride.isRepeatitive!
                        ? 'Repetitive'
                        : 'Non-Repetitive',
                    label: 'Ride Repetition',
                    icon: const Icon(Icons.repeat),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Column(
                    children: widget.ride.isRepeatitive!
                        ? [
                            IconedTextField(
                              text:
                                  widget.ride.repeatition['repeatition_per_day']
                                          ['is_looping']
                                      ? 'Looping'
                                      : 'Non-Looping',
                              label: 'Ride Looping',
                              icon: const Icon(Icons.loop),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            InkWell(
                              onTap: () => _openDialog(
                                'Repetition Days',
                                widget.ride.repeatition['repeatition_per_week']
                                    ['repeatition_days'],
                              ),
                              child: IconedTextField(
                                text: widget
                                    .ride
                                    .repeatition['repeatition_per_week']
                                        ['repeatition_days']
                                    .toString()
                                    .substring(
                                        1,
                                        widget
                                                .ride
                                                .repeatition[
                                                    'repeatition_per_week']
                                                    ['repeatition_days']
                                                .toString()
                                                .length -
                                            1),
                                label: 'Repetition Days',
                                icon: const Icon(Icons.calendar_month),
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            InkWell(
                              onTap: () => _openDialog(
                                'Repetition Times',
                                widget.ride.repeatition['repeatition_per_day']
                                    ['repeatition_times'],
                              ),
                              child: IconedTextField(
                                text: widget
                                    .ride
                                    .repeatition['repeatition_per_day']
                                        ['repeatition_times']
                                    .toString()
                                    .substring(
                                        1,
                                        widget
                                                .ride
                                                .repeatition[
                                                    'repeatition_per_day']
                                                    ['repeatition_times']
                                                .toString()
                                                .length -
                                            1),
                                label: 'Repetition Times',
                                icon: const Icon(Icons.alarm),
                              ),
                            ),
                          ]
                        : [
                            IconedTextField(
                              text: widget.ride.oneTimeDate ?? '-',
                              label: 'Ride Date',
                              icon: const Icon(Icons.calendar_month),
                            ),
                          ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  IconedTextField(
                    text: widget.ride.startPoint['address'] != null &&
                            (widget.ride.startPoint['address'] as String)
                                .isNotEmpty
                        ? widget.ride.startPoint['address']
                        : '${widget.ride.startPoint['latitude']['\$numberDecimal']}, ${widget.ride.startPoint['longitude']['\$numberDecimal']}',
                    label: 'Ride Starting Location',
                    icon: const Icon(Icons.start),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  IconedTextField(
                    text: widget.ride.endPoint['address'] != null &&
                            (widget.ride.endPoint['address'] as String)
                                .isNotEmpty
                        ? widget.ride.endPoint['address']
                        : '${widget.ride.endPoint['latitude']['\$numberDecimal']}, ${widget.ride.endPoint['longitude']['\$numberDecimal']}',
                    label: 'Ride Ending Location',
                    icon: const Icon(Icons.location_on),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  widget.ride.creator == User.ownUser!.id ||
                          widget.ride.drivers!
                              .map((e) => e['email'])
                              .toList()
                              .contains(User.ownUser!.email)
                      ? Column(
                          children: [
                            InkWell(
                              onTap: () => _openDialog(
                                  'Ride Drivers',
                                  widget.ride.drivers!
                                      .map((e) => e['email'])
                                      .toList()),
                              child: IconedTextField(
                                text: widget.ride.drivers!
                                    .map((e) => e['email'])
                                    .toList()
                                    .toString()
                                    .substring(
                                        1,
                                        widget.ride.drivers!
                                                .map((e) => e['email'])
                                                .toList()
                                                .toString()
                                                .length -
                                            1),
                                label: 'Ride Drivers',
                                icon: const Icon(Icons.person),
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                          ],
                        )
                      : Container(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      widget.ride.creator == User.ownUser!.id
                          ? Container(
                              margin: const EdgeInsets.symmetric(horizontal: 5),
                              child: ElevatedButton(
                                onPressed: _assignDriverHandler,
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all(Colors.green),
                                  padding:
                                      MaterialStateProperty.all<EdgeInsets>(
                                          const EdgeInsets.all(16)),
                                ),
                                child: const Text('Assign Driver'),
                              ),
                            )
                          : Container(),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        child: ElevatedButton(
                          onPressed: _viewInstancesHandler,
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.green),
                            padding: MaterialStateProperty.all<EdgeInsets>(
                                const EdgeInsets.all(16)),
                          ),
                          child: const Text('View'),
                        ),
                      ),
                      widget.ride.drivers!
                              .map((e) => e['email'])
                              .toList()
                              .contains(User.ownUser!.email)
                          ? Container(
                              margin: const EdgeInsets.symmetric(horizontal: 5),
                              child: ElevatedButton(
                                onPressed: (User.currentInstance != null &&
                                            User.currentInstance!.rideId !=
                                                widget.ride.id) ||
                                        (widget.ride.isFinished != null &&
                                            widget.ride.isFinished!)
                                    ? null
                                    : _handleStartRide,
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all(Colors.green),
                                  padding:
                                      MaterialStateProperty.all<EdgeInsets>(
                                          const EdgeInsets.all(16)),
                                ),
                                child: Text(User.currentInstance != null &&
                                        User.currentInstance!.rideId ==
                                            widget.ride.id
                                    ? 'Drive Screen'
                                    : 'Start Ride'),
                              ),
                            )
                          : Container()
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
