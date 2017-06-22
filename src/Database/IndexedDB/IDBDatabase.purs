module Database.IndexedDB.IDBDatabase where

import Prelude

import Control.Monad.Aff(Aff)
import Control.Monad.Eff(kind Effect, Eff)
import Control.Monad.Eff.Exception(EXCEPTION)
import Control.Monad.Eff.Console as Console
import Data.Function.Uncurried as Fn
import Data.Function.Uncurried(Fn2, Fn3)
import Data.Maybe(Maybe)

import Database.IndexedDB.Core


type IDBOpenRequest eff =
  { onBlocked       :: Maybe (IDBDatabase -> Eff (idb :: INDEXED_DB | eff) Unit)
  , onUpgradeNeeded :: Maybe (IDBDatabase -> Eff (idb :: INDEXED_DB | eff) Unit)
  }


foreign import close :: forall eff. IDBDatabase -> Eff (idb :: INDEXED_DB, exception :: EXCEPTION | eff) Unit


foreign import _createObjectStore :: forall eff. Fn3 IDBDatabase String { keyPath :: Maybe String, autoIncrement :: Boolean } (Eff (idb :: INDEXED_DB, exception :: EXCEPTION | eff) IDBObjectStore)
createObjectStore :: forall eff .  IDBDatabase -> String -> { keyPath :: Maybe String, autoIncrement :: Boolean } -> Eff (idb :: INDEXED_DB, exception :: EXCEPTION | eff) IDBObjectStore
createObjectStore db name opts =
  Fn.runFn3 _createObjectStore db name opts


foreign import _deleteObjectStore :: forall eff. Fn2 IDBDatabase String (Eff (idb :: INDEXED_DB, exception :: EXCEPTION | eff) IDBObjectStore)
deleteObjectStore :: forall eff .  IDBDatabase -> String -> Eff (idb :: INDEXED_DB, exception :: EXCEPTION | eff) IDBObjectStore
deleteObjectStore db name =
  Fn.runFn2 _deleteObjectStore db name


foreign import deleteDatabase :: forall eff. String -> Aff (idb :: INDEXED_DB | eff) Int


foreign import name :: IDBDatabase -> String


foreign import objectStoreNames :: IDBDatabase -> Array String


foreign import _open :: forall eff. Fn3 String (Maybe Int) (IDBOpenRequest eff) (Aff (idb :: INDEXED_DB | eff) IDBDatabase)
open :: forall eff .  String -> Maybe Int -> IDBOpenRequest eff -> Aff (idb :: INDEXED_DB | eff) IDBDatabase
open name mver req =
  Fn.runFn3 _open name mver req


foreign import _transaction :: forall eff. Fn3 IDBDatabase (Array String) IDBTransactionMode (Eff (idb :: INDEXED_DB, exception :: EXCEPTION | eff) IDBTransaction)
transaction :: forall eff. IDBDatabase -> Array String -> IDBTransactionMode -> Eff (idb :: INDEXED_DB, exception :: EXCEPTION | eff) IDBTransaction
transaction db stores mode =
  Fn.runFn3 _transaction db stores mode


foreign import version :: IDBDatabase -> Int
