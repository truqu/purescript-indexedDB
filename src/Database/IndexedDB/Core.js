exports._showDatabase = function _showDatabase(db) {
    return '(IDBDatabase ' +
        '{ name: ' + db.name +
        ', objectStoreNames: [' + exports.toArray(db.objectStoreNames).join(', ') + ']' +
        ', version: ' + db.version +
        ' })';
};

exports._showObjectStore = function _showObjectStore(store) {
    return '(IDBObjectStore ' +
        '{ autoIncrement: ' + store.autoIncrement +
        ', indexNames: [' + exports.toArray(store.indexNames).join(', ') + ']' +
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
