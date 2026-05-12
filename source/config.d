// SPDX-FileCopyrightText: 2026 Sahan Fernando <sahan.h.fernando@gmail.com>
// SPDX-License-Identifier: GPL-2.0-only

module bring.config;

import std.conv;
import std.exception;
static import std.file;
import std.path;
static import std.process;

import bring.util;

static import toml;

enum StoreType {
    local,
    digitalOcean
}

struct UserBringConfig {
    // TODO: Namespace these
    string digitalOceanPath;
    string digitalOceanKey;
    string digitalOceanSecret;
    string digitalOceanRegion;
    string digitalOceanBucket;
}

struct RepoBringConfig {
    StoreType storeType = StoreType.local;
}

string xdgConfigDir() {
    auto xdgVar = std.process.environment.get("XDG_CONFIG_DIR");
    if (xdgVar !is null) {
        enforce(xdgVar.existsAndIsDir, "Invalid XDG_CONFIG_DIR value");
        return xdgVar;
    }
    return "~/.config/".expandTilde;
}

UserBringConfig readUserConfig() {
    auto configDir = xdgConfigDir;
    auto configPath = buildPath(configDir, "bringrc");
    auto configData = "";
    if (configPath.existsAndIsFile) {
        configData = std.file.readText(configPath);
    }
    return configData.parseUserBringConfig();
}

string readOrDefault(toml.TOMLDocument document, string key, string defaultValue) {
    auto lookup = key in document;
    return lookup ? lookup.str : defaultValue;
}

UserBringConfig parseUserBringConfig(string configData) {
    auto document = toml.parseTOML(configData);
    // TODO: Namespace these. This is a v0 so we can try playing with the s3 api
    auto digitalOceanKey = document.readOrDefault("do-key", "");
    auto digitalOceanSecret = document.readOrDefault("do-secret", "");
    auto digitalOceanBucket = document.readOrDefault("do-bucket", "");
    auto digitalOceanPath = document.readOrDefault("do-path", "");
    auto digitalOceanRegion = document.readOrDefault("do-region", "");
    return UserBringConfig(
        digitalOceanPath: digitalOceanPath,
        digitalOceanBucket: digitalOceanBucket,
        digitalOceanKey: digitalOceanKey,
        digitalOceanSecret: digitalOceanSecret,
        digitalOceanRegion: digitalOceanRegion,
    );
}

unittest {
    assert("".parseUserBringConfig().digitalOceanBucket == "");
    assert("do-path = 'asdf'".parseUserBringConfig().digitalOceanPath == "asdf");
    assert("do-key = 'asdf'".parseUserBringConfig().digitalOceanKey == "asdf");
    assert("do-secret = 'asdf'".parseUserBringConfig().digitalOceanSecret == "asdf");
    assert("do-bucket = 'asdf'".parseUserBringConfig().digitalOceanBucket == "asdf");
    assert("do-region = 'asdf'".parseUserBringConfig().digitalOceanRegion == "asdf");
}

RepoBringConfig parseRepoBringConfig(string configData) {
    auto document = toml.parseTOML(configData);
    StoreType storeType = document.readOrDefault("store", "local").to!StoreType;
    return RepoBringConfig(storeType: storeType);
}

unittest {
    assert("".parseRepoBringConfig().storeType == StoreType.local);
    assert("store = 'local'".parseRepoBringConfig().storeType == StoreType.local);
    assert("store = 'digitalOcean'".parseRepoBringConfig().storeType == StoreType.digitalOcean);
}
