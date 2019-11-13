#include <iostream>
#include "Monster.h"
#include "MonsterGenerator.h"

Monster::Monster(MonsterType type, str_t name, str_t roar, int hp)
  : m_type(type),
    m_name(name),
    m_roar(roar),
    m_hp(hp)
{
}

const Monster::str_t Monster::getTypeString()
{
  switch (m_type)
  {
    case DRAGON: return "Dragon";
    case GOBLIN: return "Goblin";
    case OGRE: return "Ogre";
    case ORC: return "Orc";
    case SKELETON: return "Skeleton";
    case TROLL: return "Troll";
    case VAMPIRE: return "Vampire";
    case ZOMBIE: return "Zombie";

    return "Unknown";
  }
}

const void Monster::print()
{
  std::cout <<m_name<< " is a "<<getTypeString()<<" having "
            <<m_hp<<" hit points and saying "<<m_roar<< '\n';
}

int main(int argc, char const *argv[])
{
  srand(static_cast<unsigned int>(time(0)));
	Monster m = MonsterGenerator::generateMonster();
  m.print();
  return 0;
}
