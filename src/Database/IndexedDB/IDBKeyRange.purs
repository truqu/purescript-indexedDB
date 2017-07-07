-- | A key has an associated type which is one of: number, date, string, binary, or array.
module Database.IndexedDB.IDBKeyRange
  ( class IDBKeyRange, includes
  , only
  , lowerBound
  , upperBound
  , bound
  , lower
  , upper
  , lowerOpen
  , upperOpen
  ) where

import Prelude

import Data.Foreign                       (Foreign)
import Data.Function.Uncurried             as Fn
import Data.Function.Uncurried            (Fn2, Fn4)
import Data.Maybe                         (Maybe)
import Data.Nullable                      (Nullable, toMaybe)

import Database.IndexedDB.Core            (KeyRange)
import Database.IndexedDB.IDBKey.Internal (class IDBKey, Key(..), toKey, extractForeign)


--------------------
-- INTERFACES
--
-- | The IDBKeyRange interface represents a key range.
class IDBKeyRange range where
  -- | Returns true if key is included in the range, and false otherwise.
  includes :: forall k. (IDBKey k) => range -> k -> Boolean

-- | Type alias for open
type Open = Boolean


-- | Returns a new IDBKeyRange spanning only key.
only
    :: forall a. (IDBKey a)
    => a
    -> KeyRange
only key =
  _only (extractForeign $ toKey key)


-- | Returns a new IDBKeyRange starting at key with no upper bound.
-- | If `Open` is `true`, key is not included in the range.
lowerBound
    :: forall a. (IDBKey a)
    => a
    -> Open
    -> KeyRange
lowerBound key open =
  Fn.runFn2 _lowerBound (extractForeign $ toKey key) open


-- | Returns a new IDBKeyRange with no lower bound and ending at key.
-- | If `Open` is `true`, key is not included in the range.
upperBound
    :: forall a. (IDBKey a)
    => a
    -> Open
    -> KeyRange
upperBound key open =
  Fn.runFn2 _upperBound (extractForeign $ toKey key) open


-- | Returns a new IDBKeyRange spanning from `lower` to `upper`.
-- | If `lowerOpen` is `true`, `lower` is not included in the range.
-- | If `upperOpen` is `true`, `upper` is not included in the range.
-- |
-- | It throws a `DataError` if the bound is invalid.
bound
    :: forall a. (IDBKey a)
    => { lower :: a, upper :: a, lowerOpen :: Boolean, upperOpen :: Boolean }
    -> Maybe KeyRange
bound { lower: key1, upper: key2, lowerOpen: open1, upperOpen: open2 } =
  toMaybe
  $ Fn.runFn4 _bound (extractForeign $ toKey key1) (extractForeign $ toKey key2) open1 open2


--------------------
-- ATTRIBUTES
--
-- | Returns lower bound if any.
lower
    :: KeyRange
    -> Maybe Key
lower =
  _lower >>> toMaybe >>> map Key


-- | Returns upper bound if any.
upper
    :: KeyRange
    -> Maybe Key
upper =
  _upper >>> toMaybe >>> map Key


-- | Returns true if the lower open flag is set, false otherwise.
lowerOpen
    :: KeyRange
    -> Boolean
lowerOpen =
  _lowerOpen


-- | Returns true if the upper open flag is set, false otherwise.
upperOpen
    :: KeyRange
    -> Boolean
upperOpen =
  _upperOpen


--------------------
-- INSTANCES
--
instance idbKeyRangeKeyRange :: IDBKeyRange KeyRange where
  includes range =
    toKey >>> extractForeign >>> Fn.runFn2 _includes range


--------------------
-- FFI
--
foreign import _bound
  :: Fn4 Foreign Foreign Boolean Boolean (Nullable KeyRange)


foreign import _includes
  :: forall range
  .  Fn2 range Foreign Boolean


foreign import _lower
  :: KeyRange
  -> Nullable Foreign


foreign import _lowerBound
  :: Fn2 Foreign Boolean KeyRange


foreign import _lowerOpen
  :: KeyRange
  -> Boolean


foreign import _only
  :: Foreign
  -> KeyRange


foreign import _upper
  :: KeyRange
  -> Nullable Foreign


foreign import _upperBound
  :: Fn2 Foreign Boolean KeyRange


foreign import _upperOpen
  :: KeyRange
  -> Boolean
