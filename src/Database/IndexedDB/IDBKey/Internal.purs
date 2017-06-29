module Database.IndexedDB.IDBKey.Internal
    ( Key(..)
    , class IDBKey, toKey , fromKey , unsafeFromKey
    , extractForeign
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
import Data.Either                 (Either(..), either, isRight)
import Data.Identity               (Identity(..))
import Data.Nullable               (Nullable, toNullable)
import Data.Time                    as Time
import Data.Traversable            (traverse)


newtype Key = Key Foreign


extractForeign :: Key -> Foreign
extractForeign (Key f) =
  f


--------------------
-- INTERFACES
--
class IDBKey a where
  toKey         :: a -> Key
  fromKey       :: Key -> F a
  unsafeFromKey :: Key -> a


--------------------
-- INSTANCES
--
instance eqKey :: Eq Key where
  eq a b = (runExceptT >>> runIdentity >>> isRight) $
      eq <$> ((fromKey a) :: F Int) <*> fromKey b
    <|>
      eq <$> ((fromKey a) :: F Number) <*> fromKey b
    <|>
      eq <$> ((fromKey a) :: F String) <*> fromKey b
    <|>
      eq <$> ((fromKey a) :: F DateTime) <*> fromKey b
    where
      runIdentity :: forall a. Identity a -> a
      runIdentity (Identity x) = x


instance ordKey :: Ord Key where
  compare a b = (runExceptT >>> runIdentity >>> either (const LT) id) $
      compare <$> ((fromKey a) :: F Int) <*> fromKey b
    <|>
      compare <$> ((fromKey a) :: F Number) <*> fromKey b
    <|>
      compare <$> ((fromKey a) :: F String) <*> fromKey b
    <|>
      compare <$> ((fromKey a) :: F DateTime) <*> fromKey b
    where
      runIdentity :: forall a. Identity a -> a
      runIdentity (Identity x) = x


instance showKey :: Show Key where
  show a = (runExceptT >>> format) $
      (show <$> (fromKey a :: F Int))
    <|>
      (show <$> (fromKey a :: F Number))
    <|>
      (show <$> (fromKey a :: F String))
    <|>
      (show <$> (fromKey a :: F DateTime))
    where
      format :: forall a. Identity (Either a String) -> String
      format (Identity x) =
        either (const "(Key)") (\s -> "(Key " <> s <> ")") x


instance idbKeyInt :: IDBKey Int where
  toKey                 = Foreign.toForeign >>> Key
  fromKey (Key f)       = Foreign.readInt f
  unsafeFromKey (Key f) = Foreign.unsafeFromForeign f


instance idbKeyNumber :: IDBKey Number where
  toKey                 = Foreign.toForeign >>> Key
  fromKey (Key f)       = Foreign.readNumber f
  unsafeFromKey (Key f) = Foreign.unsafeFromForeign f


instance idbKeyString :: IDBKey String where
  toKey                 = Foreign.toForeign >>> Key
  fromKey (Key f)       = Foreign.readString f
  unsafeFromKey (Key f) = Foreign.unsafeFromForeign f


instance idbKeyDate :: IDBKey DateTime where
  toKey (DateTime d t)  = Key $ Fn.runFn7 _dateTimeToForeign
    (fromEnum $ Date.year d)
    (fromEnum $ Date.month d)
    (fromEnum $ Date.day d)
    (fromEnum $ Time.hour t)
    (fromEnum $ Time.minute t)
    (fromEnum $ Time.second t)
    (fromEnum $ Time.millisecond t)
  fromKey (Key f)       = Fn.runFn4 _readDateTime dateTime dateTimeF dateTimeE f
  unsafeFromKey (Key f) = Fn.runFn2 _unsafeReadDateTime dateTime f


instance idbKeyArray :: IDBKey a => IDBKey (Array a) where
  toKey                 = Foreign.toForeign >>> Key
  fromKey (Key f)       = Foreign.readArray f >>= traverse (Key >>> fromKey)
  unsafeFromKey (Key f) = map unsafeFromKey (Foreign.unsafeFromForeign f)


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


--------------------
-- FFI
--
foreign import _dateTimeToForeign  :: Fn7 Int Int Int Int Int Int Int Foreign


foreign import _readDateTime :: Fn4 (Int -> Int -> Int -> Int -> Int -> Int -> Int -> Nullable DateTime) (DateTime -> F DateTime) (String -> F DateTime) Foreign (F DateTime)


foreign import _unsafeReadDateTime :: Fn2 (Int -> Int -> Int -> Int -> Int -> Int -> Int -> Nullable DateTime) Foreign DateTime
