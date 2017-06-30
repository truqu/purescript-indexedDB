module Database.IndexedDB.IDBIndex.Internal where

import Prelude

import Control.Monad.Aff           (Aff)
import Data.Foreign                (Foreign, unsafeFromForeign)
import Data.Function.Uncurried      as Fn
import Data.Function.Uncurried     (Fn2, Fn3)
import Data.Maybe                  (Maybe)
import Data.Nullable               (Nullable, toMaybe, toNullable)

import Database.IndexedDB.Core     (IDB, CursorDirection, Index, Key, KeyCursor, KeyRange,
                                   KeyPath, ObjectStore, ValueCursor)


--------------------
-- INTERFACES
--
class IDBIndex index where
  count :: forall e. index -> Maybe KeyRange -> Aff (idb :: IDB | e) Int
  get :: forall a e. index -> KeyRange -> Aff (idb :: IDB | e) (Maybe a)
  getAllKeys :: forall e. index -> Maybe KeyRange -> Maybe Int -> Aff (idb :: IDB | e) (Array Key)
  getKey :: forall e. index -> KeyRange -> Aff (idb :: IDB | e) (Maybe Key)
  openCursor :: forall e. index -> Maybe KeyRange -> CursorDirection -> Aff (idb :: IDB | e) ValueCursor
  openKeyCursor :: forall e. index -> Maybe KeyRange -> CursorDirection -> Aff (idb :: IDB | e) KeyCursor


type IDBIndexParameters =
  { unique     :: Boolean
  , multiEntry :: Boolean
  }


--------------------
-- ATTRIBUTES
--
keyPath :: Index -> KeyPath
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
    Fn.runFn3 _openCursor index (toNullable range) (show dir)

  openKeyCursor index range dir =
    Fn.runFn3 _openKeyCursor index (toNullable range) (show dir)


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
    Fn.runFn3 _openCursor store (toNullable range) (show dir)

  openKeyCursor store range dir =
    Fn.runFn3 _openKeyCursor store (toNullable range) (show dir)


defaultParameters :: IDBIndexParameters
defaultParameters =
  { unique     : false
  , multiEntry : false
  }


--------------------
-- FFI
--
foreign import _keyPath :: Index -> Array String


foreign import _multiEntry :: Index -> Boolean


foreign import _name :: Index -> String


foreign import _objectStore :: Index -> ObjectStore


foreign import _unique :: Index -> Boolean


foreign import _count :: forall index e. Fn2 index (Nullable KeyRange) (Aff (idb :: IDB | e) Int)


foreign import _get :: forall index e. Fn2 index KeyRange (Aff (idb :: IDB | e) (Nullable Foreign))


foreign import _getAllKeys :: forall index e. Fn3 index (Nullable KeyRange) (Nullable Int) (Aff (idb :: IDB | e) (Array Key))


foreign import _getKey :: forall index e. Fn2 index KeyRange (Aff (idb :: IDB | e) (Nullable Key))


foreign import _openCursor :: forall index e. Fn3 index (Nullable KeyRange) String (Aff (idb :: IDB | e) ValueCursor)


foreign import _openKeyCursor :: forall index e. Fn3 index (Nullable KeyRange) String (Aff (idb :: IDB | e) KeyCursor)
