#!/bin/sed -Enf

# Written by Circiter (mailto:xcirciter@gmail.com)
# and can be found at "github.com/Circiter/maze-in-sed".

# (Usage: echo | ./cellular-generator.sed)

# Issue: Not all generated mazes are a perfect ones.
# FIXME: Try to solve after generation and repeat until a solution exists.

# Bug: too slow.

# An attempt to implement Mazectric the cellular automaton with rulestring B3/S1234.

# TODO: Generate a random (0, 1)-matrix.

# Generate a square matrix.
#h # Copy text to hold space.
#:make_matrix
#    /[^\n]/{ # While the given unary number is not a zero.
#        x # Swap hold space and pattern space.
#        # Add one new line to hold space for each character in the input string.
#        s/^([^\n]*\n)(.*)$/\1\1\2/
#        /^([^\n]*)$/s/^.*$/&\n/
#        x # Swap again.
#        s/[^\n]// # Decrement.
#        bmake_matrix
#    }

#g # Copy the resulting matrix back to the pattern space.

#s/^.*$//

# Initial configuration (seed).
s/^/xxxxxxxxxx\nxxxxxxxxxx\nxxxxxyyxxx\nxxxxxyyxxx\nxxxxxyxxxx\nxxxxxxxxxx\nxxxxxxxxxx\nxxxxxxxxxx\nxxxxxxxxxx\nxxxxxxxxxx\n/


:generation
    s/^x/X/; s/^y/Y/ # Initial position of the scanning window.

    h
    # Insert "a water-mark" to the hold space to
    # differenciate it from the pattern space in the future.
    x; s/$/h/; x

    # Insert stop-markers, @, before and after the matrix;
    # then duplicate the last line.
    s/^(.*)(\n[^\n]*)\n$/@\1\2@\2/

    # Slide the window across the matrix and at each
    # step try to count the neighbors of the marker.
    :convolution
        # Initialize a counter in the hold space.
        x; s/^.*$/\n&/; x

        # Insert auxiliary markers.
        s/[XY]/<&>/; s/\n</<\n/; s/>\n/\n>/

        # Shift the aux-markers in two opposite directions,
        # one character at a time.
        :shift
            s/@</@/; s/>@/@/
            s/([^@])</<\1/; s/\n</<\n/ # The first marker moves to the left.
            s/>([^@])/\1>/; s/>\n/\n>/ # The second marker moves to the right.

            s/(\n[^\n]*)[^\n]$/\1/ # Shorten the last duplicated line.
            /[^\n]$/bshift # While the last line is not empty.

        # Now the first aux. marker is located just after the NW
        # corner, if any, of 8-neighborhood of the main X/Y marker. The second
        # marker, correspondingly, is located just before the SE corner, if any.
        /y[XY]/{x; s/^(x*)\n(.*)$/\1x\n\2/; x} # W.
        /[XY]y/{x; s/^(x*)\n(.*)$/\1x\n\2/; x} # E.
        /y<[^\n]/{x; s/^(x*)\n(.*)$/\1x\n\2/; x} # NW.
        /<[\n]*[^\n]y/{x; s/^(x*)\n(.*)$/\1x\n\2/; x} # NE.
        /<[\n]*y/{x; s/^(x*)\n(.*)$/\1x\n\2/; x} # N.
        /[^\n]>y/{x; s/^(x*)\n(.*)$/\1x\n\2/; x} # SE.
        /y[^\n][\n]*>/{x; s/^(x*)\n(.*)$/\1x\n\2/; x} # SW.
        /y[\n]*>/{x; s/^(x*)\n(.*)$/\1x\n\2/; x} # S.

        s/[<>]//g; # Remove the auxiliary markers.

        # Edit the hold space (the next generation).
        x

        /^xxx\n/{s/X/Y/; bsurvive} # Born
        /^x\n/bsurvive
        /^xx\n/bsurvive
        /^xxxx\n/bsurvive
        s/Y/X/ # Die
        :survive

        s/^x*\n// # Remove the counter.

        # Move the marker synchronously in both buffers.
        :again
            s/[XY][xy]/&c/
            s/[XY]\n[xy]/&c/
            s/([XY])@/\1#/ # Insert a termination flag.
            y/XY/xy/
            s/xc/X/g; s/yc/Y/g
            /h$/{x; bagain} # If we are in the hold space.

        # Duplicate the last line.
        s/^(.*)(\n[^\n]*)@.*$/\1\2@\2/
        /#/!bconvolution

    # Check for stabilization.
    s/@//; G; s/h//
    # Pattern space: old_generation#new_generation
    # Compare both generations.
    :compare s/^(.)(.*#\n\n)\1/\2/; tcompare
    /^#\n/{x; s/$/\nstabilized/; x}

    g # Copy the newly created generation to the pattern space.
    y/XY/xy/; s/h// # Prepare for further processing.

    y/xy/ #/
    s/^/\x1b\[\?25l\x1b\[H/; p; s/\x1b\[\?25l\x1b\[H// # Display.
    y/ #/xy/

    /stabilized$/!bgeneration
