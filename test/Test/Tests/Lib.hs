module Test.Tests.Lib where

import Lib

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
unit_lib_hello_world :: IO ()
unit_lib_hello_world = helloWorld @?= "Hello World"
