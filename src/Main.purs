module Main where

import Prelude

import Control.Monad.Aff as Aff
import Control.Monad.Eff(kind Effect, Eff)
import Control.Monad.Eff.Console as Console
import Control.Monad.Eff.Console(CONSOLE)
import Control.Monad.Eff.Exception(EXCEPTION, catchException)
import Data.Maybe(Maybe(..))
import Data.Either(Either(..))

import Core
import IDBDatabase as IDBDatabase


main :: Eff (exception :: EXCEPTION, idb :: INDEXED_DB, console :: CONSOLE) Unit
main = do
  _ <- Aff.runAff (show >>> Console.log) (IDBDatabase.name >>> Console.log) $ IDBDatabase.open "myDatabase" Nothing
    { onBlocked : Nothing
    , onUpgradeNeeded : Nothing
    }

  pure unit
