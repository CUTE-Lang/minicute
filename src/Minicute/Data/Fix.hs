{-# LANGUAGE DeriveDataTypeable #-}
{-# LANGUAGE UndecidableInstances #-}
{-# LANGUAGE StandaloneDeriving #-}
module Minicute.Data.Fix
  ( Fix2(..)
  ) where

import Data.Data
import Data.Function

newtype Fix2 f a = Fix2 { unFix2 :: f (Fix2 f) a }

deriving instance (Typeable f, Typeable a, Data (f (Fix2 f) a)) => Data (Fix2 f a)

instance (Eq (f (Fix2 f) a)) => Eq (Fix2 f a) where
  (==) = (==) `on` unFix2

instance (Show (f (Fix2 f) a)) => Show (Fix2 f a) where
  showsPrec n x = showParen (n > 10) $ ("Fix2 " <>) . showsPrec 11 (unFix2 x)