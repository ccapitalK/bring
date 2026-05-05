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

void generateHashFile(Context ctx, string[] args) {
    auto path = args[1];
    enforce(!path.endsWith(".brhash"), "Can't stage bring hash file");
    auto data = cast(ubyte[]) std.file.read(path);
    auto hashData = data.hashFromData().serialize;
    auto hashPath = path ~ ".brhash";
    std.file.write(hashPath, hashData);
}

void status(Context ctx, string[] args) {
    writeln("TODO STATUS");
}

void sync(Context ctx, string[] args) {
    writeln("TODO SYNC");
}

void ensureSync(Context ctx, string[] args) {
    writeln("TODO ENSURE-SYNC");
}

void checkout(Context ctx, string[] args) {
    writeln("TODO CHECKOUT");
}

void updateGitIgnore(Context ctx, string[] args) {
    writeln("TODO UPDATE_GIT_IGNORE");
}

void initLocalStore(Context ctx, string[] args) {
    writeln("TODO INIT_LOCAL_STORE");
}

void printCommandHelp() {
    writeln("bring: Track binary files externally from a git repo");
    writeln("\nCOMMANDS:");
    auto width = COMMANDS.values.map!(cmd => cmd.name.length).maxElement;
    foreach (key; COMMANDS.keys.sort) {
        auto cmd = COMMANDS[key];
        writefln("\t%-*s - %s", width, cmd.name, cmd.description);
    }
}

struct Command {
    string name;
    string description;
    void function(Context ctx, string[] args) func;
}

immutable COMMANDS = [
    "add": Command("add", "Track a file using bring", &generateHashFile),
    "sync": Command("sync", "Synchronize hashed files in current tree with remote", &sync),
    "ensure-sync": Command("ensure-sync", "Ensure all files in tree are present in remote", &ensureSync),
    "checkout": Command("checkout", "Checkout a specific version of a tracked file, by git commit", &checkout),
    "update-gitignore": Command("checkout", "Ensure all tracked files are in gitignores", &updateGitIgnore),
    "init-local-store": Command("init-local-store", "Add a local named store", &initLocalStore),
    "status": Command("status", "Print current bring status", &status),
];

void main(string[] args) {
    if (args.length == 1) {
        args ~= "status";
    }
    if (args[1] == "--help") {
        printCommandHelp();
        return;
    }
    string[] subcommand = args[0] ~ args[2 .. $];
    auto cmd = args[1] in COMMANDS;
    if (!cmd) {
        printCommandHelp();
        throw new Exception("Unknown command " ~ args[1]);
    }
    cmd.func(setupContext(), subcommand);
}
