const toArray = function toArray(xs) {
    return Array.prototype.slice.apply(xs);
};


exports._close = function _close(db) {
    return function aff(success, error) {
        try {
            db.close();
            success();
        } catch (e) {
            error(e);
        }
    };
};

exports._createObjectStore = function _createObjectStore(db, name, opts) {
    return function aff(success, error) {
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
    };
};

exports._deleteObjectStore = function _deleteObjectStore(db, name) {
    return function aff(success, error) {
        try {
            db.deleteObjectStore(name);
            success();
        } catch (e) {
            error(e);
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
    return function aff(success) {
        db.onabort = function onabort() {
            f();
        };
        success();
    };
};

exports._onClose = function _onClose(db, f) {
    return function aff(success) {
        db.onclose = function onclose() {
            f();
        };
        success();
    };
};

exports._onError = function _onError(db, f) {
    return function aff(success) {
        db.onerror = function onerror(e) {
            f(e.target.error)();
        };
        success();
    };
};

exports._onVersionChange = function _onVersionChange(db, f) {
    return function aff(success) {
        db.onversionchange = function onversionchange(e) {
            f({ oldVersion: e.oldVersion, newVersion: e.newVersion })();
        };
        success();
    };
};

exports._transaction = function _transaction(db, stores, mode) {
    return function aff(success, error) {
        try {
            const transaction = db.transaction(stores, mode);
            success(transaction);
        } catch (e) {
            error(e);
        }
    };
};

exports._version = function _version(db) {
    return db.version;
};
