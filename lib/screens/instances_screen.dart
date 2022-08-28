import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:vtracker/models/instance.dart';
import 'package:vtracker/models/ride.dart';
import 'package:vtracker/screens/view_instance_screen.dart';

class InstancesScreen extends StatefulWidget {
  const InstancesScreen(this.ride, {Key? key}) : super(key: key);

  final Ride ride;

  @override
  State<InstancesScreen> createState() => _InstancesScreenState();
}

class _InstancesScreenState extends State<InstancesScreen> {
  late Future<List<RideInstance>> instances;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  bool isLoading = false;

  Future<List<RideInstance>> _refreshRideInstances(BuildContext context) async {
    _refreshIndicatorKey.currentState?.show();
    setState(() {
      instances =
          RideInstance.getInstances(widget.ride.id, _refreshIndicatorKey);
    });
    return instances;
  }

  void _instanceViewHandler(bool isActive, RideInstance instance) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: ((context) =>
            ViewInstanceScreen(widget.ride, instance, isActive)),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    instances = RideInstance.getInstances(widget.ride.id, _refreshIndicatorKey);
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _refreshIndicatorKey.currentState?.show();
    });
  }

  @override
  Widget build(BuildContext context) {
    return (Scaffold(
      appBar: AppBar(
        title: Text('Rides History of:  "${widget.ride.title}"'),
      ),
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: () => _refreshRideInstances(context),
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : FutureBuilder(
                future: RideInstance.getInstances(
                    widget.ride.id, _refreshIndicatorKey),
                builder: (BuildContext context,
                    AsyncSnapshot<List<RideInstance>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Container();
                  } else if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.hasError) {
                      return LayoutBuilder(builder: (context, constraints) {
                        return ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20.0),
                              constraints: BoxConstraints(
                                minHeight: constraints.maxHeight,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(
                                    Icons.error_outline,
                                    color: Colors.red,
                                    size: 60,
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(top: 16),
                                    child: Text('Error: Could not fetch data'),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      });
                    } else if (snapshot.hasData) {
                      List<RideInstance> instances = snapshot.data!;

                      if (instances.isEmpty) {
                        return const Center(
                          child: Text('No History'),
                        );
                      }

                      return ListView.builder(
                        itemCount: instances.length,
                        itemBuilder: (context, index) => Card(
                          elevation: 1,
                          child: ListTile(
                            leading: Container(
                              margin: const EdgeInsets.only(top: 10),
                              child: Icon(
                                instances[index].endDate == null ||
                                        instances[index].endDate!.isEmpty
                                    ? Icons.circle
                                    : Icons.done_all,
                                size: 20,
                                color: instances[index].endDate == null ||
                                        instances[index].endDate!.isEmpty
                                    ? Colors.green
                                    : Colors.grey,
                              ),
                            ),
                            title: instances[index].endDate == null
                                ? Text(instances[index].startDate)
                                : Text(
                                    'From:     ${instances[index].startDate}\nTo:           ${instances[index].endDate}'),
                            subtitle: Text(instances[index].endDate == null ||
                                    instances[index].endDate!.isEmpty
                                ? 'Active'
                                : 'Finished'),
                            onTap: () => _instanceViewHandler(
                              instances[index].endDate == null ||
                                  instances[index].endDate!.isEmpty,
                              instances[index],
                            ),
                          ),
                        ),
                      );
                    } else {
                      return const Center(child: CircularProgressIndicator());
                    }
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              ),
      ),
    ));
  }
}
