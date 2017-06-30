module Database.IndexedDB.IDBObjectStore
  ( class IDBObjectStore, add, clear, createIndex, delete, deleteIndex, index, put
  , module Database.IndexedDB.IDBIndex.Internal
  , autoIncrement
  , indexNames
  , keyPath
  , name
  ) where

import Prelude                              (Unit, ($), (<$>))

import Control.Monad.Aff                    (Aff)
import Control.Monad.Eff                    (Eff)
import Control.Monad.Eff.Exception          (EXCEPTION)
import Data.Foreign                         (Foreign)
import Data.Function.Uncurried               as Fn
import Data.Function.Uncurried              (Fn2, Fn3, Fn4)
import Data.Maybe                           (Maybe)
import Data.Nullable                        (Nullable, toNullable)

import Database.IndexedDB.Core              (INDEXED_DB, Index, KeyRange, ObjectStore)
import Database.IndexedDB.IDBIndex.Internal (class IDBIndex, count, get, getAllKeys, getKey, openCursor, openKeyCursor)
import Database.IndexedDB.IDBKey.Internal   (Key(Key), extractForeign)


--------------------
-- INTERFACES
--
class IDBObjectStore store where
  add :: forall value eff. store -> value -> Maybe Key -> Aff (idb :: INDEXED_DB, exception :: EXCEPTION | eff) Key
  clear :: forall eff. store -> Aff (idb :: INDEXED_DB, exception :: EXCEPTION | eff) Unit
  createIndex :: forall eff. store -> String -> (Array String) -> { unique :: Boolean, multiEntry :: Boolean } -> Eff (idb :: INDEXED_DB, exception :: EXCEPTION | eff) Index
  delete :: forall eff. store -> KeyRange -> Aff (idb :: INDEXED_DB, exception :: EXCEPTION | eff) Unit
  deleteIndex :: forall eff. store -> String -> Eff (idb :: INDEXED_DB, exception :: EXCEPTION | eff) Unit
  index :: forall eff. store -> String -> Eff (idb :: INDEXED_DB, exception :: EXCEPTION | eff) Index
  put :: forall value eff. store -> value -> Maybe Key -> Aff (idb :: INDEXED_DB, exception :: EXCEPTION | eff) Key


--------------------
-- ATTRIBUTES
--
autoIncrement :: ObjectStore -> Boolean
autoIncrement =
  _autoIncrement


indexNames :: ObjectStore -> Array String
indexNames =
  _indexNames


keyPath :: ObjectStore -> Array String
keyPath =
  _keyPath


name :: ObjectStore -> String
name =
  _name


--------------------
-- INSTANCES
--
instance idbObjectStoreObjectStore :: IDBObjectStore ObjectStore where
  add store value key =
    Key <$> Fn.runFn3 _add store value (toNullable $ extractForeign <$> key)

  clear =
    _clear

  createIndex store name' path params =
    Fn.runFn4 _createIndex store name' path params

  delete store range =
    Fn.runFn2 _delete store range

  deleteIndex store name' =
    Fn.runFn2 _deleteIndex store name'

  index store name' =
    Fn.runFn2 _index store name'

  put store value key =
    Key <$> Fn.runFn3 _put store value (toNullable $ extractForeign <$> key)


--------------------
-- FFI
--
foreign import _add :: forall value eff. Fn3 ObjectStore value (Nullable Foreign) (Aff (idb :: INDEXED_DB, exception :: EXCEPTION | eff) Foreign)


foreign import _autoIncrement :: ObjectStore -> Boolean


foreign import _clear :: forall eff. ObjectStore -> Aff (idb :: INDEXED_DB, exception :: EXCEPTION | eff) Unit


foreign import _createIndex :: forall eff. Fn4 ObjectStore String (Array String) { unique :: Boolean, multiEntry :: Boolean } (Eff (idb :: INDEXED_DB, exception :: EXCEPTION | eff) Index)


foreign import _delete :: forall eff. Fn2 ObjectStore KeyRange (Aff (idb :: INDEXED_DB, exception :: EXCEPTION | eff) Unit)


foreign import _deleteIndex :: forall eff. Fn2 ObjectStore String (Eff (idb :: INDEXED_DB, exception :: EXCEPTION | eff) Unit)


foreign import _index :: forall eff. Fn2 ObjectStore String (Eff (idb :: INDEXED_DB, exception :: EXCEPTION | eff) Index)


foreign import _indexNames :: ObjectStore -> Array String


foreign import _keyPath :: ObjectStore -> Array String


foreign import _name :: ObjectStore -> String


foreign import _put :: forall value eff. Fn3 ObjectStore value (Nullable Foreign) (Aff (idb :: INDEXED_DB, exception :: EXCEPTION | eff) Foreign)
