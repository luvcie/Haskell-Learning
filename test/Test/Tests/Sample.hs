module Test.Tests.Sample where

import Data.List

import Test.Tasty
import Test.Tasty.Discover
import Test.Tasty.Golden
import Test.Tasty.HUnit
import Test.Tasty.QuickCheck

--------------------------------------------------------------------------------

-- Sample golden test with tasty-golden
test_sample_golden_test :: TestTree
test_sample_golden_test = goldenVsString "Sample golden test"
  "test/golden/sample/output.golden" (pure "Successful golden test :)\n")


-- Sample unit test with tasty-hunit
unit_sample_list_comparison :: IO ()
unit_sample_list_comparison = [1, 2, 3] `compare` [1,2] @?= GT


-- Sample proprty test with tasty-quickcheck
prop_sample_addition_is_commutative :: Int -> Int -> Bool
prop_sample_addition_is_commutative a b = a + b == b + a
