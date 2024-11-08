import 'monster.dart';
import 'dart:math';

class Characters {
  String name;
  int health;
  int attackDamage;
  int armor;
  bool armorDefend;

  Characters({
    required this.name,
    required this.health,
    required this.attackDamage,
    required this.armor,
    this.armorDefend = false,
  });

  void attackMonster(Monsters monster) {
    int damagePercent = Random().nextInt(21) + 100; //공격력을 랜덤하게 지정 100~120
    int damage = (attackDamage * (damagePercent / 100))
        .round(); //round를 넣어 소수점 아래 값은 반올림하여 정수로 변환
    damage = max(0, damage - monster.armor); //max를 사용해 공격력 최소 0 이상 설정
    monster.health =
        max(0, monster.health - damage); //max를 사용해 몬스터 체력의 최소값을 0으로 설정
    print(
        '$name이(가) ${monster.name}에게 $damage의 데미지를 입혔습니다.'); //캐릭터가 몬스터에게 얼마의 데미지를 입혔는지 출력
  }

  void defend(Monsters monster) {
    // 방어 성공 여부를 결정하는 랜덤 확률 (0 ~ 100)
    int reflect = Random().nextInt(101);

    if (reflect <= 30) {
      // 30% 확률로 방어 성공
      int reflectPercent = Random().nextInt(20) + 20; // 반격 데미지 비율 (20 ~ 40%)
      int reflectDamage =
          (monster.attackDamage * (reflectPercent / 100)).round();

      // 방어력에 따라 추가 반격 데미지 증가
      reflectDamage += (armor * 0.1).round(); // 방어력의 10% 추가 반영
      monster.health = max(0, monster.health - reflectDamage);

      // 방어 성공 시 체력 회복 (체력의 5%)
      int healthRecovery = (health * 0.05).round();
      health = min(health + healthRecovery, 100); // 체력은 100을 넘지 않도록 제한

      print(
          '$name이(가) 방어에 성공하여 ${monster.name}에게 $reflectDamage의 반격 데미지를 입혔습니다.');
      print('$name이(가) 방어 성공으로 체력을 $healthRecovery 회복하여 현재 체력: $health');

      armorDefend = true;
    } else {
      // 방어 실패 처리
      print('$name이(가) 방어에 실패했습니다.');
      armorDefend = false;

      // 방어 실패 시 몬스터가 공격을 가함
      //monster.attackCharacter(this);  // 캐릭터가 몬스터의 공격을 받음
    }
  }

  //캐릭터 현재 상태 출력
  void showStatus() {
    print('\n$name 상태 - 체력: $health | 공격력: $attackDamage | 방어력: $armor');
  }
}