const Maybe = require('Data.Maybe');

const noOp = function noOp() {
    return function eff() {
        // Nothing
    };
};


const noOp2 = function noOp2() {
    return noOp;
};


const errorHandler = function errorHandler(cb) {
    return function _autruche(e) {
        console.log("ERROR");
        cb(new Error(e.errorCode));
    };
};

const eventHandler = function eventHandler(cb) {
    return function _patate(e) {
        cb(e.target.result)();
    };
};


exports._open = function _open(name, mver, req) {
    const ver = Maybe.fromMaybe(undefined)(mver);

    return function callback(success, error) {
        const request = indexedDB.open('library', ver);

        request.onerror = errorHandler(error);
        request.onblocked = eventHandler(Maybe.fromMaybe(noOp2)(req.onBlocked));
        request.onsuccess = eventHandler(Maybe.fromMaybe(noOp2)(req.onSuccess));
        request.onupgradeneeded = eventHandler(Maybe.fromMaybe(noOp2)(req.onUpgradeNeeded));
    };
};

exports.idbDatabaseName = function idbDatabaseName(db) {
    return db.name;
};
