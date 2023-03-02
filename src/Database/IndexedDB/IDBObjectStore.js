const errorHandler = function errorHandler(cb) {
    return function _handler(e) {
        cb(e.target.error);
    };
};

const successHandler = function successHandler(cb) {
    return function _handler(e) {
        cb(e.target.result);
    };
};

const toArray = function toArray(xs) {
    return Array.prototype.slice.apply(xs);
};


export function _add(store, value, key) {
    return function aff(error, success) {
        try {
            const request = store.add(value, key || undefined);
            request.onsuccess = successHandler(success);
            request.onerror = errorHandler(error);
        } catch (e) {
            error(e);
        }

        return function canceler(_, cancelerError) {
            cancelerError(new Error("Can't cancel IDB Effects"));
        };
    };
};

export function _autoIncrement(store) {
    return store.autoIncrement;
};

export function _clear(store) {
    return function aff(error, success) {
        try {
            const request = store.clear();
            request.onsuccess = successHandler(success);
            request.onerror = errorHandler(error);
        } catch (e) {
            error(e);
        }

        return function canceler(_, cancelerError) {
            cancelerError(new Error("Can't cancel IDB Effects"));
        };
    };
};

export function _createIndex(store, name, path, params) {
    return function aff(error, success) {
        var keyPath;

        try {
            // NOTE: keyPath supports strings and sequence of strings, however
            //       a string hasn't the same meaning as a sequence of strings
            switch (path.length) {
            case 0:
                keyPath = '';
                break;
            case 1:
                keyPath = path[0];
                break;
            default:
                keyPath = path;
            }

            const index = store.createIndex(name, keyPath, params);
            success(index);
        } catch (e) {
            error(e);
        }

        return function canceler(_, cancelerError) {
            cancelerError(new Error("Can't cancel IDB Effects"));
        };
    };
};

export function _deleteIndex(store, name) {
    return function aff(error, success) {
        try {
            store.deleteIndex(name);
            success();
        } catch (e) {
            error(e);
        }

        return function canceler(_, cancelerError) {
            cancelerError(new Error("Can't cancel IDB Effects"));
        };
    };
};

export function _delete(store, query) {
    return function aff(error, success) {
        try {
            const request = store.delete(query);
            request.onsuccess = successHandler(success);
            request.onerror = errorHandler(error);
        } catch (e) {
            error(e);
        }

        return function canceler(_, cancelerError) {
            cancelerError(new Error("Can't cancel IDB Effects"));
        };
    };
};

export function _index(store, name) {
    return function aff(error, success) {
        try {
            const index = store.index(name);
            success(index);
        } catch (e) {
            error(e);
        }

        return function canceler(_, cancelerError) {
            cancelerError(new Error("Can't cancel IDB Effects"));
        };
    };
};

export function _indexNames(store) {
    return toArray(store.indexNames);
};

export function _keyPath(store) {
    const path = store.keyPath;

    if (Array.isArray(path)) {
        return path;
    }

    if (typeof path === 'string') {
        return [path];
    }

    return [];
};

export function _name(store) {
    return store.name;
};

export function _put(store, value, key) {
    return function aff(error, success) {
        try {
            const request = store.put(value, key || undefined);
            request.onsuccess = successHandler(success);
            request.onerror = errorHandler(error);
        } catch (e) {
            error(e);
        }

        return function canceler(_, cancelerError) {
            cancelerError(new Error("Can't cancel IDB Effects"));
        };
    };
};

export function _transaction(store) {
    return store.transaction;
};
