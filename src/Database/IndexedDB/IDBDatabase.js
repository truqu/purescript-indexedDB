const Core = require('Database.IndexedDB.Core');
const $Core = require('Database.IndexedDB.Core/foreign');

const toArray = $Core.toArray;


exports.close = function close(db) {
    return function eff() {
        try {
            db.close();
        } catch (e) {
            throw new Error(e.name);
        }
    };
};

exports._createObjectStore = function _createObjectStore(fromMaybe, db, name, opts) {
    const keyPath = fromMaybe(undefined)(opts.keyPath);
    const autoIncrement = opts.autoIncrement;

    return function eff() {
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
    return function eff() {
        try {
            db.deleteObjectStore(name);
        } catch (e) {
            throw new Error(e.name);
        }
    };
};

exports.name = function name(db) {
    return db.name;
};

exports.objectStoreNames = function objectStoreNames(db) {
    return toArray(db.objectStoreNames);
};

exports._transaction = function _transaction(db, stores, mode) {
    return function eff() {
        var mode_;
        try {
            if (mode instanceof Core.ReadOnly) {
                mode_ = 'readonly';
            } else if (mode instanceof Core.ReadWrite) {
                mode_ = 'readwrite';
            } else {
                mode_ = 'versionchange';
            }

            return db.transaction(stores, mode_);
        } catch (e) {
            throw new Error(e.name);
        }
    };
};

exports.version = function version(db) {
    return db.version;
};
