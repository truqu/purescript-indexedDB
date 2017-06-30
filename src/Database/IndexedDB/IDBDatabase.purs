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
import Data.Function.Uncurried           (Fn2, Fn3, Fn4)

import Database.IndexedDB.Core
import Database.IndexedDB.IDBObjectStore (IDBObjectStoreParameters)


--------------------
-- INTERFACE
--
class IDBDatabase db where
  close :: forall e. db -> Aff (idb :: IDB | e) Unit
  createObjectStore :: forall e. db -> StoreName -> IDBObjectStoreParameters -> Aff (idb :: IDB | e) ObjectStore
  deleteObjectStore :: forall e.  db -> StoreName -> Aff (idb :: IDB | e) ObjectStore
  transaction :: forall e. db -> Array StoreName -> TransactionMode -> Aff (idb :: IDB | e) Transaction


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
-- EVENT HANDLERS
--
onAbort :: forall e e'. Database -> Eff ( | e') Unit -> Aff (idb :: IDB | e) Unit
onAbort db f =
  Fn.runFn2 _onAbort db f


onClose :: forall e e'. Database -> Eff ( | e') Unit -> Aff (idb :: IDB | e) Unit
onClose db f =
  Fn.runFn2 _onClose db f


onError :: forall e e'. Database -> (Error -> Eff ( | e') Unit) -> Aff (idb :: IDB | e) Unit
onError db f =
  Fn.runFn2 _onError db f


onVersionChange :: forall e e'. Database -> ({ oldVersion :: Int, newVersion :: Int } -> Eff ( | e') Unit) -> Aff (idb :: IDB | e) Unit
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
foreign import _close :: forall db e. db -> Aff (idb :: IDB | e) Unit


foreign import _createObjectStore :: forall db e. Fn3 db String { keyPath :: Array String, autoIncrement :: Boolean } (Aff (idb :: IDB | e) ObjectStore)


foreign import _deleteObjectStore :: forall db e. Fn2 db String (Aff (idb :: IDB | e) ObjectStore)


foreign import _name :: Database -> String


foreign import _objectStoreNames :: Database -> Array String


foreign import _onAbort :: forall db e e'. Fn2 db (Eff ( | e') Unit) (Aff (idb :: IDB | e) Unit)


foreign import _onClose :: forall db e e'. Fn2 db (Eff ( | e') Unit) (Aff (idb :: IDB | e) Unit)


foreign import _onError :: forall db e e'. Fn2 db (Error -> Eff ( | e') Unit) (Aff (idb :: IDB | e) Unit)


foreign import _onVersionChange :: forall db e e'. Fn2 db ({ oldVersion :: Int, newVersion :: Int } -> Eff ( | e') Unit) (Aff (idb :: IDB | e) Unit)


foreign import _transaction :: forall db e. Fn3 db (Array String) String (Aff (idb :: IDB | e) Transaction)


foreign import _version :: Database -> Int
