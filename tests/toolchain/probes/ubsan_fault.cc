#include <limits>

int main(int argc, char**) {
  volatile int maximum = std::numeric_limits<int>::max();
  volatile int increment = argc;
  return maximum + increment;
}
