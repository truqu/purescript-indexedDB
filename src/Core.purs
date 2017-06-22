module Core where

import Prelude
import Data.Maybe(Maybe)
import Control.Monad.Aff(Aff)
import Control.Monad.Eff(kind Effect, Eff)


foreign import data INDEXED_DB :: Effect


foreign import data IDBDatabase :: Type


foreign import _showIDBDatabase :: forall eff. IDBDatabase -> String
instance showIDBDatabase :: Show IDBDatabase where
  show = _showIDBDatabase


foreign import data IDBObjectStore :: Type


foreign import _showObjectStore :: forall eff. IDBObjectStore -> String
instance showIDBObjectStore :: Show IDBObjectStore where
  show = _showObjectStore
