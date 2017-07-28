const errorHandler = function errorHandler(cb) {
    return function _handler(e) {
        cb(new Error(e.target.error.name));
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


exports._add = function _add(store, value, key) {
    return function aff(success, error) {
        try {
            const request = store.add(value, key || undefined);
            request.onsuccess = successHandler(success);
            request.onerror = errorHandler(error);
        } catch (e) {
            error(new Error(e.name));
        }
    };
};

exports._autoIncrement = function _autoIncrement(store) {
    return store.autoIncrement;
};

exports._clear = function _clear(store) {
    return function aff(success, error) {
        try {
            const request = store.clear();
            request.onsuccess = successHandler(success);
            request.onerror = errorHandler(error);
        } catch (e) {
            error(new Error(e.name));
        }
    };
};

exports._createIndex = function _createIndex(store, name, path, params) {
    return function aff(success, error) {
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
            error(new Error(e.name));
        }
    };
};

exports._deleteIndex = function _deleteIndex(store, name) {
    return function aff(success, error) {
        try {
            store.deleteIndex(name);
            success();
        } catch (e) {
            error(new Error(e.name));
        }
    };
};

exports._delete = function _delete(store, query) {
    return function aff(success, error) {
        try {
            const request = store.delete(query);
            request.onsuccess = successHandler(success);
            request.onerror = errorHandler(error);
        } catch (e) {
            error(new Error(e.name));
        }
    };
};

exports._index = function _index(store, name) {
    return function aff(success, error) {
        try {
            const index = store.index(name);
            success(index);
        } catch (e) {
            error(new Error(e.name));
        }
    };
};

exports._indexNames = function _indexNames(store) {
    return toArray(store.indexNames);
};

exports._keyPath = function _keyPath(store) {
    const path = store.keyPath;

    if (Array.isArray(path)) {
        return path;
    }

    if (typeof path === 'string') {
        return [path];
    }

    return [];
};

exports._name = function _name(store) {
    return store.name;
};

exports._put = function _put(store, value, key) {
    return function aff(success, error) {
        try {
            const request = store.put(value, key || undefined);
            request.onsuccess = successHandler(success);
            request.onerror = errorHandler(error);
        } catch (e) {
            error(new Error(e.name));
        }
    };
};

exports._transaction = function _transaction(store) {
    return store.transaction;
};
