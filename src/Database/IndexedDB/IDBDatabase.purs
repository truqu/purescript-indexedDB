module Database.IndexedDB.IDBDatabase where

import Prelude

import Control.Monad.Aff(Aff)
import Control.Monad.Eff(Eff)
import Control.Monad.Eff.Exception(EXCEPTION)
import Data.Function.Uncurried as Fn
import Data.Function.Uncurried(Fn2, Fn3, Fn4)
import Data.Maybe(Maybe, fromMaybe)

import Database.IndexedDB.Core


foreign import close :: forall eff. IDBDatabase -> Eff (idb :: INDEXED_DB, exception :: EXCEPTION | eff) Unit


foreign import _createObjectStore :: forall a eff. Fn4 (a -> Maybe a -> a) IDBDatabase String { keyPath :: Maybe String, autoIncrement :: Boolean } (Eff (idb :: INDEXED_DB, exception :: EXCEPTION | eff) IDBObjectStore)
createObjectStore :: forall eff. IDBDatabase -> String -> { keyPath :: Maybe String, autoIncrement :: Boolean } -> Eff (idb :: INDEXED_DB, exception :: EXCEPTION | eff) IDBObjectStore
createObjectStore db name opts =
  Fn.runFn4 _createObjectStore fromMaybe db name opts


foreign import _deleteObjectStore :: forall eff. Fn2 IDBDatabase String (Eff (idb :: INDEXED_DB, exception :: EXCEPTION | eff) IDBObjectStore)
deleteObjectStore :: forall eff .  IDBDatabase -> String -> Eff (idb :: INDEXED_DB, exception :: EXCEPTION | eff) IDBObjectStore
deleteObjectStore db name =
  Fn.runFn2 _deleteObjectStore db name


foreign import name :: IDBDatabase -> String


foreign import objectStoreNames :: IDBDatabase -> Array String


foreign import _transaction :: forall eff. Fn3 IDBDatabase (Array String) IDBTransactionMode (Eff (idb :: INDEXED_DB, exception :: EXCEPTION | eff) IDBTransaction)
transaction :: forall eff. IDBDatabase -> Array String -> IDBTransactionMode -> Eff (idb :: INDEXED_DB, exception :: EXCEPTION | eff) IDBTransaction
transaction db stores mode =
  Fn.runFn3 _transaction db stores mode


foreign import version :: IDBDatabase -> Int
