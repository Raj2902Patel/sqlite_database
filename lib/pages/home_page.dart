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
                    return Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Card(
                        color: Colors.white54,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.blueGrey.withOpacity(0.5),
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
                            ),
                          ),
                          trailing: SizedBox(
                            width: 90,
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor:
                                      Colors.greenAccent.withOpacity(0.5),
                                  child: InkWell(
                                    onTap: () {
                                      showModalBottomSheet(
                                        enableDrag: false,
                                        isScrollControlled: true,
                                        context: context,
                                        sheetAnimationStyle: AnimationStyle(
                                          duration: const Duration(seconds: 2),
                                          reverseDuration:
                                              const Duration(seconds: 1),
                                        ),
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
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                CircleAvatar(
                                  backgroundColor:
                                      Colors.redAccent.withOpacity(0.5),
                                  child: InkWell(
                                    onTap: () => showDialog(
                                      barrierDismissible: false,
                                      context: context,
                                      builder: (BuildContext context) =>
                                          AlertDialog(
                                        title: const Text(
                                          "Warning!",
                                          style: TextStyle(
                                            color: Colors.red,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        content: const Text(
                                          "Are you sure you want to delete this note?",
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 20.0,
                                          ),
                                        ),
                                        actions: [
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  Colors.black.withOpacity(0.5),
                                            ),
                                            onPressed: () async {
                                              bool check = await dbRef!
                                                  .deleteNote(
                                                      sno: allNotes[index][
                                                          DBHelper
                                                              .COLUMN_NOTE_SNO]);
                                              if (check) {
                                                getNotes();
                                              } else {}
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text(
                                              "OK",
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 5,
                                          ),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  Colors.black.withOpacity(0.5),
                                            ),
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: const Text(
                                              "Cancel",
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.delete,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
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
      floatingActionButton: Theme(
        data: Theme.of(context).copyWith(
          splashFactory: NoSplash.splashFactory, // Disable the ripple effect
          highlightColor: Colors.transparent, // Disable highlight color
        ),
        child: FloatingActionButton(
          splashColor: Colors.transparent,
          highlightElevation: 0,
          backgroundColor: Colors.black,
          onPressed: () async {
            showModalBottomSheet(
              enableDrag: false,
              isScrollControlled: true,
              context: context,
              sheetAnimationStyle: AnimationStyle(
                duration: const Duration(seconds: 2),
                reverseDuration: const Duration(seconds: 1),
              ),
              builder: (context) {
                return getBottomSheet();
              },
            );
          },
          child: const Icon(
            Icons.add,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget getBottomSheet({bool isUpdate = false, int sno = 0}) {
    return PopScope(
      canPop: false,
      child: Padding(
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
                            Navigator.pop(context);
                            await Future.delayed(const Duration(seconds: 1));
                            setState(() {
                              titleController.clear();
                              descController.clear();
                            });
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
                          Navigator.pop(context);
                          await Future.delayed(Duration(seconds: 1));
                          titleController.clear();
                          descController.clear();
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
      ),
    );
  }
}
