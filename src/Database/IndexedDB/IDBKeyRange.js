export function _bound(lower, upper, lowerOpen, upperOpen) {
    try {
        return IDBKeyRange.bound(lower, upper, lowerOpen, upperOpen);
    } catch (e) {
        return null;
    }
};

export function _includes(range, key) {
    return range.includes(key);
};

export function _lower(range) {
    return range.lower;
};

export function _lowerBound(lower, open) {
    return IDBKeyRange.lowerBound(lower, open);
};

export function _lowerOpen(range) {
    return range.lowerOpen;
};

export function _only(key) {
    return IDBKeyRange.only(key);
};

export function _upper(range) {
    return range.upper;
};

export function _upperBound(upper, open) {
    return IDBKeyRange.upperBound(upper, open);
};

export function _upperOpen(range) {
    return range.upperOpen;
};
