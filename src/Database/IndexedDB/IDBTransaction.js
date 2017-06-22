const Maybe = require('Data.Maybe');
const Core = require('Database.IndexedDB.Core');


exports.abort = function abort(tx) {
    return function eff() {
        try {
            tx.abort();
        } catch (e) {
            throw new Error(e.name);
        }
    };
};

exports.error = function error(tx) {
    return tx.error == null
        ? Maybe.Nothing()
        : Maybe.Just(new Error(tx.error.name));
};

exports.mode = function mode(tx) {
    if (tx.mode === 'readwrite') {
        return Core.ReadWrite();
    } else if (tx.mode === 'versionchange') {
        return Core.VersionChange();
    }

    return Core.ReadOnly();
};

exports._objectStore = function _objectStore(tx, name) {
    return function eff() {
        try {
            return tx.objectStore(name);
        } catch (e) {
            throw new Error(e.name);
        }
    };
};
