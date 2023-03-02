const toArray = function toArray(xs) {
    return Array.prototype.slice.apply(xs);
};


export function _showCursor(cursor) {
    return '(IDBCursor ' +
        '{ direction: ' + cursor.direction +
        ', key: ' + cursor.key +
        ', primaryKey: ' + cursor.primaryKey +
        ' })';
};

export function _showDatabase(db) {
    return '(IDBDatabase ' +
        '{ name: ' + db.name +
        ', objectStoreNames: [' + toArray(db.objectStoreNames).join(', ') + ']' +
        ', version: ' + db.version +
        ' })';
};

export function _showIndex(index) {
    return '(IDBIndex ' +
        '{ name: ' + index.name +
        ', keyPath: ' + index.keyPath +
        ', multiEntry: ' + index.multiEntry +
        ', unique: ' + index.unique +
        ' })';
};

export function _showKeyRange(range) {
    return '(IDBKeyRange ' +
        '{ lower: ' + range.lower +
        ', upper: ' + range.upper +
        ', lowerOpen: ' + range.lowerOpen +
        ', upperOpen: ' + range.upperOpen +
        ' })';
};

export function _showObjectStore(store) {
    return '(IDBObjectStore ' +
        '{ autoIncrement: ' + store.autoIncrement +
        ', indexNames: [' + toArray(store.indexNames).join(', ') + ']' +
        ', keyPath: ' + store.keyPath +
        ', name: ' + store.name +
        ' })';
};

export function _showTransaction(tx) {
    return '(IDBTransaction ' +
        '{ error: ' + tx.error +
        ', mode: ' + tx.mode +
        ' })';
};
