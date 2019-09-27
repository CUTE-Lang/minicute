{-# LANGUAGE DeriveFunctor #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE StandaloneDeriving #-}
module Minicute.Control.GMachine
  ( module Minicute.Control.GMachine.Step

  , GMachineMonadT
  , GMachineMonad

  , initializeInterpreterWith
  , addInterpreterStep
  , checkInterpreterFinished
  ) where

import Control.Monad.Fail
import Control.Monad.Writer
import Data.Data
import GHC.Generics
import Minicute.Data.GMachine.Instruction
import Minicute.Control.GMachine.Step

type GMachineMonad = GMachineMonadT Maybe Maybe

newtype GMachineMonadT m' m a
  = GMachineMonadT
    (WriterT [GMachineStepMonadT m' ()] m a)
  deriving ( Generic
           , Typeable
           , Functor
           , Applicative
           , Monad
           , MonadFail
           )

deriving instance (Monad m) => MonadWriter [GMachineStepMonadT m' ()] (GMachineMonadT m' m)

initializeInterpreterWith :: (Monad m) => GMachineProgram -> GMachineMonadT m' m ()
initializeInterpreterWith = pure . const ()

addInterpreterStep :: (Monad m) => GMachineStepMonadT m' () -> GMachineMonadT m' m ()
addInterpreterStep = tell . pure

checkInterpreterFinished :: (Monad m) => GMachineMonadT m' m Bool
checkInterpreterFinished = undefined