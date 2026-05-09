module bring.commands.status;

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

void status(Context ctx, string[] args) {
    auto paths = ctx.gitRoot.allHashPaths();
    auto isHashResident = ctx.checkResidence(paths);
    foreach (path; paths.byKey) {
        auto hashOnDisk = path.hashFileContents;
        enforce(hashOnDisk.algorithm == HashAlgorithm.sha1);
        auto hashHexAsTracked = paths[path].hashHex;
        if (hashOnDisk.hashHex != hashHexAsTracked) {
            writeln("Modified: ", path);
            continue;
        }
        if (!isHashResident[hashHexAsTracked]) {
            writeln("Not pushed: ", path);
        }
    }
}
