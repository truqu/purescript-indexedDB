const toArray = function toArray(xs) {
    return Array.prototype.slice.apply(xs);
};


export function _close(db) {
    return function aff(error, success) {
        try {
            db.close();
            success();
        } catch (e) {
            error(e);
        }

        return function canceler(_, cancelerError) {
            cancelerError(new Error("Can't cancel IDB Effects"));
        };
    };
};

export function _createObjectStore(db, name, opts) {
    return function aff(error, success) {
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

            const store = db.createObjectStore(name, {
                autoIncrement: opts.autoIncrement,
                keyPath: keyPath,
            });
            success(store);
        } catch (e) {
            error(e);
        }

        return function canceler(_, cancelerError) {
            cancelerError(new Error("Can't cancel IDB Effects"));
        };
    };
};

export function _deleteObjectStore(db, name) {
    return function aff(error, success) {
        try {
            db.deleteObjectStore(name);
            success();
        } catch (e) {
            error(e);
        }

        return function canceler(_, cancelerError) {
            cancelerError(new Error("Can't cancel IDB Effects"));
        };
    };
};

export function _name(db) {
    return db.name;
};

export function _objectStoreNames(db) {
    return toArray(db.objectStoreNames);
};

export function _onAbort(db, f) {
    return function aff(error, success) {
        db.onabort = function onabort() {
            f();
        };
        success();

        return function canceler(_, cancelerError) {
            cancelerError(new Error("Can't cancel IDB Effects"));
        };
    };
};

export function _onClose(db, f) {
    return function aff(error, success) {
        db.onclose = function onclose() {
            f();
        };
        success();

        return function canceler(_, cancelerError) {
            cancelerError(new Error("Can't cancel IDB Effects"));
        };
    };
};

export function _onError(db, f) {
    return function aff(error, success) {
        db.onerror = function onerror(e) {
            f(e.target.error)();
        };
        success();

        return function canceler(_, cancelerError) {
            cancelerError(new Error("Can't cancel IDB Effects"));
        };
    };
};

export function _onVersionChange(db, f) {
    return function aff(error, success) {
        db.onversionchange = function onversionchange(e) {
            f({ oldVersion: e.oldVersion, newVersion: e.newVersion })();
        };
        success();

        return function canceler(_, cancelerError) {
            cancelerError(new Error("Can't cancel IDB Effects"));
        };
    };
};

export function _transaction(db, stores, mode) {
    return function aff(error, success) {
        var transaction;
        try {
            transaction = db.transaction(stores, mode);
            success(transaction);
        } catch (e) {
            error(e);
        }

        return function canceler(_, cancelerError, cancelerSuccess) {
            transaction.abort();
            cancelerSuccess();
        };
    };
};

export function _version(db) {
    return db.version;
};
