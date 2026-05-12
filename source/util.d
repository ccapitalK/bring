// SPDX-FileCopyrightText: 2026 Sahan Fernando <sahan.h.fernando@gmail.com>
// SPDX-License-Identifier: GPL-2.0-only

module bring.util;

import std.algorithm;
import std.exception;
static import std.file;
import std.format;
import std.process;
import std.range;

enum BRHASH_FILE_EXT = "brhash";
enum BRHASH_FILE_EXT_WITH_DOT = "." ~ BRHASH_FILE_EXT;

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

// TODO: Single syscall for this? Without an exception handler perhaps?
bool existsAndIsFile(string path) {
    return std.file.exists(path) && std.file.isFile(path);
}

// FIXME: Make this more robust, different paths for different OS, kernel timesource
void updateTimestampToNow(string path) {
    import std.datetime;
    auto now = Clock.currTime;
    std.file.setTimes(path, now, now);
}

enum READBUF_SIZE = 512 * 1024;
