const Maybe = require('Data.Maybe');
const Core = require('Core/foreign');

const noOp2 = Core.noOp2;
const errorHandler = Core.errorHandler;
const successHandler = Core.successHandler;
const eventHandler = Core.eventHandler;

exports._open = function _open(name, mver, req) {
    const ver = Maybe.fromMaybe(undefined)(mver);

    return function callback(success, error) {
        const request = indexedDB.open(name, ver);

        request.onerror = errorHandler(error);
        request.onsuccess = successHandler(success);

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
