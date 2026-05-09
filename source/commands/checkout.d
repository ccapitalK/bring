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
        enforce(ctx.store.has([path]), "Tried to fetch non-existent hash");
        auto hashPath = path ~ BRHASH_FILE_EXT_WITH_DOT;
        auto hashData = hashPath.readBringHash();
        auto data = ctx.store.get(hashData.hashHex);
        std.file.write(path, data);
    }
}
