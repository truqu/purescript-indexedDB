module Test.Main where

import Prelude

import Control.Monad.Aff                 (Aff, launchAff, forkAff, delay)
import Control.Monad.Aff.AVar            (AVAR, makeVar', modifyVar, peekVar, killVar)
import Control.Monad.Eff                 (Eff)
import Control.Monad.Eff.Class           (liftEff)
import Control.Monad.Eff.Exception       (EXCEPTION)
import Data.Date                          as Date
import Data.DateTime                      as DateTime
import Data.DateTime                     (DateTime(..), Date(..), Time(..))
import Data.Enum                         (toEnum)
import Data.Maybe                        (Maybe(..))
import Data.Time.Duration                (Milliseconds(..))
import Test.Spec                         (describe, it)
import Test.Spec.Assertions              (shouldEqual, fail)
import Test.Spec.Mocha                   (MOCHA, runMocha)

import Database.IndexedDB.Core
import Database.IndexedDB.IDBDatabase     as IDBDatabase
import Database.IndexedDB.IDBFactory      as IDBFactory
import Database.IndexedDB.IDBObjectStore  as IDBObjectStore


tearDown :: forall eff. String -> Int -> IDBDatabase -> Aff (idb :: INDEXED_DB, exception :: EXCEPTION | eff) Unit
tearDown name version db = do
  liftEff $ IDBDatabase.close db
  version' <- IDBFactory.deleteDatabase name
  version' `shouldEqual` version

-- main :: forall eff. Eff (mocha :: MOCHA, idb :: INDEXED_DB, exception :: EXCEPTION, avar :: AVAR | eff) Unit
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


  describe "IDBDatabase" do
    it "createObjectStore (keyPath: [], autoIncrement: true)" do
      let dbName          = "db-create-store-01"
          dbVersion       = 1
          storeName       = "store"
          keyPath         = []
          autoIncrement   = true
          callback var db = do
            store <- IDBDatabase.createObjectStore db storeName { keyPath, autoIncrement }
            _     <- launchAff $ IDBObjectStore.name store `shouldEqual` storeName
            _     <- launchAff $ IDBObjectStore.keyPath store `shouldEqual` keyPath
            _     <- launchAff $ IDBObjectStore.autoIncrement store `shouldEqual` autoIncrement
            _     <- launchAff $ IDBObjectStore.indexNames store `shouldEqual` []
            _     <- launchAff $ modifyVar (const true) var
            pure unit

      var <- makeVar' false
      db  <- IDBFactory.open dbName Nothing
        { onUpgradeNeeded : Just (callback var)
        , onBlocked       : Nothing
        }
      hasBeenCalled <- peekVar var
      hasBeenCalled `shouldEqual` true
      tearDown dbName dbVersion db


    it "createObjectStore (keyPath: [\"field\"], autoIncrement: true)" do
      let dbName          = "db-create-store-02"
          dbVersion       = 1
          storeName       = "store"
          keyPath         = ["field"]
          autoIncrement   = true
          callback var db = do
            store <- IDBDatabase.createObjectStore db storeName { keyPath, autoIncrement }
            _     <- launchAff $ IDBObjectStore.name store `shouldEqual` storeName
            _     <- launchAff $ IDBObjectStore.keyPath store `shouldEqual` keyPath
            _     <- launchAff $ IDBObjectStore.autoIncrement store `shouldEqual` autoIncrement
            _     <- launchAff $ IDBObjectStore.indexNames store `shouldEqual` []
            _     <- launchAff $ modifyVar (const true) var
            pure unit

      var <- makeVar' false
      db  <- IDBFactory.open dbName Nothing
        { onUpgradeNeeded : Just (callback var)
        , onBlocked       : Nothing
        }
      hasBeenCalled <- peekVar var
      hasBeenCalled `shouldEqual` true
      tearDown dbName dbVersion db


    it "createObjectStore (keyPath: [\"a\", \"b\"], autoIncrement: false)" do
      let dbName          = "db-create-store-03"
          dbVersion       = 1
          storeName       = "store"
          keyPath         = ["a", "b"]
          autoIncrement   = false
          callback var db = do
            store <- IDBDatabase.createObjectStore db storeName { keyPath, autoIncrement }
            _     <- launchAff $ IDBObjectStore.name store `shouldEqual` storeName
            _     <- launchAff $ IDBObjectStore.keyPath store `shouldEqual` keyPath
            _     <- launchAff $ IDBObjectStore.autoIncrement store `shouldEqual` autoIncrement
            _     <- launchAff $ IDBObjectStore.indexNames store `shouldEqual` []
            _     <- launchAff $ modifyVar (const true) var
            pure unit

      var <- makeVar' false
      db  <- IDBFactory.open dbName Nothing
        { onUpgradeNeeded : Just (callback var)
        , onBlocked       : Nothing
        }
      hasBeenCalled <- peekVar var
      hasBeenCalled `shouldEqual` true
      tearDown dbName dbVersion db


    it "createObjectStore (keyPath: [\"field\"], autoIncrement: false)" do
      let dbName          = "db-create-store-04"
          dbVersion       = 1
          storeName       = "store"
          keyPath         = ["field"]
          autoIncrement   = false
          callback var db = do
            store <- IDBDatabase.createObjectStore db storeName { keyPath, autoIncrement }
            _     <- launchAff $ IDBObjectStore.name store `shouldEqual` storeName
            _     <- launchAff $ IDBObjectStore.keyPath store `shouldEqual` keyPath
            _     <- launchAff $ IDBObjectStore.autoIncrement store `shouldEqual` autoIncrement
            _     <- launchAff $ IDBObjectStore.indexNames store `shouldEqual` []
            _     <- launchAff $ modifyVar (const true) var
            pure unit

      var <- makeVar' false
      db  <- IDBFactory.open dbName Nothing
        { onUpgradeNeeded : Just (callback var)
        , onBlocked       : Nothing
        }
      hasBeenCalled <- peekVar var
      hasBeenCalled `shouldEqual` true
      tearDown dbName dbVersion db


    it "deleteObjectStore" do
      let dbName           = "db-delete-store"
          dbVersion        = 2
          storeName        = "store"
          keyPath          = []
          autoIncrement    = true
          callback db      = do
            _ <- IDBDatabase.createObjectStore db storeName { keyPath, autoIncrement }
            pure unit
          callback2 var db = do
            _ <- IDBDatabase.deleteObjectStore db storeName
            _ <- launchAff $ modifyVar (const true) var
            pure unit

      var <- makeVar' false
      db  <- IDBFactory.open dbName Nothing
        { onUpgradeNeeded : Just callback
        , onBlocked       : Nothing
        }
      liftEff $ IDBDatabase.close db
      db  <- IDBFactory.open dbName (Just dbVersion)
        { onUpgradeNeeded : Just (callback2 var)
        , onBlocked       : Nothing
      }
      hasBeenCalled <- peekVar var
      hasBeenCalled `shouldEqual` true
      tearDown dbName dbVersion db

  describe "IDBObjectStore" do
    it "add(\"patate\", Nothing )" do
      let dbName        = "db-add"
          dbVersion     = 1
          storeName     = "store"
          keyPath       = []
          autoIncrement = true
          key           = 1
          callback db   = do
            store <- IDBDatabase.createObjectStore db storeName { keyPath, autoIncrement }
            key   <- launchAff $ ((unsafeFromKey >>> shouldEqual key)
              <$> IDBObjectStore.add store "patate" Nothing)
            pure unit

      db <- IDBFactory.open dbName Nothing
        { onUpgradeNeeded : Just callback
        , onBlocked       : Nothing
        }
      tearDown dbName dbVersion db

    it "add(\"patate\", Just 14 )" do
      let dbName        = "db-add"
          dbVersion     = 1
          storeName     = "store"
          keyPath       = []
          autoIncrement = true
          key           = 14
          callback db   = do
            store <- IDBDatabase.createObjectStore db storeName { keyPath, autoIncrement }
            key   <- launchAff $ ((unsafeFromKey >>> shouldEqual key)
              <$> IDBObjectStore.add store "patate" (Just $ toKey key))
            pure unit

      db <- IDBFactory.open dbName Nothing
        { onUpgradeNeeded : Just callback
        , onBlocked       : Nothing
        }
      tearDown dbName dbVersion db

    it "add(\"patate\", Just \"key\" )" do
      let dbName        = "db-add"
          dbVersion     = 1
          storeName     = "store"
          keyPath       = []
          autoIncrement = true
          key           = "key"
          callback db   = do
            store <- IDBDatabase.createObjectStore db storeName { keyPath, autoIncrement }
            key   <- launchAff $ ((unsafeFromKey >>> shouldEqual key)
              <$> IDBObjectStore.add store "patate" (Just $ toKey key))
            pure unit

      db <- IDBFactory.open dbName Nothing
        { onUpgradeNeeded : Just callback
        , onBlocked       : Nothing
        }
      tearDown dbName dbVersion db

    it "add(\"patate\", Just <date> )" do
      let dbName        = "db-add"
          dbVersion     = 1
          storeName     = "store"
          keyPath       = []
          autoIncrement = true
          mkey          = DateTime
            <$> (Date.canonicalDate <$> toEnum 2017 <*> toEnum 6 <*> toEnum 23)
            <*> (Time <$> toEnum 17 <*> toEnum 59 <*> toEnum 34 <*> toEnum 42)

      case mkey of
        Nothing ->
          fail "unable to create datetime"
        Just key -> do
          let callback db   = do
                store <- IDBDatabase.createObjectStore db storeName { keyPath, autoIncrement }
                key   <- launchAff $ ((unsafeFromKey >>> shouldEqual key)
                  <$> IDBObjectStore.add store "patate" (Just $ toKey key))
                pure unit

          db <- IDBFactory.open dbName Nothing
            { onUpgradeNeeded : Just callback
            , onBlocked       : Nothing
            }
          tearDown dbName dbVersion db

    it "add(\"patate\", Just [14, 42] )" do
      let dbName        = "db-add"
          dbVersion     = 1
          storeName     = "store"
          keyPath       = []
          autoIncrement = true
          key           = [14, 42]
          callback db   = do
            store <- IDBDatabase.createObjectStore db storeName { keyPath, autoIncrement }
            key   <- launchAff $ ((unsafeFromKey >>> shouldEqual key)
              <$> IDBObjectStore.add store "patate" (Just $ toKey key))
            pure unit

      db <- IDBFactory.open dbName Nothing
        { onUpgradeNeeded : Just callback
        , onBlocked       : Nothing
        }
      tearDown dbName dbVersion db

