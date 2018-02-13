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

exports._deleteDatabase = function _deleteDatabase(name) {
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
    };
};

exports._open = function _open(fromMaybe, name, mver, req) {
    const ver = fromMaybe(undefined)(mver);

    return function aff(error, success) {
        try {
            console.log("js open...");
            const request = indexedDB.open(name, ver);
            request.onsuccess = function onSuccess(e) {
                console.log("js _open success!");
                success(e.target.result);
            };

            request.onblocked = function onBlocked() {
                console.log("js open...blocked!");
                fromMaybe(noOp)(req.onBlocked)();
            };

            request.onupgradeneeded = function onUpgradeNeeded(e) {
                console.log("js open...upgradeNeeded!");
                const meta = { oldVersion: e.oldVersion };
                fromMaybe(noOp3)(req.onUpgradeNeeded)(e.target.result)(e.target.transaction)(meta)();
                console.log("js open...done upgrading!");
            };

            request.onerror = errorHandler(error);
        } catch (e) {
            error(e);
        } finally {
          return function (cancelError, cancelerError, cancelerSuccess) {
            cancelerSuccess();
          };
        }
    };
};
