const errorHandler = function errorHandler(cb) {
    return function _handler(e) {
        cb(e.target.error);
    };
};

const noOp = function noOp() {
    return function eff() {
        // Nothing
    };
};

const noOp2 = function noOp2() {
    return noOp;
};

const noOp3 = function noOp3() {
    return noOp2;
};

export function _deleteDatabase(name) {
    return function aff(error, success) {
        try {
            const request = indexedDB.deleteDatabase(name);

            request.onsuccess = function onSuccess(e) {
                success(e.oldVersion);
            };

            request.onerror = errorHandler(error);
        } catch (e) {
            error(e);
        }

        return function canceler(_, cancelerError) {
            cancelerError(new Error("Can't cancel IDB Effects"));
        };
    };
};

export function _open(fromMaybe, name, mver, req) {
    const ver = fromMaybe(undefined)(mver);

    return function aff(error, success) {
        try {
            const request = indexedDB.open(name, ver);
            request.onsuccess = function onSuccess(e) {
                success(e.target.result);
            };

            request.onblocked = function onBlocked() {
                fromMaybe(noOp)(req.onBlocked)();
            };

            request.onupgradeneeded = function onUpgradeNeeded(e) {
                const meta = { oldVersion: e.oldVersion };
                // eslint-disable-next-line max-len
                fromMaybe(noOp3)(req.onUpgradeNeeded)(e.target.result)(e.target.transaction)(meta)();
            };

            request.onerror = errorHandler(error);
        } catch (e) {
            error(e);
        }

        return function canceler(_, cancelerError) {
            cancelerError(new Error("Can't cancel IDB Effects"));
        };
    };
};
