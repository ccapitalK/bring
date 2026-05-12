// SPDX-FileCopyrightText: 2026 Sahan Fernando <sahan.h.fernando@gmail.com>
// SPDX-License-Identifier: GPL-2.0-only

module bring.commands.add;

import std.algorithm;
import std.exception;
static import std.file;
import std.stdio;

import bring.context;
import bring.hash;
import bring.util;

void add(Context ctx, string[] args) {
    foreach (path; args[1 .. $]) {
        enforce(!path.endsWith(BRHASH_FILE_EXT_WITH_DOT), "Can't stage bring hash file");
        if (!std.file.exists(path)) {
            writeln("Couldn't stage file ", ctx.relPathFor(path));
            continue;
        }
        auto hashData = hashFileContents(path).serialize;
        auto hashPath = path ~ BRHASH_FILE_EXT_WITH_DOT;
        std.file.write(hashPath, hashData);
    }
}
