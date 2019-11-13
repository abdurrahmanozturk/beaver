#ifndef MONSTER_H
#define MONSTER_H

#include <string>

class Monster
{
public:
  typedef std::string str_t;
  enum MonsterType
  {
    DRAGON,
    GOBLIN,
    OGRE,
    ORC,
    SKELETON,
    TROLL,
    VAMPIRE,
    ZOMBIE,
    MAX_MONSTER_TYPES
  };
private:
  MonsterType m_type;
  str_t m_name;
  str_t m_roar;
  int m_hp;
public:
  Monster(MonsterType type, str_t name, str_t roar, int hp);
  const str_t getTypeString();
  const void print();
};


#endif
