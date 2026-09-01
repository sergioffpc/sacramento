#include <cstddef>

int main() {
  auto* values = new int[1];
  volatile std::size_t outside = 1;
  values[outside] = 42;  // Deliberate ASan instrumentation probe.
  delete[] values;
  return 0;
}
