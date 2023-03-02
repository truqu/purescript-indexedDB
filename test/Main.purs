module Test.Main where

import Prelude

import Data.Array (head, drop)
import Data.Date as Date
import Data.DateTime (DateTime(..), Time(..))
import Data.DateTime.Instant (toDateTime)
import Data.Either (Either(..))
import Data.Enum (toEnum)
import Data.Maybe (Maybe(..), isNothing, maybe)
import Data.Time.Duration (Milliseconds(..))
import Data.Traversable (traverse)
import Data.Tuple (Tuple(..), uncurry)
import Database.IndexedDB.Core (CursorDirection(..), Database, Index, ObjectStore, Transaction, TransactionMode(..))
import Database.IndexedDB.IDBCursor as IDBCursor
import Database.IndexedDB.IDBDatabase as IDBDatabase
import Database.IndexedDB.IDBFactory as IDBFactory
import Database.IndexedDB.IDBIndex as IDBIndex
import Database.IndexedDB.IDBKey (Key, none, toKey)
import Database.IndexedDB.IDBKeyRange as IDBKeyRange
import Database.IndexedDB.IDBObjectStore as IDBObjectStore
import Database.IndexedDB.IDBTransaction as IDBTransaction
import Effect (Effect)
import Effect.Aff (Aff, attempt, delay, forkAff, launchAff, launchAff_)
import Effect.Aff.AVar (AVar)
import Effect.Aff.AVar as AVar
import Effect.Class (liftEffect)
import Effect.Console (log)
import Effect.Exception (name)
import Effect.Now (now)
import Test.Spec (describe, it)
import Test.Spec.Assertions (shouldEqual, fail)
import Test.Spec.Reporter (consoleReporter)
import Test.Spec.Runner (runSpec)

infixr 7 Tuple as :+:

launchAff' :: forall a. Aff a -> Effect Unit
launchAff' =
  launchAff_ <<< void

modifyAVar :: forall a. (a -> a) -> AVar a -> Aff Unit
modifyAVar fn v = do
  val <- AVar.take v
  AVar.put (fn val) v

