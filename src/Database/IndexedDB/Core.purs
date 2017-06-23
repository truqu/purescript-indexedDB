module Database.IndexedDB.Core where

import Prelude
import Data.Maybe(Maybe)
import Control.Monad.Aff(Aff)
import Control.Monad.Eff(kind Effect, Eff)
import Control.Monad.Eff.Exception(EXCEPTION)

foreign import data INDEXED_DB :: Effect


foreign import data IDBDatabase :: Type


foreign import _showIDBDatabase :: IDBDatabase -> String
instance showIDBDatabase :: Show IDBDatabase where
  show = _showIDBDatabase


foreign import data IDBObjectStore :: Type


foreign import _showIDBObjectStore :: IDBObjectStore -> String
instance showIDBObjectStore :: Show IDBObjectStore where
  show = _showIDBObjectStore

foreign import data IDBTransaction :: Type


foreign import _showIDBTransaction :: IDBTransaction -> String
instance showIDBTransaction :: Show IDBTransaction where
  show = _showIDBTransaction


data IDBTransactionMode = ReadOnly | ReadWrite | VersionChange
