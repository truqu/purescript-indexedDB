-- | An object store is the primary storage mechanism for storing data in a database.
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

import Prelude                              (Unit, ($), (<$>), (>>>))

import Control.Monad.Aff                    (Aff)
import Data.Foreign                         (Foreign)
import Data.Function.Uncurried               as Fn
import Data.Function.Uncurried              (Fn2, Fn3, Fn4)
import Data.Maybe                           (Maybe)
import Data.Nullable                        (Nullable, toNullable)

import Database.IndexedDB.Core              (IDB, Index, KeyRange, KeyPath, ObjectStore, Transaction)
import Database.IndexedDB.IDBIndex.Internal (class IDBIndex, IDBIndexParameters, count, get, getAllKeys, getKey, openCursor, openKeyCursor)
import Database.IndexedDB.IDBKey.Internal   (class IDBKey, Key(Key), extractForeign, toKey)


--------------------
-- INTERFACES
--
-- | The IDBObjectStore interface represents an object store handle.
class IDBObjectStore store where
  -- | Adds or updates a record in store with the given value and key.
  -- |
  -- | If the store uses in-line keys and key is specified a "DataError" DOMException
  -- | will be thrown.
  -- |
  -- | If add() is used, and if a record with the key already exists the request will fail,
  -- | with a "ConstraintError" DOMException.
  add
    :: forall v k e. (IDBKey k)
    => store
    -> v
    -> Maybe k
    -> Aff (idb :: IDB | e) Key

  -- | Deletes all records in store.
  clear
    :: forall e
    .  store
    -> Aff (idb :: IDB | e) Unit

  -- | Creates a new index in store with the given name, keyPath and options and
  -- | returns a new IDBIndex. If the keyPath and options define constraints that
  -- | cannot be satisfied with the data already in store the upgrade transaction
  -- | will abort with a "ConstraintError" DOMException.
  -- |
  -- | Throws an "InvalidStateError" DOMException if not called within an upgrade transaction.
  createIndex
    :: forall e
    .  store
    -> IndexName
    -> KeyPath
    -> IDBIndexParameters
    -> Aff (idb :: IDB | e) Index

  -- | Deletes records in store with the given key or in the given key range in query.
  delete
    :: forall e
    .  store
    -> KeyRange
    -> Aff (idb :: IDB | e) Unit

  -- | Deletes the index in store with the given name.
  -- |
  -- | Throws an "InvalidStateError" DOMException if not called within an upgrade transaction.
  deleteIndex
    :: forall e
    .  store
    -> IndexName
    -> Aff (idb :: IDB | e) Unit

  -- | Returns an IDBIndex for the index named name in store.
  index
    :: forall e
    .  store
    -> IndexName
    -> Aff (idb :: IDB | e) Index

  -- | Adds or updates a record in store with the given value and key.
  -- |
  -- | If the store uses in-line keys and key is specified a "DataError" DOMException
  -- | will be thrown.
  -- |
  -- | If put() is used, any existing record with the key will be replaced.
  put
    :: forall v k e. (IDBKey k)
    => store
    -> v
    -> Maybe k
    -> Aff (idb :: IDB | e) Key


-- | Type alias for IndexName
type IndexName = String


-- | Options provided when creating an object store.
type IDBObjectStoreParameters =
  { keyPath       :: KeyPath
  , autoIncrement :: Boolean
  }


defaultParameters :: IDBObjectStoreParameters
defaultParameters =
  { keyPath       : []
  , autoIncrement : false
  }


--------------------
-- ATTRIBUTES
--
-- | Returns `true` if the store has a key generator, and `false` otherwise.
autoIncrement
  :: ObjectStore
  -> Boolean
autoIncrement =
  _autoIncrement


--| Returns a list of the names of indexes in the store.
indexNames
  :: ObjectStore
  -> Array String
indexNames =
  _indexNames


-- | Returns the key path of the store, or empty array if none
keyPath
  :: ObjectStore
  -> Array String
keyPath =
  _keyPath


-- | Returns the name of the store.
name
  :: ObjectStore
  -> String
name =
  _name


-- | Returns the associated transaction.
transaction
  :: ObjectStore
  -> Transaction
transaction =
  _transaction


--------------------
-- INSTANCES
--
instance idbObjectStoreObjectStore :: IDBObjectStore ObjectStore where
  add store value key =
    Key <$> Fn.runFn3 _add store value (toNullable $ (toKey >>> extractForeign) <$> key)

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
    Key <$> Fn.runFn3 _put store value (toNullable $ (toKey >>> extractForeign) <$> key)


--------------------
-- FFI
--
foreign import _add
  :: forall value e
  .  Fn3 ObjectStore value (Nullable Foreign) (Aff (idb :: IDB | e) Foreign)


foreign import _autoIncrement
  :: ObjectStore
  -> Boolean


foreign import _clear
  :: forall e
  .  ObjectStore
  -> Aff (idb :: IDB | e) Unit


foreign import _createIndex
  :: forall e
  .  Fn4 ObjectStore String (Array String) { unique :: Boolean, multiEntry :: Boolean } (Aff (idb :: IDB | e) Index)


foreign import _delete
  :: forall e
  .  Fn2 ObjectStore KeyRange (Aff (idb :: IDB | e) Unit)


foreign import _deleteIndex
  :: forall e
  .  Fn2 ObjectStore String (Aff (idb :: IDB | e) Unit)


foreign import _index
  :: forall e
  .  Fn2 ObjectStore String (Aff (idb :: IDB | e) Index)


foreign import _indexNames
  :: ObjectStore
  -> Array String


foreign import _keyPath
  :: ObjectStore
  -> Array String


foreign import _name
  :: ObjectStore
  -> String


foreign import _put
  :: forall value e
  .  Fn3 ObjectStore value (Nullable Foreign) (Aff (idb :: IDB | e) Foreign)


foreign import _transaction
  :: ObjectStore
  -> Transaction
