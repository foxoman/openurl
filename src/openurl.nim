#[
  _                   _
 / \ ._   _  ._  | | |_) |
 \_/ |_) (/_ | | |_| | \ |_
     | v: 2.0.0   @FOXOMAN

 Open Any Url/File in the default App / WebBrowser
 Sultan Al Isaee ~ foxoman @2022
 See MIT LICENSE.txt for details of the license.
]#

## A simple proc for opening URLs with the user's
## default browser or default app handler!
##
## Support for MacOS, Windows, Haiku, termux, Unix/Linux.

import std/os, osproc, strutils, figures

const
  canNotOpenUrlErrStr: string = "$1 Could Not Open Url. UnSupported OS." % [figures.cross]
  blankPageString*: string = "http:about:blank" ## \
  ##  Blank page string.
  ##  Implements IETF RFC-6694 Section 3
  ## **See:**
  ##
  ## * https://tools.ietf.org/html/rfc6694#section-3
  openCString: string =
    when defined(windows): "start $1" % [quoteShell("")] else: "open"
    # am start -a android.intent.action.VIEW -d

proc prepare(url: string): string =
  if url.contains("://") or url == blankPageString:
    return url
  else:
    return "file://" & absolutePath(url)

proc openUrl*(url: string = blankPageString) =
  ## Opens `url` with the user's default browser or default file handel.
  ##
  ## Under Windows, `start` is used. Under Mac OS X, Haiku,
  ## unix, linux, termux the `open` command is used.
  ##
  ## Default browser blank page will open if `url` string is empty or not set.
  ##
  ## **API:**
  ##
  ## .. code-block:: nim
  ##   openUrl("https://www.foxoman.net")

  var u: string
  if url.len == 0: # If the url string is empty,
    u = quoteShell blankPageString # default to blank page
  else: u = quoteShell url.prepare

  if execShellCmd("$1 $2" % [openCString, u]) == 0:
    return
  else:
    stderr.writeLine canNotOpenUrlErrStr

when isMainModule:
  echo """
  _                   _
 / \ ._   _  ._  | | |_) |
 \_/ |_) (/_ | | |_| | \ |_
     | v: 2.0.0   @FOXOMAN
"""

  if paramCount() > 0:
    echo "$1 Open: $2" % [figures.play, prepare paramStr(1)]
    openUrl(paramStr(1))
  else:
    echo "$1 No Url input, a blank page will open." % [figures.cross]
    openUrl()