main :: Effect Unit
main = do
  launchAff_ $ runSpec [ consoleReporter ] $ do
    describe "IDBFactory" do
      let
        tearDown name version db = do
          IDBDatabase.close db
          version' <- IDBFactory.deleteDatabase name
          liftEffect $ log $ show version'
          version' `shouldEqual` version

      it "open default" do
        let
          name = "db-default"
          version = 1
        db <- IDBFactory.open name Nothing
          { onUpgradeNeeded: Nothing
          , onBlocked: Nothing
          }
        IDBDatabase.name db `shouldEqual` name
        tearDown name version db

      it "open specific version" do
        let
          name = "db-specific"
          version = 14
        db <- IDBFactory.open name (Just version)
          { onUpgradeNeeded: Nothing
          , onBlocked: Nothing
          }
        IDBDatabase.name db `shouldEqual` name
        tearDown name version db

      it "open specific version -> close -> open latest" do
        let
          name = "db-latest"
          version = 14
        db01 <- IDBFactory.open name (Just version)
          { onUpgradeNeeded: Nothing
          , onBlocked: Nothing
          }
        IDBDatabase.name db01 `shouldEqual` name
        IDBDatabase.close db01
        db02 <- IDBFactory.open name Nothing
          { onUpgradeNeeded: Nothing
          , onBlocked: Nothing
          }
        tearDown name version db02

      it "open + onUpgradeNeed" do
        let
          name = "db-upgrade-needed"
          version = 1
          callback (Tuple varName varVersion) db _ { oldVersion } = do
            _ <- launchAff $ modifyAVar (const $ IDBDatabase.name db) varName
            _ <- launchAff $ modifyAVar (const $ oldVersion) varVersion
            pure unit
        varName <- AVar.new "-"
        varVersion <- AVar.new (-1)
        db <- IDBFactory.open name Nothing
          { onUpgradeNeeded: Just (callback (Tuple varName varVersion))
          , onBlocked: Nothing
          }
        name' <- AVar.read varName
        version' <- AVar.read varVersion
        name' `shouldEqual` name
        version' `shouldEqual` 0
        tearDown name version db

      it "open + onBlocked" do
        let
          name = "db-blocked"
          version = 14
          callback var = do
            _ <- launchAff $ modifyAVar (const $ "db-blocked") var
            pure unit

        var <- AVar.new "-"
        db01 <- IDBFactory.open name Nothing
          { onUpgradeNeeded: Nothing
          , onBlocked: Nothing
          }
        _ <- forkAff do
          delay (Milliseconds 100.0)
          IDBDatabase.close db01

        db02 <- IDBFactory.open name (Just version)
          { onUpgradeNeeded: Nothing
          , onBlocked: Just (callback var)
          }
        name' <- AVar.read var
        name' `shouldEqual` name
        tearDown name version db02

    describe "IDBKeyRange" do
      it "only(int)" do
        let
          key = 14
          range = IDBKeyRange.only key
        IDBKeyRange.includes range (toKey key) `shouldEqual` true

      it "only(string)" do
        let
          key = "patate"
          range = IDBKeyRange.only key
        IDBKeyRange.includes range (toKey key) `shouldEqual` true

      it "only(float)" do
        let
          key = 14.42
          range = IDBKeyRange.only key
        IDBKeyRange.includes range (toKey key) `shouldEqual` true

      it "only(date)" do
        let
          mkey = DateTime
            <$> (Date.canonicalDate <$> toEnum 2017 <*> toEnum 6 <*> toEnum 23)
            <*> (Time <$> toEnum 17 <*> toEnum 59 <*> toEnum 34 <*> toEnum 42)

        case mkey of
          Nothing ->
            fail "unable to create datetime"
          Just key -> do
            let range = IDBKeyRange.only key
            IDBKeyRange.includes range (toKey key) `shouldEqual` true

      it "only([int])" do
        let
          key = [ 14, 42 ]
          range = IDBKeyRange.only key
        IDBKeyRange.includes range (toKey key) `shouldEqual` true

      it "only([string])" do
        let
          key = [ "patate", "autruche" ]
          range = IDBKeyRange.only key
        IDBKeyRange.includes range (toKey key) `shouldEqual` true

      it "lowerBound(14, open)" do
        let
          key = 14
          open = true
          range = IDBKeyRange.lowerBound key open
        IDBKeyRange.includes range (toKey (key + 1)) `shouldEqual` true
        IDBKeyRange.includes range (toKey key) `shouldEqual` (not open)
        IDBKeyRange.includes range (toKey (key - 1)) `shouldEqual` false

      it "lowerBound(14, close)" do
        let
          key = 14
          open = false
          range = IDBKeyRange.lowerBound key open
        IDBKeyRange.includes range (toKey (key + 1)) `shouldEqual` true
        IDBKeyRange.includes range (toKey key) `shouldEqual` (not open)
        IDBKeyRange.includes range (toKey (key - 1)) `shouldEqual` false

      it "upperBound(14, open)" do
        let
          key = 14
          open = true
          range = IDBKeyRange.upperBound key open
        IDBKeyRange.includes range (toKey (key + 1)) `shouldEqual` false
        IDBKeyRange.includes range (toKey key) `shouldEqual` (not open)
        IDBKeyRange.includes range (toKey (key - 1)) `shouldEqual` true

      it "upperBound(14, close)" do
        let
          key = 14
          open = false
          range = IDBKeyRange.upperBound key open
        IDBKeyRange.includes range (toKey (key + 1)) `shouldEqual` false
        IDBKeyRange.includes range (toKey key) `shouldEqual` (not open)
        IDBKeyRange.includes range (toKey (key - 1)) `shouldEqual` true

      it "bound(42, 14, open, open) => Nothing" do
        let
          lower = 42
          upper = 14
          lowerOpen = true
          upperOpen = true
          mrange = IDBKeyRange.bound { lower, upper, lowerOpen, upperOpen }
        isNothing mrange `shouldEqual` true

      it "bound(14, 42, open, open)" do
        let
          lower = 14
          upper = 42
          lowerOpen = true
          upperOpen = true
          mrange = IDBKeyRange.bound { lower, upper, lowerOpen, upperOpen }
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
        let
          lower = 14
          upper = 42
          lowerOpen = true
          upperOpen = false
          mrange = IDBKeyRange.bound { lower, upper, lowerOpen, upperOpen }
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
        let
          lower = 14
          upper = 42
          lowerOpen = false
          upperOpen = true
          mrange = IDBKeyRange.bound { lower, upper, lowerOpen, upperOpen }
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
        let
          lower = 14
          upper = 42
          lowerOpen = false
          upperOpen = false
          mrange = IDBKeyRange.bound { lower, upper, lowerOpen, upperOpen }
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
        IDBKeyRange.upper range `shouldEqual` none
        IDBKeyRange.lowerOpen range `shouldEqual` false
        IDBKeyRange.upperOpen range `shouldEqual` true

    describe "IDBDatabase" do
      let
        tearDown db = do
          IDBDatabase.close db
          _ <- IDBFactory.deleteDatabase (IDBDatabase.name db)
          pure unit

        setup storeParams = do
          let
            onUpgradeNeeded var db _ _ = launchAff' do
              store <- IDBDatabase.createObjectStore db "store" storeParams
              _ <- AVar.put { db, store } var
              pure unit

          var <- AVar.empty
          _ <- IDBFactory.open "db" Nothing
            { onUpgradeNeeded: Just (onUpgradeNeeded var)
            , onBlocked: Nothing
            }

          AVar.take var

      it "createObjectStore (keyPath: [], autoIncrement: true)" do
        { db, store } <- setup { keyPath: [], autoIncrement: true }
        IDBObjectStore.name store `shouldEqual` "store"
        IDBObjectStore.keyPath store `shouldEqual` []
        IDBObjectStore.autoIncrement store `shouldEqual` true
        IDBObjectStore.indexNames store `shouldEqual` []
        tearDown db

      it "createObjectStore (keyPath: [\"patate\"], autoIncrement: true)" do
        { db, store } <- setup { keyPath: [ "patate" ], autoIncrement: true }
        IDBObjectStore.name store `shouldEqual` "store"
        IDBObjectStore.keyPath store `shouldEqual` [ "patate" ]
        IDBObjectStore.autoIncrement store `shouldEqual` true
        IDBObjectStore.indexNames store `shouldEqual` []
        tearDown db

      it "createObjectStore (keyPath: [\"a\", \"b\"], autoIncrement: false)" do
        { db, store } <- setup { keyPath: [ "patate", "autruche" ], autoIncrement: false }
        IDBObjectStore.name store `shouldEqual` "store"
        IDBObjectStore.keyPath store `shouldEqual` [ "patate", "autruche" ]
        IDBObjectStore.autoIncrement store `shouldEqual` false
        IDBObjectStore.indexNames store `shouldEqual` []
        tearDown db

      it "deleteObjectStore" do
        let
          onUpgradeNeeded var db _ _ = launchAff' do
            _ <- IDBDatabase.deleteObjectStore db "store"
            AVar.put true var

        var <- AVar.empty
        { db } <- setup IDBDatabase.defaultParameters
        IDBDatabase.close db
        db' <- IDBFactory.open "db" (Just 999)
          { onUpgradeNeeded: Just (onUpgradeNeeded var)
          , onBlocked: Nothing
          }
        deleted <- AVar.take var
        deleted `shouldEqual` true
        tearDown db'

    describe "IDBObjectStore" do
      let
        tearDown db = do
          IDBDatabase.close db
          _ <- IDBFactory.deleteDatabase (IDBDatabase.name db)
          pure unit

        setup { storeParams, onUpgradeNeeded } = do
          let
            onUpgradeNeeded' var db _ _ = launchAff' do
              store <- IDBDatabase.createObjectStore db "store" storeParams
              liftEffect $ maybe (pure unit) identity (onUpgradeNeeded <*> pure db <*> pure store)
              AVar.put { db, store } var

          var <- AVar.empty
          _ <- IDBFactory.open "db" Nothing
            { onUpgradeNeeded: Just (onUpgradeNeeded' var)
            , onBlocked: Nothing
            }

          AVar.take var

      it "add()" do
        date <- liftEffect $ toDateTime <$> now
        { db } <- setup
          { storeParams: { autoIncrement: true, keyPath: [] }
          , onUpgradeNeeded: Just $ \_ store -> launchAff' do
              -- no key
              key <- IDBObjectStore.add store "patate" none
              (toKey 1) `shouldEqual` key

              -- int key
              key' <- IDBObjectStore.add store "patate" (Just 14)
              (toKey 14) `shouldEqual` key'

              -- number key
              key'' <- IDBObjectStore.add store "patate" (Just 14.42)
              (toKey 14.42) `shouldEqual` key''

              -- string key
              key''' <- IDBObjectStore.add store "patate" (Just "key")
              (toKey "key") `shouldEqual` key'''

              -- date key
              key'''' <- IDBObjectStore.add store "patate" (Just date)
              (toKey date) `shouldEqual` key''''

              -- array key
              key''''' <- IDBObjectStore.add store "patate" (Just $ toKey [ 14, 42 ])
              (toKey [ 14, 42 ]) `shouldEqual` key'''''
          }
        tearDown db

      it "clear()" do
        { db } <- setup
          { storeParams: IDBDatabase.defaultParameters
          , onUpgradeNeeded: Just $ \_ store -> launchAff' do
              key <- IDBObjectStore.add store "patate" (Just 14)
              _ <- IDBObjectStore.clear store
              val <- IDBObjectStore.get store (IDBKeyRange.only key)
              val `shouldEqual` (Nothing :: Maybe String)
          }
        tearDown db

      it "count()" do
        { db } <- setup
          { storeParams: IDBDatabase.defaultParameters
          , onUpgradeNeeded: Just $ \_ store -> launchAff' do
              _ <- IDBObjectStore.add store "patate" (Just 14)
              _ <- IDBObjectStore.add store "autruche" (Just 42)
              n <- IDBObjectStore.count store Nothing
              n `shouldEqual` 2
          }
        tearDown db

      it "getKey()" do
        { db } <- setup
          { storeParams: IDBDatabase.defaultParameters
          , onUpgradeNeeded: Just $ \_ store -> launchAff' do
              key <- IDBObjectStore.add store "patate" (Just 14)
              mkey <- IDBObjectStore.getKey store (IDBKeyRange.only 14)
              mkey `shouldEqual` (Just key)

              mkey' <- IDBObjectStore.getKey store (IDBKeyRange.only 42)
              mkey' `shouldEqual` none
          }
        tearDown db

      it "getAllKeys()" do
        { db } <- setup
          { storeParams: IDBDatabase.defaultParameters
          , onUpgradeNeeded: Just $ \_ store -> launchAff' do
              key1 <- IDBObjectStore.add store "patate" (Just 14)
              key2 <- IDBObjectStore.add store "autruche" (Just 42)
              key3 <- IDBObjectStore.add store 14 (Just 1337)

              -- no bounds
              keys <- IDBObjectStore.getAllKeys store Nothing Nothing
              keys `shouldEqual` [ key1, key2, key3 ]

              -- lower bound
              keys' <- IDBObjectStore.getAllKeys store (Just $ IDBKeyRange.lowerBound 14 true) Nothing
              keys' `shouldEqual` [ key2, key3 ]

              -- upper bound
              keys'' <- IDBObjectStore.getAllKeys store (Just $ IDBKeyRange.upperBound 42 false) Nothing
              keys'' `shouldEqual` [ key1, key2 ]

              -- count
              keys''' <- IDBObjectStore.getAllKeys store (Just $ IDBKeyRange.lowerBound 1 true) (Just 2)
              keys''' `shouldEqual` [ key1, key2 ]
          }
        tearDown db

      it "openCursor()" do
        let
          cb =
            { onSuccess: const $ pure unit
            , onError: show >>> fail >>> launchAff'
            , onComplete: pure unit
            }
        { db } <- setup
          { storeParams: IDBDatabase.defaultParameters
          , onUpgradeNeeded: Just $ \_ store -> launchAff' do
              _ <- IDBObjectStore.openCursor store Nothing Next cb
              _ <- IDBObjectStore.openCursor store Nothing NextUnique cb
              _ <- IDBObjectStore.openCursor store Nothing Prev cb
              _ <- IDBObjectStore.openCursor store Nothing PrevUnique cb
              _ <- IDBObjectStore.openCursor store (Just $ IDBKeyRange.upperBound 1 true) Next cb
              pure unit
          }
        tearDown db

      it "openKeyCursor()" do
        let
          cb =
            { onSuccess: const $ pure unit
            , onError: show >>> fail >>> launchAff'
            , onComplete: pure unit
            }
        { db } <- setup
          { storeParams: IDBDatabase.defaultParameters
          , onUpgradeNeeded: Just $ \_ store -> launchAff' do
              _ <- IDBObjectStore.openKeyCursor store Nothing Next cb
              _ <- IDBObjectStore.openKeyCursor store Nothing NextUnique cb
              _ <- IDBObjectStore.openKeyCursor store Nothing Prev cb
              _ <- IDBObjectStore.openKeyCursor store Nothing PrevUnique cb
              _ <- IDBObjectStore.openKeyCursor store (Just $ IDBKeyRange.lowerBound 1 true) Next cb
              pure unit
          }
        tearDown db

    describe "IDBIndex" do
      let
        tearDown db = do
          IDBDatabase.close db
          _ <- IDBFactory.deleteDatabase (IDBDatabase.name db)
          pure unit

        setup
          :: forall value
           . { storeParams :: { keyPath :: Array String, autoIncrement :: Boolean }
             , indexParams :: { unique :: Boolean, multiEntry :: Boolean }
             , values :: Array (Tuple value (Maybe Key))
             , keyPath :: Array String
             , onUpgradeNeeded :: Maybe (Database -> Transaction -> Index -> Effect Unit)
             }
          -> Aff { db :: Database, index :: Index, store :: ObjectStore }
        setup { storeParams, indexParams, values, keyPath, onUpgradeNeeded } = do
          let
            onUpgradeNeeded' var db tx _ = launchAff' do
              store <- IDBDatabase.createObjectStore db "store" storeParams
              _ <- traverse (uncurry (IDBObjectStore.add store)) values
              index <- IDBObjectStore.createIndex store "index" keyPath indexParams
              liftEffect $ maybe (pure unit) identity (onUpgradeNeeded <*> pure db <*> pure tx <*> pure index)
              AVar.put { db, index, store } var

          var <- AVar.empty
          _ <- IDBFactory.open "db" Nothing
            { onUpgradeNeeded: Just (onUpgradeNeeded' var)
            , onBlocked: Nothing
            }
          AVar.take var

      it "returns an IDBIndex and the properties are set correctly" do
        { db, index } <- setup
          { storeParams: IDBDatabase.defaultParameters
          , indexParams: IDBObjectStore.defaultParameters
          , onUpgradeNeeded: Nothing
          , keyPath: []
          , values: []
          }
        IDBIndex.name index `shouldEqual` "index"
        IDBIndex.keyPath index `shouldEqual` []
        IDBIndex.unique index `shouldEqual` IDBObjectStore.defaultParameters.unique
        IDBIndex.multiEntry index `shouldEqual` IDBObjectStore.defaultParameters.multiEntry
        tearDown db

      it "attempt to create an index that requires unique values on an object store already contains duplicates" do
        let onAbort var = launchAff' (AVar.put true var)
        txVar <- AVar.empty
        dbVar <- AVar.empty
        res <- attempt $ setup
          { storeParams: IDBDatabase.defaultParameters
          , indexParams:
              { unique: true
              , multiEntry: false
              }
          , keyPath: [ "indexedProperty" ]
          , values:
              [ { indexedProperty: "bar" } :+: (Just $ toKey 1)
              , { indexedProperty: "bar" } :+: (Just $ toKey 2)
              ]
          , onUpgradeNeeded: Just $ \db tx _ -> launchAff' do
              IDBTransaction.onAbort tx (onAbort txVar)
              IDBDatabase.onAbort db (onAbort dbVar)
          }
        case res of
          Right _ ->
            fail "expected abort"
          _ -> do
            shouldEqual true =<< AVar.take txVar
            shouldEqual true =<< AVar.take dbVar

      it "the index is usable right after being made" do
        { db } <- setup
          { storeParams:
              { keyPath: [ "key" ]
              , autoIncrement: false
              }
          , indexParams: IDBObjectStore.defaultParameters
          , keyPath: [ "indexedProperty" ]
          , values:
              [ { key: "key1", indexedProperty: "indexed_1" } :+: Nothing
              , { key: "key2", indexedProperty: "indexed_2" } :+: Nothing
              , { key: "key3", indexedProperty: "indexed_3" } :+: Nothing
              ]
          , onUpgradeNeeded: Just $ \_ _ index -> launchAff' do
              val <- IDBIndex.get index (IDBKeyRange.only "indexed_2")
              ((\r -> r.key) <$> val) `shouldEqual` (Just $ toKey "key2")
          }
        tearDown db

      it "empty keyPath" do
        { db } <- setup
          { storeParams: IDBDatabase.defaultParameters
          , indexParams: IDBObjectStore.defaultParameters
          , keyPath: []
          , values:
              [ "object_1" :+: (Just $ toKey 1)
              , "object_2" :+: (Just $ toKey 2)
              , "object_3" :+: (Just $ toKey 3)
              ]
          , onUpgradeNeeded: Just $ \_ _ index -> launchAff' do
              val <- IDBIndex.get index (IDBKeyRange.only "object_3")
              val `shouldEqual` (Just "object_3")
          }
        tearDown db

      it "index can be valid keys [date]" do
        date <- liftEffect $ toDateTime <$> now
        { db } <- setup
          { storeParams:
              { keyPath: [ "key" ]
              , autoIncrement: false
              }
          , indexParams: IDBObjectStore.defaultParameters
          , keyPath: [ "i" ]
          , values:
              [ { key: "date", i: (toKey date) } :+: Nothing
              ]
          , onUpgradeNeeded: Just $ \_ _ index -> launchAff' do
              val <- IDBIndex.get index (IDBKeyRange.only date)
              ((\r -> r.key) <$> val) `shouldEqual` (Just "date")
          }
        tearDown db

      it "index can be valid keys [num]" do
        let num = 14
        { db } <- setup
          { storeParams:
              { keyPath: [ "key" ]
              , autoIncrement: false
              }
          , indexParams: IDBObjectStore.defaultParameters
          , keyPath: [ "i" ]
          , values:
              [ { key: "num", i: (toKey num) } :+: Nothing
              ]
          , onUpgradeNeeded: Just $ \_ _ index -> launchAff' do
              val <- IDBIndex.get index (IDBKeyRange.only num)
              ((\r -> r.key) <$> val) `shouldEqual` (Just "num")
          }
        tearDown db

      it "index can be valid keys [array]" do
        let array = [ "patate", "autruche" ]
        { db } <- setup
          { storeParams:
              { keyPath: [ "key" ]
              , autoIncrement: false
              }
          , indexParams: IDBObjectStore.defaultParameters
          , keyPath: [ "i" ]
          , values:
              [ { key: "array", i: (toKey array) } :+: Nothing
              ]
          , onUpgradeNeeded: Just $ \_ _ index -> launchAff' do
              val <- IDBIndex.get index (IDBKeyRange.only array)
              ((\r -> r.key) <$> val) `shouldEqual` (Just "array")
          }
        tearDown db

      it "openKeyCursor() - throw InvalidStateError on index deleted by aborted upgrade" do
        res <- attempt $ setup
          { storeParams: { keyPath: [ "key" ], autoIncrement: false }
          , indexParams: IDBObjectStore.defaultParameters
          , keyPath: [ "indexedProperty" ]
          , values:
              [ { key: 14, indexedProperty: "patate" } :+: Nothing
              ]
          , onUpgradeNeeded: Just $ \db tx index -> launchAff' do
              let
                cb =
                  { onSuccess: const $ pure unit
                  , onError: show >>> fail >>> launchAff'
                  , onComplete: pure unit
                  }
              IDBTransaction.onAbort tx (pure unit)
              IDBDatabase.onAbort db (pure unit)
              IDBTransaction.abort tx
              cursor <- attempt $ IDBIndex.openKeyCursor index Nothing Next cb
              case cursor of
                Right _ -> fail "expected InvalidStateError"
                Left err -> name err `shouldEqual` "InvalidStateError"
          }
        case res of
          Right _ -> fail "expected InvalidStateError"
          _ -> pure unit

      it "openKeyCursor() - throw TransactionInactiveError on aborted transaction" do
        { db } <- setup
          { storeParams: { keyPath: [ "key" ], autoIncrement: false }
          , indexParams: IDBObjectStore.defaultParameters
          , keyPath: [ "indexedProperty" ]
          , values:
              [ { key: 14, indexedProperty: "patate" } :+: Nothing
              ]
          , onUpgradeNeeded: Nothing
          }
        let
          cb =
            { onSuccess: const $ pure unit
            , onError: show >>> fail >>> launchAff'
            , onComplete: pure unit
            }
        tx <- IDBDatabase.transaction db [ "store" ] ReadOnly
        store <- IDBTransaction.objectStore tx "store"
        index <- IDBObjectStore.index store "index"
        IDBTransaction.onAbort tx (pure unit)
        IDBTransaction.abort tx
        cursor <- attempt $ IDBIndex.openKeyCursor index Nothing Next cb
        case cursor of
          Right _ -> fail "expected TransactionInactiveError"
          Left err -> name err `shouldEqual` "TransactionInactiveError"

        tearDown db

      it "openKeyCursor() - throw InvalidStateError when the index is deleted" do
        { db } <- setup
          { storeParams: { keyPath: [ "key" ], autoIncrement: false }
          , indexParams: IDBObjectStore.defaultParameters
          , keyPath: [ "indexedProperty" ]
          , values:
              [ { key: 14, indexedProperty: "patate" } :+: Nothing
              ]
          , onUpgradeNeeded: Just $ \_ tx index -> launchAff' do
              let
                cb =
                  { onSuccess: const $ pure unit
                  , onError: show >>> fail >>> launchAff'
                  , onComplete: pure unit
                  }
              store <- IDBTransaction.objectStore tx "store"
              IDBObjectStore.deleteIndex store "index"
              cursor <- attempt $ IDBIndex.openKeyCursor index Nothing Next cb
              case cursor of
                Right _ -> fail "expected InvalidStateError"
                Left err -> name err `shouldEqual` "InvalidStateError"
          }

        tearDown db

      it "openCursor() - throw InvalidStateError on index deleted by aborted upgrade" do
        res <- attempt $ setup
          { storeParams: { keyPath: [ "key" ], autoIncrement: false }
          , indexParams: IDBObjectStore.defaultParameters
          , keyPath: [ "indexedProperty" ]
          , values:
              [ { key: 14, indexedProperty: "patate" } :+: Nothing
              ]
          , onUpgradeNeeded: Just $ \db tx index -> launchAff' do
              let
                cb =
                  { onSuccess: const $ pure unit
                  , onError: show >>> fail >>> launchAff'
                  , onComplete: pure unit
                  }
              IDBTransaction.onAbort tx (pure unit)
              IDBDatabase.onAbort db (pure unit)
              IDBTransaction.abort tx
              cursor <- attempt $ IDBIndex.openCursor index Nothing Next cb
              case cursor of
                Right _ -> fail "expected InvalidStateError"
                Left err -> name err `shouldEqual` "InvalidStateError"
          }
        case res of
          Right _ -> fail "expected InvalidStateError"
          _ -> pure unit

      it "openCursor() - throw TransactionInactiveError on aborted transaction" do
        { db } <- setup
          { storeParams: { keyPath: [ "key" ], autoIncrement: false }
          , indexParams: IDBObjectStore.defaultParameters
          , keyPath: [ "indexedProperty" ]
          , values:
              [ { key: 14, indexedProperty: "patate" } :+: Nothing
              ]
          , onUpgradeNeeded: Nothing
          }
        let
          cb =
            { onSuccess: const $ pure unit
            , onError: show >>> fail >>> launchAff'
            , onComplete: pure unit
            }
        tx <- IDBDatabase.transaction db [ "store" ] ReadOnly
        store <- IDBTransaction.objectStore tx "store"
        index <- IDBObjectStore.index store "index"
        IDBTransaction.onAbort tx (pure unit)
        IDBTransaction.abort tx
        cursor <- attempt $ IDBIndex.openCursor index Nothing Next cb
        case cursor of
          Right _ -> fail "expected TransactionInactiveError"
          Left err -> name err `shouldEqual` "TransactionInactiveError"

        tearDown db

      it "openCursor() - throw InvalidStateError when the index is deleted" do
        { db } <- setup
          { storeParams: { keyPath: [ "key" ], autoIncrement: false }
          , indexParams: IDBObjectStore.defaultParameters
          , keyPath: [ "indexedProperty" ]
          , values:
              [ { key: 14, indexedProperty: "patate" } :+: Nothing
              ]
          , onUpgradeNeeded: Just $ \db tx index -> launchAff' do
              let
                cb =
                  { onSuccess: const $ pure unit
                  , onError: show >>> fail >>> launchAff'
                  , onComplete: pure unit
                  }
              store <- IDBTransaction.objectStore tx "store"
              IDBObjectStore.deleteIndex store "index"
              cursor <- attempt $ IDBIndex.openCursor index Nothing Next cb
              case cursor of
                Right _ -> fail "expected InvalidStateError"
                Left err -> name err `shouldEqual` "InvalidStateError"
          }

        tearDown db

      it "getKey() - multiEntry - adding keys" do
        { db } <- setup
          { storeParams: IDBDatabase.defaultParameters
          , indexParams: { unique: false, multiEntry: true }
          , keyPath: [ "name" ]
          , values:
              [ { name: [ "patate", "autruche" ] } :+: (Just $ toKey 1)
              , { name: [ "bob" ] } :+: (Just $ toKey 2)
              ]
          , onUpgradeNeeded: Just $ \_ _ index -> launchAff' do
              key <- IDBIndex.getKey index (IDBKeyRange.only "patate")
              key `shouldEqual` (Just $ toKey 1)

              key' <- IDBIndex.getKey index (IDBKeyRange.only "autruche")
              key' `shouldEqual` (Just $ toKey 1)

              key'' <- IDBIndex.getKey index (IDBKeyRange.only "bob")
              key'' `shouldEqual` (Just $ toKey 2)
          }
        tearDown db

      it "get() - returns the record with the first key in the range" do
        { db } <- setup
          { storeParams: { keyPath: [ "key" ], autoIncrement: false }
          , indexParams: IDBObjectStore.defaultParameters
          , keyPath: [ "indexedProperty" ]
          , values:
              [ { key: 14, indexedProperty: "patate" } :+: Nothing
              , { key: 42, indexedProperty: "autruche" } :+: Nothing
              , { key: 1337, indexedProperty: "baguette" } :+: Nothing
              ]
          , onUpgradeNeeded: Nothing
          }

        tx <- IDBDatabase.transaction db [ "store" ] ReadOnly
        store <- IDBTransaction.objectStore tx "store"
        index <- IDBObjectStore.index store "index"
        val <- IDBIndex.get index (IDBKeyRange.lowerBound "autruche" false)
        ((\r -> r.key) <$> val) `shouldEqual` (Just 42)

        tearDown db

    describe "IDBCursor" do
      let
        tearDown db = do
          IDBDatabase.close db
          _ <- IDBFactory.deleteDatabase (IDBDatabase.name db)
          pure unit

        setup
          :: forall value
           . { storeParams :: { keyPath :: Array String, autoIncrement :: Boolean }
             , indexParams :: { unique :: Boolean, multiEntry :: Boolean }
             , values :: Array (Tuple value (Maybe Key))
             , keyPath :: Array String
             , onUpgradeNeeded :: Maybe (Database -> Transaction -> Index -> Effect Unit)
             }
          -> Aff { db :: Database, index :: Index, store :: ObjectStore }
        setup { storeParams, indexParams, values, keyPath, onUpgradeNeeded } = do
          let
            onUpgradeNeeded' var db tx _ = launchAff' do
              store <- IDBDatabase.createObjectStore db "store" storeParams
              _ <- traverse (uncurry (IDBObjectStore.add store)) values
              index <- IDBObjectStore.createIndex store "index" keyPath indexParams
              liftEffect $ maybe (pure unit) identity (onUpgradeNeeded <*> pure db <*> pure tx <*> pure index)
              AVar.put { db, index, store } var

          var <- AVar.empty
          db <- IDBFactory.open "db" Nothing
            { onUpgradeNeeded: Just (onUpgradeNeeded' var)
            , onBlocked: Nothing
            }
          AVar.take var

      it "continue() - iterate to the next record" do
        { db } <- setup
          { storeParams: IDBDatabase.defaultParameters
          , indexParams: IDBObjectStore.defaultParameters
          , keyPath: []
          , values:
              [ "cupcake" :+: (Just $ toKey 4)
              , "pancake" :+: (Just $ toKey 2)
              , "pie" :+: (Just $ toKey 1)
              , "pie" :+: (Just $ toKey 3)
              ]
          , onUpgradeNeeded: Nothing
          }
        let
          cb vdone vvals =
            { onComplete: launchAff' do
                AVar.put unit vdone

            , onError: \error -> launchAff' do
                fail $ "unexpected error: " <> show error

            , onSuccess: \cursor -> launchAff' do
                vals <- AVar.take vvals
                pure (IDBCursor.value cursor) >>= shouldEqual (maybe "" _.v $ head vals)
                IDBCursor.primaryKey cursor >>= shouldEqual (maybe (toKey 0) _.k $ head vals)
                AVar.put (drop 1 vals) vvals
                IDBCursor.continue cursor none
            }
        vdone <- AVar.empty
        vvals <- AVar.new
          [ { v: "pie", k: toKey 1 }
          , { v: "pancake", k: toKey 2 }
          , { v: "pie", k: toKey 3 }
          , { v: "cupcake", k: toKey 4 }
          ]
        tx <- IDBDatabase.transaction db [ "store" ] ReadOnly
        store <- IDBTransaction.objectStore tx "store"
        IDBObjectStore.openCursor store Nothing Next (cb vdone vvals)
        AVar.take vdone
        tearDown db

      it "continue() - attempt to iterate in the wrong direction" do
        { db } <- setup
          { storeParams: IDBDatabase.defaultParameters
          , indexParams: IDBObjectStore.defaultParameters
          , keyPath: []
          , values:
              [ "cupcake" :+: (Just $ toKey 4)
              , "pancake" :+: (Just $ toKey 2)
              , "pie" :+: (Just $ toKey 1)
              , "pie" :+: (Just $ toKey 3)
              ]
          , onUpgradeNeeded: Nothing
          }
        let
          cb vdone =
            { onComplete: launchAff' do
                fail $ "shouldn't complete"

            , onError: \error -> launchAff' do
                fail $ "unexpected error: " <> show error

            , onSuccess: \cursor -> launchAff' do
                res <- attempt $ IDBCursor.continue cursor (Just 1)
                case res of
                  Left err -> do
                    name err `shouldEqual` "DataError"
                    AVar.put unit vdone
                  Right _ -> do
                    fail "expected continue to fail"
            }
        vdone <- AVar.empty
        tx <- IDBDatabase.transaction db [ "store" ] ReadOnly
        store <- IDBTransaction.objectStore tx "store"
        IDBObjectStore.openCursor store Nothing Next (cb vdone)
        AVar.take vdone
        tearDown db

      it "advance() - iterate cursor number of times specified by count" do
        { db } <- setup
          { storeParams: { keyPath: [ "pKey" ], autoIncrement: false }
          , indexParams: IDBObjectStore.defaultParameters
          , keyPath: []
          , values:
              [ { pKey: "pkey_0", iKey: "ikey_0" } :+: Nothing
              , { pKey: "pkey_1", iKey: "ikey_1" } :+: Nothing
              , { pKey: "pkey_2", iKey: "ikey_2" } :+: Nothing
              , { pKey: "pkey_3", iKey: "ikey_3" } :+: Nothing
              ]
          , onUpgradeNeeded: Nothing
          }
        let
          cb vdone vjump =
            { onComplete: launchAff' do
                AVar.put unit vdone

            , onError: \error -> launchAff' do
                fail $ "unexpected error: " <> show error

            , onSuccess: \cursor -> launchAff' do
                jump <- AVar.take vjump
                if jump then do
                  IDBCursor.advance cursor 3
                else do
                  let value = IDBCursor.value cursor
                  value.pKey `shouldEqual` "pkey_3"
                  value.iKey `shouldEqual` "ikey_3"
                  IDBCursor.continue cursor none
                AVar.put false vjump
            }
        vdone <- AVar.empty
        vjump <- AVar.new true
        tx <- IDBDatabase.transaction db [ "store" ] ReadOnly
        store <- IDBTransaction.objectStore tx "store"
        IDBObjectStore.openCursor store Nothing Next (cb vdone vjump)
        AVar.take vdone
        tearDown db

      it "delete() - remove a record from the object store" do
        { db } <- setup
          { storeParams: { keyPath: [ "pKey" ], autoIncrement: false }
          , indexParams: IDBObjectStore.defaultParameters
          , keyPath: []
          , values:
              [ { pKey: "pkey_0", iKey: "ikey_0" } :+: Nothing
              , { pKey: "pkey_1", iKey: "ikey_1" } :+: Nothing
              , { pKey: "pkey_2", iKey: "ikey_2" } :+: Nothing
              , { pKey: "pkey_3", iKey: "ikey_3" } :+: Nothing
              ]
          , onUpgradeNeeded: Nothing
          }
        let
          cb vdone store =
            { onComplete: launchAff' do
                mval <- map _.pKey <$> IDBIndex.get store (IDBKeyRange.only "pkey_0")
                mval `shouldEqual` (Nothing :: Maybe String)
                AVar.put unit vdone

            , onError: \error -> launchAff' do
                fail $ "unexpected error: " <> show error

            , onSuccess: \cursor -> launchAff' do
                let value = IDBCursor.value cursor
                value.pKey `shouldEqual` "pkey_0"
                IDBCursor.delete cursor
                IDBCursor.advance cursor 4
            }
        vdone <- AVar.empty
        tx <- IDBDatabase.transaction db [ "store" ] ReadWrite
        store <- IDBTransaction.objectStore tx "store"
        IDBObjectStore.openCursor store Nothing Next (cb vdone store)
        AVar.take vdone
        tearDown db

      it "update() - modify a record in the object store" do
        { db } <- setup
          { storeParams: { keyPath: [ "pKey" ], autoIncrement: false }
          , indexParams: IDBObjectStore.defaultParameters
          , keyPath: []
          , values:
              [ { pKey: "pkey_0", iKey: "ikey_0" } :+: Nothing
              ]
          , onUpgradeNeeded: Nothing
          }
        let
          cb vdone store =
            { onComplete: launchAff' do
                mval <- map _.iKey <$> IDBIndex.get store (IDBKeyRange.only "pkey_0")
                mval `shouldEqual` (Just "patate")
                AVar.put unit vdone

            , onError: \error -> launchAff' do
                fail $ "unexpected error: " <> show error

            , onSuccess: \cursor -> launchAff' do
                let value = IDBCursor.value cursor
                value.pKey `shouldEqual` "pkey_0"
                key <- IDBCursor.update cursor { pKey: "pkey_0", iKey: "patate" }
                key `shouldEqual` toKey "pkey_0"
                IDBCursor.advance cursor 4
            }
        vdone <- AVar.empty
        tx <- IDBDatabase.transaction db [ "store" ] ReadWrite
        store <- IDBTransaction.objectStore tx "store"
        IDBObjectStore.openCursor store Nothing Next (cb vdone store)
        AVar.take vdone
        tearDown db

      it "update() - throw ReadOnlyError after update on ReadOnly transaction" do
        { db } <- setup
          { storeParams: { keyPath: [ "pKey" ], autoIncrement: false }
          , indexParams: IDBObjectStore.defaultParameters
          , keyPath: []
          , values:
              [ { pKey: "pkey_0", iKey: "ikey_0" } :+: Nothing
              ]
          , onUpgradeNeeded: Nothing
          }
        let
          cb vdone =
            { onComplete: launchAff' do
                fail $ "shouldn't complete"

            , onError: \error -> launchAff' do
                fail $ "unexpected error: " <> show error

            , onSuccess: \cursor -> launchAff' do
                res <- attempt $ IDBCursor.update cursor "patate"
                case res of
                  Left err -> do
                    name err `shouldEqual` "ReadOnlyError"
                    AVar.put unit vdone
                  Right _ ->
                    fail $ "expected ReadOnlyError"
            }
        vdone <- AVar.empty
        tx <- IDBDatabase.transaction db [ "store" ] ReadOnly
        store <- IDBTransaction.objectStore tx "store"
        IDBObjectStore.openCursor store Nothing Next (cb vdone)
        AVar.take vdone
        tearDown db

