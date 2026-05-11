// SPDX-FileCopyrightText: 2026 Sahan Fernando <sahan.h.fernando@gmail.com>
// SPDX-License-Identifier: GPL-2.0-only

module bring.worktree;

import std.algorithm;
import std.exception;
static import std.file;
import std.path;
import std.range;
import std.stdio;

import bring.context;
import bring.hash;
import bring.util;

// FIXME: std.file.dirEntries eagerly call fsstat. This could be worked around for .brhash files,
// but there is no way to just walk the dirs without also seeing the files.

// Returns mapping from path to hash, for each tracked file in the repo
BringHash[string] allHashPaths(string gitRoot) {
    BringHash[string] m;
    void visit(string path) {
        try {
            foreach (entry; std.file.dirEntries(path, std.file.SpanMode.shallow)) {
                // TODO: Parse and handle Gitignore. Warn if gitignoring .brhash but not the corresponding file
                if (entry.isDir) {
                    if (entry.name.baseName != ".git") {
                        visit(entry.name);
                    }
                    continue;
                }

                // TODO: Think through proper behaviour for symlinks. For now we always refuse to follow them
                if (!entry.isFile) {
                    continue;
                }

                if (!entry.name.endsWith(BRHASH_FILE_EXT_WITH_DOT)) {
                    continue;
                }
                auto trackedFilePath = entry.name.removeSuffix(BRHASH_FILE_EXT_WITH_DOT);
                auto hash = readBringHash(entry.name);

                // FIXME: Graceful error handling for this
                enforce(!trackedFilePath.endsWith(BRHASH_FILE_EXT_WITH_DOT), "Can't nest brhash extensions");
                m[trackedFilePath] = hash;
            }
            // FIXME: Catch other exceptions here
        } catch (std.file.FileException e) {
            writeln("Exception when trying to visit '", path, "': ", e);
        }
    }

    visit(gitRoot);
    return m;
}

// FIXME: Use BringHash as key, instead of string
bool[string] checkResidence(Context ctx, BringHash[string] trackedFileHashes) {
    auto allHashes = trackedFileHashes.byValue
        .map!"a.hashHex"
        .toSet!string
        .keys;
    bool[string] isHashResident;
    foreach (chunk; allHashes.chunks(16)) {
        foreach (i, res; ctx.store.has(chunk)) {
            isHashResident[chunk[i]] = res;
        }
    }
    return isHashResident;
}
