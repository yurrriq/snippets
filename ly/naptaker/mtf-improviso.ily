%%%% The stylesheet for MTF-IMPROVISO music notation font
%%%%
%%%% In order for this to work, this file's directory needs to
%%%% be placed in LilyPond's path
%%%%
%%%% NOTE: If a change in the staff-size is needed, include
%%%% this file after it, like:
%%%%
%%%% #(set-global-staff-size 17)
%%%% \include "mtf-improviso.ily"
%%%%
%%%% Copyright (C) 2014-2016 Abraham Lee (tisimst.lilypond@gmail.com)

\version "2.19.12"

\paper {
  #(define fonts
    (set-global-fonts
     #:music "Improviso"
     #:brace "Improviso"
     #:roman "Permanent Marker"
     #:sans "Pea Missy with a Marker"
     #:typewriter "Thickmarker"
     #:factor (/ staff-height pt 20))) % 0.9
}

\layout {
  \override Staff.Beam.beam-thickness = #0.5
  \override Staff.Beam.length-fraction = #1.0
  \override Voice.Stem.thickness = #2.5
  \override Hairpin.thickness = #2
  \override PianoPedalBracket.thickness = #2
  \override Tie.line-thickness = #2
  \override Tie.thickness = #0
  \override Slur.line-thickness = #2
  \override Slur.thickness = #0
  \override PhrasingSlur.line-thickness = #2
  \override PhrasingSlur.thickness = #0
  \override MultiMeasureRestNumber.font-size = #2
  \override LyricHyphen.thickness = #3
  \override LyricExtender.thickness = #3
  \override Score.VoltaBracket.thickness = #2
  \override TupletBracket.thickness = #2
  \override Score.SystemStartBar.thickness = #3
  \override StaffGroup.SystemStartBracket.thickness = #0.25
  \override StaffGroup.SystemStartBracket.padding = #0.5
  \override Staff.BarLine.hair-thickness = #3
  \override Staff.BarLine.thick-thickness = #6
}