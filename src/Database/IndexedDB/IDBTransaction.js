exports._abort = function _abort(tx) {
    return function eff() {
        try {
            tx.abort();
        } catch (e) {
            throw new Error(e.name);
        }
    };
};

exports._error = function _error(tx) {
    return tx.error == null
        ? null
        : new Error(tx.error.name);
};

exports._mode = function _mode(ReadOnly, ReadWrite, VersionChange, tx) {
    if (tx.mode === 'readwrite') {
        return ReadWrite;
    } else if (tx.mode === 'versionchange') {
        return VersionChange;
    }

    return ReadOnly;
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
