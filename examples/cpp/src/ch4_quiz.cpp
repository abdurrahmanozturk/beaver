#include <iostream>
#include <string>

typedef std::string str_t;
typedef double health_t;
enum class MonsterType
{
  OGRE,         //0
  DRAGON,       //1
  ORC,          //2
  GIANT_SPIDER, //3
  SLIME,        //4
  UNKNOWN       //5
};

struct Monster
{
  MonsterType type;  //monster type
  str_t name;  //monster name
  health_t health; // monster health
};

str_t getMonsterType(Monster monster)
{
  if (monster.type==MonsterType::OGRE)  {
    return "Ogre";
  }
  else if (monster.type==MonsterType::DRAGON)  {
    return "Dragon";
  }
  else if (monster.type==MonsterType::ORC)  {
    return "Orc";
  }
  else if (monster.type==MonsterType::GIANT_SPIDER)  {
    return "Giant Spider";
  }
  else if (monster.type==MonsterType::SLIME)  {
    return "Slime";
  }
  else
    return "Unknown monster";
}

void printMonster(Monster monster)  //print monster stats
{
  std::cout <<"This "<<getMonsterType(monster)
            <<" is named "<<monster.name
            <<" has "<<monster.health<<" health"<< '\n';
}

int main()
{
  Monster ogre{MonsterType::OGRE,"Iritor",145.01};
  Monster slime{MonsterType::SLIME,"Garopuza",79.01};
  printMonster(ogre);
  printMonster(slime);
  return 0;
}
