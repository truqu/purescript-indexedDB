const Maybe = require('Data.Maybe');
const Core = require('Core/foreign');

const toArray = Core.toArray;
const noOp2 = Core.noOp2;
const errorHandler = Core.errorHandler;
const eventHandler = Core.eventHandler;


exports.close = function close(db) {
    return function effects() {
        try {
            db.close();
        } catch (e) {
            throw new Error(e.name);
        }
    };
};

exports._createObjectStore = function _createObjectStore(db, name, opts) {
    const keyPath = Maybe.fromMaybe(undefined)(opts.keyPath);
    const autoIncrement = opts.autoIncrement;

    return function effects() {
        try {
            return db.createObjectStore(name, {
                keyPath: keyPath,
                autoIncrement: autoIncrement,
            });
        } catch (e) {
            throw new Error(e.name);
        }
    };
};

exports._deleteObjectStore = function _deleteObjectStore(db, name) {
    return function effects() {
        try {
            db.deleteObjectStore(name);
        } catch (e) {
            throw new Error(e.name);
        }
    };
};

exports.deleteDatabase = function deleteDatabase(name) {
    return function callback(success, error) {
        const request = indexedDB.deleteDatabase(name);

        request.onsuccess = function onSuccess(e) {
            success(e.oldVersion);
        };

        request.onerror = errorHandler(error);
    };
};

exports._open = function _open(name, mver, req) {
    const ver = Maybe.fromMaybe(undefined)(mver);

    return function callback(success, error) {
        const request = indexedDB.open(name, ver);
        request.onsuccess = function onSuccess(e) {
            success(e.target.result);
        };

        request.onerror = errorHandler(error);
        request.onblocked = eventHandler(Maybe.fromMaybe(noOp2)(req.onBlocked));
        request.onupgradeneeded = eventHandler(Maybe.fromMaybe(noOp2)(req.onUpgradeNeeded));
    };
};

exports.name = function name(db) {
    return db.name;
};

exports.version = function version(db) {
    return db.version;
};

exports.objectStoreNames = function objectStoreNames(db) {
    return toArray(db.objectStoreNames);
};
