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
class IDBKeyRange range where
  includes :: range -> Key -> Boolean


only :: forall a. (IDBKey a) => a -> KeyRange
only key =
  _only (extractForeign $ toKey key)


lowerBound :: forall a. (IDBKey a) => a -> Boolean -> KeyRange
lowerBound key open =
  Fn.runFn2 _lowerBound (extractForeign $ toKey key) open


upperBound :: forall a. (IDBKey a) => a -> Boolean -> KeyRange
upperBound key open =
  Fn.runFn2 _upperBound (extractForeign $ toKey key) open

bound :: forall a. (IDBKey a) => { lower :: a, upper :: a, lowerOpen :: Boolean, upperOpen :: Boolean } -> Maybe KeyRange
bound { lower: key1, upper: key2, lowerOpen: open1, upperOpen: open2 } =
  toMaybe
  $ Fn.runFn4 _bound (extractForeign $ toKey key1) (extractForeign $ toKey key2) open1 open2


--------------------
-- ATTRIBUTES
--
lower :: KeyRange -> Maybe Key
lower =
  _lower >>> toMaybe >>> map Key


upper :: KeyRange -> Maybe Key
upper =
  _upper >>> toMaybe >>> map Key


lowerOpen :: KeyRange -> Boolean
lowerOpen =
  _lowerOpen


upperOpen :: KeyRange -> Boolean
upperOpen =
  _upperOpen


--------------------
-- INSTANCES
--
instance idbKeyRangeKeyRange :: IDBKeyRange KeyRange where
  includes range =
    extractForeign >>> Fn.runFn2 _includes range


--------------------
-- FFI
--
foreign import _bound :: Fn4 Foreign Foreign Boolean Boolean (Nullable KeyRange)


foreign import _includes :: forall range. Fn2 range Foreign Boolean


foreign import _lower :: KeyRange -> Nullable Foreign


foreign import _lowerBound :: Fn2 Foreign Boolean KeyRange


foreign import _lowerOpen :: KeyRange -> Boolean


foreign import _only :: Foreign -> KeyRange


foreign import _upper :: KeyRange -> Nullable Foreign


foreign import _upperBound :: Fn2 Foreign Boolean KeyRange


foreign import _upperOpen :: KeyRange -> Boolean
