import 'package:flutter/material.dart';
import 'package:movies_app/views/detailsPage.dart';
import 'package:movies_app/models/movieList_tile.dart';
import '../services/accessDatabase.dart' as database;
import 'favoritePage.dart';

class recommendPage extends StatefulWidget {
  const recommendPage({Key? key}) : super(key: key);

  @override
  _recommendPage createState() => _recommendPage();
}

class _recommendPage extends State<recommendPage> {
  // FIX: Hold a single Future created once in initState.
  // Previously retrieveMoviesList() was called twice per build (once via
  // .then() and once inside FutureBuilder), causing duplicate list entries.
  late Future _moviesFuture;

  @override
  void initState() {
    super.initState();
    _moviesFuture = database.retrieveMoviesList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(120),
        child: AppBar(
          backgroundColor: Colors.white,
          shadowColor: Colors.transparent,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(40),
            child: Container(
              alignment: Alignment.bottomLeft,
              padding: const EdgeInsets.fromLTRB(20, 0, 0, 20),
              child: const Text(
                "Movies",
                style: TextStyle(
                  color: Color.fromRGBO(48, 62, 86, 1),
                  fontSize: 35,
                  letterSpacing: 0.1,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        height: 90,
        padding: const EdgeInsets.fromLTRB(25, 15, 25, 15),
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ElevatedButton(
              child: Column(
                children: const [
                  Icon(Icons.slow_motion_video,
                      color: Colors.deepPurple, size: 30),
                  Text("Movies",
                      style: TextStyle(color: Colors.deepPurple, fontSize: 15)),
                ],
              ),
              onPressed: () {},
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
                shadowColor: MaterialStateProperty.all<Color>(Colors.transparent),
              ),
            ),
            ElevatedButton(
              child: Column(
                children: [
                  Icon(Icons.favorite_outline_sharp,
                      color: Colors.blueGrey.shade300, size: 25),
                  Text("Favorites",
                      style: TextStyle(
                          color: Colors.blueGrey.shade300, fontSize: 10)),
                ],
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => favoritePage()),
                );
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
                shadowColor: MaterialStateProperty.all<Color>(Colors.transparent),
              ),
            ),
          ],
        ),
      ),
      body: FutureBuilder(
        // FIX: Reuse the same Future — never create a new one inside build().
        future: _moviesFuture,
        builder: (buildContext, AsyncSnapshot<dynamic> movies) {
          if (movies.hasError) {
            return Center(
              child: Text(
                "Failed to load movies.\n${movies.error}",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.red.shade300, fontSize: 16),
              ),
            );
          }
          if (!movies.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView.builder(
            shrinkWrap: true,
            itemCount: movies.data.length,
            itemBuilder: (BuildContext ctxt, int index) {
              final movieList = movies.data;
              return Column(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // FIX: Use built-in showModalBottomSheet —
                      // replaces the broken modal_bottom_sheet package.
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        shape: const RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(16)),
                        ),
                        builder: (context) {
                          return SizedBox(
                            height: 720,
                            child: detailsPage(movieDetails: movieList[index]),
                          );
                        },
                      );
                    },
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.white),
                    ),
                    child: movieList_tile(
                      title: movieList[index].title,
                      backdrop: movieList[index].backdrop ?? '',
                      genres: movieList[index].genres,
                    ),
                  ),
                  Divider(
                    indent: 110,
                    height: 0,
                    thickness: 0.5,
                    color: Colors.blueGrey.shade100,
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
