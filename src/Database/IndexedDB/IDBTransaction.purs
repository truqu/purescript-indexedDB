module Database.IndexedDB.IDBTransaction where

import Prelude

import Control.Monad.Aff(Aff)
import Control.Monad.Eff(Eff)
import Control.Monad.Eff.Exception(EXCEPTION, Error)
import Data.Function.Uncurried as Fn
import Data.Function.Uncurried(Fn2)
import Data.Maybe(Maybe)

import Database.IndexedDB.Core


foreign import abort :: forall eff. IDBTransaction -> Eff (idb :: INDEXED_DB, exception :: EXCEPTION | eff) Unit


foreign import _objectStore :: forall eff. Fn2 IDBTransaction String (Eff (idb :: INDEXED_DB, exception :: EXCEPTION | eff) IDBObjectStore)
objectStore :: forall eff. IDBTransaction -> String -> Eff (idb :: INDEXED_DB, exception :: EXCEPTION | eff) IDBObjectStore
objectStore tx name =
  Fn.runFn2 _objectStore tx name


foreign import mode :: IDBTransaction -> IDBTransactionMode


foreign import error :: IDBTransaction -> Maybe Error
