module bring.context;

import std.algorithm;
import std.array;
import std.digest;
static import std.file;
import std.path;
import std.stdio;
import std.string : toLower;

import bring.util;

interface Store {
    bool[] has(string[] hashes);
    ubyte[] get(string hash);
    void put(string hash, ubyte[] data);
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

    bool[] has(string[] hashes) {
        return hashes.map!(h => isFile(pathForHash(h))).array;
    }

    ubyte[] get(string hash) {
        return cast(ubyte[]) std.file.read(pathForHash(hash));
    }

    // XXX Don't require reading in memory
    void put(string hash, ubyte[] data) {
        std.file.write(pathForHash(hash), data);
    }
}

class Context {
    string gitRoot;
    Store store;
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
    ctx.store = new FSStore("~/.local/share/bringStore".expandTilde);
    return ctx;
}
