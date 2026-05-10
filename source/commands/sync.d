// SPDX-License-Identifier: GPL-2.0-only

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
        auto hashOnDisk = path.getFileDataHashWithCaching;
        enforce(hashOnDisk.algorithm == HashAlgorithm.sha1);
        auto hashHexAsTracked = paths[path].hashHex;
        if (hashOnDisk.hashHex != hashHexAsTracked) {
            writeln("Warning: Skipping modified file ", path);
            continue;
        }
        if (isHashResident[hashHexAsTracked]) {
            continue;
        }
        writeln("Syncing ", path);
        auto file = File(path, "rb");
        ctx.store.put(hashHexAsTracked, file.byChunk(512 * 1024));
    }
}
