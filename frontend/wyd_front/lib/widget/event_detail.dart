import 'package:flutter/material.dart';

class EventDetail extends StatefulWidget {
  const EventDetail({super.key});

  @override
  State<EventDetail> createState() => _EventDetailState();
}

class _EventDetailState extends State<EventDetail> {
  late bool isEditing;

  @override
  void initState() {
    super.initState();
    isEditing = false;
  }

  @override
  Widget build(BuildContext context) {
    String eventName = 'Evento senza nome';
    final TextEditingController controller =
        TextEditingController(text: eventName);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    isEditing = true;
                  });
                },
                child: isEditing
                    ? TextField(
                        style: const TextStyle(fontSize: 16),
                        controller: controller,
                        autofocus: true,
                        onChanged: (value) {
                          setState(() {
                            eventName =
                                value.isEmpty ? 'Evento senza nome' : value;
                          });
                        },
                        onTapOutside: (event) {
                          setState(() {
                            isEditing = false;
                          });
                        },
                        decoration: const InputDecoration(
                          hintText: 'Inserisci il nome dell\'evento',
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 8), // Adjust this value
                          isDense: true, // Ensures a more compact height
                          border:
                              OutlineInputBorder(borderSide: BorderSide.none),
                        ),
                      )
                    : Text(
                        eventName,
                        style: const TextStyle(fontSize: 16),
                      ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Annulla'),
            ),
          ],
        ),
        const Expanded(child: Center(child: Text("prova"))),
        Align(
          alignment: Alignment.bottomRight,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Salva'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
