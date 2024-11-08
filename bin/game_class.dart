import 'dart:io';
import 'dart:math';
import 'character.dart';
import 'monster.dart';

class Game {
  Characters character;
  List<Monsters> monsters;
  int killedMonster = 0;

  Game({
    required this.character,
    required this.monsters,
  });

  //Game.fromFiles 팩토리 생성자로 파일에서 데이터를 불러와 Game 객체를 초기화
  factory Game.fromFiles(String characterFile, String monsterFile) {
    Characters character;
    List<Monsters> monsters = [];

    //캐릭터, 몬스터 파일 유효성 검사
    try {
      //캐릭터 파일 로드 및 파일이 없는 경우 처리
      File characFile = File(characterFile);
      if (!characFile.existsSync()) {
        throw FileSystemException('캐릭터 파일을 찾을 수 없습니다.');
      }

      //캐릭터 파일 읽기 및 빈파일 처리
      List<String> characData = characFile.readAsLinesSync();
      if (characData.isEmpty) {
        throw FileSystemException('캐릭터 파일 데이터가 없습니다.');
      }

      //캐릭터 스탯을 int와 List로 변환, 요소가 적거나 많은 경우 오류 발생
      List<int> characStatus = characData[0].split(',').map(int.parse).toList();
      if (characStatus.length != 3) {
        throw FormatException('캐릭터 파일 데이터 형식이 잘못되었습니다.');
      }

      //캐릭터 명 입력 및 유효성 검사
      String characterName = '';
      while (characterName.isEmpty ||
          !RegExp(r'^[a-zA-Z가-힣]+$').hasMatch(characterName)) {
        stdout.write('캐릭터 이름을 입력해주세요 (한글, 영문 대소문자만 가능): ');
        characterName = stdin.readLineSync() ?? '';
        if (characterName.isEmpty ||
            !RegExp(r'^[a-zA-Z가-힣]+$').hasMatch(characterName)) {
          print('잘못된 이름입니다. 한글과 영문 대소문자만 입력 가능합니다.');
        }
      }

      //Characters 객체를 생성
      character = Characters(
        name: characterName,
        health: characStatus[0],
        attackDamage: characStatus[1],
        armor: characStatus[2],
      );

      //몬스터 파일 로드 및 파일이 없는 경우 처리
      File monFile = File(monsterFile);
      if (!monFile.existsSync()) {
        throw FileSystemException('몬스터 파일을 찾을 수 없습니다.');
      }

      //몬스터 파일 읽기 및 빈파일 처리
      List<String> monsterData = monFile.readAsLinesSync();
      if (monsterData.isEmpty) {
        throw FormatException('몬스터 파일 데이터가 없습니다.');
      }

      //몬스터 스탯을 int와 List로 변환, 요소가 적거나 많은 경우 오류 발생
      monsters = monsterData.map((line) {
        var parts = line.split(','); //데이터를 , 기준으로 나눔
        if (parts.length != 3) {
          throw FormatException('몬스터 파일 데이터 형식이 잘못되었습니다.');
        }
        //몬스터 데이터를 정수로 변환
        return Monsters(
          name: parts[0],
          health: int.parse(parts[1]),
          attackDamage: int.parse(parts[2]),
          armor: 0,
        );
      }).toList(); //리스트로 변환

      //Game.fromFiles 팩토리 생성자에서 Game 객체를 반환
      return Game(character: character, monsters: monsters);
    } catch (e) {
      print('데이터 로드 중 오류 발생: $e'); //이외의 상황에서 오류 문구 출력
      rethrow;
    }
  }

