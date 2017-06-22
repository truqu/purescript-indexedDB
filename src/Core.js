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

exports.eventHandler = function eventHandler(cb) {
    return function _handler(e) {
        cb(e.target.result)();
    };
};
