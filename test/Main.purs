module Test.Main where

import Prelude

import Control.Monad.Aff                 (Aff, launchAff, forkAff, delay, attempt)
import Control.Monad.Aff.AVar            (AVAR, makeVar, makeVar', modifyVar, peekVar, putVar, takeVar)
import Control.Monad.Eff                 (Eff)
import Control.Monad.Eff.Class           (liftEff)
import Control.Monad.Eff.Exception       (EXCEPTION)
import Control.Monad.Eff.Now             (NOW, now)
import Data.Date                          as Date
import Data.DateTime                      as DateTime
import Data.DateTime                     (DateTime(..), Time(..))
import Data.DateTime.Instant             (toDateTime)
import Data.Either                       (Either(..))
import Data.Enum                         (toEnum)
import Data.Maybe                        (Maybe(..), isNothing, maybe)
import Data.Time.Duration                (Milliseconds(..))
import Data.Traversable                  (traverse)
import Data.Tuple                        (Tuple(..), uncurry)
import Test.Spec                         (describe, describeOnly, it, itOnly)
import Test.Spec.Assertions              (shouldEqual, fail)
import Test.Spec.Mocha                   (MOCHA, runMocha)

import Database.IndexedDB.Core
import Database.IndexedDB.IDBKey
import Database.IndexedDB.IDBDatabase     as IDBDatabase
import Database.IndexedDB.IDBFactory      as IDBFactory
import Database.IndexedDB.IDBIndex        as IDBIndex
import Database.IndexedDB.IDBKeyRange     as IDBKeyRange
import Database.IndexedDB.IDBObjectStore  as IDBObjectStore
import Database.IndexedDB.IDBTransaction  as IDBTransaction


infixr 7 Tuple as :+:

launchAff' :: forall a e. Aff e a -> Eff (exception :: EXCEPTION | e) Unit
launchAff' aff =
  pure unit <* (launchAff aff)

main :: forall eff. Eff (now :: NOW, mocha :: MOCHA, idb :: IDB, exception :: EXCEPTION, avar :: AVAR | eff) Unit
main = runMocha do
  describe "IDBFactory" do
    let
        tearDown name version db = do
          IDBDatabase.close db
          version' <- IDBFactory.deleteDatabase name
          version' `shouldEqual` version

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
      IDBDatabase.close db
      db <- IDBFactory.open name Nothing
        { onUpgradeNeeded : Nothing
        , onBlocked       : Nothing
        }
      tearDown name version db


    it "open + onUpgradeNeed" do
      let name    = "db-upgrade-needed"
          version = 1
          callback var db _ = do
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
        IDBDatabase.close db01

      db02  <- IDBFactory.open name (Just version)
        { onUpgradeNeeded : Nothing
        , onBlocked       : Just (callback var)
        }
      name <- peekVar var
      name `shouldEqual` name
      tearDown name version db02

  describe "IDBKeyRange" do
    it "only(int)" do
      let key   = 14
          range = IDBKeyRange.only key
      IDBKeyRange.includes range (toKey key) `shouldEqual` true

    it "only(string)" do
      let key   = "patate"
          range = IDBKeyRange.only key
      IDBKeyRange.includes range (toKey key) `shouldEqual` true

    it "only(float)" do
      let key   = 14.42
          range = IDBKeyRange.only key
      IDBKeyRange.includes range (toKey key) `shouldEqual` true

    it "only(date)" do
      let mkey = DateTime
            <$> (Date.canonicalDate <$> toEnum 2017 <*> toEnum 6 <*> toEnum 23)
            <*> (Time <$> toEnum 17 <*> toEnum 59 <*> toEnum 34 <*> toEnum 42)

      case mkey of
        Nothing ->
          fail "unable to create datetime"
        Just key -> do
          let range = IDBKeyRange.only key
          IDBKeyRange.includes range (toKey key) `shouldEqual` true

    it "only([int])" do
      let key   = [14, 42]
          range = IDBKeyRange.only key
      IDBKeyRange.includes range (toKey key) `shouldEqual` true

    it "only([string])" do
      let key   = ["patate", "autruche"]
          range = IDBKeyRange.only key
      IDBKeyRange.includes range (toKey key) `shouldEqual` true

    it "lowerBound(14, open)" do
      let key   = 14
          open  = true
          range = IDBKeyRange.lowerBound key open
      IDBKeyRange.includes range (toKey (key + 1)) `shouldEqual` true
      IDBKeyRange.includes range (toKey key) `shouldEqual` (not open)
      IDBKeyRange.includes range (toKey (key - 1)) `shouldEqual` false

    it "lowerBound(14, close)" do
      let key   = 14
          open  = false
          range = IDBKeyRange.lowerBound key open
      IDBKeyRange.includes range (toKey (key + 1)) `shouldEqual` true
      IDBKeyRange.includes range (toKey key) `shouldEqual` (not open)
      IDBKeyRange.includes range (toKey (key - 1)) `shouldEqual` false

    it "upperBound(14, open)" do
      let key   = 14
          open  = true
          range = IDBKeyRange.upperBound key open
      IDBKeyRange.includes range (toKey (key + 1)) `shouldEqual` false
      IDBKeyRange.includes range (toKey key) `shouldEqual` (not open)
      IDBKeyRange.includes range (toKey (key - 1)) `shouldEqual` true

    it "upperBound(14, close)" do
      let key   = 14
          open  = false
          range = IDBKeyRange.upperBound key open
      IDBKeyRange.includes range (toKey (key + 1)) `shouldEqual` false
      IDBKeyRange.includes range (toKey key) `shouldEqual` (not open)
      IDBKeyRange.includes range (toKey (key - 1)) `shouldEqual` true

    it "bound(42, 14, open, open) => Nothing" do
      let lower     = 42
          upper     = 14
          lowerOpen = true
          upperOpen = true
          mrange    = IDBKeyRange.bound { lower, upper, lowerOpen, upperOpen }
      isNothing mrange `shouldEqual` true

    it "bound(14, 42, open, open)" do
      let lower     = 14
          upper     = 42
          lowerOpen = true
          upperOpen = true
          mrange    = IDBKeyRange.bound { lower, upper, lowerOpen, upperOpen }
      case mrange of
        Nothing ->
          fail "invalid range provided"
        Just range -> do
          IDBKeyRange.includes range (toKey (lower + 1)) `shouldEqual` true
          IDBKeyRange.includes range (toKey (upper - 1)) `shouldEqual` true
          IDBKeyRange.includes range (toKey (lower - 1)) `shouldEqual` false
          IDBKeyRange.includes range (toKey (upper + 1)) `shouldEqual` false
          IDBKeyRange.includes range (toKey lower) `shouldEqual` (not lowerOpen)
          IDBKeyRange.includes range (toKey upper) `shouldEqual` (not upperOpen)

    it "bound(14, 42, open, close)" do
      let lower     = 14
          upper     = 42
          lowerOpen = true
          upperOpen = false
          mrange    = IDBKeyRange.bound { lower, upper, lowerOpen, upperOpen }
      case mrange of
        Nothing ->
          fail "invalid range provided"
        Just range -> do
          IDBKeyRange.includes range (toKey (lower + 1)) `shouldEqual` true
          IDBKeyRange.includes range (toKey (upper - 1)) `shouldEqual` true
          IDBKeyRange.includes range (toKey (lower - 1)) `shouldEqual` false
          IDBKeyRange.includes range (toKey (upper + 1)) `shouldEqual` false
          IDBKeyRange.includes range (toKey lower) `shouldEqual` (not lowerOpen)
          IDBKeyRange.includes range (toKey upper) `shouldEqual` (not upperOpen)

    it "bound(14, 42, close, open)" do
      let lower     = 14
          upper     = 42
          lowerOpen = false
          upperOpen = true
          mrange    = IDBKeyRange.bound { lower, upper, lowerOpen, upperOpen }
      case mrange of
        Nothing ->
          fail "invalid range provided"
        Just range -> do
          IDBKeyRange.includes range (toKey (lower + 1)) `shouldEqual` true
          IDBKeyRange.includes range (toKey (upper - 1)) `shouldEqual` true
          IDBKeyRange.includes range (toKey (lower - 1)) `shouldEqual` false
          IDBKeyRange.includes range (toKey (upper + 1)) `shouldEqual` false
          IDBKeyRange.includes range (toKey lower) `shouldEqual` (not lowerOpen)
          IDBKeyRange.includes range (toKey upper) `shouldEqual` (not upperOpen)

    it "bound(14, 42, close, close)" do
      let lower     = 14
          upper     = 42
          lowerOpen = false
          upperOpen = false
          mrange    = IDBKeyRange.bound { lower, upper, lowerOpen, upperOpen }
      case mrange of
        Nothing ->
          fail "invalid range provided"
        Just range -> do
          IDBKeyRange.includes range (toKey (lower + 1)) `shouldEqual` true
          IDBKeyRange.includes range (toKey (upper - 1)) `shouldEqual` true
          IDBKeyRange.includes range (toKey (lower - 1)) `shouldEqual` false
          IDBKeyRange.includes range (toKey (upper + 1)) `shouldEqual` false
          IDBKeyRange.includes range (toKey lower) `shouldEqual` (not lowerOpen)
          IDBKeyRange.includes range (toKey upper) `shouldEqual` (not upperOpen)

    it "can access attributes of a range" do
      let range = IDBKeyRange.lowerBound 14 false
      IDBKeyRange.lower range `shouldEqual` (Just $ toKey 14)
      IDBKeyRange.upper range `shouldEqual` (Nothing :: Maybe Key)
      IDBKeyRange.lowerOpen range `shouldEqual` false
      IDBKeyRange.upperOpen range `shouldEqual` true

  describe "IDBDatabase" do
    let
        tearDown db = do
          IDBDatabase.close db
          _ <- IDBFactory.deleteDatabase (IDBDatabase.name db)
          pure unit

        setup storeParams = do
          let onUpgradeNeeded var db _ = launchAff' do
                store <- IDBDatabase.createObjectStore db "store" storeParams
                _     <- putVar var { db, store }
                pure unit

          var <- makeVar
          db  <- IDBFactory.open "db" Nothing
            { onUpgradeNeeded : Just (onUpgradeNeeded var)
            , onBlocked : Nothing
            }

          takeVar var

    it "createObjectStore (keyPath: [], autoIncrement: true)" do
      { db, store } <- setup { keyPath: [], autoIncrement: true }
      IDBObjectStore.name store `shouldEqual` "store"
      IDBObjectStore.keyPath store `shouldEqual` []
      IDBObjectStore.autoIncrement store `shouldEqual` true
      IDBObjectStore.indexNames store `shouldEqual` []
      tearDown db

    it "createObjectStore (keyPath: [\"patate\"], autoIncrement: true)" do
      { db, store } <- setup { keyPath: ["patate"], autoIncrement: true }
      IDBObjectStore.name store `shouldEqual` "store"
      IDBObjectStore.keyPath store `shouldEqual` ["patate"]
      IDBObjectStore.autoIncrement store `shouldEqual` true
      IDBObjectStore.indexNames store `shouldEqual` []
      tearDown db

    it "createObjectStore (keyPath: [\"a\", \"b\"], autoIncrement: false)" do
      { db, store } <- setup { keyPath: ["patate", "autruche"], autoIncrement: false }
      IDBObjectStore.name store `shouldEqual` "store"
      IDBObjectStore.keyPath store `shouldEqual` ["patate", "autruche"]
      IDBObjectStore.autoIncrement store `shouldEqual` false
      IDBObjectStore.indexNames store `shouldEqual` []
      tearDown db

    it "deleteObjectStore" do
      let onUpgradeNeeded var db _ = launchAff' do
            _ <- IDBDatabase.deleteObjectStore db "store"
            putVar var true

      var           <- makeVar
      { db, store } <- setup IDBObjectStore.defaultParameters
      IDBDatabase.close db
      db <- IDBFactory.open "db" (Just 999) { onUpgradeNeeded : Just (onUpgradeNeeded var)
                                            , onBlocked       : Nothing
                                            }
      deleted <- takeVar var
      deleted `shouldEqual` true
      tearDown db


  describe "IDBObjectStore" do
    let
        tearDown db = do
          IDBDatabase.close db
          _ <- IDBFactory.deleteDatabase (IDBDatabase.name db)
          pure unit

        setup { storeParams, onUpgradeNeeded } = do
          let onUpgradeNeeded' var db _ = launchAff' do
                store <- IDBDatabase.createObjectStore db "store" storeParams
                liftEff $ maybe (pure unit) id (onUpgradeNeeded <*> pure db <*> pure store)
                putVar var { db, store }

          var <- makeVar
          db  <- IDBFactory.open "db" Nothing
            { onUpgradeNeeded : Just (onUpgradeNeeded' var)
            , onBlocked : Nothing
            }

          takeVar var

    it "add()" do
      date   <- liftEff $ toDateTime <$> now
      { db } <- setup
        { storeParams: { autoIncrement: true, keyPath: [] }
        , onUpgradeNeeded: Just $ \_ store -> launchAff' do
            -- no key
            key <- IDBObjectStore.add store "patate" (Nothing :: Maybe Key)
            (toKey 1) `shouldEqual` key

            -- int key
            key <- IDBObjectStore.add store "patate" (Just 14)
            (toKey 14) `shouldEqual` key

            -- number key
            key <- IDBObjectStore.add store "patate" (Just 14.42)
            (toKey 14.42) `shouldEqual` key

            -- string key
            key <- IDBObjectStore.add store "patate" (Just "key")
            (toKey "key") `shouldEqual` key

            -- date key
            key <- IDBObjectStore.add store "patate" (Just date)
            (toKey date) `shouldEqual` key

            -- array key
            key <- IDBObjectStore.add store "patate" (Just $ toKey [14, 42])
            (toKey [14, 42]) `shouldEqual` key
        }
      tearDown db

    it "clear()" do
      { db } <- setup
        { storeParams: IDBObjectStore.defaultParameters
        , onUpgradeNeeded: Just $ \_ store -> launchAff' do
            key <- IDBObjectStore.add store "patate" (Just 14)
            _   <- IDBObjectStore.clear store
            val <- IDBObjectStore.get store (IDBKeyRange.only key)
            val `shouldEqual` (Nothing :: Maybe String)
        }
      tearDown db

    it "count()" do
      { db } <- setup
        { storeParams: IDBObjectStore.defaultParameters
        , onUpgradeNeeded: Just $ \_ store -> launchAff' do
            key <- IDBObjectStore.add store "patate" (Just 14)
            key <- IDBObjectStore.add store "autruche" (Just 42)
            n   <- IDBObjectStore.count store Nothing
            n `shouldEqual` 2
        }
      tearDown db

    it "getKey()" do
      { db } <- setup
        { storeParams: IDBObjectStore.defaultParameters
        , onUpgradeNeeded: Just $ \_ store -> launchAff' do
            key  <- IDBObjectStore.add store "patate" (Just 14)
            mkey <- IDBObjectStore.getKey store (IDBKeyRange.only 14)
            mkey `shouldEqual` (Just key)

            mkey <- IDBObjectStore.getKey store (IDBKeyRange.only 42)
            mkey `shouldEqual` (Nothing :: Maybe Key)
          }
      tearDown db

    it "getAllKeys()" do
      { db } <- setup
        { storeParams: IDBObjectStore.defaultParameters
        , onUpgradeNeeded: Just $ \_ store -> launchAff' do
            key1  <- IDBObjectStore.add store "patate" (Just 14)
            key2  <- IDBObjectStore.add store "autruche" (Just 42)
            key3  <- IDBObjectStore.add store 14 (Just 1337)

            -- no bounds
            keys  <- IDBObjectStore.getAllKeys store Nothing Nothing
            keys `shouldEqual` [key1, key2, key3]

            -- lower bound
            keys  <- IDBObjectStore.getAllKeys store (Just $ IDBKeyRange.lowerBound 14 true) Nothing
            keys `shouldEqual` [key2, key3]

            -- upper bound
            keys  <- IDBObjectStore.getAllKeys store (Just $ IDBKeyRange.upperBound 42 false) Nothing
            keys `shouldEqual` [key1, key2]

            -- count
            keys  <- IDBObjectStore.getAllKeys store (Just $ IDBKeyRange.lowerBound 1 true) (Just 2)
            keys `shouldEqual` [key1, key2]
        }
      tearDown db

    it "openCursor()" do
      { db } <- setup
        { storeParams: IDBObjectStore.defaultParameters
        , onUpgradeNeeded: Just $ \_ store -> launchAff' do
            _ <- IDBObjectStore.openCursor store Nothing Next
            _ <- IDBObjectStore.openCursor store Nothing NextUnique
            _ <- IDBObjectStore.openCursor store Nothing Prev
            _ <- IDBObjectStore.openCursor store Nothing PrevUnique
            _ <- IDBObjectStore.openCursor store (Just $ IDBKeyRange.upperBound 1 true) Next
            pure unit
        }
      tearDown db

    it "openKeyCursor()" do
      { db } <- setup
        { storeParams: IDBObjectStore.defaultParameters
        , onUpgradeNeeded: Just $ \_ store -> launchAff' do
            _ <- IDBObjectStore.openKeyCursor store Nothing Next
            _ <- IDBObjectStore.openKeyCursor store Nothing NextUnique
            _ <- IDBObjectStore.openKeyCursor store Nothing Prev
            _ <- IDBObjectStore.openKeyCursor store Nothing PrevUnique
            _ <- IDBObjectStore.openKeyCursor store (Just $ IDBKeyRange.lowerBound 1 true) Next
            pure unit
        }
      tearDown db

  describe "IDBIndex" do
    let
        tearDown db = do
          IDBDatabase.close db
          _ <- IDBFactory.deleteDatabase (IDBDatabase.name db)
          pure unit

        setup :: forall value e e'.
                 { storeParams     :: { keyPath :: Array String, autoIncrement :: Boolean }
                 , indexParams     :: { unique :: Boolean, multiEntry :: Boolean }
                 , values          :: Array (Tuple value (Maybe Key))
                 , keyPath         :: Array String
                 , onUpgradeNeeded :: Maybe (Database -> Transaction -> Index -> Eff (idb :: IDB, avar :: AVAR, exception :: EXCEPTION | e') Unit)
               } -> Aff (idb :: IDB, avar :: AVAR | e) { db :: Database, index :: Index, store :: ObjectStore }
        setup { storeParams, indexParams, values, keyPath, onUpgradeNeeded } = do
          let onUpgradeNeeded' var db tx = launchAff' do
                store <- IDBDatabase.createObjectStore db "store" storeParams
                _     <- traverse (uncurry (IDBObjectStore.add store)) values
                index <- IDBObjectStore.createIndex store "index" keyPath indexParams
                liftEff $ maybe (pure unit) id (onUpgradeNeeded <*> pure db <*> pure tx <*> pure index)
                putVar var { db, index, store }

          var <- makeVar
          db  <- IDBFactory.open "db" Nothing
            { onUpgradeNeeded : Just (onUpgradeNeeded' var)
            , onBlocked : Nothing
            }
          takeVar var


    it "returns an IDBIndex and the properties are set correctly" do
      { db, index } <- setup
        { storeParams     : IDBObjectStore.defaultParameters
        , indexParams     : IDBIndex.defaultParameters
        , onUpgradeNeeded : Nothing
        , keyPath         : []
        , values          : []
        }
      IDBIndex.name index `shouldEqual` "index"
      IDBIndex.keyPath index `shouldEqual` []
      IDBIndex.unique index `shouldEqual` IDBIndex.defaultParameters.unique
      IDBIndex.multiEntry index `shouldEqual` IDBIndex.defaultParameters.multiEntry
      tearDown db

    it "attempt to create an index that requires unique values on an object store already contains duplicates" do
      let onAbort var = launchAff' (putVar var true)
      txVar <- makeVar
      dbVar <- makeVar
      res   <- attempt $ setup
        { storeParams     : IDBObjectStore.defaultParameters
        , indexParams     : { unique : true
                            , multiEntry : false
                            }
        , keyPath         : ["indexedProperty"]
        , values          : [ { indexedProperty: "bar" } :+: (Just $ toKey 1)
                            , { indexedProperty: "bar" } :+: (Just $ toKey 2)
                            ]
        , onUpgradeNeeded : Just $ \db tx _ -> launchAff' do
            IDBTransaction.onAbort tx (onAbort txVar)
            IDBDatabase.onAbort db (onAbort dbVar)
        }
      case res of
        Right _ ->
          fail "expected abort"
        _       -> do
          shouldEqual true =<< takeVar txVar
          shouldEqual true =<< takeVar dbVar


    it "the index is usable right after being made" do
      { db } <- setup
        { storeParams     : { keyPath       : ["key"]
                            , autoIncrement : false
                            }
        , indexParams     : IDBIndex.defaultParameters
        , keyPath         : ["indexedProperty"]
        , values          : [ { key: "key1", indexedProperty: "indexed_1" } :+: Nothing
                            , { key: "key2", indexedProperty: "indexed_2" } :+: Nothing
                            , { key: "key3", indexedProperty: "indexed_3" } :+: Nothing
                            ]
        , onUpgradeNeeded : Just $ \_ _ index -> launchAff' do
            val <- IDBIndex.get index (IDBKeyRange.only "indexed_2")
            ((\r -> r.key) <$> val) `shouldEqual` (Just $ toKey "key2")
        }
      tearDown db

    it "empty keyPath" do
      { db } <- setup
        { storeParams     : IDBObjectStore.defaultParameters
        , indexParams     : IDBIndex.defaultParameters
        , keyPath         : []
        , values          : [ "object_1" :+: (Just $ toKey 1)
                            , "object_2" :+: (Just $ toKey 2)
                            , "object_3" :+: (Just $ toKey 3)
                            ]
        , onUpgradeNeeded : Just $ \_ _ index -> launchAff' do
            val <- IDBIndex.get index (IDBKeyRange.only "object_3")
            val `shouldEqual` (Just "object_3")
        }
      tearDown db

    it "index can be valid keys [date]" do
      date   <- liftEff $ toDateTime <$> now
      { db } <- setup
        { storeParams     : { keyPath: ["key"]
                            , autoIncrement: false
                            }
        , indexParams     : IDBIndex.defaultParameters
        , keyPath         : ["i"]
        , values          : [ { key: "date", i: (toKey date) } :+: Nothing
                            ]
        , onUpgradeNeeded : Just $ \_ _ index -> launchAff' do
            val <- IDBIndex.get index (IDBKeyRange.only date)
            ((\r -> r.key) <$> val) `shouldEqual` (Just "date")
        }
      tearDown db

    it "index can be valid keys [num]" do
      let num = 14
      { db } <- setup
        { storeParams     : { keyPath: ["key"]
                            , autoIncrement: false
                            }
        , indexParams     : IDBIndex.defaultParameters
        , keyPath         : ["i"]
        , values          : [ { key: "num", i: (toKey num) } :+: Nothing
                            ]
        , onUpgradeNeeded : Just $ \_ _ index -> launchAff' do
            val <- IDBIndex.get index (IDBKeyRange.only num)
            ((\r -> r.key) <$> val) `shouldEqual` (Just "num")
        }
      tearDown db

    it "index can be valid keys [array]" do
      let array = ["patate", "autruche"]
      { db } <- setup
        { storeParams     : { keyPath: ["key"]
                            , autoIncrement: false
                            }
        , indexParams     : IDBIndex.defaultParameters
        , keyPath         : ["i"]
        , values          : [ { key: "array", i: (toKey array) } :+: Nothing
                            ]
        , onUpgradeNeeded : Just $ \_ _ index -> launchAff' do
            val <- IDBIndex.get index (IDBKeyRange.only array)
            ((\r -> r.key) <$> val) `shouldEqual` (Just "array")
        }
      tearDown db

    it "multiEntry - adding keys" do
      { db } <- setup
        { storeParams     : IDBObjectStore.defaultParameters
        , indexParams     : { unique: false, multiEntry: true }
        , keyPath         : ["name"]
        , values          : [ { name: ["patate", "autruche"] } :+: (Just $ toKey 1)
                            , { name: ["bob"] } :+: (Just $ toKey 2)
                            ]
        , onUpgradeNeeded : Just $ \_ _ index -> launchAff' do
            key <- IDBIndex.getKey index (IDBKeyRange.only "patate")
            key `shouldEqual` (Just $ toKey 1)

            key <- IDBIndex.getKey index (IDBKeyRange.only "autruche")
            key `shouldEqual` (Just $ toKey 1)

            key <- IDBIndex.getKey index (IDBKeyRange.only "bob")
            key `shouldEqual` (Just $ toKey 2)
        }
      tearDown db
