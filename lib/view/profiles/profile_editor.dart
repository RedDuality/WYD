import 'package:flutter/material.dart';
import 'package:wyd_front/model/profile.dart';
import 'package:wyd_front/service/model/profile_service.dart';
import 'package:wyd_front/service/util/image_service.dart';
import 'package:wyd_front/state/event_provider.dart';

class ProfileEditor extends StatefulWidget {
  final Profile profile;
  const ProfileEditor({super.key, required this.profile});

  @override
  State<ProfileEditor> createState() => ProfileEditorState();
}

class ProfileEditorState extends State<ProfileEditor> {
  late Color _selectedColor;
  late Image profileImage;
  late TextEditingController nameController;
  late TextEditingController tagController;
  final _formKey = GlobalKey<FormState>();
  bool changed = false;
  bool colorChanged = false;

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.profile.color ?? Colors.green;
    profileImage = ImageService.getImage(size: ImageSize.big);
    nameController = TextEditingController(text: widget.profile.name);
    tagController = TextEditingController(text: widget.profile.tag);
  }

  @override
  void dispose() {
    nameController.dispose();
    tagController.dispose();
    super.dispose();
  }

  void update(Profile updatedProfile) async {
    await ProfileService().updateProfile(updatedProfile);
    if (colorChanged) EventProvider().myUpdateFilter();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: LayoutBuilder(builder: (context, constraints) {
            double size =
                constraints.maxWidth < 300 ? constraints.maxWidth : 300;
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Card(
                  elevation: 15,
                  shadowColor: _selectedColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                    side: BorderSide(
                      color: _selectedColor,
                      width: 3.5,
                    ),
                  ),
                  child:
                      SizedBox(width: size, height: size, child: profileImage),
                ),
                SizedBox(height: 50),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Container(
                        constraints: const BoxConstraints(maxWidth: 350),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: TextFormField(
                            controller: nameController,
                            decoration: InputDecoration(labelText: 'Name'),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Name cannot be empty';
                              }
                              if (value.length < 6) {
                                return 'Name must be at least 6 characters';
                              }
                              return null;
                            },
                            onChanged: (value) {
                              setState(() {
                                changed = true;
                              });
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: 25),
                      Container(
                        constraints: const BoxConstraints(maxWidth: 350),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: TextFormField(
                            controller: tagController,
                            decoration: InputDecoration(labelText: 'Tag'),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Tag cannot be empty';
                              }
                              if (value.length < 6) {
                                return 'Tag must be at least 6 characters';
                              }
                              return null;
                            },
                            onChanged: (value) {
                              setState(() {
                                changed = true;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 50),
                ColorSelector(
                  initialColor: _selectedColor,
                  onColorSelected: (color) {
                    setState(() {
                      _selectedColor = color;
                      colorChanged = color != widget.profile.color;
                    });
                  },
                ),
                SizedBox(height: 25),
                SizedBox(
                  height: 50,
                  child: changed || colorChanged
                      ? ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              final updatedProfile = widget.profile.copyWith(
                                name: nameController.text,
                                tag: tagController.text,
                                color: _selectedColor,
                              );
                              Navigator.pop(context);
                              update(updatedProfile);
                            }
                          },
                          child: Text("Save"))
                      : Container(),
                )
              ],
            );
          }),
        ),
      ],
    );
  }
}

class ColorSelector extends StatefulWidget {
  final Color initialColor;
  final ValueChanged<Color> onColorSelected;

  const ColorSelector(
      {super.key, required this.initialColor, required this.onColorSelected});

  @override
  State<ColorSelector> createState() => _ColorSelectorState();
}

class _ColorSelectorState extends State<ColorSelector> {
  late Color selectedColor;

  @override
  void initState() {
    super.initState();
    selectedColor = widget.initialColor;
  }

  @override
  Widget build(BuildContext context) {
    final colors = [
      Colors.black,
      Colors.red,
      Colors.green,
      Colors.blue,
      Colors.yellow,
      Colors.orange,
      Colors.purple,
      Colors.brown,
    ];

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8.0,
      runSpacing: 8.0,
      children: colors.map((color) {
        return GestureDetector(
          onTap: () {
            setState(() {
              selectedColor = color;
            });
            widget.onColorSelected(color);
          },
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 8),
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: selectedColor == color
                  ? Colors.black
                  : Colors.white, // outer ring
            ),
            child: Center(
              child: Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white, // middle ring
                ),
                child: Center(
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color, // inner color
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
