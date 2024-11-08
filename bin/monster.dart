import 'character.dart';
import 'dart:math';

class Monsters {
  String name;
  int health;
  int attackDamage;
  int armor;

  Monsters({
    required this.name,
    required this.health,
    required this.attackDamage,
    required this.armor,
  });

  //몬스터가 캐릭터를 공격
  void attackCharacter(Characters character) {
    if (!character.armorDefend) {
      int damagePercent = Random().nextInt(21) + 80; //공격에 랜덤값 부여
      int damage =
          (attackDamage * (damagePercent / 100)).round(); //round를 사용하여 정수로 변환
      int maxDamage = max(damage, character.armor + 1);
      //max를 사용해 몬스터 공격력의 최소 값을 캐릭터 방어력 +1로 설정
      int monsterDamage = maxDamage - character.armor;
      character.health =
          max(0, character.health - monsterDamage); //캐릭터에게 공격된 값 계산
      print('${character.name}이(가) $name에게 $monsterDamage의 피해를 입었습니다.'); //상태 출력
    }
  }

  //몬스터 현재 상태 출력
  void showStatus() {
    print('$name 상태 - 체력: $health | 공격력: $attackDamage\n');
  }
}