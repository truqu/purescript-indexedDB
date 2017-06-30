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


exports._advance = function _advance(cursor, count) {
    return function aff(success, error) {
        try {
            cursor.advance(count);
            success();
        } catch (e) {
            error(new Error(e.name));
        }
    };
};

exports._continue = function _continue(cursor, key) {
    return function aff(success, error) {
        try {
            cursor.continue(key || undefined);
        } catch (e) {
            error(new Error(e.name));
        }
    };
};

exports._continuePrimaryKey = function _continuePrimaryKey(cursor, key, primaryKey) {
    return function aff(success, error) {
        try {
            cursor.continuePrimaryKey(key, primaryKey);
        } catch (e) {
            error(new Error(e.name));
        }
    };
};

exports._delete = function _delete(cursor) {
    return function aff(success, error) {
        try {
            const request = cursor.delete();
            request.onsuccess = successHandler(success);
            request.onerror = errorHandler(error);
        } catch (e) {
            error(new Error(e.name));
        }
    };
};

exports._direction = function _direction(fromString, cursor) {
    return fromString(cursor.direction);
};

exports._key = function _key(cursor) {
    return cursor.key;
};

exports._primaryKey = function _primaryKey(cursor) {
    return cursor.primaryKey;
};

exports._source = function _source(IDBObjectStore, IDBIndex, cursor) {
    console.log(typeof cursor.source);
    console.log(Object.getPrototypeOf(cursor.source));
    console.log(cursor.source);
    throw new Error('TODO');
};

exports._update = function _update(cursor, value) {
    return function aff(success, error) {
        try {
            const request = cursor.update(value);
            request.onsuccess = successHandler(success);
            request.onerror = errorHandler(error);
        } catch (e) {
            error(new Error(e.name));
        }
    };
};

exports._value = function _value(cursor) {
    return cursor.value;
};
