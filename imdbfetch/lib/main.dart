import 'dart:io';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:imdbfetch/FetchData/movie.dart';
import 'package:imdbfetch/FetchData/omdb.dart';
import 'generalfunciton.dart';
import 'package:window_size/window_size.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    setWindowTitle('IMDb Fetch');
    setWindowMinSize(const Size(650, 400));
    setWindowMaxSize(Size.infinite);
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'IMDb Fatch',
      theme:
          ThemeData(primarySwatch: Colors.amber, backgroundColor: Colors.grey),
      home: MyWidget(),
    );
  }
}

class MyWidget extends StatefulWidget {
  @override
  _MyWidgetState createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  Omdb _omdb;
  String omdb_API = "6e826122";
  Movie _movie;
  List<Map<String, Object>> _resultData = [];
  bool _isDataSubmit = false;
  bool _switch480p = true;
  String _url480p = "";
  bool _switch720p = true;
  String _url720p = "";
  List<String> _catagory = [];
  String _language = "Both";
  String _type = "Movie";
  String _fileSize;
  List<String> _totallanguage = ["Both", "Hindi", "English"],
      _viewType = ["Movie", "Web Series"];
  List<String> _movieSize = [
        "\"380mb for 480p & 750mb for 720p\"",
        "\"400mb for 480p & 850mb for 720p\"",
        "\"450mb for 480p & 1gb for 720p\"",
        "\"500mb for 480p & 1.5gb for 720p\""
      ],
      _webSeriesSize = [
        "\"850mb for 480p & 1.5gb for 720p Zip file\"",
        "\"1gb for 480p & 2gb for 720p Zip file\"",
        "\"1.5gb for 480p & 2.5gb for 720p Zip file\"",
        "\"2gb for 480p & 3.2gb for 720p Zip file\""
      ];
  TextEditingController _idController = TextEditingController();
  TextEditingController _url480pController = TextEditingController();
  TextEditingController _url720pController = TextEditingController();
  TextEditingController _imageController = TextEditingController();
  TextEditingController _yearController = TextEditingController();

  completeClear() {
    _idController.clear();
    _imageController.clear();
    _url480pController.clear();
    _url720pController.clear();
    _yearController.clear();
    _catagory.clear();
    _movie = null;
  }

  String isError() {
    if (_idController.text.isNotEmpty) {
      if (_movie != null) {
        if (_movie.response == "False")
          return "Incorrect IMDb id";
        else if (RegExp(r'(A-Z|[a-z]|–|-)').hasMatch(_movie.year)) {
          if (_yearController.text.isNotEmpty &&
              _yearController.text.length == 4) return "Healthy";
          return "please enter year manually ${_movie.year}";
        } else {
          _yearController.text = _movie.year;
          return "Healthy";
        }
      }
    }
    return "";
  }

