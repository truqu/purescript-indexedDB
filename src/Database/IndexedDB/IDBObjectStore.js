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
