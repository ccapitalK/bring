// SPDX-FileCopyrightText: 2026 Sahan Fernando <sahan.h.fernando@gmail.com>
// SPDX-License-Identifier: GPL-2.0-only

module bring.commands.push;

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

void push(Context ctx, string[] args) {
    auto paths = ctx.gitRoot.allHashPaths();
    auto isHashResident = ctx.checkResidence(paths);
    foreach (path; paths.byKey) {
        auto relpath = ctx.relPathFor(path);
        auto hashOnDisk = path.getFileDataHashWithCaching;
        enforce(hashOnDisk.algorithm == HashAlgorithm.sha1);
        auto hashHexAsTracked = paths[path].hashHex;
        if (hashOnDisk.hashHex != hashHexAsTracked) {
            writeln("Warning: Skipping modified file ", relpath);
            continue;
        }
        if (isHashResident[hashHexAsTracked]) {
            continue;
        }
        writeln("Syncing ", relpath);
        auto file = File(path, "rb");
        ctx.store.put(hashHexAsTracked, file.byChunk(READBUF_SIZE));
    }
}
