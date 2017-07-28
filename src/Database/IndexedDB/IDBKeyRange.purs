-- | A key has an associated type which is one of: number, date, string, binary, or array.
module Database.IndexedDB.IDBKeyRange
  -- * Types
  ( Open

  -- * Constructors
  , only
  , lowerBound
  , upperBound
  , bound

  -- * Interface
  , includes

  -- * Attributes
  , lower
  , upper
  , lowerOpen
  , upperOpen
  ) where

import Prelude                            (($), (>>>))

import Data.Foreign                       (Foreign)
import Data.Function.Uncurried             as Fn
import Data.Function.Uncurried            (Fn2, Fn4)
import Data.Maybe                         (Maybe)
import Data.Nullable                      (Nullable, toMaybe)

import Database.IndexedDB.Core            (class IDBKeyRange, KeyRange)
import Database.IndexedDB.IDBKey.Internal (class IDBKey, toKey, toForeign)


--------------------
-- TYPES
--

-- | Type alias for open
type Open = Boolean


--------------------
-- CONSTRUCTORS
--

-- | Returns a new IDBKeyRange spanning only key.
only
    :: forall a. (IDBKey a)
    => a
    -> KeyRange
only key =
  _only (toForeign $ toKey key)


-- | Returns a new IDBKeyRange starting at key with no upper bound.
-- | If `Open` is `true`, key is not included in the range.
lowerBound
    :: forall a. (IDBKey a)
    => a
    -> Open
    -> KeyRange
lowerBound key open =
  Fn.runFn2 _lowerBound (toForeign $ toKey key) open


-- | Returns a new IDBKeyRange with no lower bound and ending at key.
-- | If `Open` is `true`, key is not included in the range.
upperBound
    :: forall a. (IDBKey a)
    => a
    -> Open
    -> KeyRange
upperBound key open =
  Fn.runFn2 _upperBound (toForeign $ toKey key) open


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
  $ Fn.runFn4 _bound (toForeign $ toKey key1) (toForeign $ toKey key2) open1 open2


--------------------
-- INTERFACE
--

-- | Returns true if key is included in the range, and false otherwise.
includes
  :: forall k range. (IDBKey k) => (IDBKeyRange range)
  => range
  -> k
  -> Boolean
includes range =
  toKey >>> toForeign >>> Fn.runFn2 _includes range


--------------------
-- ATTRIBUTES
--
-- | Returns lower bound if any.
lower
  :: forall key. (IDBKey key)
  => KeyRange
  -> Maybe key
lower =
  _lower >>> toMaybe


-- | Returns upper bound if any.
upper
  :: forall key. (IDBKey key)
  => KeyRange
  -> Maybe key
upper =
  _upper >>> toMaybe


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
-- FFI
--

foreign import _only
  :: Foreign
  -> KeyRange

foreign import _lowerBound
  :: Fn2 Foreign Boolean KeyRange


foreign import _upperBound
  :: Fn2 Foreign Boolean KeyRange


foreign import _bound
  :: Fn4 Foreign Foreign Boolean Boolean (Nullable KeyRange)


foreign import _includes
  :: forall range
  .  Fn2 range Foreign Boolean


foreign import _lower
  :: forall key. (IDBKey key)
  => KeyRange
  -> Nullable key


foreign import _upper
  :: forall key. (IDBKey key)
  => KeyRange
  -> Nullable key


foreign import _lowerOpen
  :: KeyRange
  -> Boolean


foreign import _upperOpen
  :: KeyRange
  -> Boolean
