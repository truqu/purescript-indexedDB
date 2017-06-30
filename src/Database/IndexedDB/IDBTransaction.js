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

exports._onAbort = function _onAbort(tx, f) {
    return function eff() {
        tx.onabort = function onabort() {
            f();
        };
    };
};

exports._onComplete = function _onComplete(tx, f) {
    return function eff() {
        tx.oncomplete = function oncomplete() {
            f();
        };
    };
};

exports._onError = function _onError(tx, f) {
    return function eff() {
        tx.onerror = function onerror(e) {
            f(new Error(e.target.error.name))();
        };
    };
};
