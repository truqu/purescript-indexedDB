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

import Database.IndexedDB.Core

import Data.Function.Uncurried (Fn2, Fn3, Fn4)
import Data.Function.Uncurried as Fn
import Data.Maybe (Maybe)
import Data.Nullable (Nullable, toNullable)
import Database.IndexedDB.IDBIndex (count, get, getAllKeys, getKey, openCursor, openKeyCursor)
import Database.IndexedDB.IDBKey.Internal (class IDBKey, Key, unsafeFromKey, toKey)
import Effect.Aff (Aff)
import Effect.Aff.Compat (EffectFnAff, fromEffectFnAff)
import Foreign (Foreign)
import Prelude (Unit, map, ($), (<$>), (>>>), (<<<))

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
  { unique :: Boolean
  , multiEntry :: Boolean
  }

defaultParameters :: IndexParameters
defaultParameters =
  { unique: false
  , multiEntry: false
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
  :: forall key val store
   . (IDBKey key)
  => (IDBObjectStore store)
  => store
  -> val
  -> Maybe key
  -> Aff Key
add store value key =
  map toKey $ fromEffectFnAff $ Fn.runFn3 _add store value (toNullable $ (toKey >>> unsafeFromKey) <$> key)

-- | Deletes all records in store.
clear
  :: forall store
   . (IDBObjectStore store)
  => store
  -> Aff Unit
clear =
  fromEffectFnAff <<< _clear

-- | Creates a new index in store with the given name, keyPath and options and
-- | returns a new IDBIndex. If the keyPath and options define constraints that
-- | cannot be satisfied with the data already in store the upgrade transaction
-- | will abort with a "ConstraintError" DOMException.
-- |
-- | Throws an "InvalidStateError" DOMException if not called within an upgrade transaction.
createIndex
  :: forall store
   . (IDBObjectStore store)
  => store
  -> IndexName
  -> KeyPath
  -> IndexParameters
  -> Aff Index
createIndex store name' path params =
  fromEffectFnAff $ Fn.runFn4 _createIndex store name' path params

-- | Deletes records in store with the given key or in the given key range in query.
delete
  :: forall store
   . (IDBObjectStore store)
  => store
  -> KeyRange
  -> Aff Unit
delete store range =
  fromEffectFnAff $ Fn.runFn2 _delete store range

-- | Deletes the index in store with the given name.
-- |
-- | Throws an "InvalidStateError" DOMException if not called within an upgrade transaction.
deleteIndex
  :: forall store
   . (IDBObjectStore store)
  => store
  -> IndexName
  -> Aff Unit
deleteIndex store name' =
  fromEffectFnAff $ Fn.runFn2 _deleteIndex store name'

-- | Returns an IDBIndex for the index named name in store.
index
  :: forall store
   . (IDBObjectStore store)
  => store
  -> IndexName
  -> Aff Index
index store name' =
  fromEffectFnAff $ Fn.runFn2 _index store name'

-- | Adds or updates a record in store with the given value and key.
-- |
-- | If the store uses in-line keys and key is specified a "DataError" DOMException
-- | will be thrown.
-- |
-- | If put() is used, any existing record with the key will be replaced.
put
  :: forall val key store
   . (IDBKey key)
  => (IDBObjectStore store)
  => store
  -> val
  -> Maybe key
  -> Aff Key
put store value key =
  map toKey $ fromEffectFnAff $ Fn.runFn3 _put store value (toNullable $ (toKey >>> unsafeFromKey) <$> key)

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
  :: forall val store
   . Fn3 store val (Nullable Foreign) (EffectFnAff Foreign)

foreign import _autoIncrement
  :: ObjectStore
  -> Boolean

foreign import _clear
  :: forall store
   . store
  -> EffectFnAff Unit

foreign import _createIndex
  :: forall store
   . Fn4 store String (Array String) { unique :: Boolean, multiEntry :: Boolean } (EffectFnAff Index)

foreign import _delete
  :: forall store
   . Fn2 store KeyRange (EffectFnAff Unit)

foreign import _deleteIndex
  :: forall store
   . Fn2 store String (EffectFnAff Unit)

foreign import _index
  :: forall store
   . Fn2 store String (EffectFnAff Index)

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
  :: forall val store
   . Fn3 store val (Nullable Foreign) (EffectFnAff Foreign)

foreign import _transaction
  :: ObjectStore
  -> Transaction
