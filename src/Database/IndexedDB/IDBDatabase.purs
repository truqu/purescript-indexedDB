module Database.IndexedDB.IDBDatabase where

import Prelude

import Control.Monad.Aff(Aff)
import Control.Monad.Eff(Eff)
import Control.Monad.Eff.Exception(EXCEPTION)
import Data.Function.Uncurried as Fn
import Data.Function.Uncurried(Fn2, Fn3)
import Data.Maybe(Maybe)

import Database.IndexedDB.Core


foreign import close :: forall eff. IDBDatabase -> Synchronous eff Unit


foreign import _createObjectStore :: forall eff. Fn3 IDBDatabase String { keyPath :: Maybe String, autoIncrement :: Boolean } (Synchronous eff IDBObjectStore)
createObjectStore :: forall eff .  IDBDatabase -> String -> { keyPath :: Maybe String, autoIncrement :: Boolean } -> Synchronous eff IDBObjectStore
createObjectStore db name opts =
  Fn.runFn3 _createObjectStore db name opts


foreign import _deleteObjectStore :: forall eff. Fn2 IDBDatabase String (Synchronous eff IDBObjectStore)
deleteObjectStore :: forall eff .  IDBDatabase -> String -> Synchronous eff IDBObjectStore
deleteObjectStore db name =
  Fn.runFn2 _deleteObjectStore db name


foreign import name :: IDBDatabase -> String


foreign import objectStoreNames :: IDBDatabase -> Array String


foreign import _transaction :: forall eff. Fn3 IDBDatabase (Array String) IDBTransactionMode (Synchronous eff IDBTransaction)
transaction :: forall eff. IDBDatabase -> Array String -> IDBTransactionMode -> Synchronous eff IDBTransaction
transaction db stores mode =
  Fn.runFn3 _transaction db stores mode


foreign import version :: IDBDatabase -> Int
