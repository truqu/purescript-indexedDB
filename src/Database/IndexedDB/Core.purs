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


data IDBCursorDirection = Next | NextUnique | Prev | PrevUnique


foreign import data IDBKeyRange :: Type


foreign import data IDBCursorWithValue :: Type


foreign import data IDBKeyCursor :: Type


foreign import data IDBIndex :: Type


newtype KeyPath = KeyPath Foreign


instance showIDBCursorDirection :: Show IDBCursorDirection where
  show Next       = "next"
  show NextUnique = "nextunique"
  show Prev       = "prev"
  show PrevUnique = "prevunique"


instance eqKeyPath :: Eq KeyPath where
  eq a b = (runExceptT >>> runIdentity >>> isRight) $
      eq <$> ((fromKeyPath a) :: F Int) <*> fromKeyPath b
    <|>
      eq <$> ((fromKeyPath a) :: F String) <*> fromKeyPath b
    <|>
      eq <$> ((fromKeyPath a) :: F DateTime) <*> fromKeyPath b
    where
      runIdentity :: forall a. Identity a -> a
      runIdentity (Identity a) = a


class Index a where
  toKeyPath         :: a -> KeyPath
  fromKeyPath       :: KeyPath -> F a
  unsafeFromKeyPath :: KeyPath -> a


instance indexInt :: Index Int where
  toKeyPath                 = Foreign.toForeign >>> KeyPath
  fromKeyPath (KeyPath f)       = Foreign.readInt f
  unsafeFromKeyPath (KeyPath f) = Foreign.unsafeFromForeign f


instance indexString :: Index String where
  toKeyPath                 = Foreign.toForeign >>> KeyPath
  fromKeyPath (KeyPath f)       = Foreign.readString f
  unsafeFromKeyPath (KeyPath f) = Foreign.unsafeFromForeign f


instance indexDate :: Index DateTime where
  toKeyPath (DateTime d t) = KeyPath $ Fn.runFn7 _dateTimeToForeign
    (fromEnum $ Date.year d)
    (fromEnum $ Date.month d)
    (fromEnum $ Date.day d)
    (fromEnum $ Time.hour t)
    (fromEnum $ Time.minute t)
    (fromEnum $ Time.second t)
    (fromEnum $ Time.millisecond t)
  fromKeyPath (KeyPath f)       = Fn.runFn4 _readDateTime dateTime dateTimeF dateTimeE f
  unsafeFromKeyPath (KeyPath f) = Fn.runFn2 _unsafeReadDateTime dateTime f


instance indexArray :: Index a => Index (Array a) where
  toKeyPath                 = Foreign.toForeign >>> KeyPath
  fromKeyPath (KeyPath f)       = Foreign.readArray f >>= traverse (KeyPath >>> fromKeyPath)
  unsafeFromKeyPath (KeyPath f) = map unsafeFromKeyPath (Foreign.unsafeFromForeign f)


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
