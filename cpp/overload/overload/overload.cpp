#include <iostream>

int add(int x, int y)
{
    return x + y;
}

int add(int x, int y, int z)
{
    return x + y + z;
}

int main()
{
    std::cout << add(1, 2, 3);
}