import "package:flutter/material.dart";
import "package:pill_reminder/database/db_helper.dart";
import "package:pill_reminder/screens/add_edit_reminder.dart";
import "package:pill_reminder/services/notifications_helper.dart";

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

  class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> _reminders = [];
  @override
  void initState() {
    super.initState();
    _loadReminders();
  }

 
  Future<void> _loadReminders() async {
    final reminders = await DbHelper.getReminders();
    setState(() {
      _reminders = reminders;
    });
  }

  Future<void> _toggleReminder(int id, bool isActive) async {
    await DbHelper.toggleReminder(id, isActive);
    if(isActive) {
      final reminder = _reminders.firstWhere((element) => element['id'] == id);
      await NotificationsHelper.ScheduleNotification(
        id,
        reminder['title'],
        reminder['category'],
        DateTime.parse(reminder['schedule_time']),
      );
    } else {
      await NotificationsHelper.CancelNotification(id);
    }
    _loadReminders();
  }

  Future<void> _deleteReminder(int id) async {
    await DbHelper.deleteReminder(id);
    await NotificationsHelper.CancelNotification(id);
    _loadReminders();
  }

  Future<bool?> _showDeleteConfirmationDialog(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Reminder'),
        content: Text('Are you sure you want to delete this reminder?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            title: Text(
              "Reminder",
              style: TextStyle(color: Colors.teal),
            ),
            iconTheme: IconThemeData(color: Colors.teal),
          ),
            body: _reminders.isEmpty ? Center(child: Text("No Reminders Founds",
            style: TextStyle(fontSize: 18, color: Colors.teal),),) : ListView.builder( 
              itemCount: _reminders.length,
              itemBuilder: (context, index) {
              final reminder = _reminders[index];
              return Dismissible(key: Key(reminder['id'].toString()), 
              direction: DismissDirection.endToStart,
              background: Container(
              color: Colors.redAccent,
              padding: EdgeInsets.only(right: 20),
              alignment: Alignment.centerRight,
              child: Icon(
                Icons.delete, 
                color: Colors.white, 
                size: 30
                ),
              ),
              confirmDismiss: (direction) async {
                return await _showDeleteConfirmationDialog(context);
              },
              onDismissed: (direction) {
                _deleteReminder(reminder['id']);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Reminder Deleted')));
              },
              child: Card(
                color: Colors.teal[50],
                elevation: 6,
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ListTile(),
              )
              );
              },
              ),
            floatingActionButton: FloatingActionButton(
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
            onPressed: () {
              Navigator.push(
              context, 
              MaterialPageRoute(
                builder: (context) => AddEditReminderScreen(),
                ),);
            },
            child: Icon(Icons.add),      
            ),     
          ), 
        );
      } 
    }

    // show confirmation dialong before deleting a reminder
    Future<bool?> _showDeleteConfirmationDialog(BuildContext context){
      return showDialog<bool>(context: context, builder: (BuildContext context){
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text('Delete Reminder'),
          content: Text('Are you sure you want to delete this reminder?'),
          actions: [
            TextButton(
              onPressed: (){
              Navigator.of(context).pop(false); // don't delete
            }, 
            child: Text("Cancel"),
            ), 
            TextButton(
              onPressed: (){
              Navigator.of(context).pop(true); // confirm delete
            }, 
            child: Text(
            "Delete",
            style: TextStyle(color: Colors.redAccent),
              ),
            )
          ],
        );
      }, 
    );
 }
  

    
