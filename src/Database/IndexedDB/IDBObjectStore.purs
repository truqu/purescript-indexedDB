module Database.IndexedDB.IDBObjectStore where

import Prelude

import Control.Monad.Aff(Aff)
import Control.Monad.Eff(Eff)
import Control.Monad.Eff.Exception(EXCEPTION)
import Data.Function.Uncurried as Fn
import Data.Function.Uncurried(Fn2, Fn3, Fn4)
import Data.Maybe(Maybe, fromMaybe)

import Database.IndexedDB.Core


foreign import autoIncrement :: IDBObjectStore -> Boolean


foreign import indexNames :: IDBObjectStore -> Array String


foreign import keyPath :: IDBObjectStore -> Array String


foreign import name :: IDBObjectStore -> String
