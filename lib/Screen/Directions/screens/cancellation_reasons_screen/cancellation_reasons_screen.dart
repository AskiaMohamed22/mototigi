import 'package:flutter/material.dart';
import 'package:mototigi/app_router.dart';
import 'package:mototigi/theme/style.dart';
import 'package:group_button/group_button.dart';

class CancellationReasonsScreen extends StatefulWidget {
  @override
  _CancellationReasonsScreenState createState() => _CancellationReasonsScreenState();
}

class _CancellationReasonsScreenState extends State<CancellationReasonsScreen> {
  String? selectedReason;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: whiteColor,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text('Raison d\'annulation', style: TextStyle(color: Colors.black)),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
            ),
            onPressed: selectedReason != null
                ? () {
                    Navigator.of(context).pushReplacementNamed(AppRoute.homeScreen);
                  }
                : null,
            child:  Text('Valider', style: headingWhite),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: <Widget>[
            const SizedBox(height: 50),
            const Text(
              "Veuillez sélectionner la raison de l'annulation :",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 2,
            ),
            SizedBox(height: screenSize.height * 0.08),
            GroupButton(
              buttons: const [
                "Je ne souhaite pas partager",
                "Impossible de contacter le chauffeur",
                "Le prix n'est pas raisonnable",
                "Adresse incorrecte",
              ],
              onSelected: (index, isSelected) {
                setState(() => selectedReason = isSelected ? const [
                      "Je ne souhaite pas partager",
                      "Impossible de contacter le chauffeur",
                      "Le prix n'est pas raisonnable",
                      "Adresse incorrecte",
                    ][index] : null);
              },
              options: GroupButtonOptions(
                selectedColor: primaryColor,
                unselectedTextStyle: const TextStyle(fontSize: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
