module bring.commands.sync;

import std.algorithm;
import std.exception;
static import std.file;
import std.format;
import std.path;
import std.process;
import std.range;
import std.stdio;

import bring.context;
import bring.hash;
import bring.util;
import bring.worktree;

void sync(Context ctx, string[] args) {
    auto paths = ctx.gitRoot.allHashPaths();
    auto isHashResident = ctx.checkResidence(paths);
    foreach (path; paths.byKey) {
        auto hashOnDisk = path.hashFileContents;
        enforce(hashOnDisk.algorithm == HashAlgorithm.sha1);
        auto hashHexAsTracked = paths[path].hashHex;
        if (hashOnDisk.hashHex != hashHexAsTracked) {
            writeln("Warning: Skipping modified file ", path);
            continue;
        }
        writeln("Syncing ", path);
        ctx.store.put(hashHexAsTracked, cast(ubyte[]) std.file.read(path));
    }
}
