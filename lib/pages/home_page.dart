import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:sqlite_flutter/data/local/db_helper.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // controllers
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descController = TextEditingController();

  List<Map<String, dynamic>> allNotes = [];
  DBHelper? dbRef;
  bool isLoading = true;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    dbRef = DBHelper.getInstance;
    showLoaderAndFetchNotes();
  }

  void showLoaderAndFetchNotes() async {
    await Future.delayed(const Duration(seconds: 3));
    getNotes();
  }

  void getNotes() async {
    allNotes = await dbRef!.getAllNotes();
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: Colors.blue.withOpacity(0.5),
        title: const Padding(
          padding: EdgeInsets.only(left: 30.0),
          child: Text(
            "Notes",
            style: TextStyle(
              color: Colors.black,
              fontSize: 26.0,
            ),
          ),
        ),
      ),
      body: isLoading
          ? Center(
              child: Lottie.asset('assets/animation/loading.json',
                  height: 80, width: 80),
            )
          : allNotes.isNotEmpty
              ? ListView.builder(
                  itemCount: allNotes.length,
                  itemBuilder: (_, index) {
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.grey.withOpacity(0.5),
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 20.0,
                          ),
                        ),
                      ),
                      title: Text(
                        overflow: TextOverflow.ellipsis,
                        allNotes[index][DBHelper.COLUMN_NOTE_TITLE],
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 20.0,
                        ),
                      ),
                      subtitle: Text(
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        allNotes[index][DBHelper.COLUMN_NOTE_DESC],
                        style: const TextStyle(
                          color: Colors.blueGrey,
                          fontSize: 16.0,
                          letterSpacing: 2.0,
                        ),
                      ),
                      trailing: SizedBox(
                        width: 80,
                        child: Row(
                          children: [
                            InkWell(
                              onTap: () {
                                showModalBottomSheet(
                                  isScrollControlled: true,
                                  context: context,
                                  builder: (context) {
                                    titleController.text = allNotes[index]
                                        [DBHelper.COLUMN_NOTE_TITLE];
                                    descController.text = allNotes[index]
                                        [DBHelper.COLUMN_NOTE_DESC];
                                    return getBottomSheet(
                                        isUpdate: true,
                                        sno: allNotes[index]
                                            [DBHelper.COLUMN_NOTE_SNO]);
                                  },
                                );
                              },
                              child: const Icon(
                                Icons.edit_note_rounded,
                                color: Colors.green,
                              ),
                            ),
                            const SizedBox(
                              width: 15,
                            ),
                            InkWell(
                              onTap: () async {
                                bool check = await dbRef!.deleteNote(
                                    sno: allNotes[index]
                                        [DBHelper.COLUMN_NOTE_SNO]);
                                if (check) {
                                  getNotes();
                                } else {}
                              },
                              child: const Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                )
              : const Center(
                  child: Text(
                    "No Notes Found!",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 22.0,
                    ),
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          showModalBottomSheet(
            isScrollControlled: true,
            context: context,
            builder: (context) {
              return getBottomSheet();
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget getBottomSheet({bool isUpdate = false, int sno = 0}) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(15.0),
        width: double.infinity,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isUpdate ? "Update Note" : "Add Note",
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 20.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: "Title",
                    labelStyle: const TextStyle(
                      color: Colors.black,
                      fontSize: 20.0,
                    ),
                    hintText: "Enter Title",
                    hintStyle: const TextStyle(
                      color: Colors.black,
                      fontSize: 16.0,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0),
                      borderSide: const BorderSide(color: Colors.blueGrey),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0),
                      borderSide: const BorderSide(color: Colors.black),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please Enter A Title!";
                    } else if (value.length <= 3) {
                      return "Title Must Be At Least 4 Characters Long.";
                    } else if (value.length > 15) {
                      return "Title Must Be 15 Characters or Less";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  controller: descController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: "Description",
                    labelStyle: const TextStyle(
                      color: Colors.black,
                      fontSize: 20.0,
                    ),
                    hintText: "Enter Description",
                    hintStyle: const TextStyle(
                      color: Colors.black,
                      fontSize: 16.0,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0),
                      borderSide: const BorderSide(color: Colors.blueGrey),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0),
                      borderSide: const BorderSide(color: Colors.black),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please Enter A Description!";
                    } else if (value.length <= 7) {
                      return "Description Must Be At Least 8 Characters Long.";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        splashFactory: InkRipple.splashFactory,
                        overlayColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        side: BorderSide(
                          width: 2,
                          color: Colors.blue.withOpacity(0.5),
                        ),
                      ),
                      onPressed: () async {
                        // Validate the form before submission
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          var title = titleController.text;
                          var desc = descController.text;

                          bool check = isUpdate
                              ? await dbRef!.updateNote(
                                  mTitle: title, mDesc: desc, sno: sno)
                              : await dbRef!
                                  .addNote(mTitle: title, mDesc: desc);

                          if (check) {
                            getNotes();
                          }

                          setState(() {
                            titleController.clear();
                            descController.clear();
                          });
                          Navigator.pop(context);
                        }
                      },
                      child: Text(
                        isUpdate ? "Update Note" : "Add Note",
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 18.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        splashFactory: InkRipple.splashFactory,
                        overlayColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        side: BorderSide(
                          width: 2,
                          color: Colors.red.withOpacity(0.5),
                        ),
                      ),
                      onPressed: () async {
                        titleController.clear();
                        descController.clear();
                        Navigator.pop(context);
                      },
                      child: const Text(
                        "Cancel",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
