exports._abort = function _abort(tx) {
    return function aff(success, error) {
        try {
            tx.abort();
            success();
        } catch (e) {
            error(e);
        }
    };
};

exports._db = function _db(tx) {
    return tx.db;
};

exports._error = function _error(tx) {
    return tx.error == null
        ? null
        : tx.error;
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
    return function aff(error, success) {
        try {
            const store = tx.objectStore(name);
            success(store);
        } catch (e) {
            error(e);
        } finally {
          return function(_msg,_err,succ){
            succ();
          };
        }
    };
};

exports._objectStoreNames = function _objectStoreNames(tx) {
    return tx.objectStoreNames;
};

exports._onAbort = function _onAbort(tx, f) {
    return function (_, success) {
        tx.onabort = function onabort() {
            f();
        };
        success();
        return function(_msg,_err,succ){ return succ();};
    };
};

exports._onComplete = function _onComplete(tx, f) {
    return function aff(_,success) {
        tx.oncomplete = function oncomplete() {
            f();
        };
        success();
        return function (_msg,_err,succ){return succ();};
    };
};

exports._onError = function _onError(tx, f) {
    return function aff(_, success) {
        tx.onerror = function onerror(e) {
            f(e.target.error)();
        };
        success();
        return function (_msg,_err,succ){return succ();};
    };
};
