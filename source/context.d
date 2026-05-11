// SPDX-FileCopyrightText: 2026 Sahan Fernando <sahan.h.fernando@gmail.com>
// SPDX-License-Identifier: GPL-2.0-only

module bring.context;

import std.algorithm;
import std.array;
import std.digest;
static import std.file;
import std.path;
import std.range;
import std.stdio;
import std.string : toLower;

import bring.util;

interface Store {
    bool[] has(string[] hashes);
    ubyte[] get(string hash);
    void putStream(string hash, ubyte[] delegate() nextChunk);
    // FIXME: This is so prone to bugs. Just use a scope interface object
    void put(Range)(string hash, Range chunks) if (isInputRange!(Range, ubyte[])) {
        bool isFirst = true;
        scope ubyte[] delegate() func = {
            if (chunks.empty) {
                return (ubyte[]).init; // Defensive, if someone calls this after the end of the range
            }
            // Note: This looks grody, but is needed because some ranges reuse the buffers
            if (!isFirst) {
                chunks.popFront();
                if (chunks.empty) {
                    return (ubyte[]).init;
                }
            }
            isFirst = false;
            return chunks.front;
        };
        putStream(hash, func);
    }
}

// TODO: Single syscall for this? Without an exception handler perhaps?
private bool isFile(string path) {
    return std.file.exists(path) && std.file.isFile(path);
}

class FSStore : Store {
    string rootPath;

    this(string rootPath) {
        this.rootPath = rootPath;
    }

    private string pathForHash(string hash) const {
        // FIXMEV0: Path escape
        return buildPath(rootPath, "blobs", hash.toLower);
    }

    override bool[] has(string[] hashes) {
        return hashes.map!(h => isFile(pathForHash(h))).array;
    }

    override ubyte[] get(string hash) {
        // FIXME: Stream this
        return cast(ubyte[]) std.file.read(pathForHash(hash));
    }

    void putStream(string hash, ubyte[] delegate() nextChunk) {
        auto file = File(pathForHash(hash), "wb");
        while (true) {
            auto chunk = nextChunk();
            if (chunk == []) {
                break;
            }
            file.rawWrite(chunk);
        }
    }
}

class Context {
    string gitRoot;
    Store store;

    string relPathFor(string path) const => relativePath(path, gitRoot);
}

string getGitRoot() {
    auto gitRoot = executeOrDie(["git", "rev-parse", "--show-toplevel"]);
    while (gitRoot.endsWith("\n")) {
        gitRoot = gitRoot[0 .. $ - 1];
    }
    return gitRoot;
}

Context setupContext() {
    auto gitRoot = getGitRoot();
    writeln("Root: ", gitRoot);
    auto ctx = new Context();
    ctx.gitRoot = gitRoot;
    // TODO: Factor this out
    auto storeDir = "~/.local/share/bringStore".expandTilde;
    ctx.store = new FSStore(storeDir);
    if (!std.file.exists(storeDir)) {
        std.file.mkdir(storeDir);
    }
    auto blobsDir = buildPath(storeDir, "blobs");
    if (!std.file.exists(blobsDir)) {
        std.file.mkdir(blobsDir);
    }
    return ctx;
}
