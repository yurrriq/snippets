\version "2.18.2"
\include "deutsch.ly"

\include "oll-core/package.ily"
\loadModule snippets.editorial-tools.auto-transpose
\loadModule snippets.editorial-tools.edition-engraver
%\include "editorial-tools/auto-transpose/definitions.ily"
%\include "editorial-tools/edition-engraver/definitions.ily"

% some music to insert into example
bach = \relative c'' { b a c h }

% add two transposing instrument-definitions
\addInstrumentDefinition #"eb-clarinet"
  #`((instrumentTransposition . ,(ly:make-pitch 0 2 -1/2))
     (shortInstrumentName . "Es-Kl")
     (clefGlyph . "clefs.G")
     (middleCPosition . -6)
     (clefPosition . -2)
     (instrumentCueName . "Es-Kl")
     (midiInstrument . "clarinet"))

\addInstrumentDefinition #"b-clarinet"
  #`((instrumentTransposition . ,(ly:make-pitch -1 6 -1/2))
     (shortInstrumentName . "Kl")
     (clefGlyph . "clefs.G")
     (middleCPosition . -6)
     (clefPosition . -2)
     (instrumentCueName . "Kl")
     (midiInstrument . "clarinet"))

\addInstrumentDefinition #"concert-pitch"
  #`((instrumentTransposition . #f)
     (shortInstrumentName . "C")
     (clefGlyph . "clefs.G")
     (middleCPosition . -6)
     (clefPosition . -2)
     (instrumentCueName . "C")
     (midiInstrument . "clarinet"))

%%% create demo score

\addEdition transp
\editionMod transp 2 0/1 switch.instrument.Staff.A \instrumentSwitch "b-clarinet"
\editionMod transp 3 0/1 switch.instrument.Staff.A \instrumentSwitch "eb-clarinet"
\editionMod transp 4 2/4 switch.instrument.Staff.A \instrumentSwitch "b-clarinet"
\editionMod transp 5 0/4 switch.instrument.Staff.A \instrumentSwitch "concert-pitch"

music = { $bach $bach $bach <>_"repeat unfold c''" \repeat unfold 4 c''4 <>_"repeat unfold d''" \repeat unfold 4 d'' }
global = { \key f \major s1 \key f \major s1 \key f \major s1 }
\score {
  \new Staff \with {
    \autoTranspose
    \consists \editionEngraver switch.instrument
  } \new Voice <<
    \global
    \music
  >>
  \layout {}
  \midi { \tempo 4=150 }
}


