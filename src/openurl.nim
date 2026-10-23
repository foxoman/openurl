## Open a URL or file with the default application.
## Supports Windows, macOS, Linux, Haiku, and Android/Termux.

import std/[os, strutils, uri]

when defined(windows):
  import std/widestrs

  proc shellExecuteW(
    window: pointer,
    operation, target, parameters, directory: WideCString,
    showCommand: int32,
  ): pointer {.stdcall, dynlib: "shell32.dll", importc: "ShellExecuteW".}

else:
  import std/osproc

const blankPageString* = "about:blank"

func hasUriScheme(value: string): bool =
  ## RFC 3986: ALPHA *( ALPHA / DIGIT / "+" / "-" / "." ) ":"
  if value.len == 0 or value[0] notin Letters:
    return false

  for i in 1 ..< value.len:
    case value[i]
    of ':':
      return true
    of Letters, Digits, '+', '-', '.':
      discard
    else:
      return false

func isWindowsDrivePath(value: string): bool =
  value.len >= 2 and value[0] in Letters and value[1] == ':'

proc fileUri(path: string): string =
  let absolute = absolutePath(path)

  when defined(windows):
    let normalized = absolute.replace(
      '\\',
      '/',
    )
    let encoded = encodeUrl(normalized, usePlus = false).replace("%2F", "/").replace(
      "%3A",
      ":",
    )

    if normalized.startsWith("//"):
      result = "file:" & encoded # UNC: file://server/share
    else:
      result = "file:///" & encoded # file:///C:/path
  else:
    result = "file://" & encodeUrl(absolute, usePlus = false).replace(
      "%2F",
      "/",
    )

proc prepare(value: string): string =
  if '\0' in value:
    raise newException(
      ValueError,
      "URLs and paths cannot contain NUL bytes",
    )

  if value.len == 0:
    return blankPageString

  # Existing paths take precedence over URL-like filenames.
  if fileExists(value) or dirExists(value):
    return fileUri(value)

  when defined(windows):
    if isWindowsDrivePath(value) or value.startsWith("\\\\"):
      return fileUri(value)

  if hasUriScheme(value):
    return value

  if value.startsWith("www."):
    return "https://" & value

  result = fileUri(value)

when not defined(windows):
  proc launch(
      executable: string,
      arguments: openArray[string],
  ) =
    # No shell: each argument is passed separately.
    let child = startProcess(
      executable,
      args = arguments,
      options = {poParentStreams},
    )
    defer:
      close(child)

    let status = waitForExit(child)
    if status != 0:
      raise newException(
        OSError,
        executable & " exited with status " & $status,
      )

  proc tryLaunch(
      name: string,
      arguments: openArray[string],
  ): bool =
    let executable = findExe(name)
    if executable.len == 0:
      return false

    launch(
      executable,
      arguments,
    )
    result = true

proc openUrl*(url: string = blankPageString) =
  ## Opens a URL or file with the default application.
  ##
  ## Empty input opens about:blank.
  ## Files are converted to absolute, percent-encoded file URIs.
  ##
  ## Raises ValueError for invalid input and OSError on launch failure.
  let target = prepare(url)

  when defined(windows):
    let operation = newWideCString("open")
    let destination = newWideCString(target)

    let status = cast[int](shellExecuteW(nil, operation, destination, nil, nil, 1'i32))

    if status <= 32:
      raise newException(
        OSError,
        "Windows could not open the target (code " & $status & ")",
      )
  elif defined(macosx) or defined(haiku):
    if not tryLaunch("open", [target]):
      raise newException(
        OSError,
        "The 'open' command was not found",
      )
  else:
    # Termux supplies a wrapper that handles Android integration.
    if tryLaunch("termux-open", [target]):
      return

    when defined(android) or defined(droid):
      if tryLaunch("am", ["start", "-a", "android.intent.action.VIEW", "-d", target]):
        return

    if tryLaunch("xdg-open", [target]):
      return

    if tryLaunch("gio", ["open", target]):
      return

    raise newException(
      OSError,
      "No supported opener found: termux-open, am, xdg-open, or gio",
    )

when isMainModule:
  try:
    if paramCount() > 1:
      stderr.writeLine("Usage: openurl [URL_OR_FILE]")
      quit(QuitFailure)

    openUrl(
      if paramCount() == 1:
        paramStr(1)
      else:
        blankPageString
    )
  except CatchableError as error:
    stderr.writeLine(
      "openurl: ",
      error.msg,
    )
    quit(QuitFailure)
