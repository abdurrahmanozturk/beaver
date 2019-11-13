#ifndef CARD_H
#define CARD_H

#include <iostream>

class Card
{
public:
  enum Rank
  {
    RANK_2,    //0
    RANK_3,
    RANK_4,
    RANK_5,
    RANK_6,
    RANK_7,
    RANK_8,
    RANK_9,
    RANK_10,
    RANK_JACK,
    RANK_QUEEN,
    RANK_KING,
    RANK_ACE,
    MAX_RANKS  //13
  };
  enum Suit
  {
    SUIT_CLUB,  //0
    SUIT_DIAMOND,
    SUIT_HEART,
    SUIT_SPADE,
    MAX_SUITS     //4
  };
private:
  Rank m_rank;
  Suit m_suit;
public:
  Card(Rank rank=RANK_2, Suit suit=SUIT_CLUB);
  void print() const;
  int getValue() const;
};

#endif
