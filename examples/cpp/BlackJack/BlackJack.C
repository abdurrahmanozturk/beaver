#include <iostream>
#include <ctime>
#include "BlackJack.h"
#include "Card.h"
#include "Deck.h"

bool hit()
{
  while (true)
  {
    std::cout << "hit(h) or stand(s) " << '\n';
    char x;
    std::cin >> x;
    if (std::cin.fail())
    {
      std::cin.clear();
      std::cin.ignore(32767,'\n');
    }
    else
    {
      std::cin.ignore(32767,'\n');
      if (x=='h')
        return true;
      else
        return false;
    }
  }
}

bool playAgain(Deck &deck)
{
  std::cout << "Do you want to play again? y or n" << '\n';
  char playagain;
  std::cin >> playagain;
  if (playagain=='y')
  {
      deck.shuffle();
      return true;
  }
  else
    return false;
}

bool play(Deck &deck)
{
  int dealerSum = deck.dealCard().getValue();
  int playerSum = deck.dealCard().getValue();
  playerSum += deck.dealCard().getValue();
  std::cout << "Player = "<<playerSum<< '\n';
  std::cout << "Dealer = " <<dealerSum<<'\n';
  if (playerSum==21)
  {
    std::cout << "Black Jack!" << '\n';
    return true;
  }
  while (hit())
  {
    playerSum += deck.dealCard().getValue();
    std::cout << "Player = "<<playerSum<< '\n';
    std::cout << "Dealer = " <<dealerSum<<'\n';
    if (playerSum==21)
    {
      std::cout << "Black Jack!" << '\n';
      return true;
    }
    if (playerSum>21)
      return false;
  }
  dealerSum += deck.dealCard().getValue();
  std::cout << "Player = "<<playerSum<< '\n';
  std::cout << "Dealer = " <<dealerSum<<'\n';
  if (dealerSum<17)
  {
    dealerSum += deck.dealCard().getValue();
    std::cout << "Player = "<<playerSum<< '\n';
    std::cout << "Dealer = " <<dealerSum<<'\n';
    if (dealerSum>21)
    {
      return true;
    }
    else
    {
      if (playerSum>dealerSum || playerSum==dealerSum)
        return true;
      else
        return false;
    }
  }
  else
  {
    if (playerSum>dealerSum || playerSum==dealerSum)
      return true;
    else
      return false;
  }

}

int main(int argc, char const *argv[])
{
  std::cout << "-----------------------------------------------------" << '\n';
  std::cout << "-                    BLACK JACK                     -" << '\n';
  std::cout << "-----------------------------------------------------" << '\n';
  Deck deck;
  do
  {
    if (play(deck))
    {
      std::cout << "You won!" << '\n';
    }
    else
    {
      std::cout << "You lost!" << '\n';
    }
  } while (playAgain(deck));
  std::cout << "Thanks for playing." << '\n';
  return 0;
}
