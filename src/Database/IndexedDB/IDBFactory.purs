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

import Database.IndexedDB.Core

import Data.Function.Uncurried (Fn4)
import Data.Function.Uncurried as Fn
import Data.Maybe (Maybe, fromMaybe)
import Effect (Effect)
import Effect.Aff (Aff)
import Effect.Aff.Compat (EffectFnAff, fromEffectFnAff)
import Prelude (Unit, ($), (<<<))

--------------------
-- TYPES
--

-- Type alias for binding listeners to an initial open action.
type Callbacks =
  { onBlocked :: Maybe (Effect Unit)
  , onUpgradeNeeded :: Maybe (Database -> Transaction -> { oldVersion :: Int } -> Effect Unit)
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
  :: DatabaseName
  -> Aff Int
deleteDatabase =
  fromEffectFnAff <<< _deleteDatabase

-- | Attempts to open a connection to the named database with the specified version.
-- | If the database already exists with a lower version and there are open connections
-- | that don’t close in response to a versionchange event, the request will be blocked
-- | until all they close, then an upgrade will occur. If the database already exists with
-- | a higher version the request will fail.
-- |
-- | When the version isn't provided (`Nothing`), attempts to open a connection to the
-- | named database with the current version, or 1 if it does not already exist.
open
  :: DatabaseName
  -> Maybe Version
  -> Callbacks
  -> Aff Database
open name mver req =
  fromEffectFnAff $ Fn.runFn4 _open fromMaybe name mver req

--------------------
-- FFI
--
foreign import _deleteDatabase
  :: String
  -> EffectFnAff Int

foreign import _open
  :: forall a
   . Fn4 (a -> Maybe a -> a) String (Maybe Int) (Callbacks) (EffectFnAff Database)
