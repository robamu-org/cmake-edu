#include <iostream>

#include "foo/foo.h"

using namespace std;

namespace foo {
    void magic() {
        cout << "foo::magic was called" << endl;
    }
}