module bring.util;

import std.algorithm;
import std.exception;
import std.format;
import std.process;
import std.range;

string executeOrDie(string[] cmd) {
    auto res = execute(cmd);
    enforce(res.status == 0, cmd.format!"Failed to execute %s");
    return res.output;
}

string removeSuffix(string s, string suffix) {
    enforce(s.endsWith(suffix));
    return s[0 .. $ - suffix.length];
}

void[0][T] toSet(T, U)(U val) if (isInputRange!(U)) {
    void[0][T] m;
    foreach (v; val) {
        m[v] = [];
    }
    return m;
}
