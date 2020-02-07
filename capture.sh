#!/bin/sh
#
# capture_ocr
#
# Look for and convert on screen text to actual text in both a clipboard
# and a pop up window, using OCR (Optical Character Recognition)
#
#  Requires tesseract and imagemagick to be installed.
#
PROGNAME=`type $0 | awk '{print $3}'`  # search for executable on path
PROGDIR=`dirname "$PROGNAME"`          # extract directory of program
PROGNAME=`basename "$PROGNAME"`        # base name of program

: ${XPAGER:=less}           # Select "less" if a pager is  not defined
XPAGER=${XEDITOR:-$XPAGER}   # Pop it in an editor is that is defined

DEPENDENCIES="convert tesseract xsel $XPAGER"

# Check Dependencies a script requires is available
for i in $DEPENDENCIES; do
  if type $i >/dev/null 2>&1; then
    : all good
  else
    echo >&2  "$PROGNAME: Required program dependency \"$i\" missing"
    echo "$PROGNAME: Required program dependency \"$i\" missing" | $XPAGER - &
    exit 10
  fi
done

convert x: -resize 300% -set density 300 \
        +dither  -colors 2  -normalize \
        $debug png:- |

  # Optical Character Recognition (OCR) decoding..
  tesseract --psm 6 stdin stdout |

  # Replace specific unicode output with equivelent ASCII
  sed 's/[“”]/"/g; s/—/-/g' |

  # Save result into clipboard
  xsel -ib

# Popup a window with the OCR text stored in the Clipboard
xsel -ob | $XPAGER -      # popup text window


