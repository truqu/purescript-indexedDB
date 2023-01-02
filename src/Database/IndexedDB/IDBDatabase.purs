-- | Each origin has an associated set of databases. A database has zero or more object
-- | stores which hold the data stored in the database.
module Database.IndexedDB.IDBDatabase
  -- * Types
  ( StoreName
  , ObjectStoreParameters
  , defaultParameters

  -- * Interface
  , close
  , createObjectStore
  , deleteObjectStore
  , transaction

  -- * Attributes
  , name
  , objectStoreNames
  , version

  -- * Event handlers
  , onAbort
  , onClose
  , onError
  , onVersionChange
  ) where

import Database.IndexedDB.Core

import Data.Function.Uncurried (Fn2, Fn3)
import Data.Function.Uncurried as Fn
import Effect (Effect)
import Effect.Aff (Aff)
import Effect.Aff.Compat (EffectFnAff, fromEffectFnAff)
import Effect.Exception (Error)
import Prelude (Unit, show, (<<<), ($))

--------------------
-- TYPES
--

-- | Type alias for StoreName
type StoreName = String

-- | Options provided when creating an object store.
type ObjectStoreParameters =
  { keyPath :: KeyPath
  , autoIncrement :: Boolean
  }

defaultParameters :: ObjectStoreParameters
defaultParameters =
  { keyPath: []
  , autoIncrement: false
  }

--------------------
-- INTERFACE
--

-- | Closes the connection once all running transactions have finished.
close
  :: forall db
   . (IDBDatabase db)
  => db
  -> Aff Unit
close =
  fromEffectFnAff <<< _close

-- | Creates a new object store with the given name and options and returns a new IDBObjectStore.
-- |
-- | Throws a "InvalidStateError" DOMException if not called within an upgrade transaction
createObjectStore
  :: forall db
   . (IDBDatabase db)
  => db
  -> StoreName
  -> ObjectStoreParameters
  -> Aff ObjectStore
createObjectStore db name' opts =
  fromEffectFnAff $ Fn.runFn3 _createObjectStore db name' opts

-- | Deletes the object store with the given name.
-- |
-- | Throws a "InvalidStateError" DOMException if not called within an upgrade transaction.
deleteObjectStore
  :: forall db
   . (IDBDatabase db)
  => db
  -> StoreName
  -> Aff ObjectStore
deleteObjectStore db name' =
  fromEffectFnAff $ Fn.runFn2 _deleteObjectStore db name'

-- | Returns a new transaction with the given mode (ReadOnly|ReadWrite)
-- | and scope which in the form of an array of object store names.
transaction
  :: forall db
   . (IDBDatabase db)
  => db
  -> Array StoreName
  -> TransactionMode
  -> Aff Transaction
transaction db stores mode' =
  fromEffectFnAff $ Fn.runFn3 _transaction db stores (show mode')

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
  :: Database
  -> Effect Unit
  -> Aff Unit
onAbort db f =
  fromEffectFnAff $ Fn.runFn2 _onAbort db f

-- | Event handler for the `close` event.
onClose
  :: Database
  -> Effect Unit
  -> Aff Unit
onClose db f =
  fromEffectFnAff $ Fn.runFn2 _onClose db f

-- | Event handler for the `error` event.
onError
  :: Database
  -> (Error -> Effect Unit)
  -> Aff Unit
onError db f =
  fromEffectFnAff $ Fn.runFn2 _onError db f

-- | Event handler for the `versionchange` event.
onVersionChange
  :: Database
  -> ( { oldVersion :: Int, newVersion :: Int }
       -> Effect Unit
     )
  -> Aff Unit
onVersionChange db f =
  fromEffectFnAff $ Fn.runFn2 _onVersionChange db f

--------------------
-- FFI
--

foreign import _close
  :: forall db
   . db
  -> EffectFnAff Unit

foreign import _createObjectStore
  :: forall db
   . Fn3 db String { keyPath :: Array String, autoIncrement :: Boolean } (EffectFnAff ObjectStore)

foreign import _deleteObjectStore
  :: forall db
   . Fn2 db String (EffectFnAff ObjectStore)

foreign import _name
  :: Database
  -> String

foreign import _objectStoreNames
  :: Database
  -> Array String

foreign import _onAbort
  :: forall db
   . Fn2 db (Effect Unit) (EffectFnAff Unit)

foreign import _onClose
  :: forall db
   . Fn2 db (Effect Unit) (EffectFnAff Unit)

foreign import _onError
  :: forall db
   . Fn2 db (Error -> Effect Unit) (EffectFnAff Unit)

foreign import _onVersionChange
  :: forall db
   . Fn2 db ({ oldVersion :: Int, newVersion :: Int } -> Effect Unit) (EffectFnAff Unit)

foreign import _transaction
  :: forall db
   . Fn3 db (Array String) String (EffectFnAff Transaction)

foreign import _version
  :: Database
  -> Int
