import 'package:flutter/material.dart';

class SetProfileButton extends StatelessWidget {

  final IconData iconForSettings;
  final String textForSettings;
  final VoidCallback action;

  const SetProfileButton({
    super.key,
    required this.iconForSettings,
    required this.textForSettings,
    required this.action
  });

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Material(
      child: InkWell(
        onTap: action,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            //color: Colors.grey,
            border: Border(
              bottom: BorderSide(
                color: Colors.indigo.shade200,
                width: 2.0
              )
            )
          ),
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 10, top: 5),
            child: Row(
              children: [
                SizedBox(
                  width: screenWidth * 0.15,
                  child: Icon(iconForSettings)
                ),
                Text(
                  textForSettings,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}