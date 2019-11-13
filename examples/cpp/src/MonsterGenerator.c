#include "MonsterGenerator.h"
#include "Monster.h"
#include <ctime>
#include <cstdlib>

int MonsterGenerator::getRandomNumber(int min, int max)
{
  static const double fraction = 1.0 / (static_cast<double>(RAND_MAX) + 1.0);
  return static_cast<int>(rand() * fraction * (max - min + 1) + min);
}

Monster MonsterGenerator::generateMonster()
{
  static Monster::str_t s_names[6]={"Glety","Dweart","Munbun","Pirte","Jaliya","Ortok"};
  static Monster::str_t s_roars[6]={"*cliyt*","*huaah*","*numnum*","*pirpir*","*cisst*","*Oooor*"};
  int rnd_type=getRandomNumber(0,Monster::MAX_MONSTER_TYPES-1);
  int rnd_name=getRandomNumber(0,5);
  int rnd_roar=getRandomNumber(0,5);
  int rnd_hp=getRandomNumber(1,100);
  return Monster(static_cast<Monster::MonsterType>(rnd_type),s_names[rnd_name], s_roars[rnd_roar],rnd_hp);
}
