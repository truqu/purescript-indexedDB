const Maybe = require('Data.Maybe');
const Core = require('Core/foreign');

const toArray = Core.toArray;
const noOp2 = Core.noOp2;
const errorHandler = Core.errorHandler;
const eventHandler = Core.eventHandler;

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

exports.deleteDatabase = function _deleteDatabase(name) {
    return function callback(success, error) {
        const request = indexedDB.deleteDatabase(name);

        request.onsuccess = function onSuccess(e) {
            success(e.oldVersion);
        };

        request.onerror = errorHandler(error);
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
