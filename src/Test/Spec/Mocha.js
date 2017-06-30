/* global exports, it */

// module Test.Spec.Mocha

if (typeof describe !== 'function' || typeof it !== 'function') {
    throw new Error('Mocha globals seem to be unavailable!');
}

exports.itAsync = function (only) {
    "use strict";
    return function (name) {
        return function (aff) {
            return function () {
                var f = only ? it.only : it;
                f(name, function (done) {
                    aff(function () {
                        done();
                    }, function (err) {
                        done(err);
                    });
                });
            };
        };
    };
};

exports.itPending = function (name) {
    "use strict";
    return function () {
        it(name);
    };
};

exports.describe = function (only) {
    "use strict";
    return function (name) {
        return function (nested) {
            return function () {
                var f = only ? describe.only : describe;
                f(name, function () {
                    nested();
                });
            };
        };
    };
};
