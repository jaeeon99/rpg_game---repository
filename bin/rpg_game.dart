import 'dart:io';
import 'game_class.dart';

//저장된 게임 결과 불러오기
void loadGame() {
  File resultFile = File('result.txt');
  if (resultFile.existsSync()) {
    List<String> resultData = resultFile.readAsLinesSync();
    for (var line in resultData) {
      print(line);
    }
  } else {
    print('저장된 게임 결과가 없습니다.');
  }
}

void main() {
  print('콘솔 RPG 게임을 시작합니다!');
  try {
    //텍스트 파일의 캐릭터, 몬스터 정보 불러오기
    String characterFile = 'characters.txt';
    String monsterFile = 'monsters.txt';

    //게임 클래스에 불러온 정보 넣기
    Game game = Game.fromFiles(characterFile, monsterFile);
    game.gameStart();

    //게임 결과 불러오기
    print('게임 결과를 불러오려면 Enter 키를 누르세요.');
    stdin.readLineSync();
    loadGame();
  } catch (e) {
    //지정되지 않은 행동을 하거나 오류 발생 시
    print('게임을 시작하는 중 오류가 발생했습니다: $e');
  }
}