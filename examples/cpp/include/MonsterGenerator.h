#ifndef MONSTERGENERATOR_H
#define MONSTERGENERATOR_H

#include "Monster.h"

class MonsterGenerator
{
public:
  static Monster generateMonster();
  static int getRandomNumber(int min, int max);
};

#endif
