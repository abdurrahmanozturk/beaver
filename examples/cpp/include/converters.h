#ifndef CONVERTERS_H     // prevents duplications (preprocessing)
#define CONVERTERS_H     // defines header

namespace myConverters
{
  int decimalToBinary(int x)
  {
    std::cout << "The binary representation of " <<x<<" is ";
    int count=static_cast<int>(log2(x));
    int bin[count];
    for (int i = count; i>=0; i--)
    {
      if (x>=pow(2,i)) {
        x-=pow(2,i);
        bin[i]=1;
        // std::cout << "1";
      } else
        bin[i]=0;
        // std::cout << "0";
    }
    for (int i = count; i >=0; i--)
    {
      std::cout << bin[i];
    }
    std::cout <<'\n';
  }
  int hexToRGB()
  {
    const unsigned int redBits = 0xFF000000;
    const unsigned int greenBits = 0x00FF0000;
    const unsigned int blueBits = 0x0000FF00;
    const unsigned int alphaBits = 0x000000FF;

    std::cout << "Enter a 32-bit RGBA color value in hexadecimal (e.g. FF7F3300): ";
    unsigned int pixel;
    std::cin >> std::hex >> pixel; // std::hex allows us to read in a hex value

    // use bitwise AND to isolate red pixels, then right shift the value into the range 0-255
    unsigned char red = (pixel & redBits) >> 24;
    unsigned char green = (pixel & greenBits) >> 16;
    unsigned char blue = (pixel & blueBits) >> 8;
    unsigned char alpha = pixel & alphaBits;

    std::cout << "Your color contains:\n";
    std::cout << static_cast<int>(red) << " of 255 red\n";
    std::cout << static_cast<int>(green) << " of 255 green\n";
    std::cout << static_cast<int>(blue) << " of 255 blue\n";
    std::cout << static_cast<int>(alpha) << " of 255 alpha\n";
  }
}
#endif
