# openurl
```
  _                   _
 / \ ._   _  ._  | | |_) |
 \_/ |_) (/_ | | |_| | \ |_
     | v: 2.0.0   @FOXOMAN
```
 Open Any Url/File in the default App / WebBrowser
 Sultan Al Isaee ~ foxoman @2022
 See MIT LICENSE.txt for details of the license.

 ### install
 ```nimble install openurl```

 ### example

 ```
 import openurl, figures

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

