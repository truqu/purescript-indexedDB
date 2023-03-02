export function _dateTimeToForeign(y, m, d, h, mi, s, ms) {
    return new Date(y, m, d, h, mi, s, ms);
};

export function _readDateTime(parse, right, left, date) {
    if (Object.getPrototypeOf(date) !== Date.prototype) {
        return left(typeof date);
    }

    const y = date.getFullYear();
    const m = date.getMonth() + 1;
    const d = date.getDate();
    const h = date.getHours();
    const mi = date.getMinutes();
    const s = date.getSeconds();
    const ms = date.getMilliseconds();

    const mdate = parse(y)(m)(d)(h)(mi)(s)(ms);

    if (mdate == null) {
        return left(typeof date); // TODO Could return better error
    }

    return right(mdate);
};

export function _unsafeReadDateTime(parse, date) {
    const y = date.getFullYear();
    const m = date.getMonth() + 1;
    const d = date.getDate();
    const h = date.getHours();
    const mi = date.getMinutes();
    const s = date.getSeconds();
    const ms = date.getMilliseconds();

    return parse(y)(m)(d)(h)(mi)(s)(ms);
};
