import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Ativa modo imersivo para esconder barra de navegação e status
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(TrucoCounterApp());
}

class TrucoCounterApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TrucoPA by Rafael Mesquita',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: TrucoCounterPage(),
    );
  }
}

class TrucoCounterPage extends StatefulWidget {
  @override
  _TrucoCounterPageState createState() => _TrucoCounterPageState();
}

class _TrucoCounterPageState extends State<TrucoCounterPage> {
  int _scoreA = 0;
  int _scoreB = 0;

  void _incrementScore(String team) {
    setState(() {
      if (team == 'A' && _scoreA < 12) _scoreA++;
      if (team == 'B' && _scoreB < 12) _scoreB++;
      _checkWinner();
    });
  }

  void _decrementScore(String team) {
    setState(() {
      if (team == 'A' && _scoreA > 0) _scoreA--;
      if (team == 'B' && _scoreB > 0) _scoreB--;
    });
  }

  void _addPoints(String team, int points) {
    setState(() {
      if (team == 'A') _scoreA = (_scoreA + points).clamp(0, 12);
      if (team == 'B') _scoreB = (_scoreB + points).clamp(0, 12);
      _checkWinner();
    });
  }

  void _resetGame() {
    setState(() {
      _scoreA = 0;
      _scoreB = 0;
    });
  }

  void _checkWinner() {
    if (_scoreA == 12) _showWinnerDialog("Time A venceu!");
    if (_scoreB == 12) _showWinnerDialog("Time B venceu!");
  }

  void _showWinnerDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Fim de Jogo"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _resetGame();
            },
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamArea(String team, int score) {
    double _dragStartY = 0;

    return Expanded(
      child: GestureDetector(
        onVerticalDragStart: (details) {
          _dragStartY = details.globalPosition.dy;
        },
        onVerticalDragEnd: (details) {
          // velocidade do swipe vertical
          double velocity = details.velocity.pixelsPerSecond.dy;

          if (_dragStartY == 0) return;

          // swipe rápido para cima = velocity negativa e grande magnitude
          if (velocity < -200) {
            _incrementScore(team);
          } 
          // swipe rápido para baixo = velocity positiva e grande magnitude
          else if (velocity > 200) {
            _decrementScore(team);
          }

          _dragStartY = 0;
        },
        child: Container(
          color: team == 'A' ? Colors.green[50] : Colors.green[100],
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Time $team',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Text(
                '$score',
                style: TextStyle(fontSize: 72, fontWeight: FontWeight.w900),
              ),
              SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () => _addPoints(team, 3),
                    child: Text('+3 Truco'),
                  ),
                  ElevatedButton(
                    onPressed: () => _addPoints(team, 6),
                    child: Text('+6 Seis'),
                  ),
                  ElevatedButton(
                    onPressed: () => _addPoints(team, 9),
                    child: Text('+9 Nove'),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Text(
                'Deslize rápido para cima ↥ para +1\nDeslize rápido para baixo ↧ para -1',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey[700]),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('TrucoPA by Rafael Mesquita'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                _buildTeamArea('A', _scoreA),
                _buildTeamArea('B', _scoreB),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: ElevatedButton.icon(
              onPressed: _resetGame,
              icon: Icon(Icons.refresh),
              label: Text("Resetar Jogo"),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                backgroundColor: Colors.redAccent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
