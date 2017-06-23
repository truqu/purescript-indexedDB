module Test.Main where

import Prelude

import Data.Time.Duration             (Milliseconds(..))
import Control.Monad.Aff              (Aff, launchAff, forkAff, delay)
import Control.Monad.Aff.AVar         (AVAR, makeVar', modifyVar, peekVar, killVar)
import Control.Monad.Eff              (Eff)
import Control.Monad.Eff.Class        (liftEff)
import Control.Monad.Eff.Exception    (EXCEPTION)
import Data.Maybe                     (Maybe(..))
import Test.Spec                      (describe, it, itOnly)
import Test.Spec.Assertions           (shouldEqual)
import Test.Spec.Mocha                (MOCHA, runMocha)

import Database.IndexedDB.Core
import Database.IndexedDB.IDBDatabase  as IDBDatabase
import Database.IndexedDB.IDBFactory   as IDBFactory


tearDown :: forall eff. String -> Int -> IDBDatabase -> Aff (idb :: INDEXED_DB, exception :: EXCEPTION | eff) Unit
tearDown name version db = do
  liftEff $ IDBDatabase.close db
  version' <- IDBFactory.deleteDatabase name
  version' `shouldEqual` version

main :: forall eff. Eff (mocha :: MOCHA, idb :: INDEXED_DB, exception :: EXCEPTION, avar :: AVAR | eff) Unit
main = runMocha do
  describe "IDBFactory" do
    it "open default" do
      let name    = "db-default"
          version = 1
      db <- IDBFactory.open name Nothing
        { onUpgradeNeeded : Nothing
        , onBlocked       : Nothing
        }
      IDBDatabase.name db `shouldEqual` name
      tearDown name version db


    it "open specific version" do
      let name    = "db-specific"
          version = 14
      db <- IDBFactory.open name (Just version)
        { onUpgradeNeeded : Nothing
        , onBlocked       : Nothing
        }
      IDBDatabase.name db `shouldEqual` name
      tearDown name version db


    it "open specific version -> close -> open latest" do
      let name    = "db-latest"
          version = 14
      db <- IDBFactory.open name (Just version)
        { onUpgradeNeeded : Nothing
        , onBlocked : Nothing
        }
      IDBDatabase.name db `shouldEqual` name
      liftEff $ IDBDatabase.close db
      db <- IDBFactory.open name Nothing
        { onUpgradeNeeded : Nothing
        , onBlocked       : Nothing
        }
      tearDown name version db


    it "open + onUpgradeNeed" do
      let name    = "db-upgrade-needed"
          version = 1
          callback var db = do
            _ <- launchAff $ modifyVar (const $ IDBDatabase.name db) var
            pure unit
      var <- makeVar' "-"
      db  <- IDBFactory.open name Nothing
        { onUpgradeNeeded : Just (callback var)
        , onBlocked       : Nothing
        }
      name <- peekVar var
      name `shouldEqual` name
      tearDown name version db


    it "open + onBlocked" do
      let name    = "db-blocked"
          version = 14
          callback var = do
            _ <- launchAff $ modifyVar (const $ "db-blocked") var
            pure unit

      var   <- makeVar' "-"
      db01  <- IDBFactory.open name Nothing
        { onUpgradeNeeded : Nothing
        , onBlocked       : Nothing
        }
      _ <- forkAff do
        delay (Milliseconds 100.0)
        liftEff $ IDBDatabase.close db01

      db02  <- IDBFactory.open name (Just version)
        { onUpgradeNeeded : Nothing
        , onBlocked       : Just (callback var)
        }
      name <- peekVar var
      name `shouldEqual` name
      tearDown name version db02
