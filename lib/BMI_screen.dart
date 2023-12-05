import 'package:flutter/material.dart';
import 'Controller/sqlite_db.dart';




class BMIScreen extends StatefulWidget {
  const BMIScreen({super.key});


  @override
  State<BMIScreen> createState() => _BMIScreenState();
}

class _BMIScreenState extends State<BMIScreen> {

  final TextEditingController nameController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController statusController = TextEditingController();
  final TextEditingController genderController = TextEditingController();
  final TextEditingController BMIController = TextEditingController();
  double bmi = 0;

  void _calculateBMI() {
    double height = double.parse(heightController.text.trim()) / 100;
    double weight = double.parse(weightController.text.trim());

    if (heightController.text.isNotEmpty && weightController.text.isNotEmpty) {
      bmi = weight / (height * height);
      BMIController.text = bmi.toStringAsFixed(2);
      String gender = genderController.text;
      String bmiStatus = _getBMIStatus(bmi, gender);

      Map<String, dynamic> rowData = {
        'username': nameController.text,
        'weight': weight,
        'height': height,
        'gender': gender,
        'bmi_status': bmiStatus,
      };

      SQLiteDB().insert('bmi', rowData);
    }
  }

  String _getBMIStatus(double bmi, String genderController) {
    if (genderController == 'Male') {
      if (bmi < 18.5) {
        return 'Underweight. Careful during strong wind!';
      } else if (bmi >= 18.5 && bmi <= 24.9) {
        return 'That’s ideal! Please maintain';
      } else if (bmi >= 25.0 && bmi <= 29.9) {
        return 'Overweight! Work out please';
      } else {
        return 'Whoa Obese! Dangerous mate!';
      }
    } else if (genderController == 'Female') {
      if (bmi < 16) {
        return 'Underweight. Careful during strong wind!';
      } else if (bmi >= 16 && bmi <= 22) {
        return 'That’s ideal! Please maintain';
      } else if (bmi >= 22 && bmi <= 27) {
        return 'Overweight! Work out please';
      } else {
        return 'Whoa Obese! Dangerous mate!';
      }
    } else {
      return 'Invalid gender';
    }
  }


  @override
  void initState() {
    super.initState();
    init();
  }
  //fdfdfd

  void init() async {
    List<Map<String, dynamic>> previousData = await SQLiteDB().queryAll('bmi');

    if (previousData.isNotEmpty) {
      Map<String, dynamic> lastRecord = previousData.last;

      setState(() {
        nameController.text = lastRecord['username'];
        heightController.text = lastRecord['height'].toString();
        weightController.text = lastRecord['weight'].toString();
        statusController.text = lastRecord['bmi_status'];
        genderController.text = lastRecord['gender'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Expenses'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Your Fullname',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: heightController,
                decoration: const InputDecoration(
                  labelText: 'height in cm',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: weightController,
                decoration: const InputDecoration(
                  labelText: 'weight in KG',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: BMIController,
                readOnly: true,
                //onTap: _selectDate,
                decoration: const InputDecoration(labelText: 'BMI value: '),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: ListTile(
                      title: const Text('Male'),
                      leading: Radio(
                        value: 'Male',
                        groupValue: genderController.text,
                        onChanged: (value) {
                          setState(() {
                            genderController.text = value.toString();
                          });
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      title: const Text('Female'),
                      leading: Radio(
                        value: 'Female',
                        groupValue: genderController.text,
                        onChanged: (value) {
                          setState(() {
                            genderController.text = value.toString();
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                _calculateBMI();
                setState(() {
                  statusController.text = _getBMIStatus(double.parse(BMIController.text), genderController.text);
                });
              },
              child: const Text('Calculate BMI and Save'),
            ),

            const SizedBox(height: 50,),

            if (statusController.text.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  statusController.text,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
