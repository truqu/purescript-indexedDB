module Database.IndexedDB.IDBKeyRange
  ( class IDBKeyRange, includes
  , Range(..)
  , new
  , lower
  , upper
  , lowerOpen
  , upperOpen
  ) where

import Prelude

import Data.Function.Uncurried      as Fn
import Data.Function.Uncurried     (Fn2, Fn4)
import Data.Foreign                (Foreign)

import Database.IndexedDB.Core     (KeyRange)
import Database.IndexedDB.IDBKey.Internal (Key(..), extractForeign)


--------------------
-- INTERFACES
--
class IDBKeyRange range where
  includes :: range -> Key -> Boolean


data Range key
  = Only key
  | LowerBound { lower :: key, lowerOpen :: Boolean }
  | UpperBound { upper :: key, upperOpen :: Boolean }
  | Bound { lower :: key, upper :: key, lowerOpen :: Boolean, upperOpen :: Boolean }


new :: Range Key -> KeyRange
new range =
  case range of
    Only key ->
      _only (extractForeign key)

    LowerBound { lower: key, lowerOpen: open } ->
      Fn.runFn2 _lowerBound (extractForeign key) open

    UpperBound { upper: key, upperOpen: open } ->
      Fn.runFn2 _upperBound (extractForeign key) open

    Bound { lower: key1, upper: key2, lowerOpen: open1, upperOpen: open2 } ->
      Fn.runFn4 _bound (extractForeign key1) (extractForeign key2) open1 open2


--------------------
-- ATTRIBUTES
--
lower :: KeyRange -> Key
lower =
  _lower >>> Key


upper :: KeyRange -> Key
upper =
  _upper >>> Key


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
foreign import _bound :: Fn4 Foreign Foreign Boolean Boolean KeyRange


foreign import _includes :: forall range. Fn2 range Foreign Boolean


foreign import _lower :: KeyRange -> Foreign


foreign import _lowerBound :: Fn2 Foreign Boolean KeyRange


foreign import _lowerOpen :: KeyRange -> Boolean


foreign import _only :: Foreign -> KeyRange


foreign import _upper :: KeyRange -> Foreign


foreign import _upperBound :: Fn2 Foreign Boolean KeyRange


foreign import _upperOpen :: KeyRange -> Boolean
