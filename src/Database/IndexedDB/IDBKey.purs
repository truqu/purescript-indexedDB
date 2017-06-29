module Database.IndexedDB.IDBKey
    ( IDBKey
    , class IsIDBKey, toIDBKey , fromIDBKey , unsafeFromIDBKey
    ) where

import Prelude

import Control.Alt                 ((<|>))
import Control.Monad.Except        (ExceptT(..), runExceptT)
import Data.Date                    as Date
import Data.DateTime               (DateTime(..), Time(..))
import Data.Enum                   (fromEnum, toEnum)
import Data.Foreign                 as Foreign
import Data.Foreign                (Foreign, F)
import Data.Function.Uncurried      as Fn
import Data.Function.Uncurried     (Fn2, Fn4, Fn7)
import Data.List.NonEmpty          (NonEmptyList(..))
import Data.List.Types             (List(..))
import Data.NonEmpty               (NonEmpty(..))
import Data.Either                 (Either(..), isRight)
import Data.Identity               (Identity(..))
import Data.Nullable               (Nullable, toNullable)
import Data.Time                    as Time
import Data.Traversable            (traverse)

newtype IDBKey = IDBKey Foreign


class IsIDBKey a where
  toIDBKey         :: a -> IDBKey
  fromIDBKey       :: IDBKey -> F a
  unsafeFromIDBKey :: IDBKey -> a


instance eqIDBKey :: Eq IDBKey where
  eq a b = (runExceptT >>> runIdentity >>> isRight) $
      eq <$> ((fromIDBKey a) :: F Int) <*> fromIDBKey b
    <|>
      eq <$> ((fromIDBKey a) :: F String) <*> fromIDBKey b
    <|>
      eq <$> ((fromIDBKey a) :: F DateTime) <*> fromIDBKey b
    where
      runIdentity :: forall a. Identity a -> a
      runIdentity (Identity x) = x


instance isIDBKeyInt :: IsIDBKey Int where
  toIDBKey                    = Foreign.toForeign >>> IDBKey
  fromIDBKey (IDBKey f)       = Foreign.readInt f
  unsafeFromIDBKey (IDBKey f) = Foreign.unsafeFromForeign f


instance isIDBKeyString :: IsIDBKey String where
  toIDBKey                    = Foreign.toForeign >>> IDBKey
  fromIDBKey (IDBKey f)       = Foreign.readString f
  unsafeFromIDBKey (IDBKey f) = Foreign.unsafeFromForeign f


instance isIDBKeyDate :: IsIDBKey DateTime where
  toIDBKey (DateTime d t)     = IDBKey $ Fn.runFn7 _dateTimeToForeign
    (fromEnum $ Date.year d)
    (fromEnum $ Date.month d)
    (fromEnum $ Date.day d)
    (fromEnum $ Time.hour t)
    (fromEnum $ Time.minute t)
    (fromEnum $ Time.second t)
    (fromEnum $ Time.millisecond t)
  fromIDBKey (IDBKey f)       = Fn.runFn4 _readDateTime dateTime dateTimeF dateTimeE f
  unsafeFromIDBKey (IDBKey f) = Fn.runFn2 _unsafeReadDateTime dateTime f


instance isIDBKeyArray :: IsIDBKey a => IsIDBKey (Array a) where
  toIDBKey                     = Foreign.toForeign >>> IDBKey
  fromIDBKey (IDBKey f)       = Foreign.readArray f >>= traverse (IDBKey >>> fromIDBKey)
  unsafeFromIDBKey (IDBKey f) = map unsafeFromIDBKey (Foreign.unsafeFromForeign f)


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
