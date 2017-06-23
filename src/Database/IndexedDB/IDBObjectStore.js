const $Core = require('Database.IndexedDB.Core/foreign');

const toArray = $Core.toArray;


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
        return path.split(':');
    }

    return [];
};

exports.name = function name(store) {
    return store.name;
};
