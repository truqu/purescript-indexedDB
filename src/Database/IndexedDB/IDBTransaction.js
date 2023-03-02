export function _abort(tx) {
    return function aff(error, success) {
        try {
            tx.abort();
            success();
        } catch (e) {
            error(e);
        }

        return function canceler(_, cancelerError) {
            cancelerError(new Error("Can't cancel IDB Effects"));
        };
    };
};

export function _db(tx) {
    return tx.db;
};

export function _error(tx) {
    return tx.error == null
        ? null
        : tx.error;
};

export function _mode(ReadOnly, ReadWrite, VersionChange, tx) {
    if (tx.mode === 'readwrite') {
        return ReadWrite;
    } else if (tx.mode === 'versionchange') {
        return VersionChange;
    }

    return ReadOnly;
};

export function _objectStore(tx, name) {
    return function aff(error, success) {
        try {
            const store = tx.objectStore(name);
            success(store);
        } catch (e) {
            error(e);
        }

        return function canceler(_, cancelerError) {
            cancelerError(new Error("Can't cancel IDB Effects"));
        };
    };
};

export function _objectStoreNames(tx) {
    return tx.objectStoreNames;
};

export function _onAbort(tx, f) {
    return function aff(error, success) {
        tx.onabort = function onabort() {
            f();
        };
        success();

        return function canceler(_, cancelerError) {
            cancelerError(new Error("Can't cancel IDB Effects"));
        };
    };
};

export function _onComplete(tx, f) {
    return function aff(error, success) {
        tx.oncomplete = function oncomplete() {
            f();
        };
        success();

        return function canceler(_, cancelerError) {
            cancelerError(new Error("Can't cancel IDB Effects"));
        };
    };
};

export function _onError(tx, f) {
    return function aff(error, success) {
        tx.onerror = function onerror(e) {
            f(e.target.error)();
        };
        success();

        return function canceler(_, cancelerError) {
            cancelerError(new Error("Can't cancel IDB Effects"));
        };
    };
};
