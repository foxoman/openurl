# To run these tests, simply execute `nimble test`.

import unittest
import openurl

test "File Uri":
  openurl(r"tests")
