# To run these tests, simply execute `nimble test`.

import unittest
import openurl

test "File Uri":
  openurl(r"C:\Users\alissais\Documents\2022 FAQs_v2.pdf")
