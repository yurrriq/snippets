\version "2.18.2"

\include "oll-core/package.ily"
\loadModule snippets.notation-snippets.alternating-time-signatures

\header {
  title = "Alternating Time Signatures"
}

\markup "Using \\fractionList directly"

\relative c' {
  \once \override Score.TimeSignature.stencil =
    \fractionList #'((6 8)(5 4))
  \time 6/8
  c8 c c c c c
  \omit Score.TimeSignature
  \time 5/4
  c4 c c c c
  \undo \omit Score.TimeSignature
  \time 3/8
}

\markup "Using \\fractionList directly (with hyphens)"

\relative c' {
  \once \override Score.TimeSignature.stencil =
    \fractionList #'(#t (6 8)(5 4))
  \time 6/8
  c8 c c c c c
  \omit Score.TimeSignature
  \time 5/4
  c4 c c c c
  \undo \omit Score.TimeSignature
  \time 3/8
}

\markup "Using \\alternatingTimeSignatures"

\relative c' {
  \alternatingTimeSignatures #'((3 8) (4 8) (5 8))
  \time 3/8
  c8 d e
  \omit Score.TimeSignature
  \time 4/8
  f g a b
  \time 5/8
  c g c, f e
  \time 3/8
  d e f
  g a b
  \time 4/8
  c b a b
  \undo \omit Score.TimeSignature
  \time 6/8
  c b a g f e

}

\markup "Using the function doesn't have any impact on complex polymetrics"

\relative c' {
  \override TupletNumber.text = #tuplet-number::calc-fraction-text
  \alternatingTimeSignatures #'(#t (3 4) (4 7))
  c4 d e
  \omit Score.TimeSignature
  \time 4/7
  <<
    {
      \tupletSpan 4*16/7
      \tuplet 7/4 {
        \voiceOne
        f e f fis
        g a ais b
      }
      \time 3/4
      c4 g
    }
    \new Voice {
      \voiceTwo
      \scaleDurations 4/7 { s2 }
      % the lower music is actually shorter than the upper,
      % but I think the notation should be simplified here.
      % We use \scaleDurations for this, with a little math.
      % The upper voice spans 6/7 + 1/4 = 31/28
      % the lower voice 4/4, so the relation is 31/28
      \tuplet 5/4 {
        \scaleDurations 31/28 {
          f4 d b \tuplet 3/2 { cis d fis }
        }
      }
      g

    }
  >>

   c,
}

\markup "Using the function doesn't check whether subsequent music matches the set of
indicated time signatures."

\relative c' {
  \alternatingTimeSignatures #'((3 4)(4 4))
  c4 c c
  \omit Score.TimeSignature
  \time 6/8
  c8 c c c c c
  \time 4/4
  c4 c c c
  \undo \omit Score.TimeSignature
  \time 5/4
}

\markup "If you're daring you can even pass floating point numbers to \\fractionList"

\relative c' {
  \once \override Score.TimeSignature.stencil =
    \fractionList #'(#t (3.5 4)(5 4))
  \time 7/8
  c8[ c] c[ c] c[ c] c
  \omit Score.TimeSignature
  \time 5/4
  c4 c c c c
  \undo \omit Score.TimeSignature
  \time 3/8
}

\markup "Malformed time signature lists produce errors (see console output)"

#(ly:message "


Here comes the warning for malformed signature lists:
=====================================================

")

\relative c' {
  \alternatingTimeSignatures #'((6 5 4)(4 4))
  c1
  \alternatingTimeSignatures #'((5 4)(1))
  c1
}

#(ly:message "

=====================================================


")