const $Core = require('Database.IndexedDB.Core/foreign');

const toArray = $Core.toArray;
const errorHandler = $Core.errorHandler;
const successHandler = $Core.successHandler;

exports._add = function _add(store, value, key) {
    return function aff(success, error) {
        const request = store.add(value, key || undefined);
        request.onsuccess = successHandler(success);
        request.onerror = errorHandler(error);
    };
};

exports.autoIncrement = function autoIncrement(store) {
    return store.autoIncrement;
};

exports.clear = function clear(store) {
    return function aff(success, error) {
        const request = store.clear();
        request.onsuccess = successHandler(success);
        request.onerror = errorHandler(error);
    };
};

exports._count = function _count(store, query) {
    return function aff(success, error) {
        const request = store.count(query);
        request.onsuccess = successHandler(success);
        request.onerror = errorHandler(error);
    };
};

exports._createIndex = function _createIndex(store, name, path, params) {
    return function eff() {
        var keyPath;

        try {
            // NOTE: keyPath supports strings and sequence of strings, however
            //       a string hasn't the same meaning as a sequence of strings
            switch (path.length) {
            case 0:
                keyPath = null;
                break;
            case 1:
                keyPath = path[0];
                break;
            default:
                keyPath = path;
            }

            store.createIndex(name, keyPath, params);
        } catch (e) {
            throw new Error(e.name);
        }
    };
};

exports._deleteIndex = function _deleteIndex(store, name) {
    return function eff() {
        try {
            store.deleteIndex(name);
        } catch (e) {
            throw new Error(e.name);
        }
    };
};

exports._delete = function _delete(store, query) {
    return function aff(success, error) {
        const request = store.delete(query || undefined);
        request.onsuccess = successHandler(success);
        request.onerror = errorHandler(error);
    };
};

exports._get = function _get(store, query) {
    return function aff(success, error) {
        const request = store.get(query || undefined);
        request.onsuccess = successHandler(success);
        request.onerror = errorHandler(error);
    };
};

exports._getKey = function _getKey(store, query) {
    return function aff(success, error) {
        const request = store.getKey(query || undefined);
        request.onsuccess = successHandler(success);
        request.onerror = errorHandler(error);
    };
};

exports._getAll = function _getAll(store, query, count) {
    return function aff(success, error) {
        const request = store.getAll(query, count);
        request.onsuccess = successHandler(success);
        request.onerror = errorHandler(error);
    };
};

exports._getAllKeys = function _getAllKeys(store, query, count) {
    return function aff(success, error) {
        const request = store.getAllKeys(query, count);
        request.onsuccess = successHandler(success);
        request.onerror = errorHandler(error);
    };
};

exports._index = function _index(store, name) {
    return function eff() {
        try {
            return store.index(name);
        } catch (e) {
            throw new Error(e.name);
        }
    };
};

exports.indexNames = function indexNames(store) {
    return toArray(store.indexNames);
};

exports.keyPath = function keyPath(store) {
    const path = store.keyPath;

    if (Array.isArray(path)) {
        return path;
    }

    if (typeof path === 'string') {
        return path.split('.');
    }

    return [];
};

exports.name = function name(store) {
    return store.name;
};

exports._openCursor = function _openCursor(store, query, dir) {
    return function aff(success, error) {
        const request = store.openCursor(query, dir);
        request.onsuccess = successHandler(success);
        request.onerror = errorHandler(error);
    };
};

exports._openKeyCursor = function _openKeyCursor(store, query, dir) {
    return function aff(success, error) {
        const request = store.openKeyCursor(query, dir);
        request.onsuccess = successHandler(success);
        request.onerror = errorHandler(error);
    };
};

exports._put = function _put(store, value, key) {
    return function aff(success, error) {
        const request = store.put(value, key || undefined);
        request.onsuccess = successHandler(success);
        request.onerror = errorHandler(error);
    };
};
