{- HLINT ignore "Redundant do" -}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE QuasiQuotes #-}
-- |
-- Copyright: (c) 2018-present Junyoung Clare Jang
-- License: BSD 3-Clause
module Minicute.Transpilers.Lifting.LambdaTest
  ( spec_lambdaLifting
  ) where

import Test.Tasty.Hspec

import Control.Monad
import Data.Tuple.Extra
import Minicute.Transpilers.Lifting.Lambda
import Minicute.Utils.Minicute.TH

spec_lambdaLifting :: Spec
spec_lambdaLifting
  = forM_ testCases (uncurry3 lambdaLiftingTest)

lambdaLiftingTest :: TestName -> TestBeforeContent -> TestAfterContent -> SpecWith (Arg Expectation)
lambdaLiftingTest name beforeContent afterContent = do
  it ("lift lambda expression from " <> name) $ do
    lambdaLifting beforeContent `shouldBe` afterContent

type TestName = String
type TestBeforeContent = MainProgram 'Simple 'MC
type TestAfterContent = MainProgram 'Simple 'LLMC
type TestCase = (TestName, TestBeforeContent, TestAfterContent)

testCases :: [TestCase]
testCases =
  [ ( "empty program"
    , [qqMiniMainMC||]
    , [qqMiniMainLLMC||]
    )

  , ( "program with single lambda as a body of a top-level definition"
    , [qqMiniMainMC|
                  f = \x -> x
      |]
    , [qqMiniMainLLMC|
                 f0 = annon1;
                 annon1 x2 = x2
      |]
    )

  , ( "program with let expression containing lambdas"
    , [qqMiniMainMC|
                  f = let
                        g = \x -> x;
                        h = \x -> x * x
                      in
                        g 5 + h 4
      |]
    , [qqMiniMainLLMC|
                 f0 = let
                        g1 = annon3;
                        h2 = annon5
                      in
                        g1 5 + h2 4;
                 annon3 x4 = x4;
                 annon5 x6 = x6 * x6
      |]
    )
  ]
