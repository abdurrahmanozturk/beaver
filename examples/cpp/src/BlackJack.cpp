#include <iostream>
#include <vector>
#include <string>
#include <array>
#include <random>

typedef std::string str_t;

enum CardRank
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

enum CardSuit
{
  SUIT_CLUBS,  //0
  SUIT_DIAMONDS,
  SUIT_HEARTS,
  SUIT_SPADES,
  MAX_SUITS     //4
};

struct Card
{
  CardRank rank;
  CardSuit suit;
};

void printCard(const Card &card)
{
  switch (card.rank)
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
  switch (card.suit)
  {
    case SUIT_CLUBS:      std::cout << "C"; break;
    case SUIT_DIAMONDS:   std::cout << "D"; break;
    case SUIT_HEARTS:     std::cout << "H"; break;
    case SUIT_SPADES:     std::cout << "S"; break;
  }
  std::cout <<" ";
}

void printDeck(const auto &deck)
{
  for (const auto &card : deck)
    {
      printCard(card);
      std::cout <<" ";
    }
    std::cout <<'\n';
}

void swapCard(Card &card1, Card &card2)
{
  Card temp;
  temp = card1;
  card1=card2;
  card2=temp;
}

void shuffleDeck(auto &deck)
{
  std::random_device rd;
	std::mt19937 mersenne(rd()); // Create a mersenne twister, seeded using the random device
	std::uniform_int_distribution<> die(0, MAX_SUITS*MAX_RANKS); // generate random numbers between min and max
  for (size_t i=0; i<(MAX_SUITS*MAX_RANKS); ++i)
  {
    swapCard(deck[i],deck[die(mersenne)]);
  }
}

bool getHitOrStand()
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

int getCardValue(const Card &card)
{
  switch (card.rank)
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

bool playBlackJack(const auto &deck)
{
  const Card *cardPtr = &deck[0];
  int dealerSum{getCardValue(*cardPtr++)};
  int playerSum{getCardValue(*cardPtr++) + getCardValue(*cardPtr++)};
  std::cout << "Dealer = " <<dealerSum<<'\n';
  std::cout << "Player = "<<playerSum<< '\n';
  if (playerSum==21)
  {
    std::cout << "Black Jack!" << '\n';
    return true;
  }
  while (getHitOrStand())
  {
    playerSum+=getCardValue(*cardPtr++);
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
  dealerSum+=getCardValue(*cardPtr++);
  std::cout << "Player = "<<playerSum<< '\n';
  std::cout << "Dealer = " <<dealerSum<<'\n';
  if (dealerSum<17)
  {
    dealerSum+=getCardValue(*cardPtr++);
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

bool playAgain()
{
  std::cout << "Do you want to play again? y or n" << '\n';
  char playagain;
  std::cin >> playagain;
  if (playagain=='y')
    return 1;
  else
    return 0;
}

int main ()
{
  std::cout << "-----------------------------------------------------" << '\n';
  std::cout << "-                    BLACK JACK                     -" << '\n';
  std::cout << "-----------------------------------------------------" << '\n';
  const int maxCards=MAX_SUITS*MAX_RANKS;
  std::array<Card,maxCards> deck;
  for (size_t i = 0; i<MAX_SUITS; ++i)
  {
    for (size_t j = 0; j < MAX_RANKS; j++)
    {
      deck[i*MAX_RANKS+j].rank = static_cast<CardRank>(j);
      deck[i*MAX_RANKS+j].suit = static_cast<CardSuit>(i);
      // printCard(deck[i*MAX_RANKS+j]);
    }
  }
  do
  {
    shuffleDeck(deck);
    // printDeck(deck);
    if (playBlackJack(deck))
    {
      std::cout << "You won!" << '\n';
    }
    else
    {
      std::cout << "You lost!" << '\n';
    }
  } while (playAgain());
  std::cout << "Thanks for playing." << '\n';
  return 0;
}
