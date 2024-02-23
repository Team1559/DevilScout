import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '/components/menu_scaffold.dart';
import '/components/user_edit_dialog.dart';
import '/server/events.dart';
import '/server/teams.dart';
import '/server/users.dart';

class ManagementPage extends StatelessWidget {
  const ManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MenuScaffold(
      title: 'Manage',
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
          child: Column(
            children: [
              Text(
                'Current Event',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              GestureDetector(
                onTap: () => Navigator.push<Event>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SelectEventDialog(),
                    fullscreenDialog: true,
                  ),
                ).then((event) {
                  if (event == null) return;

                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Event changed'),
                      content: const Text(
                        'Team members will see the new event after logging out and in again.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: Navigator.of(context).pop,
                          child: const Text('Okay'),
                        ),
                      ],
                    ),
                  );
                }),
                child: Card(
                  child: ListTile(
                    title: Text(
                      Event.currentEvent?.name ?? 'No Event Selected',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    subtitle: Event.currentEvent == null
                        ? null
                        : Text(Event.currentEvent!.location),
                    trailing: const Icon(Icons.edit),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Team Roster',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 10),
              const RosterPanel(),
            ],
          ),
        ),
      ),
    );
  }
}

class SelectEventDialog extends StatefulWidget {
  const SelectEventDialog({super.key});

  @override
  State<SelectEventDialog> createState() => _SelectEventDialogState();
}

class _SelectEventDialogState extends State<SelectEventDialog> {
  final TextEditingController searchController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  bool showingSearch = false;
  List<Event> results = List.of(Event.allEvents);

  @override
  void initState() {
    super.initState();
    refresh();
  }

  Future<void> refresh() => serverGetAllEvents().whenComplete(updateResults);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: showingSearch
            ? TextField(
                decoration: const InputDecoration(hintText: 'Search'),
                controller: searchController,
                onChanged: updateResults,
              )
            : const Text('Select Event'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => setState(() {
              showingSearch = !showingSearch;
              if (!showingSearch) {
                searchController.clear();
                updateResults();
              }
            }),
          )
        ],
      ),
      body: Scrollbar(
        controller: scrollController,
        child: RefreshIndicator(
          onRefresh: refresh,
          child: ListView.builder(
            controller: scrollController,
            shrinkWrap: true,
            itemCount: results.length,
            itemBuilder: (context, index) => EventCard(
              event: results[index],
            ),
          ),
        ),
      ),
    );
  }

  void updateResults([String? searchText]) {
    searchText ??= searchController.text;
    setState(() {
      results = List.of(Event.allEvents);
      if (searchText!.isNotEmpty) {
        searchText = searchText!.toLowerCase();
        results = results
            .where((event) => eventMatchesSearch(event, searchText!))
            .toList();
        scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  bool eventMatchesSearch(Event event, String searchText) {
    return event.name.toLowerCase().contains(searchText) ||
        event.key.toLowerCase().contains(searchText) ||
        event.location.toLowerCase().contains(searchText);
  }
}

class EventCard extends StatelessWidget {
  static final DateFormat _dateFormat = DateFormat('MMMM d');
  static final DateFormat _dayOnlyFormat = DateFormat('d');

  final Event event;

  const EventCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(
          event.name,
          style: Theme.of(context).textTheme.titleSmall,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle:
            Text('${event.location}\n${formatDates(event.start, event.end)}'),
        isThreeLine: true,
        onTap: () => showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Select event'),
            content: Text(
              'Your entire team will be switched to ${event.name}.',
            ),
            actions: [
              TextButton(
                onPressed: Navigator.of(context).pop,
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  serverEditCurrentTeam(eventKey: event.key).then((response) {
                    if (!context.mounted) return;

                    if (!response.success) {
                      // error message
                      return;
                    }

                    Navigator.pop(context);
                    Navigator.pop(context, event);
                  });
                },
                child: const Text('Select'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String formatDates(DateTime start, DateTime end) {
    if (start == end) {
      return _dateFormat.format(start);
    }

    if (start.month == end.month) {
      return '${_dateFormat.format(start)} to ${_dayOnlyFormat.format(end)}';
    }

    return '${_dateFormat.format(start)} to ${_dateFormat.format(end)}';
  }
}

class RosterPanel extends StatefulWidget {
  const RosterPanel({super.key});

  @override
  State<RosterPanel> createState() => _RosterPanelState();
}

class _RosterPanelState extends State<RosterPanel> {
  @override
  void initState() {
    super.initState();
    refresh();
  }

  Future<void> refresh() =>
      serverGetUsers().whenComplete(() => setState(() {}));

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.black,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      height: MediaQuery.of(context).size.height * 0.5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Scrollbar(
                child: RefreshIndicator(
                  onRefresh: refresh,
                  child: ListView.builder(
                    itemCount: User.allUsers.length,
                    itemBuilder: (context, index) =>
                        _userCard(User.allUsers[index], context),
                  ),
                ),
              ),
            ),
          ),
          FilledButton(
            style: const ButtonStyle(
              shape: MaterialStatePropertyAll(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                ),
              ),
            ),
            onPressed: () => showModalBottomSheet<User>(
              context: context,
              isScrollControlled: true,
              isDismissible: true,
              builder: (context) => const UserEditDialog(showAdmin: false),
            ).then((user) {
              if (user != null) {
                setState(() {
                  User.allUsers.add(user);
                });
              }
            }),
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }

  Card _userCard(User user, BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(
          user.fullName,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        subtitle: Text(
          user.username,
          style: Theme.of(context).textTheme.labelMedium,
        ),
        trailing: IconButton(
          icon: const Icon(Icons.edit),
          onPressed: user.isAdmin
              ? null
              : () => showModalBottomSheet<User>(
                    context: context,
                    isScrollControlled: true,
                    isDismissible: true,
                    builder: (context) => UserEditDialog(
                      user: user,
                      showAdmin: true,
                    ),
                  ).then((user) {
                    if (user == null) {
                      setState(() {
                        User.allUsers.remove(user);
                      });
                    }
                  }),
        ),
      ),
    );
  }
}
