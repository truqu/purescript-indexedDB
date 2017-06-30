module Database.IndexedDB.IDBObjectStore
  ( class IDBObjectStore, add, clear, createIndex, delete, deleteIndex, index, put
  , module Database.IndexedDB.IDBIndex.Internal
  , IDBObjectStoreParameters
  , IndexName
  , autoIncrement
  , indexNames
  , keyPath
  , name
  , transaction
  , defaultParameters
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

import Database.IndexedDB.Core              (IDB, Index, KeyRange, KeyPath, ObjectStore, Transaction)
import Database.IndexedDB.IDBIndex.Internal (class IDBIndex, IDBIndexParameters, count, get, getAllKeys, getKey, openCursor, openKeyCursor)
import Database.IndexedDB.IDBKey.Internal   (Key(Key), extractForeign)


--------------------
-- INTERFACES
--
class IDBObjectStore store where
  add :: forall value e. store -> value -> Maybe Key -> Aff (idb :: IDB | e) Key
  clear :: forall e. store -> Aff (idb :: IDB | e) Unit
  createIndex :: forall e. store -> IndexName -> KeyPath -> IDBIndexParameters -> Eff (idb :: IDB, exception :: EXCEPTION | e) Index
  delete :: forall e. store -> KeyRange -> Aff (idb :: IDB | e) Unit
  deleteIndex :: forall e. store -> IndexName -> Eff (idb :: IDB, exception :: EXCEPTION | e) Unit
  index :: forall e. store -> IndexName -> Eff (idb :: IDB, exception :: EXCEPTION | e) Index
  put :: forall value e. store -> value -> Maybe Key -> Aff (idb :: IDB | e) Key


type IndexName = String


type IDBObjectStoreParameters =
  { keyPath       :: KeyPath
  , autoIncrement :: Boolean
  }


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


transaction :: ObjectStore -> Transaction
transaction =
  _transaction


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


defaultParameters :: IDBObjectStoreParameters
defaultParameters =
  { keyPath       : []
  , autoIncrement : false
  }


--------------------
-- FFI
--
foreign import _add :: forall value e. Fn3 ObjectStore value (Nullable Foreign) (Aff (idb :: IDB | e) Foreign)


foreign import _autoIncrement :: ObjectStore -> Boolean


foreign import _clear :: forall e. ObjectStore -> Aff (idb :: IDB | e) Unit


foreign import _createIndex :: forall e. Fn4 ObjectStore String (Array String) { unique :: Boolean, multiEntry :: Boolean } (Eff (idb :: IDB | e) Index)


foreign import _delete :: forall e. Fn2 ObjectStore KeyRange (Aff (idb :: IDB | e) Unit)


foreign import _deleteIndex :: forall e. Fn2 ObjectStore String (Eff (idb :: IDB | e) Unit)


foreign import _index :: forall e. Fn2 ObjectStore String (Eff (idb :: IDB | e) Index)


foreign import _indexNames :: ObjectStore -> Array String


foreign import _keyPath :: ObjectStore -> Array String


foreign import _name :: ObjectStore -> String


foreign import _put :: forall value e. Fn3 ObjectStore value (Nullable Foreign) (Aff (idb :: IDB | e) Foreign)


foreign import _transaction :: ObjectStore -> Transaction
