#include <iostream>
#include <string>

class Greeter {
public:
    Greeter(const std::string& name) : name_(name) {}
    void greet() const {
        std::cout << "C++ Greeter says: Hello, " << name_ << "!" << std::endl;
    }
private:
    std::string name_;
};

extern "C" {
    void* greeter_new(const char* name) {
        return new Greeter(name);
    }
    void greeter_greet(void* greeter) {
        static_cast<Greeter*>(greeter)->greet();
    }
    void greeter_delete(void* greeter) {
        delete static_cast<Greeter*>(greeter);
    }
}
