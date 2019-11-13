#ifndef DECK_H
#define DECK_H

#include <iostream>
#include <array>
#include <vector>
#include "Card.h"

class Deck
{
private:
  typedef std::vector<Card> cardVec_t;
  int m_cardIndex;
  std::array<Card,52> m_deck;
  cardVec_t m_dealer;
  cardVec_t m_player;
  static void swapCard(Card &card1, Card &card2);
  static int getRandomNumber();
public:
  Deck();
  const Card& dealCard();
  void print() const;
  void shuffle();
  void reset();
  // const Card& toDealer();
  // const Card& toPlayer();
  // void dealerHand() const;
  // void playerHand() const;
};

#endif
