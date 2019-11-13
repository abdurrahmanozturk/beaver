#include <iostream>
#include <random>

int getValidNumber(int i)
{
  while (true)
  {
    std::cout << "Your number "<<i<<" is: ";
    int x;
    std::cin >> x;
    if (std::cin.fail())
    {
      std::cin.clear();
      std::cin.ignore(32767,'\n');
    }
    else
    {
      std::cin.ignore(32767,'\n');
      return x;
    }
  }
}

bool playGame(int count,int luckynum)
{
  for (size_t i = 1; i <= count; i++)
  {
    int x{getValidNumber(i)};
    if (x>luckynum)
      std::cout << "High" << '\n';
    else if (x<luckynum)
      std::cout << "Low" << '\n';
    else
      return true;
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

int main()
{
  std::random_device rd;
	std::mt19937 mersenne(rd()); // Create a mersenne twister, seeded using the random device
	std::uniform_int_distribution<> die(0, 1); // generate random numbers between min and max
  do
    {
    int luckynum=die(mersenne);
    int count{7};
    std::cout << "-------------------------------------------------------------------------" << '\n';
    std::cout << "* This is a hi-lo game, you will have 7 tries to find the secret number *" << '\n';
    std::cout << "-------------------------------------------------------------------------" << '\n';
    bool won=playGame(count,luckynum);
    if (won==1)
      std::cout << "\a\aYou Won!\a\a" << '\n';
    else
      std::cout << "You lost. It was " <<luckynum<< '\n';
    }
    while (playAgain());
  std::cout << "Thanks for playing." << '\n';
  return 0;
}
