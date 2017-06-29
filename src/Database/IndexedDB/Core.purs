module Database.IndexedDB.Core
  ( INDEXED_DB
  , IDBCursorSource(..)
  , IDBDatabase
  , IDBIndex
  , IDBKeyCursor
  , IDBKeyRange
  , IDBObjectStore
  , IDBTransaction
  , IDBTransactionMode(..)
  , IDBValueCursor
  , module Database.IndexedDB.IDBCursorDirection
  , module Database.IndexedDB.IDBKey
  ) where

import Prelude

import Control.Monad.Aff           (Aff)
import Control.Monad.Eff           (kind Effect, Eff)
import Control.Monad.Eff.Exception (EXCEPTION)
import Data.Function.Uncurried      as Fn
import Data.Function.Uncurried     (Fn2, Fn4, Fn7)
import Data.Maybe                  (Maybe)
import Data.Nullable               (Nullable, toNullable)

import Database.IndexedDB.IDBCursorDirection
import Database.IndexedDB.IDBKey


data IDBTransactionMode = ReadOnly | ReadWrite | VersionChange


data IDBCursorSource = IDBObjectStore IDBObjectStore | IDBIndex IDBIndex


foreign import data INDEXED_DB :: Effect


foreign import data IDBDatabase :: Type


foreign import data IDBIndex :: Type


foreign import data IDBKeyCursor :: Type


foreign import data IDBKeyRange :: Type


foreign import data IDBObjectStore :: Type


foreign import data IDBTransaction :: Type


foreign import data IDBValueCursor :: Type


foreign import _showIDBDatabase :: IDBDatabase -> String
instance showIDBDatabase :: Show IDBDatabase where
  show = _showIDBDatabase


foreign import _showIDBObjectStore :: IDBObjectStore -> String
instance showIDBObjectStore :: Show IDBObjectStore where
  show = _showIDBObjectStore


foreign import _showIDBTransaction :: IDBTransaction -> String
instance showIDBTransaction :: Show IDBTransaction where
  show = _showIDBTransaction