  imageTextField(
          {@required String title,
          @required IconData icon,
          @required TextEditingController controller}) =>
      Padding(
        padding: const EdgeInsets.all(4.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
                width: 100,
                child: FittedBox(
                  child: Row(
                    children: [
                      Text(title),
                      IconButton(
                          onPressed: RegExp(r'(\.jpg|.png|.jpeg|.gif)')
                                  .hasMatch(_imageController.text)
                              ? () {
                                  showDialog(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                            title: Text("Image"),
                                            content: Image.network(
                                                _imageController.text),
                                            actions: [
                                              TextButton(
                                                  onPressed: () =>
                                                      Navigator.of(context)
                                                          .pop(),
                                                  child: Text("Ok",
                                                      style: TextStyle(
                                                        color: Colors.green,
                                                      )))
                                            ],
                                          ));
                                }
                              : null,
                          icon: Icon(icon))
                    ],
                  ),
                )),
            Expanded(
                child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: TextFormField(
                controller: controller,
                enabled: isError() == "Healthy" ? true : false,
                onChanged: (value) {
                  setState(() {});
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Auto Detect',
                ),
              ),
            ))
          ],
        ),
      );
  customColumnTextField(
          {@required Function(String) onTap,
          @required String title,
          @required bool currentSwitchValue,
          @required Function(bool) onSwitchTap,
          @required TextEditingController controller,
          double height}) =>
      Container(
        height: 150,
        width: MediaQuery.of(context).size.width / 2.1,
        padding: const EdgeInsets.all(4.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ListTile(
                dense: true,
                minLeadingWidth: 0,
                title: Text(title),
                leading: Image.asset(
                  "assets/images/onedrive.png",
                  height: 24,
                ),
                trailing: Container(
                  height: 24,
                  child: FittedBox(
                    child: CupertinoSwitch(
                        value: currentSwitchValue, onChanged: onSwitchTap),
                  ),
                )),
            Expanded(
                child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: TextFormField(
                minLines: 4,
                maxLines: 5,
                controller: controller,
                enabled: isError() == "Healthy" ? true : false,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter a search term',
                ),
                onChanged: onTap,
              ),
            ))
          ],
        ),
      );

  String _linkChecker(String _url, bool isOneDrive) {
// filter
    setState(() {
      if (_url.contains(String.fromCharCode(13)) || _url.contains("\n")) {
        _url = _url.replaceAll(String.fromCharCode(13), "");
        _url = _url.replaceAll("\n", "");
      }
// OneDrive
      if (_url.contains("my.sharepoint.com") &&
          !_url.contains("?download=1") &&
          isOneDrive) {
        if (!_url.contains("?")) _url = "$_url?";

        _url = _url.replaceAll(
            _url.substring(_url.lastIndexOf("?"), _url.length), "?download=1");
      }
    });

    return _url;
  }

  @override
  initState() {
    super.initState();
    setState(() {});
    _fileSize = _movieSize.first;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _idController.dispose();
    _imageController.dispose();
    _url480pController.dispose();
    _url720pController.dispose();
    _yearController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_idController.text.isEmpty) {
      _isDataSubmit = false;
      completeClear();
    }
    return Scaffold(
        backgroundColor: Colors.grey.shade100,
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(8.0),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _isDataSubmit
                      ? Center(
                          child: Text(
                            isError(),
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isError() == "Healthy"
                                    ? Colors.green
                                    : Colors.red),
                          ),
                        )
                      : Offstage(),
                  ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: 4.0),
                    leading: Image.asset("assets/images/imdb.png", scale: 2),
                    title: TextField(
                      controller: _idController,
                      onChanged: (value) {
                        setState(() {});
                      },
                      decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: "Movie Title or IMDb Id"),
                    ),
                    trailing: IconButton(
                        onPressed: () async {
                          _catagory.clear();
                          _url480pController.clear();
                          _url720pController.clear();
                          _yearController.clear();

                          _omdb = Omdb(omdb_API, _idController.text);
                          await _omdb
                              .getMovie()
                              .then((value) => _movie = value);

                          setState(() {
                            _isDataSubmit = true;
                            if (_movie.response != "False") {
                              _imageController.text = _movie.poster;
                              _movie.genre.split(",").forEach((element) {
                                _catagory
                                    .add("\"${element.replaceAll(" ", "")}\"");
                              });
                            }
                          });
                        },
                        icon: Icon(
                          Icons.check,
                          color: _idController.text.isNotEmpty
                              ? Colors.green
                              : null,
                        )),
                  ),
                  imageTextField(
                    icon: Icons.image,
                    title: "ImageUrl",
                    controller: _imageController,
                  ),
                  Divider(),
                  Row(
                    children: [
                      customColumnTextField(
                        title: "480p Url",
                        controller: _url480pController,
                        currentSwitchValue: _switch480p,
                        onSwitchTap: (value) {
                          setState(() {
                            _switch480p = value;
                            _url480p = "";
                          });
                        },
                        onTap: (value) {
                          setState(() {
                            _url480p = value;
                            _url480p = _linkChecker(_url480p, _switch480p);
                          });
                        },
                      ),
                      Divider(),
                      customColumnTextField(
                          title: "720p Url",
                          controller: _url720pController,
                          currentSwitchValue: _switch720p,
                          onSwitchTap: (value) {
                            setState(() {
                              _switch720p = value;
                              _url720p = "";
                            });
                          },
                          onTap: (value) {
                            setState(() {
                              _url720p = value;
                              _url720p = _linkChecker(_url720p, _switch720p);
                            });
                          }),
                    ],
                  ),
                  Center(
                    child: Container(
                      padding: EdgeInsets.all(4.0),
                      width: 300,
                      clipBehavior: Clip.none,
                      child: DropdownButtonFormField(
                        icon: Icon(Icons.storage),
                        value: _fileSize,
                        isDense: true,
                        decoration: InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.all(8.0),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15))),
                        items: _type != "Movie"
                            ? _webSeriesSize
                                .map((String item) => DropdownMenuItem<String>(
                                    child: Text(
                                      "$item",
                                      overflow: TextOverflow.clip,
                                      style: TextStyle(fontSize: 12),
                                    ),
                                    value: item))
                                .toList()
                            : _movieSize
                                .map((String item) => DropdownMenuItem<String>(
                                    child: Text(
                                      "$item",
                                      overflow: TextOverflow.clip,
                                      style: TextStyle(fontSize: 12),
                                    ),
                                    value: item))
                                .toList(),
                        onChanged: (value) {
                          setState(() {
                            _fileSize = value.toString();
                          });
                        },
                      ),
                    ),
                  ),
                  Divider(),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          child: Row(
                            children: [
                              Icon(Icons.language),
                              DropdownButton(
                                isDense: true,
                                value: _language,
                                items: _totallanguage.map((String item) {
                                  return DropdownMenuItem<String>(
                                    child: Text('$item'),
                                    value: item,
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _language = value.toString();
                                  });
                                },
                                elevation: 8,
                                style: TextStyle(
                                    color: Colors.green, fontSize: 16),
                              ),
                              SizedBox(width: 16),
                              Icon(Icons.movie_filter_sharp),
                              DropdownButton(
                                isDense: true,
                                value: _type,
                                items: _viewType.map((String item) {
                                  return DropdownMenuItem<String>(
                                    child: Text('$item'),
                                    value: item,
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _type = value.toString();
                                    if (value != "Movie")
                                      _fileSize = _webSeriesSize[0];
                                    else
                                      _fileSize = _movieSize[0];
                                  });
                                },
                                elevation: 8,
                                style: TextStyle(
                                    color: Colors.green, fontSize: 16),
                              ),
                              SizedBox(width: 16),
                              Icon(Icons.calendar_today_rounded),
                              Container(
                                width: 100,
                                height: 50,
                                padding: EdgeInsets.all(8.0),
                                child: TextField(
                                  controller: _yearController,
                                  decoration: InputDecoration(
                                      isDense: true,
                                      enabled: _movie != null ? true : false,
                                      border: OutlineInputBorder(),
                                      hintText: "eg.2021"),
                                  onSubmitted: (value) {
                                    setState(() {});
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            TextButton(
                                onPressed: () {
                                  setState(() {});
                                  _resultData.removeLast();
                                },
                                onLongPress: () =>
                                    setState(() => _resultData.clear()),
                                child: Text(
                                  "Clear all",
                                  style: TextStyle(
                                      fontSize: 10, color: Colors.grey),
                                )),
                            ElevatedButton(
                                onPressed: isError() == "Healthy" &&
                                        RegExp(r'(\.jpg|.png|.jpeg|.gif)')
                                            .hasMatch(_imageController.text)
                                    ? () {
                                        setState(() {});
                                        _resultData.add(
                                          {
                                            "\"isLinkActive\"": true,
                                            "\"name\"": "\"${_movie.title}\"",
                                            "\"image\"":
                                                "\"${_imageController.text}\"",
                                            "\"url\"": [
                                              "\"${_url480p == "null" ? "" : _url480p}\"",
                                              "\"${_url720p == "null" ? "" : _url720p}\""
                                            ],
                                            "\"releaseyear\"":
                                                "${int.parse(_yearController.text)}",
                                            "\"duration\"":
                                                "\"${GeneralFunciton().mmtoH(int.parse(_movie.runtime.split(" ")[0]))}\"",
                                            "\"language\"":
                                                "\"${_language == "Both" ? "Dual Audio (Hindi-English)" : _language}\"",
                                            "\"description\"":
                                                "\"${_movie.plot}\\n\\nDirector: ${_movie.director}\\nWriter: ${_movie.writer}\\nActors: ${_movie.actors}\"",
                                            "\"category\"": _catagory,
                                            "\"rating\"":
                                                "${double.parse(_movie.imdbRating).toStringAsFixed(1)}",
                                            "\"size\"": "$_fileSize",
                                            "\"type\"": "\"$_type\"",
                                            "\"quality\"": [
                                              "\"480p\"",
                                              "\"720p\""
                                            ]
                                          },
                                        );
                                        Clipboard.setData(ClipboardData(
                                                text: _resultData
                                                    .toString()
                                                    .replaceRange(0, 1, "")
                                                    .toString()
                                                    .replaceRange(
                                                        _resultData
                                                                .toString()
                                                                .length -
                                                            2,
                                                        _resultData
                                                                .toString()
                                                                .length -
                                                            1,
                                                        ",")))
                                            .catchError((e) {})
                                            .whenComplete(() {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                            content: Text('copy'),
                                          ));
                                        });
                                        completeClear();
                                      }
                                    : null,
                                child: Text("Next Element")),
                          ],
                        )
                      ]),
                  Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                          width: MediaQuery.of(context).size.width / 2 - 16,
                          child: Text(
                            isError() == "Healthy"
                                ? "${double.parse(_movie.imdbRating).toString()}\nTitle: ${_movie.title}_(${_yearController.text})\n"
                                    "Duration: ${_movie.runtime}\n"
                                    "Type ${_movie.type}\nLanguage:${_language == "Both" ? "Dual Audio (Hindi-English)" : _language}\n"
                                    "Description: ${_movie.plot}\\nDirector: ${_movie.director}\nWriter: ${_movie.writer}\nActors: ${_movie.actors},\n"
                                    "FileSize: $_fileSize\n${_movie.genre.replaceAll(" ", "").split(",").toString()}\n${_imageController.text}\n480p: $_url480p\n720p: $_url720p"
                                : "Empty",
                            style: TextStyle(
                              fontSize: 10,
                            ),
                          )),
                      Container(
                        width: MediaQuery.of(context).size.width / 2 - 16,
                        height: MediaQuery.of(context).size.height / 2.2,
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: SingleChildScrollView(
                          child: Text(
                            _resultData
                                .toString()
                                .replaceRange(0, 1, "")
                                .toString()
                                .replaceRange(_resultData.toString().length - 2,
                                    _resultData.toString().length - 1, ",\n")
                                .replaceAll(",", ",\n"),
                            style: TextStyle(fontSize: 10),
                          ),
                        ),
                      ),
                    ],
                  ),
                ]),
          ),
        ));
  }
}

