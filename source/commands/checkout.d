// SPDX-FileCopyrightText: 2026 Sahan Fernando <sahan.h.fernando@gmail.com>
// SPDX-License-Identifier: GPL-2.0-only

module bring.commands.checkout;

import std.algorithm;
import std.exception;
static import std.file;
import std.stdio;

import bring.context;
import bring.hash;
import bring.util;
import bring.worktree;

void checkout(Context ctx, string[] args) {
    foreach (path; args[1 .. $]) {
        if (path.endsWith(BRHASH_FILE_EXT_WITH_DOT)) {
            path = path.removeSuffix(BRHASH_FILE_EXT_WITH_DOT);
        }
        enforce(!path.endsWith(BRHASH_FILE_EXT_WITH_DOT), "Can't nest brhash extensions");
        auto hashPath = path ~ BRHASH_FILE_EXT_WITH_DOT;
        if (!std.file.exists(hashPath)) {
            writeln("Warn: Tried to checkout non-existent file");
            continue;
        }
        auto hashData = hashPath.readBringHash();
        enforce(ctx.store.has([hashData.hashHex])[0], "Tried to fetch non-existent hash");
        {
            auto outFile = File(path, "wb");
            ctx.store.getStream(hashData.hashHex, (ubyte[] chunk) {
                if (chunk.length > 0) {
                    outFile.rawWrite(chunk);
                }
            });
        }
        updateTimestampToNow(hashPath);
    }
}
