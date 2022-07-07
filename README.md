# openurl
```
  _                   _
 / \ ._   _  ._  | | |_) |
 \_/ |_) (/_ | | |_| | \ |_
     | v: 2.0.3   @FOXOMAN
```
 Open Any Url/File in the default App / WebBrowser
 Sultan Al Isaee ~ foxoman @2022

 See MIT LICENSE.txt for details of the license.

 Support for MacOS, Windows, Haiku, android/termux, Unix/Linux.

 ### install
 ```nimble install openurl```

### api

```openurl(PATH)```
*PATH* can be a file/folder url or a website or even empty to open blank page in a browser.

- **use raw string for file/folder path** ie: ```openurl(r"c:\dev\folder") ```
- `url` for a website should start with http or https
- compile with `-d:droid` to have support for android activity,in termux no need to do that as unix `open` is supported.

 ### example

 ```
 import openurl, figures

 when isMainModule:
  echo """
  _                   _
 / \ ._   _  ._  | | |_) |
 \_/ |_) (/_ | | |_| | \ |_
     | v: 2.0.3   @FOXOMAN
"""

  if paramCount() > 0:
    echo "$1 Open: $2" % [figures.play, prepare paramStr(1)]
    openUrl(paramStr(1))
  else:
    echo "$1 No Url input, a blank page will open." % [figures.cross]
    openUrl()

