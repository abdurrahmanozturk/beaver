#include <iostream>
#include "Card.h"

Card::Card(Rank rank, Suit suit)
  : m_rank(rank),
    m_suit(suit)
{
}

void Card::print() const
{
  switch (m_rank)
  {
    case RANK_2:      std::cout << "2"; break;
    case RANK_3:      std::cout << "3"; break;
    case RANK_4:      std::cout << "4"; break;
    case RANK_5:      std::cout << "5"; break;
    case RANK_6:      std::cout << "6"; break;
    case RANK_7:      std::cout << "7"; break;
    case RANK_8:      std::cout << "8"; break;
    case RANK_9:      std::cout << "9"; break;
    case RANK_10:     std::cout << "T"; break;
    case RANK_JACK:   std::cout << "J"; break;
    case RANK_QUEEN:  std::cout << "Q"; break;
    case RANK_KING:   std::cout << "K"; break;
    case RANK_ACE:    std::cout << "A"; break;
  }
  switch (m_suit)
  {
    case SUIT_CLUB:      std::cout << "C"; break;
    case SUIT_DIAMOND:   std::cout << "D"; break;
    case SUIT_HEART:     std::cout << "H"; break;
    case SUIT_SPADE:     std::cout << "S"; break;
  }
  std::cout <<" ";
}

int Card::getValue() const
{
  switch (m_rank)
  {
    case RANK_2:      return 2;
    case RANK_3:      return 3;
    case RANK_4:      return 4;
    case RANK_5:      return 5;
    case RANK_6:      return 6;
    case RANK_7:      return 7;
    case RANK_8:      return 8;
    case RANK_9:      return 9;
    case RANK_10:
    case RANK_JACK:
    case RANK_QUEEN:
    case RANK_KING:   return 10;
    case RANK_ACE:    return 11;
  }
  std::cout << "Error: returned to 0!" << '\n';
  return 0;
}
