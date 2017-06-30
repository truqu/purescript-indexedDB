module Database.IndexedDB.IDBDatabase
  ( class IDBDatabase, close, createObjectStore, deleteObjectStore, transaction
  , StoreName
  , name
  , objectStoreNames
  , version
  ) where

import Prelude                           (Unit, show)

import Control.Monad.Eff                 (Eff)
import Control.Monad.Eff.Exception       (EXCEPTION)
import Data.Function.Uncurried            as Fn
import Data.Function.Uncurried           (Fn2, Fn3, Fn4)

import Database.IndexedDB.Core
import Database.IndexedDB.IDBObjectStore (IDBObjectStoreParameters)


--------------------
-- INTERFACE
--
class IDBDatabase db where
  close :: forall eff. db -> Eff (idb :: INDEXED_DB, exception :: EXCEPTION | eff) Unit
  createObjectStore :: forall eff. db -> StoreName -> IDBObjectStoreParameters -> Eff (idb :: INDEXED_DB, exception :: EXCEPTION | eff) ObjectStore
  deleteObjectStore :: forall eff .  db -> StoreName -> Eff (idb :: INDEXED_DB, exception :: EXCEPTION | eff) ObjectStore
  transaction :: forall eff. db -> KeyPath -> TransactionMode -> Eff (idb :: INDEXED_DB, exception :: EXCEPTION | eff) Transaction


type StoreName = String


--------------------
-- ATTRIBUTES
--
name :: Database -> String
name =
  _name


objectStoreNames :: Database -> Array String
objectStoreNames =
  _objectStoreNames


version :: Database -> Int
version =
  _version


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
    Fn.runFn4 _transaction show db stores mode'


--------------------
-- FFI
--
foreign import _close :: forall db eff. db -> Eff (idb :: INDEXED_DB, exception :: EXCEPTION | eff) Unit


foreign import _createObjectStore :: forall db eff. Fn3 db String { keyPath :: Array String, autoIncrement :: Boolean } (Eff (idb :: INDEXED_DB, exception :: EXCEPTION | eff) ObjectStore)


foreign import _deleteObjectStore :: forall db eff. Fn2 db String (Eff (idb :: INDEXED_DB, exception :: EXCEPTION | eff) ObjectStore)


foreign import _name :: Database -> String


foreign import _objectStoreNames :: Database -> Array String


foreign import _transaction :: forall db eff. Fn4 (db -> String) db (Array String) TransactionMode (Eff (idb :: INDEXED_DB, exception :: EXCEPTION | eff) Transaction)


foreign import _version :: Database -> Int
