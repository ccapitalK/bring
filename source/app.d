module bring.app;

import std.algorithm;
import std.exception;
static import std.file;
import std.format;
import std.path;
import std.process;
import std.stdio;

import bring.context;
import bring.hash;
import bring.util;

// Returns mapping from path to hash, for each tracked file in the repo
BringHash[string] allHashPaths(string gitRoot) {
    BringHash[string] m;
    void visit(string path) {
        try {
            foreach (entry; std.file.dirEntries(path, std.file.SpanMode.shallow)) {
                if (entry.isDir) {
                    visit(entry.name);
                    continue;
                }

                // TODO: Think through proper behaviour for symlinks. For now we always refuse to follow them
                if (!entry.isFile) {
                    continue;
                }

                if (!entry.name.endsWith(".brhash")) {
                    continue;
                }
                auto trackedFilePath = entry.name.baseName().removeSuffix(".brhash");
                auto hash = readBringHash(entry.name);

                // FIXME: Graceful error handling for this
                enforce(!trackedFilePath.endsWith(".brhash"), "Can't nest brhash extensions");
                m[trackedFilePath] = hash;
            }
            // FIXME: Catch specific exceptions, such as permission denied
        } catch (Exception e) {
            writeln("Exception when trying to visit directory '", path,);
        }
    }

    visit(gitRoot);
    return m;
}

void uploadFile(string path) {
}

void generateHashFile(string path) {
    enforce(!path.endsWith(".brhash"), "Can't stage bring hash file");
    auto data = cast (ubyte[]) std.file.read(path);
    auto hashData = data.hashFromData().serialize;
    auto hashPath = path ~ ".brhash";
    std.file.write(hashPath, hashData);
}

void main(string[] args) {
    auto gitRoot = executeOrDie(["git", "rev-parse", "--show-toplevel"]);
    auto ctx = setupContext();
    args[1].generateHashFile();
}
