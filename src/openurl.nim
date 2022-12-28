#[
  _                   _
 / \ ._   _  ._  | | |_) |
 \_/ |_) (/_ | | |_| | \ |_
     |            @FOXOMAN

 Open Any Url/File in the default App / WebBrowser
 Sultan Al Isaee ~ foxoman @2022-2023
 See MIT LICENSE.txt for details of the license.
]#

## A simple proc for opening URLs with the user's
## default browser or default app handler!
##
## Support for MacOS, Windows, Haiku, Android/Termux, Unix/Linux.

import std/[os, osproc, strutils]

const
  canNotOpenUrlErrStr: string =
    "[✖] Could Not Open Url. UnSupported OS."
  blankPageString*: string = "http:about:blank" ## \
  ##  Blank page string.
  ##  Implements IETF RFC-6694 Section 3
  ## **See:**
  ##
  ## * https://tools.ietf.org/html/rfc6694#section-3
  openCString: string =
    when defined(windows): "start $1" % [quoteShell("")]
    elif defined(droid): "am start -a android.intent.action.VIEW -d"
    else: "open"                                ## \
  ## Support Windows using `start`, Support for all unix/linux based
  ## using `open` and support for android Java Activity 'start'.
  ##
  ## In termux the unix open will be used, to activate Android Java Activity
  ## Open use `-d:droid`.

proc prepare(url: string): string =
  if url.contains("://") or url.contains("www.") or url == blankPageString:
    url
  else:
    "file://" & absolutePath(url)

proc openUrl*(url: string = blankPageString) =
  ## Opens `url` with the user's default browser or default file handel.
  ##
  ## Under Windows, `start` is used. Under Mac OS X, Haiku,
  ## unix, linux, termux the `open` command is used.
  ##
  ## If Android Activity support enable with `-d:droid` then android
  ## acitivty is used!
  ##
  ## Default browser blank page will open if `url` string is empty or not set.
  ##
  ## - `url` for a website should start with http or https
  ## - use raw string for system path eg `openurl(r"c:\folder\file")`
  ## - compile with `-d:droid` to have support for android activity,
  ##   in termux no need to do that as unix `open` is supported.
  ##
  ## **API:**
  ##
  ## .. code-block:: nim
  ##   openUrl("https://www.foxoman.net")
  ##
  ## .. code-block:: nim
  ##   openUrl(r"c:\Dev\Folder")
  ##
  ## .. code-block:: nim
  ##   openUrl()

  var u = quoteShell:
    if url.len == 0:  # If the url string is empty,
      blankPageString # default to blank page
    else:
      url.prepare

  if execShellCmd("$1 $2" % [openCString, u]) != 0:
    stderr.writeLine canNotOpenUrlErrStr

when isMainModule:
  echo """
  _                   _
 / \ ._   _  ._  | | |_) |
 \_/ |_) (/_ | | |_| | \ |_
     |            @FOXOMAN
"""

  if paramCount() > 0:
    echo "[✔] Open: $1" % [prepare paramStr(1)]
    openUrl(paramStr(1))
  else:
    echo "[✖] No URL input, a blank page will open."
    openUrl()
