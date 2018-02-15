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

exports._advance = function _advance(cursor, count) {
    return function aff(error, success) {
        try {
            cursor.advance(count);
            success();
        } catch (e) {
            error(e);
        } finally {
            return function (_msg,_err,cancelerSuccess){
                cancelerSuccess();
            };
        }
    };
};

exports._continue = function _continue(cursor, key) {
    return function aff(error, success) {
        try {
            cursor.continue(key || undefined);
            success();
        } catch (e) {
            error(e);
        } finally {
            return function (_msg,_err,cancelerSuccess){
                cancelerSuccess();
            };
        }
    };
};

exports._continuePrimaryKey = function _continuePrimaryKey(cursor, key, primaryKey) {
    return function aff(error, success) {
        try {
            cursor.continuePrimaryKey(key, primaryKey);
            success();
        } catch (e) {
            error(e);
        } finally {
            return function(_msg,_err,cancelerSuccess){
                cancelerSuccess();
            };
        }
    };
};

exports._delete = function _delete(cursor) {
    return function aff(error, success) {
        try {
            const request = cursor.delete();
            request.onsuccess = successHandler(success);
            request.onerror = errorHandler(error);
        } catch (e) {
            error(e);
        } finally {
            return function (_msg,_err,cancelerSuccess){
                cancelerSuccess();
            };
        }
    };
};

exports._direction = function _direction(fromString, cursor) {
    return fromString(cursor.direction);
};

exports._key = function _key(cursor) {
    return function aff(error, success) {
        try {
            success(cursor.key);
        } catch (e) {
            error(e);
        } finally {
            return function(_msg,_err,cancelerSuccess){
                cancelerSuccess();
            };
        }
    };
};

exports._primaryKey = function _primaryKey(cursor) {
    return function aff(error, success) {
        try {
            success(cursor.primaryKey);
        } catch (e) {
            error(e);
        } finally {
            return function(_msg,_err,cancelerSuccess){
                cancelerSuccess();
            };
        }
    };
};

exports._source = function _source(IDBObjectStore, IDBIndex, cursor) {
    switch (cursor.source.constructor.name) {
    case 'IDBIndex':
        return IDBIndex(cursor.source);
    case 'IDBObjectStore':
        return IDBObjectStore(cursor.source);
    default:
        throw Object.create(Error.prototype, {
            message: {
                enumerable: true,
                value: 'Unable to retrieve the cursor\'s source constructor.',
            },
            name: {
                enumerable: true,
                value: 'UnexpectedCursorSource',
            },
        });
    }
};

exports._update = function _update(cursor, value) {
    return function aff(error, success) {
        try {
            const request = cursor.update(value);
            request.onsuccess = successHandler(success);
            request.onerror = errorHandler(error);
        } catch (e) {
            error(e);
        } finally {
            return function (_msg,_err,cancelerSuccess){
                cancelerSuccess();
            };
        }
    };
};

exports._value = function _value(cursor) {
    return cursor.value;
};
