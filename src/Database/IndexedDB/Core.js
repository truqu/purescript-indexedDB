const toArray = function toArray(xs) {
    return Array.prototype.slice.apply(xs);
};


exports._showDatabase = function _showDatabase(db) {
    return '(IDBDatabase ' +
        '{ name: ' + db.name +
        ', objectStoreNames: [' + toArray(db.objectStoreNames).join(', ') + ']' +
        ', version: ' + db.version +
        ' })';
};

exports._showIndex = function _showIndex(index) {
    return '(IDBIndex ' +
        '{ name: ' + index.name +
        ', keyPath: ' + index.keyPath +
        ', multiEntry: ' + index.multiEntry +
        ', unique: ' + index.unique +
        ' })';
};

exports._showKeyRange = function _showKeyRange(range) {
    return '(IDBKeyRange ' +
        '{ lower: ' + range.lower +
        ', upper: ' + range.upper +
        ', lowerOpen: ' + range.lowerOpen +
        ', upperOpen: ' + range.upperOpen +
        ' })';
};

exports._showObjectStore = function _showObjectStore(store) {
    return '(IDBObjectStore ' +
        '{ autoIncrement: ' + store.autoIncrement +
        ', indexNames: [' + toArray(store.indexNames).join(', ') + ']' +
        ', keyPath: ' + store.keyPath +
        ', name: ' + store.name +
        ' })';
};

exports._showTransaction = function _showTransaction(tx) {
    return '(IDBTransaction ' +
        '{ error: ' + tx.error +
        ', mode: ' + tx.mode +
        ' })';
};
