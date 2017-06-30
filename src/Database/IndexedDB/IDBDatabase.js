const $Core = require('Database.IndexedDB.Core/foreign');

const toArray = $Core.toArray;


exports._close = function _close(db) {
    return function eff() {
        try {
            db.close();
        } catch (e) {
            throw new Error(e.name);
        }
    };
};

exports._createObjectStore = function _createObjectStore(db, name, opts) {
    return function eff() {
        var keyPath;

        try {
            // NOTE 1: createObjectStore throws when given an empty array
            // NOTE 2: keyPath supports strings and sequence of strings, however
            //         a string hasn't the same meaning as a sequence of strings
            switch (opts.keyPath.length) {
            case 0:
                keyPath = undefined;
                break;
            case 1:
                keyPath = opts.keyPath[0];
                break;
            default:
                keyPath = opts.keyPath;
            }
            return db.createObjectStore(name, {
                autoIncrement: opts.autoIncrement,
                keyPath: keyPath,
            });
        } catch (e) {
            throw new Error(e.name);
        }
    };
};

exports._deleteObjectStore = function _deleteObjectStore(db, name) {
    return function eff() {
        try {
            db.deleteObjectStore(name);
        } catch (e) {
            throw new Error(e.name);
        }
    };
};

exports._name = function _name(db) {
    return db.name;
};

exports._objectStoreNames = function _objectStoreNames(db) {
    return toArray(db.objectStoreNames);
};

exports._onAbort = function _onAbort(db, f) {
    return function eff() {
        db.onabort = function onabort() {
            f();
        };
    };
};

exports._onClose = function _onClose(db, f) {
    return function eff() {
        db.onclose = function onclose() {
            f();
        };
    };
};

exports._onError = function _onError(db, f) {
    return function eff() {
        db.onerror = function onerror(e) {
            f(new Error(e.target.error.name))();
        };
    };
};

exports._onVersionChange = function _onVersionChange(db, f) {
    return function eff() {
        db.onversionchange = function onversionchange(e) {
            f({ oldVersion: e.oldVersion, newVersion: e.newVersion })();
        };
    };
};

exports._transaction = function _transaction(show, db, stores, mode) {
    return function eff() {
        try {
            return db.transaction(stores, show(mode));
        } catch (e) {
            throw new Error(e.name);
        }
    };
};

exports._version = function _version(db) {
    return db.version;
};
