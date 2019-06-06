{-# LANGUAGE DeriveDataTypeable #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE DeriveLift #-}
{-# LANGUAGE OverloadedStrings #-}
module Minicute.Types.Minicute.Precedence
  ( module Minicute.Types.Minicute.Common


  , Precedence( .. )

  , PrecedenceTable
  , PrecedenceTableEntry

  , isInfix

  , defaultPrecedenceTable
  , binaryPrecedenceTable
  , binaryIntegerPrecendenceTable
  , binaryDataPrecendenceTable

  , miniApplicationPrecedence
  , miniApplicationPrecedence1

  , prettyBinaryExpressionPrec
  ) where

import Data.Data
import Data.Text.Prettyprint.Doc ( Pretty( .. ) )
import Data.Text.Prettyprint.Doc.Minicute
import GHC.Generics
import Language.Haskell.TH.Syntax
import Minicute.Types.Minicute.Common

import qualified Data.Text.Prettyprint.Doc as PP

data Precedence
  = PInfixN { precedence :: Int }
  | PInfixL { precedence :: Int }
  | PInfixR { precedence :: Int }
  | PPrefix { precedence :: Int }
  | PPostfix { precedence :: Int }
  deriving ( Generic
           , Typeable
           , Data
           , Lift
           , Eq
           , Ord
           , Show
           , Read
           )

type OperatorName = String
type PrecedenceTableEntry = (OperatorName, Precedence)
type PrecedenceTable = [PrecedenceTableEntry]

isInfix :: Precedence -> Bool
isInfix (PInfixN _) = True
isInfix (PInfixL _) = True
isInfix (PInfixR _) = True
isInfix _ = False
{-# INLINEABLE isInfix #-}

-- |
-- All precedences should be smaller than 'miniApplicationPrecedence'.
-- Where do I need to check this condition?
defaultPrecedenceTable :: PrecedenceTable
defaultPrecedenceTable
  = binaryPrecedenceTable

binaryPrecedenceTable :: PrecedenceTable
binaryPrecedenceTable
  = binaryDataPrecendenceTable
    <> binaryIntegerPrecendenceTable

binaryIntegerPrecendenceTable :: PrecedenceTable
binaryIntegerPrecendenceTable
  = [ ("+", PInfixL 40)
    , ("-", PInfixL 40)
    , ("*", PInfixL 50)
    , ("/", PInfixL 50)
    ]

binaryDataPrecendenceTable :: PrecedenceTable
binaryDataPrecendenceTable
  = [ (">=", PInfixL 10)
    , (">", PInfixL 10)
    , ("<=", PInfixL 10)
    , ("<", PInfixL 10)
    , ("==", PInfixL 10)
    , ("!=", PInfixL 10)
    ]

miniApplicationPrecedence :: Int
miniApplicationPrecedence = 100
{-# INLINEABLE miniApplicationPrecedence #-}

miniApplicationPrecedence1 :: Int
miniApplicationPrecedence1 = 101
{-# INLINEABLE miniApplicationPrecedence1 #-}


prettyBinaryExpressionPrec :: (Pretty a, PrettyPrec (expr_ a)) => Int -> String -> Precedence -> expr_ a -> expr_ a -> PP.Doc ann
prettyBinaryExpressionPrec p op opPrec e1 e2
  = (if p > opP then PP.parens else id) . PP.hsep
    $ [ prettyPrec leftP e1
      , pretty op
      , prettyPrec rightP e2
      ]
  where
    (leftP, opP, rightP)
      = case opPrec of
          PInfixN opP' -> (opP' + 1, opP', opP' + 1)
          PInfixL opP' -> (opP', opP', opP' + 1)
          PInfixR opP' -> (opP' + 1, opP', opP')
          _ -> (miniApplicationPrecedence1, miniApplicationPrecedence, miniApplicationPrecedence1)
{-# INLINEABLE prettyBinaryExpressionPrec #-}
