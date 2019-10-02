{-# LANGUAGE DeriveDataTypeable #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeFamilies #-}
module Minicute.Data.GMachine.Code
  ( module Minicute.Data.GMachine.Instruction

  , Code
  , initialCode
  , fetchNextInstruction
  , putInstruction
  , putInstructions
  , assertLastCode
  ) where

import Control.Lens.Getter ( use )
import Control.Lens.Operators
import Control.Lens.TH
import Control.Lens.Wrapped ( _Wrapped )
import Control.Monad.Fail ( MonadFail )
import Control.Monad.State
import Data.Data
import GHC.Generics
import Minicute.Data.GMachine.Instruction

import qualified Minicute.Transpilers.GMachine as GMachine ( initialCode )

newtype Code
  = Code [Instruction]
  deriving ( Generic
           , Typeable
           , Data
           , Eq
           , Ord
           )

makeWrapped ''Code

initialCode :: Code
initialCode = Code GMachine.initialCode

fetchNextInstruction :: (MonadState s m, s ~ Code, MonadFail m) => m Instruction
fetchNextInstruction = do
  insts <- use _Wrapped
  case insts of
    inst : insts' -> do
      _Wrapped .= insts'
      return inst
    _ ->
      fail "popInstructionFromCode: No more instructions exist"

putInstruction :: (MonadState s m, s ~ Code) => Instruction -> m ()
putInstruction inst = _Wrapped %= (inst :)

putInstructions :: (MonadState s m, s ~ Code) => [Instruction] -> m ()
putInstructions insts = _Wrapped %= (insts <>)

assertLastCode :: (MonadState s m, s ~ Code, MonadFail m) => m ()
assertLastCode = do
  insts <- use _Wrapped
  case insts of
    [] -> return ()
    _ -> fail "assertLastCode: Not a last code"