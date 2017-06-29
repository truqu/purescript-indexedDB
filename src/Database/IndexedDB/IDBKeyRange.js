exports._bound = function _bound(lower, upper, lowerOpen, upperOpen) {
    try {
        return IDBKeyRange.bound(lower, upper, lowerOpen, upperOpen);
    } catch (e) {
        return null;
    }
};

exports._includes = function _includes(range, key) {
    return range.includes(key);
};

exports._lower = function _lower(range) {
    return range.lower;
};

exports._lowerBound = function _lowerBound(lower, open) {
    return IDBKeyRange.lowerBound(lower, open);
};

exports._lowerOpen = function _lowerOpen(range) {
    return range.lowerOpen;
};

exports._only = function _only(key) {
    return IDBKeyRange.only(key);
};

exports._upper = function _upper(range) {
    return range.upper;
};

exports._upperBound = function _upperBound(upper, open) {
    return IDBKeyRange.upperBound(upper, open);
};

exports._upperOpen = function _upperOpen(range) {
    return range.upperOpen;
};
