import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pill_reminder/database/db_helper.dart';
import 'package:pill_reminder/screens/home_screen.dart';
import 'package:pill_reminder/services/notifications_helper.dart';

class AddEditReminderScreen extends StatefulWidget{
  final int? reminderId;
  const AddEditReminderScreen({super.key, this.reminderId});

  @override
  State<AddEditReminderScreen> createState() => _AddEditReminderScreenState();
}

class _AddEditReminderScreenState extends State<AddEditReminderScreen>{
  final _formKey = GlobalKey<FormState>();

  TextEditingController _titleController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();

  String _category = 'work';
  DateTime _remindersTime = DateTime.now();

  @override
  void initState(){
    // TODO: implement initState
    super.initState();
    if(widget.reminderId != null){
      fetchReminder();
    }
  }

  Future<void> fetchReminder() async{
      try{
        final data = await DbHelper.getReminder(widget.reminderId!);
        if (data != null){
          setState(() {
            _titleController.text = data['title'];
            _descriptionController.text = data['description'];
            _category = data['category'];
            _remindersTime = DateTime.parse(data['RemindersTime']);
          });
        }
      } catch(e){
    } 
  }

    @override
    Widget build(BuildContext context){
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.teal,),
          backgroundColor: Colors.white,
          title: Text(
            widget.reminderId == null ? 'Add Reminder' : 'Edit Reminder',
            style: TextStyle(
              color: Colors.teal,
            ),
          ),

        ),
        body: SingleChildScrollView(
          child: Padding(padding: EdgeInsets.all(16), child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInputCard(
                label: "Title", 
                icon: Icons.title, 
                child: TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    hintText: "Enter title",
                    border: InputBorder.none, 
                  ),
                  validator:(value) {
                    value!.isEmpty ? "Please enter a title" : null;
                    },
                  ),
                ),
                SizedBox(height: 20),
                  _buildInputCard(
                label: "Description", 
                icon: Icons.description, 
                child: TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: "Enter Description",
                    border: InputBorder.none, 
                  ),
                  validator:(value) {
                    value!.isEmpty ? "Please description" : null;
                    },
                  ),
                ),
                SizedBox(height: 20),
                _buildInputCard(
                label: "Category", 
                icon: Icons.category, 
                child: DropdownButtonFormField(
                    value: _category,  
                    dropdownColor: Colors.teal.shade50,
                    decoration: InputDecoration.collapsed(hintText: ''),
                    items:['Work', "Personal", "Health", "Others"]
                .map((category) {
                  return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                  );
                }).toList(), 
                onChanged: (value){
                  setState(() {
                    _category = value!;
                  });
                },
              ),
            ),
            SizedBox(height: 20),
            _buildDateTimerPicker(label: "Date", icon: Icons.calendar_today,
            displayValue: displayValue, onPressed:),
            SizedBox(height: 20),
                ],
              ),
            ),  
          ),
        ),
      );
    }
  
  Widget _buildInputCard(
  {required String label, required IconThemeData icon, required Widget child}) {
    return Card(
    elevation: 6,
    color: Colors.teal.shade50,
    shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(15),),
    child: Padding(padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
        children: [
        Icon(icon, color: Colors.teal),
        SizedBox(width: 10,),
        Text(
  label, 
        style: TextStyle(
        fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            child,
          ], 
        )
      ),
    );
  }


  Widget _buildDateTimerPicker({required String label, required IconData icon, required
  String displayValue, required Function() onPressed}){
    return Card(
    elevation: 6,
    color: Colors.teal.shade50,
    shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.teal),
        title: Text(label, style: TextStyle(
        fontWeight: FontWeight.bold,
          ),
        ),
        trailing: TextButton(
          onPressed: onPressed, 
          child: Text(
          displayValue, 
          style: TextStyle (color: Colors.teal),
          ),),
      ),
    );
  }


  Future<void> _selectDate() async{
    DateTime? picked = await showDatePicker(
    context: context, 
    initialDate: _remindersTime,
    firstDate: DateTime(2000), 
    lastDate: DateTime(2100));
    if (picked !=null){
      setState(() {
        _remindersTime = DateTime(
        picked.year,
        picked.month,
        picked.day,
        _remindersTime.hour,
        _remindersTime.minute,
        );
      });
    }
  }

  
  Future<void> _selectTime() async{
    TimeOfDay? picked = await showTimePicker(
    context: context, 
    initialTime: TimeOfDay(
    hour: _remindersTime.hour, 
    minute: _remindersTime.minute
    )
);
    if (picked !=null){
      setState(() {
        _remindersTime = DateTime(
        _remindersTime.year,
        _remindersTime.month,
        _remindersTime.day,
        picked.hour,
        picked.minute,
        );
      });
    }
  }


  Future<void> _saveReminder() async{
    if (_formKey.currentState!.validate()){
      final newReminder = {
        'title': _titleController.text,
        'description': _descriptionController.text,
        'isActive': 1,
        'RemindersTime': _remindersTime.toIso8601String(),
        'category': _category,
      };
      if (widget.reminderId == null){
        final reminderId = await DbHelper.AddReminder(newReminder);
        NotificationsHelper.ScheduleNotification(
          reminderId, _titleController.text, _category, _remindersTime);
      } else {
        await DbHelper.updateReminder(widget.reminderId!, newReminder);
        NotificationsHelper.ScheduleNotification(widget.reminderId!,
         _titleController.text, _category, _remindersTime);
      }
      Navigator.pushReplacement(
        context, 
        MaterialPageRoute(
        builder: (context) => HomeScreen(),
      ));
    }
  }
}