exports.toArray = function toArray(xs) {
    return Array.prototype.slice.apply(xs);
};

exports.noOp = function noOp() {
    return function eff() {
        // Nothing
    };
};

exports.noOp2 = function noOp2() {
    return exports.noOp;
};

exports.errorHandler = function errorHandler(cb) {
    return function _handler(e) {
        cb(new Error(e.target.error.name));
    };
};

exports.successHandler = function successHandler(cb) {
    return function _handler(e) {
        cb(e.target.result);
    };
};

exports._showIDBDatabase = function _showIDBDatabase(db) {
    return '(IDBDatabase ' +
        '{ name: ' + db.name +
        ', objectStoreNames: [' + exports.toArray(db.objectStoreNames).join(', ') + ']' +
        ', version: ' + db.version +
        ' })';
};

exports._showIDBObjectStore = function _showIDBObjectStore(store) {
    return '(IDBObjectStore ' +
        '{ autoIncrement: ' + store.autoIncrement +
        ', indexNames: [' + exports.toArray(store.indexNames).join(', ') + ']' +
        ', keyPath: ' + store.keyPath +
        ', name: ' + store.name +
        ' })';
};

exports._showIDBTransaction = function _showIDBTransaction(tx) {
    return '(IDBTransaction ' +
        '{ error: ' + tx.error +
        ', mode: ' + tx.mode +
        ' })';
};

exports._dateTimeToForeign = function _dateTimeToForeign(y, m, d, h, mi, s, ms) {
    return new Date(y, m, d, h, mi, s, ms);
};

exports._readDateTime = function _readDateTime(parse, right, left, date) {
    if (Object.getPrototypeOf(date) !== Date.prototype) {
        return left(typeof date);
    }

    const y = date.getFullYear();
    const m = date.getMonth() + 1;
    const d = date.getDate();
    const h = date.getHours();
    const mi = date.getMinutes();
    const s = date.getSeconds();
    const ms = date.getMilliseconds();

    const mdate = parse(y)(m)(d)(h)(mi)(s)(ms);

    if (mdate == null) {
        return left(typeof date); // TODO Could return better error
    }

    return right(mdate);
};

exports._unsafeReadDateTime = function _unsafeReadDateTime(parse, date) {
    const y = date.getFullYear();
    const m = date.getMonth() + 1;
    const d = date.getDate();
    const h = date.getHours();
    const mi = date.getMinutes();
    const s = date.getSeconds();
    const ms = date.getMilliseconds();

    return parse(y)(m)(d)(h)(mi)(s)(ms);
};
