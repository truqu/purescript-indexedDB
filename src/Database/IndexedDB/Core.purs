module Database.IndexedDB.Core where

import Prelude

import Control.Alt                 ((<|>))
import Control.Monad.Aff           (Aff)
import Control.Monad.Eff           (kind Effect, Eff)
import Control.Monad.Eff.Exception (EXCEPTION)
import Control.Monad.Except        (ExceptT(..), runExceptT)
import Data.Date                    as Date
import Data.DateTime                as DateTime
import Data.DateTime               (DateTime(..), Date(..), Time(..))
import Data.Either                 (Either(..), isRight)
import Data.Enum                   (fromEnum, toEnum)
import Data.Foreign                 as Foreign
import Data.Foreign                (Foreign, F)
import Data.Function.Uncurried      as Fn
import Data.Function.Uncurried     (Fn2, Fn4, Fn7)
import Data.Identity               (Identity(..))
import Data.List.NonEmpty          (NonEmptyList(..))
import Data.List.Types             (List(..))
import Data.Maybe                  (Maybe)
import Data.NonEmpty               (NonEmpty(..))
import Data.Nullable               (Nullable, toNullable)
import Data.Time                    as Time
import Data.Traversable            (traverse)


foreign import data INDEXED_DB :: Effect


foreign import data IDBDatabase :: Type


foreign import _showIDBDatabase :: IDBDatabase -> String
instance showIDBDatabase :: Show IDBDatabase where
  show = _showIDBDatabase


foreign import data IDBObjectStore :: Type


foreign import _showIDBObjectStore :: IDBObjectStore -> String
instance showIDBObjectStore :: Show IDBObjectStore where
  show = _showIDBObjectStore

foreign import data IDBTransaction :: Type


foreign import _showIDBTransaction :: IDBTransaction -> String
instance showIDBTransaction :: Show IDBTransaction where
  show = _showIDBTransaction


data IDBTransactionMode = ReadOnly | ReadWrite | VersionChange


newtype Key = Key Foreign


instance eqKey :: Eq Key where
  eq a b = (runExceptT >>> runIdentity >>> isRight) $
      eq <$> ((fromKey a) :: F Int) <*> fromKey b
    <|>
      eq <$> ((fromKey a) :: F String) <*> fromKey b
    <|>
      eq <$> ((fromKey a) :: F DateTime) <*> fromKey b
    where
      runIdentity :: forall a. Identity a -> a
      runIdentity (Identity a) = a

class Index a where
  toKey         :: a -> Key
  fromKey       :: Key -> F a
  unsafeFromKey :: Key -> a


instance indexInt :: Index Int where
  toKey                 = Foreign.toForeign >>> Key
  fromKey (Key f)       = Foreign.readInt f
  unsafeFromKey (Key f) = Foreign.unsafeFromForeign f


instance indexString :: Index String where
  toKey                 = Foreign.toForeign >>> Key
  fromKey (Key f)       = Foreign.readString f
  unsafeFromKey (Key f) = Foreign.unsafeFromForeign f


instance indexDate :: Index DateTime where
  toKey (DateTime d t) = Key $ Fn.runFn7 _dateTimeToForeign
    (fromEnum $ Date.year d)
    (fromEnum $ Date.month d)
    (fromEnum $ Date.day d)
    (fromEnum $ Time.hour t)
    (fromEnum $ Time.minute t)
    (fromEnum $ Time.second t)
    (fromEnum $ Time.millisecond t)
  fromKey (Key f)       = Fn.runFn4 _readDateTime dateTime dateTimeF dateTimeE f
  unsafeFromKey (Key f) = Fn.runFn2 _unsafeReadDateTime dateTime f


instance indexArray :: Index a => Index (Array a) where
  toKey                 = Foreign.toForeign >>> Key
  fromKey (Key f)       = Foreign.readArray f >>= traverse (Key >>> fromKey)
  unsafeFromKey (Key f) = map unsafeFromKey (Foreign.unsafeFromForeign f)


foreign import _dateTimeToForeign  :: Fn7 Int Int Int Int Int Int Int Foreign
foreign import _readDateTime       :: Fn4 (Int -> Int -> Int -> Int -> Int -> Int -> Int -> Nullable DateTime) (DateTime -> F DateTime) (String -> F DateTime) Foreign (F DateTime)
foreign import _unsafeReadDateTime :: Fn2 (Int -> Int -> Int -> Int -> Int -> Int -> Int -> Nullable DateTime) Foreign DateTime


dateTime :: Int -> Int -> Int -> Int -> Int -> Int -> Int -> Nullable DateTime
dateTime y m d h mi s ms =
  toNullable $ DateTime
  <$> (Date.canonicalDate <$> toEnum y <*> toEnum m <*> toEnum d)
  <*> (Time <$> toEnum h <*> toEnum mi <*> toEnum s <*> toEnum ms)


dateTimeF :: DateTime -> F DateTime
dateTimeF =
  Right >>> Identity >>> ExceptT


dateTimeE :: String -> F DateTime
dateTimeE =
  Foreign.TypeMismatch "Date" >>> flip NonEmpty Nil >>> NonEmptyList >>> Left >>> Identity >>> ExceptT
