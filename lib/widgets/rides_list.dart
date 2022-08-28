import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:vtracker/Services/utils.dart';
import 'package:vtracker/models/ride.dart';
import 'package:vtracker/screens/ride_screen.dart';

class RidesList extends StatefulWidget {
  final String type;
  final bool ownRides;
  const RidesList(this.type, this.ownRides, {Key? key}) : super(key: key);

  @override
  State<RidesList> createState() => _RidesListState();
}

class _RidesListState extends State<RidesList> {
  late Future<List<Ride>> rides;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  bool isLoading = false;

  Future<List<Ride>> _refreshRides(BuildContext context) async {
    _refreshIndicatorKey.currentState?.show();
    setState(() {
      rides = Ride.getRides(widget.type, _refreshIndicatorKey);
    });
    return rides;
  }

  void _deleteRide(String rideId) async {
    bool? confirmDelete = await Utils.showConfirmDialog(
      context: context,
      title: 'Confirm Delete',
      content: 'Are you sure you want to delete this ride??',
      confirmString: 'Delete',
    );

    if (confirmDelete == null || !confirmDelete) return;

    setState(() {
      isLoading = true;
    });

    try {
      bool? result = await Ride.deleteRide(rideId);
      if (result != null && result) {
        Utils.showScaffoldMessage(
          context: context,
          msg: 'Ride deleted successfully',
          error: false,
        );

        _refreshIndicatorKey.currentState?.show();
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      Utils.showScaffoldMessage(
        context: context,
        msg: e.toString().substring(11),
        error: true,
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    rides = Ride.getRides(widget.type, _refreshIndicatorKey);
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _refreshIndicatorKey.currentState?.show();
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      key: _refreshIndicatorKey,
      onRefresh: () => _refreshRides(context),
      child: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : FutureBuilder(
              future: Ride.getRides(widget.type, _refreshIndicatorKey),
              builder:
                  (BuildContext context, AsyncSnapshot<List<Ride>> snapshot) {
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
                    List<Ride> rides = snapshot.data!;

                    return ListView.builder(
                      itemCount: rides.length,
                      itemBuilder: (context, index) => Card(
                        elevation: 1,
                        child: ListTile(
                          trailing: widget.ownRides
                              ? InkWell(
                                  child: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onTap: () => _deleteRide(rides[index].id),
                                )
                              : null,
                          leading: Container(
                            margin: const EdgeInsets.only(top: 10),
                            child: Icon(Icons.circle,
                                size: 20,
                                color: rides[index].isActive != null &&
                                        rides[index].isActive!
                                    ? Colors.green
                                    : Colors.grey),
                          ),
                          title: rides[index].isFinished != null &&
                                  rides[index].isFinished!
                              ? Row(
                                  children: [
                                    Text(rides[index].title),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    const Icon(
                                      Icons.done_all,
                                      color: Colors.green,
                                    )
                                  ],
                                )
                              : Text(rides[index].title),
                          subtitle: Text(
                              rides[index].isPublic! ? 'Public' : 'Private'),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => RideScreen(rides[index]),
                            ),
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
    );
  }
}
