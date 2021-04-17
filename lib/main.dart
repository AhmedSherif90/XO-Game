import 'package:flutter/material.dart';
import 'package:splashscreen/splashscreen.dart';
import 'package:flutter/services.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(new MaterialApp(
    home: new MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return new SplashScreen(
        seconds: 3,
        navigateAfterSeconds: new AfterSplash(),
        title: new Text(
          'Welcome to  X O Game',
          style: new TextStyle(
              color: Colors.green,
              fontFamily: 'Arial',
              fontWeight: FontWeight.bold,
              fontSize: 30.0),
        ),
        image: new Image.asset('assets/1.png'),
        backgroundColor: Colors.white,
        styleTextUnderTheLoader: new TextStyle(),
        photoSize: 200.0,
        loaderColor: Colors.green,
    );
  }
}

class AfterSplash extends StatelessWidget {


  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,

        home: MainPage( ),
      );
}

class MainPage extends StatefulWidget {

  @override
  _MainPageState createState() => _MainPageState();
}

class Player {
  static const none = '';
  static const X = 'X';
  static const O = 'O';
}

class _MainPageState extends State<MainPage> {
  static final countMatrix = 3;
  static final double size = 99;

  String lastMove = Player.none;
  List<List<String>> matrix;

  @override
  void initState() {
    super.initState();

    setEmptyFields();
  }

  void setEmptyFields() =>
      setState(() =>
      matrix = List.generate(
        countMatrix,
            (_) => List.generate(countMatrix, (_) => Player.none),
      ));

  Color getBackgroundColor() {
    final thisMove = lastMove == Player.X ? Player.O : Player.X;

    return getFieldColor(thisMove).withAlpha(110);
  }

  String getPlayerName() {
    final thisMove = lastMove == Player.X ? Player.O : Player.X;

    return getPlayer(thisMove);
  }

  @override
  Widget build(BuildContext context) =>
      Scaffold(
        backgroundColor: getBackgroundColor(),
        appBar: AppBar(
          leading:Icon(
            Icons.gamepad_outlined ),
          actions: <Widget>[

            IconButton(
              icon: Icon(
                Icons.repeat,
                color: Colors.white,
              ),
              onPressed: () {
                showEndDialog('Restart the game');
              },
            )
          ],

          backgroundColor: getBackgroundColor(),
          title: Text(
            getPlayerName(),
            style: new TextStyle(
                fontFamily: 'Arial',
                fontWeight: FontWeight.w900,
                fontSize: 30.0),
          ),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: Utils.modelBuilder(matrix, (x, value) => buildRow(x)),
        ),
      );

  Widget buildRow(int x) {
    final values = matrix[x];

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: Utils.modelBuilder(
        values,
            (y, value) => buildField(x, y),
      ),
    );
  }

  Color getFieldColor(String value) {
    switch (value) {
      case Player.O:
        return Colors.blue;
      case Player.X:
        return Colors.red;
      default:
        return Colors.white;
    }
  }

  String getPlayer(String value) {
    switch (value) {
      case Player.O:
        return "Player O";
      case Player.X:
        return "Player X";
      default:
        return "Player none ";
    }
  }

  Widget buildField(int x, int y) {
    final value = matrix[x][y];
    final color = getFieldColor(value);

    return Container(
      margin: EdgeInsets.fromLTRB(11, 44, 9, 30),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          minimumSize: Size(size, size),
          primary: color,
        ),
        child: Text(value, style: TextStyle(fontSize: 32)),
        onPressed: () => selectField(value, x, y),
      ),
    );
  }

  void selectField(String value, int x, int y) {
    if (value == Player.none) {
      final newValue = lastMove == Player.X ? Player.O : Player.X;

      setState(() {
        lastMove = newValue;
        matrix[x][y] = newValue;
      });

      if (isWinner(x, y)) {
        showEndDialog('Player $newValue Won');
      } else if (isEnd()) {
        showEndDialog('Undecided Game');
      }
    }
  }

  bool isEnd() =>
      matrix.every((values) => values.every((value) => value != Player.none));


  bool isWinner(int x, int y) {
    var col = 0,
        row = 0,
        diag = 0,
        rdiag = 0;
    final player = matrix[x][y];
    final n = countMatrix;

    for (int i = 0; i < n; i++) {
      if (matrix[x][i] == player) col++;
      if (matrix[i][y] == player) row++;
      if (matrix[i][i] == player) diag++;
      if (matrix[i][n - i - 1] == player) rdiag++;
    }

    return row == n || col == n || diag == n || rdiag == n;
  }

   showEndDialog(String title) {
    if (title == "Restart the game") {
      showDialog(

        context: context,
        barrierDismissible: false,
        builder: (context) =>
            AlertDialog(
              title: Text(title),
              content: Text('Press to Restart the Game'),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    setEmptyFields();
                    Navigator.of(context).pop();
                  },
                  child: Text('Restart'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cansel'),
                )
              ],
            ),
      );
    }
    else{
      showDialog(

        context: context,
        barrierDismissible: false,
        builder: (context) =>
            AlertDialog(
              title: Text(title),
              content: Text('Press to Restart the Game'),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    setEmptyFields();
                    Navigator.of(context).pop();
                  },
                  child: Text('Restart'),
                ),

              ],
            ),
      );
    }
  }
}

class Utils {
  static List<Widget> modelBuilder<M>(
          List<M> models, Widget Function(int index, M model) builder) =>
      models
          .asMap()
          .map<int, Widget>(
              (index, model) => MapEntry(index, builder(index, model)))
          .values
          .toList();
}
