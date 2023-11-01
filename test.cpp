#include <iostream>
#include <expected>
#include <unordered_map>

#define STRINGIFY(x) #x
#define TOSTRING(x) STRINGIFY(x)

int main(int arc, char** argv) {
    std::expected<long, char> v{__cplusplus};
    std::string omp = "N/A";
    #ifdef _OPENMP
        std::unordered_map<int, std::string> map{
            {200505,"2.5"},{200805,"3.0"},{201107,"3.1"},{201307,"4.0"},{201511,"4.5"},{201811,"5.0"},{202011,"5.1"}};

        omp = map.at(_OPENMP) + " (" + TOSTRING(_OPENMP) + ")";
    #endif

    if (v.has_value()) {
        std::cout << "C++ " << v.value() << std::endl;
    }
    std::cout << "OpenMP: " << omp  << std::endl;

    return 0;
}