// {
//             "isLinkActive": true,
//             "name": "Ray",
//             "image": "https://i.pinimg.com/originals/25/0a/68/250a680e2a40ec1a87b152af51fce3d5.jpg",
//             "url": [
//                 "https://eduid01-my.sharepoint.com/:u:/g/personal/mi_eduid01_onmicrosoft_com/ERrm4oAu4oxDotqpqIBxuEsBVBGrWIGYnL1ywXj_0q38Qw?download=1",
//                 "https://eduid01-my.sharepoint.com/:u:/g/personal/mi_eduid01_onmicrosoft_com/ETtErDxhmdJEsIkyHbxP-3QBdYgTfIkxwHOtsLHfrGn5iA?download=1"
//             ],
//             "releaseyear": 2021,
//             "duration": "50min",
//             "language": "Hindi",
//             "description": "From a satire to a psychological thriller, four short stories from celebrated auteur and writer Satyajit Ray are adapted for the screen in this series.\n\nCreator: Sayantan Mukherjee\nStars: Bidita Bag, Manoj Bajpayee, Ali Fazal",
//             "category": [
//                 "Crime",
//                 "Action",
//                 "Drama",
//                 "Thriller"
//             ],
//             "rating": 9.0,
//             "size": "850mb for 480p & 1.5gb for 720p Zip file",
//             "type": "Web Series",
//             "quality": [
//                 "480p",
//                 "720p"
//             ]
//         }, "category": ["Drama"], "rating": "0.0", "size": "850mb for 480p & 1.5gb for 720p Zip file", "type": "Movie", "quality": ["480p", "720p"]}]