  //게임 시작
  void gameStart() {
    print('게임을 시작합니다.');
    //캐릭터 체력이 0 초과이거나 몬스터 리스트에 몬스터가 없을 때까지 반복
    while (character.health > 0 && monsters.isNotEmpty) {
      Monsters fightMonster = getRandomMonster(); //랜덤 몬스터 호출
      print('\n${character.name}이(가) ${fightMonster.name}과 전투를 시작합니다.');
      battle(fightMonster); //배틀 매서드 호출

      // 몬스터 처치 후 리스트에서 제거
      monsters.remove(fightMonster);

      //몬스터 리스트가 비어있지 않은 경우 진행
      //기존 if문 사용 시 루프가 진행되지 않고 빠져나가는 현상이 발생. while 문으로 변경
      if (monsters.isNotEmpty) {
        while (true) {
          // 반복문을 사용해 유효한 입력이 들어올 때까지 계속 질문
          print('\n다음 몬스터와 대결하시겠습니까?(y/n)');
          String? choice = stdin.readLineSync();

          if (choice == 'N' || choice == 'n') {
            print('\n게임이 종료됩니다.');
            while (true) {
              print('게임을 저장하시겠습니까?(y/n)');
              String? action = stdin.readLineSync();

              if (action != null && (action == 'y' || action == 'Y')) {
                saveResult('패배'); // 패배 결과를 저장
                return; // 유효한 입력이므로 루프 종료
              } else if (action != null && (action == 'n' || action == 'N')) {
                print('결과를 저장하지 않습니다.');
                return; // 유효한 입력이므로 루프 종료
              } else {
                print('\n잘못된 입력입니다. 다시 입력해주세요.');
                // 유효하지 않은 입력일 경우 루프가 계속 진행되어 다시 입력 요청
              }
            }
          } else if (choice == 'Y' || choice == 'y') {
            print('\n다음 몬스터와의 전투를 시작합니다!');
            break; // 유효한 입력이므로 루프 종료하고 다음 전투로 진행
          } else {
            print('\n잘못 입력했습니다. 다시 입력하세요.');
            // 유효하지 않은 입력이므로 루프가 계속 진행되어 다시 입력 요청
          }
        }
      }

      if (killedMonster == 3) {
        //몬스터 리스트 모두 처치 시
        print('\n모든 몬스터를 물리쳤습니다! ${character.name}이 게임에서 승리했습니다.');

        while (true) {
          print('게임을 저장하시겠습니까?(y/n)');
          String? action = stdin.readLineSync();

          if (action != null && (action == 'y' || action == 'Y')) {
            saveResult('승리'); // 승리 결과를 저장
            return; // 유효한 입력이므로 루프 종료
          } else if (action != null && (action == 'n' || action == 'N')) {
            print('결과를 저장하지 않습니다.');
            return; // 유효한 입력이므로 루프 종료
          } else {
            print('\n잘못된 입력입니다. 다시 입력해주세요.');
            // 유효하지 않은 입력일 경우 루프가 계속 진행되어 다시 입력 요청
          }
        }
      }
    }
  }

  // 랜덤으로 몬스터를 선택하고 처치한 몬스터는 다시 만나지 않도록
  Monsters getRandomMonster() {
    return monsters[Random().nextInt(monsters.length)];
  }

  //전투 매서드
  void battle(Monsters monster) {
    //캐릭터와 몬스터 둘 다 체력이 0보다 클 때 지속됨
    while (character.health > 0 && monster.health > 0) {
      //캐릭터와 몬스터 상태 출력
      character.showStatus();
      monster.showStatus();

      //캐릭터의 행동 선택
      print('\n행동을 선택하세요 (1: 공격하기, 2: 방어하기)');
      String? action = stdin.readLineSync();
      if (action == '1') {
        character.attackMonster(monster);
        character.armorDefend = false;
      } else if (action == '2') {
        character.defend(monster);
      } else {
        print('\n잘못된 입력입니다. 다시 입력해주세요.');
        continue;
      }

      //몬스터의 체력이 0보다 크고 캐릭터가 방어에 실패했을 때, 몬스터가 캐릭터를 공격
      if (monster.health > 0 && character.armorDefend == false) {
        monster.attackCharacter(character);
      }

      //캐릭터의 체력이 0보다 작거나 같을 때, 게임 결과값을 패배로 저장
      if (character.health <= 0) {
        print('\n${character.name}이(가) 체력이 0이 되어 패배했습니다.');

        while (true) {
          print('게임을 저장하시겠습니까?(y/n)');
          String? action = stdin.readLineSync();

          if (action != null && (action == 'y' || action == 'Y')) {
            saveResult('패배'); // 패배 결과를 저장
            return; // 유효한 입력이므로 루프 종료
          } else if (action != null && (action == 'n' || action == 'N')) {
            print('결과를 저장하지 않습니다.');
            return; // 유효한 입력이므로 루프 종료
          } else {
            print('\n잘못된 입력입니다. 다시 입력해주세요.');
            // 유효하지 않은 입력일 경우 루프가 계속 진행되어 다시 입력 요청
          }
        }
      }
    }
    if (monster.health <= 0) {
      print('${monster.name}이(가) 체력이 0이 되어 쓰러졌습니다.');
      killedMonster++;
    }
  }

  // 게임 결과 저장
  void saveResult(String result) {
    File resultFile = File('result.txt');
    String timestamp = DateTime.now().toString();
    resultFile.writeAsStringSync(
        '이름: ${character.name}, 체력: ${character.health}, 공격력: ${character.attackDamage}, '
        '방어력: ${character.armor}, 몬스터 킬 수: $killedMonster, 결과: $result, 저장 시간: $timestamp\n',
        mode: FileMode.append); // 기존 파일에 결과를 추가로 저장
    print('게임 결과가 저장되었습니다.');
  }
}