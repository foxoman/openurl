# To run these tests, simply execute `nimble test`.

import unittest
import openurl

test "Web Url":
  openurl("https://www.foxoman.net")
