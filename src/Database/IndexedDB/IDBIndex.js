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


export function _keyPath(index) {
    const path = index.keyPath;

    if (Array.isArray(path)) {
        return path;
    }

    if (typeof path === 'string' && path !== '') {
        return [path];
    }

    return [];
};

export function _multiEntry(index) {
    return index.multiEntry;
};

export function _name(index) {
    return index.name;
};

export function _objectStore(index) {
    return index.obectStore;
};

export function _unique(index) {
    return index.unique;
};

export function _count(index, query) {
    return function aff(error, success) {
        try {
            const request = index.count(query);
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

export function _get(index, range) {
    return function aff(error, success) {
        try {
            const request = index.get(range);
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

/*
 * NOTE: Require some additional work. The array (which isn't necessarily a list of
 * polymorphic types in js) can't be easily translated to a PureScript array.
 *
 * However, it may be doable to convert the result to some key / value structure with values of
 * different types.
export function _getAll(index, query, count) {
    return function aff(error, success) {
        const request = index.getAll(query, count);
        request.onsuccess = successHandler(success);
        request.onerror = errorHandler(error);
    };
};
*/

export function _getAllKeys(index, range, count) {
    return function aff(error, success) {
        try {
            const request = index.getAllKeys(range, count || undefined);
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

export function _getKey(index, range) {
    return function aff(error, success) {
        try {
            const request = index.getKey(range);
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

export function _openCursor(index, query, dir, cb) {
    return function aff(error, success) {
        try {
            const request = index.openCursor(query, dir);
            request.onsuccess = function onSuccess(e) {
                if (e.target.result != null) {
                    cb.onSuccess(e.target.result)();
                } else {
                    cb.onComplete();
                }
            };
            request.onerror = function onError(e) {
                cb.onError(e.target.error);
            };
            success();
        } catch (e) {
            error(e);
        }

        return function canceler(_, cancelerError) {
            cancelerError(new Error("Can't cancel IDB Effects"));
        };
    };
};

export function _openKeyCursor(index, query, dir, cb) {
    return function aff(error, success) {
        try {
            const request = index.openKeyCursor(query, dir);
            request.onsuccess = function onSuccess(e) {
                if (e.target.result != null) {
                    cb.onSuccess(e.target.result)();
                } else {
                    cb.onComplete();
                }
            };
            request.onerror = function onError(e) {
                cb.onError(e.target.error);
            };
            success();
        } catch (e) {
            error(e);
        }

        return function canceler(_, cancelerError) {
            cancelerError(new Error("Can't cancel IDB Effects"));
        };
    };
};
