import 'package:doctor_app/controller/doctor_controller.dart';
import 'package:doctor_app/repository/doctor_repository.dart';
import 'package:doctor_app/screens/welcome_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/doctor.dart';
import '../../widget/doctor/doctor_actions_widget.dart';
import '../../widget/doctor/doctor_data_widget.dart';
import '../../widget/info_widget.dart';
import 'add_doctor_page.dart';

class DoctorPage extends StatefulWidget {
  final User userFire;
  const DoctorPage({Key? key, required this.userFire}) : super(key: key);

  @override
  State<DoctorPage> createState() => _DoctorPageState();
}

class _DoctorPageState extends State<DoctorPage> {
  List<Doctor> apiDoctor = [];
  DoctorController doctorController = DoctorController(DoctorRepository());
  late Future<List<Doctor>> futureDoctor;
  TextStyle titleStyle =
      const TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0);

  TextStyle propStyle =
      TextStyle(color: Colors.brown[900], fontWeight: FontWeight.bold);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    futureDoctor = doctorController.fetchDoctorList(widget.userFire.uid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctores'),
        centerTitle: true,
        leading: IconButton(
            onPressed: () => Navigator.pop(
                context,
                MaterialPageRoute(
                    builder: (context) => WelcomePage(
                          userFire: widget.userFire,
                        ))),
            icon: const Icon(Icons.arrow_back)),
        actions: [
          IconButton(
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AddDoctorPage(
                            userFire: widget.userFire,
                          ))),
              icon: const Icon(Icons.add)),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => setState(() {
              print("Refrescar uid: ${widget.userFire.uid}");
              futureDoctor =
                  doctorController.fetchDoctorList(widget.userFire.uid);
            }),
          )
        ],
      ),
      body: FutureBuilder<List<Doctor>>(
        future: futureDoctor,
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return const Center(
                child: CircularProgressIndicator(),
              );
            case ConnectionState.done:
            default:
              if (snapshot.hasError) {
                final error = "${snapshot.error}";
                return InfoWidget(info: error, color: Colors.red);
              } else if (snapshot.data!.isNotEmpty) {
                List<Doctor> data = snapshot.data!;

                return ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    return Card(
                      margin: const EdgeInsets.all(10),
                      color: Colors.orange.shade100,
                      child: Padding(
                        padding:
                            const EdgeInsets.only(left: 10, top: 5, bottom: 5),
                        child: Row(
                          children: [
                            DoctorDataWidget(
                              data: data,
                              titleStyle: titleStyle,
                              propStyle: propStyle,
                              position: index,
                            ),
                            DoctorActionsWidget(
                              data: data,
                              doctorController: doctorController,
                              position: index,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              } else {
                return const InfoWidget(
                    info: "No hay doctores disponibles", color: Colors.red);
              }
          }
        },
      ),
    );
  }
}