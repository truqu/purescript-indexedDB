-- | Database objects are accessed through methods on the IDBFactory interface.
-- | A single object implementing this interface is present in the global scope
-- | of environments that support Indexed DB operations.
module Database.IndexedDB.IDBFactory
  -- * Types
  ( Callbacks
  , DatabaseName
  , Version

  -- * Interface
  , deleteDatabase
  , open
  ) where

import Prelude                  (Unit, ($), (<<<))

import Control.Monad.Aff        (Aff)
import Control.Monad.Aff.Compat (fromEffFnAff, EffFnAff)
import Control.Monad.Eff        (Eff)
import Data.Function.Uncurried   as Fn
import Data.Function.Uncurried  (Fn4)
import Data.Maybe               (Maybe, fromMaybe)

import Database.IndexedDB.Core


--------------------
-- TYPES
--

-- Type alias for binding listeners to an initial open action.
type Callbacks e =
  { onBlocked       :: Maybe (Eff (| e) Unit)
  , onUpgradeNeeded :: Maybe (Database -> Transaction -> { oldVersion :: Int } -> Eff (| e) Unit)
  }


-- | Type alias for DatabaseName.
type DatabaseName = String


-- | Type alias for Version.
type Version = Int


--------------------
-- INTERFACE
--

-- | Attempts to delete the named database. If the database already exists
-- | and there are open connections that don’t close in response to a
-- | `versionchange` event, the request will be blocked until all they close.
deleteDatabase
    :: forall e
    .  DatabaseName
    -> Aff (idb :: IDB | e) Int
deleteDatabase =
  fromEffFnAff <<< _deleteDatabase


-- | Attempts to open a connection to the named database with the specified version.
-- | If the database already exists with a lower version and there are open connections
-- | that don’t close in response to a versionchange event, the request will be blocked
-- | until all they close, then an upgrade will occur. If the database already exists with
-- | a higher version the request will fail.
-- |
-- | When the version isn't provided (`Nothing`), attempts to open a connection to the
-- | named database with the current version, or 1 if it does not already exist.
open
    :: forall e e'
    .  DatabaseName
    -> Maybe Version
    -> Callbacks e'
    -> Aff (idb :: IDB | e) Database
open name mver req =
  fromEffFnAff $ Fn.runFn4 _open fromMaybe name mver req


--------------------
-- FFI
--
foreign import _deleteDatabase
    :: forall e
    .  String
    -> EffFnAff (idb :: IDB | e) Int


foreign import _open
    :: forall a e e'
    .  Fn4 (a -> Maybe a -> a) String (Maybe Int) (Callbacks e') (EffFnAff (idb :: IDB | e) Database)
