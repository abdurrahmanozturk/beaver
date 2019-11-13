#include <iostream>
#include <random>
#include <vector>
#include "Deck.h"
#include "Card.h"

Deck::Deck()
{
  m_cardIndex=0;
  for (size_t i = 0; i < Card::MAX_SUITS; i++)
  {
    for (size_t j = 0; j < Card::MAX_RANKS; j++)
    {
      m_deck[i*Card::MAX_RANKS+j]=Card(static_cast<Card::Rank>(j),static_cast<Card::Suit>(i));
    }
  }
  print();
  shuffle();
}

void Deck::print() const
{
  for (const auto &card : m_deck)
    {
      card.print();
      std::cout <<" ";
    }
    std::cout <<'\n';

}

void Deck::swapCard(Card &card1, Card &card2)
{
  Card temp = card1;   // dont create an empty class like Card temp;
  card1=card2;
  card2=temp;
}

int Deck::getRandomNumber()
{
  std::random_device rd;
	std::mt19937 mersenne(rd()); // Create a mersenne twister, seeded using the random device
	std::uniform_int_distribution<> die(0, Card::MAX_SUITS*Card::MAX_RANKS); // generate random numbers between min and max
  return die(mersenne);
}

void Deck::reset()
{
  m_cardIndex = 0;
  m_dealer.clear();
  m_player.clear();
}

void Deck::shuffle()
{
  for (size_t i=0; i<(Card::MAX_SUITS*Card::MAX_RANKS); ++i)
  {
    swapCard(m_deck[i],m_deck[getRandomNumber()]);
  }
  reset();
  std::cout<<"Deck is shuffled."<<'\n';
  print();
}

const Card& Deck::dealCard()
{
  m_deck[m_cardIndex].print();
  std::cout<<'\n';
  return m_deck[m_cardIndex++];
}

// const Card& Deck::toDealer()
// {
//   std::cout<<m_dealer.size()<<'\n';
//   std::cout<<"tD1"<<'\n';
//   m_dealer.push_back(m_deck[m_cardIndex]);
//   std::cout<<"tD3"<<'\n';
//   return m_deck[m_cardIndex++];
// }
//
// void Deck::dealerHand() const
// {
//   std::cout<<" Dealer Hand"<<'\n';
//   for (auto &card : m_dealer)
//   {
//     card.print();
//   }
//   std::cout<<'\n';
// }
//
// const Card& Deck::toPlayer()
// {
//   m_player.push_back(m_deck[m_cardIndex]);
//   m_deck[m_cardIndex].print();
//   return m_deck[m_cardIndex++];
// }
// void Deck::playerHand() const
// {
//   std::cout<<" Player Hand"<<'\n';
//   for (auto &card : m_player)
//   {
//     card.print();
//   }
//   std::cout<<'\n';
// }
