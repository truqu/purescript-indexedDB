-- | An object store is the primary storage mechanism for storing data in a database.
module Database.IndexedDB.IDBObjectStore
  -- * Types
  ( IndexName
  , IndexParameters
  , defaultParameters

  -- * Interface
  , add
  , clear
  , createIndex
  , delete
  , deleteIndex
  , index
  , put

  -- * Attributes
  , autoIncrement
  , indexNames
  , keyPath
  , name
  , transaction

  -- * Re-Exports
  , module Database.IndexedDB.IDBIndex
  ) where

import Prelude                            (Unit, ($), (<$>), (>>>))

import Control.Monad.Aff                  (Aff)
import Control.Monad.Aff.Compat (EffFnAff, fromEffFnAff)
import Data.Foreign                       (Foreign)
import Data.Function.Uncurried             as Fn
import Data.Function.Uncurried            (Fn2, Fn3, Fn4)
import Data.Maybe                         (Maybe)
import Data.Nullable                      (Nullable, toNullable)

import Database.IndexedDB.Core
import Database.IndexedDB.IDBIndex        (count, get, getAllKeys, getKey, openCursor, openKeyCursor)
import Database.IndexedDB.IDBKey.Internal (class IDBKey, Key, unsafeFromKey, toKey)

--------------------
-- TYPES
--

-- | Type alias for IndexName
type IndexName = String


-- | Flags to set on the index.
-- |
-- | An index has a `unique` flag. When this flag is set, the index enforces that no
-- | two records in the index has the same key. If a record in the index’s referenced
-- | object store is attempted to be inserted or modified such that evaluating the index’s
-- | key path on the records new value yields a result which already exists in the index,
-- | then the attempted modification to the object store fails.
-- |
-- | An index has a `multiEntry` flag. This flag affects how the index behaves when the
-- | result of evaluating the index’s key path yields an array key. If the `multiEntry` flag
-- | is unset, then a single record whose key is an array key is added to the index.
-- | If the `multiEntry` flag is true, then the one record is added to the index for each
-- | of the subkeys.
type IndexParameters =
  { unique     :: Boolean
  , multiEntry :: Boolean
  }


defaultParameters :: IndexParameters
defaultParameters =
  { unique     : false
  , multiEntry : false
  }


--------------------
-- INTERFACES
--

-- | Adds or updates a record in store with the given value and key.
-- |
-- | If the store uses in-line keys and key is specified a "DataError" DOMException
-- | will be thrown.
-- |
-- | If add() is used, and if a record with the key already exists the request will fail,
-- | with a "ConstraintError" DOMException.
add
  :: forall e key val store. (IDBKey key) => (IDBObjectStore store)
  => store
  -> val
  -> Maybe key
  -> Aff (idb :: IDB | e) Key
add store value key =
  toKey <$> fromEffFnAff (Fn.runFn3 _add store value (toNullable $ (toKey >>> unsafeFromKey) <$> key))


-- | Deletes all records in store.
clear
  :: forall e store. (IDBObjectStore store)
  => store
  -> Aff (idb :: IDB | e) Unit
clear =
  _clear >>> fromEffFnAff


-- | Creates a new index in store with the given name, keyPath and options and
-- | returns a new IDBIndex. If the keyPath and options define constraints that
-- | cannot be satisfied with the data already in store the upgrade transaction
-- | will abort with a "ConstraintError" DOMException.
-- |
-- | Throws an "InvalidStateError" DOMException if not called within an upgrade transaction.
createIndex
  :: forall e store. (IDBObjectStore store)
  => store
  -> IndexName
  -> KeyPath
  -> IndexParameters
  -> Aff (idb :: IDB | e) Index
createIndex store name' path params =
  fromEffFnAff $ Fn.runFn4 _createIndex store name' path params


-- | Deletes records in store with the given key or in the given key range in query.
delete
  :: forall e store. (IDBObjectStore store)
  => store
  -> KeyRange
  -> Aff (idb :: IDB | e) Unit
delete store range =
  fromEffFnAff $ Fn.runFn2 _delete store range


-- | Deletes the index in store with the given name.
-- |
-- | Throws an "InvalidStateError" DOMException if not called within an upgrade transaction.
deleteIndex
  :: forall e store. (IDBObjectStore store)
  => store
  -> IndexName
  -> Aff (idb :: IDB | e) Unit
deleteIndex store name' =
  fromEffFnAff $ Fn.runFn2 _deleteIndex store name'


-- | Returns an IDBIndex for the index named name in store.
index
  :: forall e store. (IDBObjectStore store)
  => store
  -> IndexName
  -> Aff (idb :: IDB | e) Index
index store name' =
  fromEffFnAff $ Fn.runFn2 _index store name'


-- | Adds or updates a record in store with the given value and key.
-- |
-- | If the store uses in-line keys and key is specified a "DataError" DOMException
-- | will be thrown.
-- |
-- | If put() is used, any existing record with the key will be replaced.
put
  :: forall e val key store. (IDBKey key) => (IDBObjectStore store)
  => store
  -> val
  -> Maybe key
  -> Aff (idb :: IDB | e) Key
put store value key =
  toKey <$> fromEffFnAff (Fn.runFn3 _put store value (toNullable $ (toKey >>> unsafeFromKey) <$> key))


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
-- FFI
--
foreign import _add
  :: forall e val store
  .  Fn3 store val (Nullable Foreign) (EffFnAff (idb :: IDB | e) Foreign)


foreign import _autoIncrement
  :: ObjectStore
  -> Boolean


foreign import _clear
  :: forall e store
  .  store
  -> EffFnAff (idb :: IDB | e) Unit


foreign import _createIndex
  :: forall e store
  .  Fn4 store String (Array String) { unique :: Boolean, multiEntry :: Boolean } (EffFnAff (idb :: IDB | e) Index)


foreign import _delete
  :: forall e store
  .  Fn2 store KeyRange (EffFnAff (idb :: IDB | e) Unit)


foreign import _deleteIndex
  :: forall e store
  .  Fn2 store String (EffFnAff (idb :: IDB | e) Unit)


foreign import _index
  :: forall e store
  .  Fn2 store String (EffFnAff (idb :: IDB | e) Index)


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
  :: forall e val store
  .  Fn3 store val (Nullable Foreign) (EffFnAff (idb :: IDB | e) Foreign)


foreign import _transaction
  :: ObjectStore
  -> Transaction
