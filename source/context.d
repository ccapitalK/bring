// SPDX-FileCopyrightText: 2026 Sahan Fernando <sahan.h.fernando@gmail.com>
// SPDX-License-Identifier: GPL-2.0-only

module bring.context;

import std.algorithm;
static import std.file;
import std.path;
import std.range;
import std.stdio;
import std.string : toLower;

import bring.util;

interface Store {
    /// Batch hash presence query api. Takes a list of hashes, returns a list of isPresent for each query.
    bool[] has(string[] hashes);
    // Get the binary data for a given hash, as a stream of data chunks
    void getStream(string hash, void delegate(ubyte[]) onChunk);
    // Write the binary data for a given hash, provided as a stream of data chunks
    void putStream(string hash, ubyte[]delegate() nextChunk);
}

// FIXME: This is so prone to bugs. Just use a scope interface object
void put(Range)(Store store, string hash, Range chunks)
        if (isInputRange!(Range, ubyte[])) {
    bool isFirst = true;
    scope ubyte[]delegate() func = {
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
    store.putStream(hash, func);
}

// FIXME: This is so prone to bugs. Just use a scope interface object
ubyte[] get(Store store, string hash) {
    auto builder = appender!(ubyte[])([]);
    store.getStream(hash, (ubyte[] data) {
        builder.put(data);
    });
    return builder.data;
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
        return hashes.map!(h => existsAndIsFile(pathForHash(h))).array;
    }

    override void getStream(string hash, void delegate(ubyte[]) onChunk) {
        auto file = File(pathForHash(hash), "rb");
        foreach (chunk; file.byChunk(READBUF_SIZE) ) {
            onChunk(chunk);
        }
        onChunk([]);
    }

    void putStream(string hash, ubyte[]delegate() nextChunk) {
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
