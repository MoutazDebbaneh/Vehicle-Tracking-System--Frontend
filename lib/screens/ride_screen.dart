import 'package:flutter/material.dart';
import 'package:vtracker/models/ride.dart';
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
                    Icons.circle,
                    color: Colors.green,
                    size: 16,
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
                    text: widget.ride.isPublic! ? 'Public' : 'Private',
                    label: 'Ride Visibility',
                    icon: const Icon(Icons.visibility),
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
