// SPDX-License-Identifier: GPL-2.0-only

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
    writefln!"%d files tracked.\n"(paths.length);
    bool hasChanges;
    foreach (path; paths.byKey) {
        auto relpath = ctx.relPathFor(path);
        // FIXME: Rethink this, so that we don't keep stat-ing the same files
        if (!std.file.exists(path)) {
            writeln("Deleted: ", relpath);
            hasChanges = true;
            continue;
        }
        auto hashOnDisk = path.getFileDataHashWithCaching;
        enforce(hashOnDisk.algorithm == HashAlgorithm.sha1);
        auto hashHexAsTracked = paths[path].hashHex;
        if (hashOnDisk.hashHex != hashHexAsTracked) {
            writeln("Modified: ", relpath);
            hasChanges = true;
            continue;
        }
        if (!isHashResident[hashHexAsTracked]) {
            writeln("Not pushed: ", relpath);
            hasChanges = true;
        }
    }
    if (!hasChanges) {
        writeln("All files present and unmodified.");
    }
}
