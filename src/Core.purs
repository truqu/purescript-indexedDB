module Core where

import Prelude
import Data.Maybe(Maybe)
import Control.Monad.Aff(Aff)
import Control.Monad.Eff(kind Effect, Eff)


foreign import data INDEXED_DB :: Effect


foreign import data IDBDatabase :: Type


type IDBOpenRequest eff =
  { onBlocked       :: Maybe (IDBDatabase -> Eff eff Unit)
  , onUpgradeNeeded :: Maybe (IDBDatabase -> Eff eff Unit)
  }
