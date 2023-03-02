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

export function _advance(cursor, count) {
    return function aff(error, success) {
        try {
            cursor.advance(count);
            success();
        } catch (e) {
            error(e);
        }

        return function canceler(_, cancelerError) {
            cancelerError(new Error("Can't cancel IDB Effects"));
        };
    };
};

export function _continue(cursor, key) {
    return function aff(error, success) {
        try {
            cursor.continue(key || undefined);
            success();
        } catch (e) {
            error(e);
        }

        return function canceler(_, cancelerError) {
            cancelerError(new Error("Can't cancel IDB Effects"));
        };
    };
};

export function _continuePrimaryKey(cursor, key, primaryKey) {
    return function aff(error, success) {
        try {
            cursor.continuePrimaryKey(key, primaryKey);
            success();
        } catch (e) {
            error(e);
        }

        return function canceler(_, cancelerError) {
            cancelerError(new Error("Can't cancel IDB Effects"));
        };
    };
};

export function _delete(cursor) {
    return function aff(error, success) {
        try {
            const request = cursor.delete();
            request.onsuccess = successHandler(success);
            request.onerror = errorHandler(error);
        } catch (e) {
            error(e);
        }

        return function canceler(_, cancelerError) {
            cancelerError(new Error("Can't cancel IDB Effects"));
        };
    };
};

export function _direction(fromString, cursor) {
    return fromString(cursor.direction);
};

export function _key(cursor) {
    return function aff(error, success) {
        try {
            success(cursor.key);
        } catch (e) {
            error(e);
        }

        return function canceler(_, cancelerError) {
            cancelerError(new Error("Can't cancel IDB Effects"));
        };
    };
};

export function _primaryKey(cursor) {
    return function aff(error, success) {
        try {
            success(cursor.primaryKey);
        } catch (e) {
            error(e);
        }

        return function canceler(_, cancelerError) {
            cancelerError(new Error("Can't cancel IDB Effects"));
        };
    };
};

export function _source(IDBObjectStore, IDBIndex, cursor) {
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

export function _update(cursor, value) {
    return function aff(error, success) {
        try {
            const request = cursor.update(value);
            request.onsuccess = successHandler(success);
            request.onerror = errorHandler(error);
        } catch (e) {
            error(e);
        }

        return function canceler(_, cancelerError) {
            cancelerError(new Error("Can't cancel IDB Effects"));
        };
    };
};

export function _value(cursor) {
    return cursor.value;
};
