module Database.IndexedDB.IDBObjectStore where

import Prelude

import Control.Monad.Aff(Aff)
import Control.Monad.Eff(Eff)
import Control.Monad.Eff.Exception(EXCEPTION)
import Data.Function.Uncurried as Fn
import Data.Function.Uncurried(Fn3)
import Data.Maybe(Maybe, fromMaybe)
import Data.Nullable(Nullable, toNullable)

import Database.IndexedDB.Core


foreign import _add :: forall value eff. Fn3 IDBObjectStore value (Nullable Key) (Aff (idb :: INDEXED_DB, exception :: EXCEPTION | eff) Key)
add :: forall key value eff .  IDBObjectStore -> value -> Maybe Key -> Aff (idb :: INDEXED_DB, exception :: EXCEPTION | eff) Key
add store value mkey =
  Fn.runFn3 _add store value (toNullable mkey)


foreign import autoIncrement :: IDBObjectStore -> Boolean


foreign import indexNames :: IDBObjectStore -> Array String


foreign import keyPath :: IDBObjectStore -> Array String


foreign import name :: IDBObjectStore -> String
