module Database.IndexedDB.IDBIndex
  ( class IDBIndex, count, get, getAllKeys, getKey, openCursor, openKeyCursor
  , keyPath
  , multiEntry
  , name
  , unique
  ) where

import Prelude

import Control.Monad.Aff           (Aff)
import Control.Monad.Eff.Exception (EXCEPTION)
import Data.Function.Uncurried      as Fn
import Data.Function.Uncurried     (Fn2, Fn3)
import Data.Maybe                  (Maybe)
import Data.Nullable               (Nullable, toMaybe, toNullable)
import Data.Foreign                (Foreign, unsafeFromForeign)

import Database.IndexedDB.Core     (INDEXED_DB, CursorDirection, Index, Key, KeyCursor, KeyRange, ObjectStore, ValueCursor)


--------------------
-- INTERFACES
--
class IDBIndex index where
  count :: forall eff. index -> Maybe KeyRange -> Aff (idb :: INDEXED_DB, exception :: EXCEPTION | eff) Int
  get :: forall a eff. index -> KeyRange -> Aff (idb :: INDEXED_DB, exception :: EXCEPTION | eff) (Maybe a)
  getAllKeys :: forall eff. index -> Maybe KeyRange -> Maybe Int -> Aff (idb :: INDEXED_DB, exception :: EXCEPTION | eff) (Array Key)
  getKey :: forall eff. index -> KeyRange -> Aff (idb :: INDEXED_DB, exception :: EXCEPTION | eff) (Maybe Key)
  openCursor :: forall eff. index -> Maybe KeyRange -> Maybe CursorDirection -> Aff (idb :: INDEXED_DB, exception :: EXCEPTION | eff) ValueCursor
  openKeyCursor :: forall eff. index -> Maybe KeyRange -> Maybe CursorDirection -> Aff (idb :: INDEXED_DB, exception :: EXCEPTION | eff) KeyCursor


--------------------
-- ATTRIBUTES
--
keyPath :: Index -> String
keyPath =
  _keyPath


multiEntry :: Index -> Boolean
multiEntry =
  _multiEntry


name :: Index -> String
name =
  _name


objectStore :: Index -> ObjectStore
objectStore =
  _objectStore


unique :: Index -> Boolean
unique =
  _unique


--------------------
-- INSTANCES
--
instance idbIndexIndex :: IDBIndex Index where
  count index range =
    Fn.runFn2 _count index (toNullable range)

  get index range =
    (toMaybe >>> map unsafeFromForeign) <$> Fn.runFn2 _get index range

  getAllKeys index range count =
    Fn.runFn3 _getAllKeys index (toNullable range) (toNullable count)

  getKey index range =
    toMaybe <$> Fn.runFn2 _getKey index range

  openCursor index range dir =
    Fn.runFn3 _openCursor index (toNullable range) (toNullable dir)

  openKeyCursor index range dir =
    Fn.runFn3 _openKeyCursor index (toNullable range) (toNullable dir)


instance idbIndexObjectStore :: IDBIndex ObjectStore where
  count store range =
    Fn.runFn2 _count store (toNullable range)

  get store range =
    (toMaybe >>> map unsafeFromForeign) <$> Fn.runFn2 _get store range

  getAllKeys store range count =
    Fn.runFn3 _getAllKeys store (toNullable range) (toNullable count)

  getKey store range =
    toMaybe <$> Fn.runFn2 _getKey store range

  openCursor store range dir =
    Fn.runFn3 _openCursor store (toNullable range) (toNullable dir)

  openKeyCursor store range dir =
    Fn.runFn3 _openKeyCursor store (toNullable range) (toNullable dir)


--------------------
-- FFI
--
foreign import _keyPath :: Index -> String


foreign import _multiEntry :: Index -> Boolean


foreign import _name :: Index -> String


foreign import _objectStore :: Index -> ObjectStore


foreign import _unique :: Index -> Boolean


foreign import _count :: forall index eff. Fn2 index (Nullable KeyRange) (Aff (idb :: INDEXED_DB, exception :: EXCEPTION | eff) Int)


foreign import _get :: forall index eff. Fn2 index KeyRange (Aff (idb :: INDEXED_DB, exception :: EXCEPTION | eff) (Nullable Foreign))


foreign import _getAllKeys :: forall index eff. Fn3 index (Nullable KeyRange) (Nullable Int) (Aff (idb :: INDEXED_DB, exception :: EXCEPTION | eff) (Array Key))


foreign import _getKey :: forall index eff. Fn2 index KeyRange (Aff (idb :: INDEXED_DB, exception :: EXCEPTION | eff) (Nullable Key))


foreign import _openCursor :: forall index eff. Fn3 index (Nullable KeyRange) (Nullable CursorDirection) (Aff (idb :: INDEXED_DB, exception :: EXCEPTION | eff) ValueCursor)


foreign import _openKeyCursor :: forall index eff. Fn3 index (Nullable KeyRange) (Nullable CursorDirection) (Aff (idb :: INDEXED_DB, exception :: EXCEPTION | eff) KeyCursor)
