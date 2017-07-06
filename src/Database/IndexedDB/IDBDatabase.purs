-- | Each origin has an associated set of databases. A database has zero or more object
-- | stores which hold the data stored in the database.
module Database.IndexedDB.IDBDatabase
  ( class IDBDatabase, close, createObjectStore, deleteObjectStore, transaction
  , StoreName
  , name
  , objectStoreNames
  , version
  , onAbort
  , onClose
  , onError
  , onVersionChange
  ) where

import Prelude                           (Unit, show)

import Control.Monad.Aff                 (Aff)
import Control.Monad.Eff                 (Eff)
import Control.Monad.Eff.Exception       (Error)
import Data.Function.Uncurried            as Fn
import Data.Function.Uncurried           (Fn2, Fn3)

import Database.IndexedDB.Core
import Database.IndexedDB.IDBObjectStore (IDBObjectStoreParameters)


--------------------
-- INTERFACE
--
-- | The IDBDatabase interface represents a connection to a database.
class IDBDatabase db where
  -- | Closes the connection once all running transactions have finished.
  close :: forall e. db -> Aff (idb :: IDB | e) Unit

  -- | Creates a new object store with the given name and options and returns a new IDBObjectStore.
  -- |
  -- | Throws a "InvalidStateError" DOMException if not called within an upgrade transaction
  createObjectStore :: forall e. db -> StoreName -> IDBObjectStoreParameters -> Aff (idb :: IDB | e) ObjectStore

  -- | Deletes the object store with the given name.
  -- |
  -- | Throws a "InvalidStateError" DOMException if not called within an upgrade transaction.
  deleteObjectStore :: forall e.  db -> StoreName -> Aff (idb :: IDB | e) ObjectStore

  -- | Returns a new transaction with the given mode (ReadOnly|ReadWrite)
  -- | and scope which in the form of an array of object store names.
  transaction :: forall e. db -> Array StoreName -> TransactionMode -> Aff (idb :: IDB | e) Transaction


type StoreName = String


--------------------
-- ATTRIBUTES
--
-- | Returns the name of the database.
name
    :: Database
    -> String
name =
  _name


-- | Returns a list of the names of object stores in the database.
objectStoreNames
    :: Database
    -> Array String
objectStoreNames =
  _objectStoreNames


-- | Returns the version of the database.
version
    :: Database
    -> Int
version =
  _version


--------------------
-- EVENT HANDLERS
--
-- | Event handler for the `abort` event.
onAbort
    :: forall e e'
    .  Database
    -> Eff ( | e') Unit
    -> Aff (idb :: IDB | e) Unit
onAbort db f =
  Fn.runFn2 _onAbort db f


-- | Event handler for the `close` event.
onClose
    :: forall e e'
    .  Database
    -> Eff ( | e') Unit
    -> Aff (idb :: IDB | e) Unit
onClose db f =
  Fn.runFn2 _onClose db f


-- | Event handler for the `error` event.
onError
    :: forall e e'
    .  Database
    -> (Error -> Eff ( | e') Unit)
    -> Aff (idb :: IDB | e) Unit
onError db f =
  Fn.runFn2 _onError db f


-- | Event handler for the `versionchange` event.
onVersionChange
    :: forall e e'
    .  Database
    -> ({ oldVersion :: Int, newVersion :: Int }
    -> Eff ( | e') Unit)
    -> Aff (idb :: IDB | e) Unit
onVersionChange db f =
  Fn.runFn2 _onVersionChange db f


--------------------
-- INSTANCES
--
instance idbDatabaseDatabase :: IDBDatabase Database where
  close =
    _close

  createObjectStore db name' opts =
    Fn.runFn3 _createObjectStore db name' opts

  deleteObjectStore db name' =
    Fn.runFn2 _deleteObjectStore db name'

  transaction db stores mode' =
    Fn.runFn3 _transaction db stores (show mode')


--------------------
-- FFI
--
foreign import _close
    :: forall db e
    .  db
    -> Aff (idb :: IDB | e) Unit


foreign import _createObjectStore
    :: forall db e
    .  Fn3 db String { keyPath :: Array String, autoIncrement :: Boolean } (Aff (idb :: IDB | e) ObjectStore)


foreign import _deleteObjectStore
    :: forall db e
    .  Fn2 db String (Aff (idb :: IDB | e) ObjectStore)


foreign import _name
    :: Database
    -> String


foreign import _objectStoreNames
    :: Database
    -> Array String


foreign import _onAbort
    :: forall db e e'
    .  Fn2 db (Eff ( | e') Unit) (Aff (idb :: IDB | e) Unit)


foreign import _onClose
    :: forall db e e'
    .  Fn2 db (Eff ( | e') Unit) (Aff (idb :: IDB | e) Unit)


foreign import _onError
    :: forall db e e'
    .  Fn2 db (Error -> Eff ( | e') Unit) (Aff (idb :: IDB | e) Unit)


foreign import _onVersionChange
    :: forall db e e'
    .  Fn2 db ({ oldVersion :: Int, newVersion :: Int } -> Eff ( | e') Unit) (Aff (idb :: IDB | e) Unit)


foreign import _transaction
    :: forall db e
    .  Fn3 db (Array String) String (Aff (idb :: IDB | e) Transaction)


foreign import _version
    :: Database
    -> Int
