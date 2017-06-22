module Main where

import Prelude

import Control.Monad.Aff as Aff
import Control.Monad.Eff(kind Effect, Eff)
import Control.Monad.Eff.Console as Console
import Control.Monad.Eff.Console(CONSOLE)
import Control.Monad.Eff.Exception(EXCEPTION)
import Data.Maybe(Maybe(..), fromMaybe)

import Core
import IDBDatabase as IDBDatabase


main :: Eff (exception :: EXCEPTION, idb :: INDEXED_DB, console :: CONSOLE) Unit
main = do
  _ <- Aff.launchAff $ IDBDatabase.open "myDatabase" Nothing
    { onSuccess : Just (IDBDatabase.name >>> Console.log)
    , onBlocked : Nothing
    , onUpgradeNeeded : Nothing
    }
  pure unit
