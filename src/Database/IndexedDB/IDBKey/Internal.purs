-- | A key has an associated type which is one of: number, date, string, or array.
-- |
-- | NOTE: Binary keys aren't supported yet.
module Database.IndexedDB.IDBKey.Internal
  ( Key
  , class IDBKey
  , toKey
  , fromKey
  , unsafeFromKey
  , none
  ) where

import Prelude

import Control.Alt ((<|>))
import Control.Monad.Except (ExceptT(..), runExceptT)
import Data.Date as Date
import Data.DateTime (DateTime(..), Time(..))
import Data.Either (Either(..), either, isRight)
import Data.Enum (fromEnum, toEnum)
import Foreign as Foreign
import Foreign (Foreign, F)
import Data.Function.Uncurried as Fn
import Data.Function.Uncurried (Fn2, Fn4, Fn7)
import Data.Identity (Identity(..))
import Data.List.NonEmpty (NonEmptyList(..))
import Data.List.Types (List(..))
import Data.Maybe (Maybe(..))
import Data.NonEmpty (NonEmpty(..))
import Data.Nullable (Nullable, toNullable)
import Data.Time as Time
import Data.Traversable (traverse)

newtype Key = Key Foreign

--------------------
-- INTERFACES
--
-- | Interface describing a key. Use the `unsafeFromKey` to convert a key
-- | to a known type (e.g if you only strings as keys, or perfectly knows the
-- | type of a given key).
class IDBKey a where
  toKey :: a -> Key
  fromKey :: Key -> F a
  unsafeFromKey :: Key -> a

none :: Maybe Key
none =
  Nothing

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
      <|>
        eq <$> ((fromKey a) :: F (Array Key)) <*> fromKey b
    where
    runIdentity :: forall a. Identity a -> a
    runIdentity (Identity x) = x

instance ordKey :: Ord Key where
  compare a b = (runExceptT >>> runIdentity >>> either (const LT) identity) $
    compare <$> ((fromKey a) :: F Int) <*> fromKey b
      <|>
        compare <$> ((fromKey a) :: F Number) <*> fromKey b
      <|>
        compare <$> ((fromKey a) :: F String) <*> fromKey b
      <|>
        compare <$> ((fromKey a) :: F DateTime) <*> fromKey b
      <|>
        compare <$> ((fromKey a) :: F (Array Key)) <*> fromKey b
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
      <|>
        (show <$> (fromKey a :: F (Array Key)))
    where
    format :: forall a. Identity (Either a String) -> String
    format (Identity x) =
      either (const "(Key)") (\s -> "(Key " <> s <> ")") x

instance idbKeyKey :: IDBKey Key where
  toKey = identity
  fromKey = pure
  unsafeFromKey = identity

instance idbKeyForeign :: IDBKey Foreign where
  toKey = Key
  fromKey (Key f) = pure f
  unsafeFromKey (Key f) = f

instance idbKeyInt :: IDBKey Int where
  toKey = Foreign.unsafeToForeign >>> Key
  fromKey (Key f) = Foreign.readInt f
  unsafeFromKey (Key f) = Foreign.unsafeFromForeign f

instance idbKeyNumber :: IDBKey Number where
  toKey = Foreign.unsafeToForeign >>> Key
  fromKey (Key f) = Foreign.readNumber f
  unsafeFromKey (Key f) = Foreign.unsafeFromForeign f

instance idbKeyString :: IDBKey String where
  toKey = Foreign.unsafeToForeign >>> Key
  fromKey (Key f) = Foreign.readString f
  unsafeFromKey (Key f) = Foreign.unsafeFromForeign f

instance idbKeyDate :: IDBKey DateTime where
  toKey (DateTime d t) = Key $ Fn.runFn7 _dateTimeToForeign
    (fromEnum $ Date.year d)
    (fromEnum $ Date.month d)
    (fromEnum $ Date.day d)
    (fromEnum $ Time.hour t)
    (fromEnum $ Time.minute t)
    (fromEnum $ Time.second t)
    (fromEnum $ Time.millisecond t)
  fromKey (Key f) = Fn.runFn4 _readDateTime dateTime dateTimeF dateTimeE f
  unsafeFromKey (Key f) = Fn.runFn2 _unsafeReadDateTime dateTime f

instance idbKeyArray :: IDBKey a => IDBKey (Array a) where
  toKey = Foreign.unsafeToForeign >>> Key
  fromKey (Key f) = Foreign.readArray f >>= traverse (Key >>> fromKey)
  unsafeFromKey (Key f) = map unsafeFromKey (Foreign.unsafeFromForeign f)

-- FFI constructor to build a DateTime from years, months, days, hours, minutes, seconds and millis
dateTime
  :: Int -- ^ years
  -> Int -- ^ months
  -> Int -- ^ days
  -> Int -- ^ hours
  -> Int -- ^ minutes
  -> Int -- ^ seconds
  -> Int -- ^ milliseconds
  -> Nullable DateTime
dateTime y m d h mi s ms =
  toNullable $ DateTime
    <$> (Date.canonicalDate <$> toEnum y <*> toEnum m <*> toEnum d)
    <*> (Time <$> toEnum h <*> toEnum mi <*> toEnum s <*> toEnum ms)

-- FFI constructor to convert a JS `Date` into a successful `F DateTime`
dateTimeF
  :: DateTime
  -> F DateTime
dateTimeF =
  Right >>> Identity >>> ExceptT

-- FFI constructor to convert a string into an errored `F DateTime`
dateTimeE
  :: String
  -> F DateTime
dateTimeE =
  Foreign.TypeMismatch "Date" >>> flip NonEmpty Nil >>> NonEmptyList >>> Left >>> Identity >>> ExceptT

--------------------
-- FFI
--
foreign import _dateTimeToForeign
  :: Fn7 Int Int Int Int Int Int Int Foreign

foreign import _readDateTime
  :: Fn4 (Int -> Int -> Int -> Int -> Int -> Int -> Int -> Nullable DateTime) (DateTime -> F DateTime) (String -> F DateTime) Foreign (F DateTime)

foreign import _unsafeReadDateTime
  :: Fn2 (Int -> Int -> Int -> Int -> Int -> Int -> Int -> Nullable DateTime) Foreign DateTime
