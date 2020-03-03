#!/bin/sed -Ef

# Simple flood fill solver (github.com/Circiter/maze-in-sed).
# Written by Circiter (mailto:xcirciter@gmail.com)
# Original by xsot (github.com/xsot)

# Performs breadth-first search.

:input $!{N; binput} # Work on the entire file, not on line-by-line basis.
G # This can be replaced by s/^(.*)$/\1\n/.

:wave-propagation

  # Insert the End-Of-Line (EOL) marker at the end of each line.
  :eol-markers
    s/([^%])\n/\1%\n/
  /^.*%\n$/!beol-markers

  :vertical-scroll

    s/.*/&@/ # Insert the EOF marker.

    :horizontal-shift

      # Cyclic shift (rotation) of the first line.
      s/^([^\n])([^\n]*)\n/\2\1\n/

      # Place the first line right after the last one.
      s/^([^\n]*\n)(.*)$/\2\1/

      # Terminate if we see the EOF marker at the beginning
      /^@/!bhorizontal-shift

    s/^@// # Remove the EOF marker.

    # Add empty line before the maze (just to make it possible to treat all
    # the lines as equal, i.e. starting from \n, not from either ^ or \n).
    # May be we can use a GNU extension s/.../.../m instead.
    s/^(.*)$/\n\1/

    # Grow the wave-front.
    s/\n([Eudlr][^\n]*\n) ([^\n]*\n)/\n\1U\2/
    s/\n ([^\n]*\n)([Eudlr][^\n]*\n)/\nD\1\2/

    s/ ([Eudlr])/R\1/g
    s/([Eudlr]) /\1L/g

    # If we hit the source cell then mark it as the first
    # cell of the path between S and E.
    s/\n([Eudlr][^\n]*\n)S([^\n]*\n)/\n\1^\2/
    s/\nS([^\n]*\n)([Eudlr][^\n]*\n)/\nv\1\2/

    s/S([Eudlr])/>\1/g
    s/([Eudlr])S/\1</g

    # If we are tracing back...
    s/\n[Eu]([^\n]*\n)(\^[^\n]*\n)/\n^\1\2/
    s/\n[Ed]([^\n]*\n)(\^[^\n]*\n)/\nv\1\2/
    s/\n[El]([^\n]*\n)(\^[^\n]*\n)/\n<\1\2/
    s/\n[Er]([^\n]*\n)(\^[^\n]*\n)/\n>\1\2/

    s/\n(v[^\n]*\n)[Eu]([^\n]*\n)/\n\1^\2/
    s/\n(v[^\n]*\n)[Ed]([^\n]*\n)/\n\1v\2/
    s/\n(v[^\n]*\n)[El]([^\n]*\n)/\n\1<\2/
    s/\n(v[^\n]*\n)[Er]([^\n]*\n)/\n\1>\2/

    s/^\n// # Remove the extra line.

    s/>[Eu]/>^/
    s/>[Ed]/>v/
    s/>[El]/></
    s/>[Er]/>>/

    s/[Eu]</^</
    s/[Ed]</v</
    s/[El]</<</
    s/[Er]</></

    # Terminate if we are one step before the initial configuration.
    /^%/!bvertical-scroll

  s/%//g # Remove EOLs.

  y/UDLR/udlr/; # Make the wave-front just ordinary wave.

  # Move cursor to the upper left corner, hide it, and display maze.
  s/.*/\x1b[?25l\x1b[H&/
  p
  s/\x1b\[\?25l\x1b\[H//

  /S/bwave-propagation # Propagate the wave until we hit the source cell.
  /E/bwave-propagation # Trace back until we hit the exit cell.

s/[udlr]/ /g # Leave only path and walls.
s/[<v^>]/\x1b[31m&\x1b[0m/g # Colorize the path.
# In the end, place the cursor again at the home position and make it visible.
s/.*/\x1b[H\x1b[?25h&/
