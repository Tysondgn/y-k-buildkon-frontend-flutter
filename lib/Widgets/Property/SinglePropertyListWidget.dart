
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:real_state/Pages/Property/PropertyDetailPage.dart';
import 'package:real_state/config/ApiLinks.dart';
import 'package:real_state/Pages/Error/InternetErrorPage.dart';
import 'package:real_state/Pages/Error/SpacificErrorPage.dart';
import 'package:real_state/Pages/Error/EmptyPropertyPage.dart';
import 'package:real_state/Pages/Property/PropertyListPage.dart';
import 'package:real_state/config/StaticMethod.dart';
import 'package:real_state/Provider/MyProvider.dart';

class SinglePropertyListWidget extends StatefulWidget {
  final property_id;
  const SinglePropertyListWidget({Key? key,required this.property_id}) : super(key: key);

  @override
  State<SinglePropertyListWidget> createState() => _SinglePropertyListWidgetState();
}

class _SinglePropertyListWidgetState extends State<SinglePropertyListWidget> {
  @override
  Widget build(BuildContext context) {

    final appState = Provider.of<MyProvider>(context);
    Widget propertyContent = Container();
    List<Map<String, dynamic>> propertyListDemo = [];
    var url = Uri.parse(ApiLinks.fetchSinglePropertyById);
    var data = {"p_id":widget.property_id};
    return PopScope(
        child: Scaffold(
          appBar: AppBar(
            title: Text('property details'),
          ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: StaticMethod.fetchSingleProperties(data,url),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Display a circular progress indicator while waiting for data.
            return Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 50),
                  child: const LinearProgressIndicator(),
                )
            );
          } else if (snapshot.hasError ) {
            // Handle error state.
            if (snapshot.error is SocketException) {
              // Handle network-related errors (internet connection loss).
              return const InternetErrorPage();
            } else {
              // Handle other errors (server error or unexpected error).
              return SpacificErrorPage(errorString: snapshot.error.toString(),fromWidget: appState.activeWidget,);
            }
          }
          else if(snapshot.hasData){

            // Display user details when data is available.
            if(snapshot.data!['success']==true){
              final propertyResult = snapshot.data!;
              //print('property list is ${propertyResult}');
              if(propertyResult['result'].length!=0){
                for (var propertyData in propertyResult['result']) {
                  if (propertyData['pi_name'] != null && propertyData['pi_name'] != '') {
                    // Split pi_name into an array of image URLs
                    List<String> imageUrls = propertyData['pi_name'].split(',');
                    // Update the propertyData with the new imageUrls array
                    propertyData['pi_name'] = imageUrls;
                  } else {
                    // Handle the case where there are no images
                    propertyData['pi_name'] = []; // or an empty array []
                  }

                  // Add the updated propertyData to the propertyList
                  propertyListDemo.add(propertyData);
                }
                appState.selectedProperty = propertyListDemo[0];


                propertyContent = const PropertyDetailPage();
              }else{
                propertyContent = const EmptyPropertyPage(text: "empty property list",);
              }
              return propertyContent;
            }else{
              return SpacificErrorPage(errorString: snapshot.data!['message'],fromWidget: appState.activeWidget,);
            }
          }
          else{
            return SpacificErrorPage(errorString: snapshot.error.toString(),fromWidget: appState.activeWidget,);
          }
        },
      ),
    )
    );
  }
}
