// SPDX-License-Identifier: GPL-2.0-only

module bring.app;

import std.algorithm;
import std.exception;
static import std.file;
import std.format;
import std.path;
import std.process;
import std.stdio;

import bring.context;
import bring.commands.checkout;
import bring.commands.status;
import bring.commands.sync;
import bring.hash;
import bring.util;
import bring.worktree;

void add(Context ctx, string[] args) {
    foreach (path; args[1 .. $]) {
        enforce(!path.endsWith(BRHASH_FILE_EXT_WITH_DOT), "Can't stage bring hash file");
        if (!std.file.exists(path)) {
            writeln("Couldn't stage file ", ctx.relPathFor(path));
            continue;
        }
        auto hashData = hashFileContents(path).serialize;
        auto hashPath = path ~ BRHASH_FILE_EXT_WITH_DOT;
        std.file.write(hashPath, hashData);
    }
}

void ensureSync(Context ctx, string[] args) {
    writeln("TODO ENSURE-SYNC");
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
    "add": Command("add", "Track a file using bring", &add),
    "sync": Command("sync", "Synchronize hashed files in current tree with remote", &sync),
    "ensure-sync": Command("ensure-sync", "Ensure all files in tree are present in remote", &ensureSync),
    "checkout": Command("checkout", "Checkout a specific version of a tracked file, by git commit", &checkout),
    "update-gitignore": Command("checkout", "Ensure all tracked files are in gitignores", &updateGitIgnore),
    "init-local-store": Command("init-local-store", "Add a local named store", &initLocalStore),
    "status": Command("status", "Print current bring status (default)", &status),
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
