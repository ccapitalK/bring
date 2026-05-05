module bring.context;

import std.algorithm;
import std.array;
import std.digest;
static import std.file;
import std.path;
import std.stdio;

import bring.util;

interface Store {
    bool[] has(string[] hashes);
    ubyte[] get(string hash);
    void put(string hash, ubyte[] data);
}

class FSStore : Store {
    string rootPath;

    this(string rootPath) {
        this.rootPath = rootPath;
    }

    private string pathForHash(string hash) const {
        // FIXMEV0: Path escape
        return buildPath(rootPath, "blobs", hash);
    }

    bool[] has(string[] hashes) {
        return hashes.map!(h => std.file.isFile(pathForHash(h))).array;
    }

    ubyte[] get(string hash) {
        return cast(ubyte[]) std.file.read(pathForHash(hash));
    }

    void put(string hash, ubyte[] data) {
        std.file.write(pathForHash(hash), data);
    }
}

class Context {
    string gitRoot;
    Store store;
}

Context setupContext() {
    auto gitRoot = executeOrDie(["git", "rev-parse", "--show-toplevel"]);
    writeln("Root: ", gitRoot);
    auto ctx = new Context();
    ctx.gitRoot = gitRoot;
    ctx.store = new FSStore("~/.local/share/bringStore".expandTilde);
    return ctx;
}
