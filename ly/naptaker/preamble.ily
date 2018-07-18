fuzzOn     = \set midiInstrument = #"overdriven guitar"
fuzzOff    = \set midiInstrument = #"electric guitar (clean)"

xOn  = {
  \deadNotesOn
  \set midiInstrument = #"electric guitar (muted)"
  \omit ChordName
  \omit FretBoard
}
xOff = {
  \deadNotesOff
  \set midiInstrument = #"electric guitar (clean)"
  \undo \omit ChordName
  \undo \omit FretBoard
  \once \once \set chordChanges = ##f
}

%% Basically \hideNotes, except deliberately excluding TabNoteHead
hideNotesNotTabStaff = {
  %% hide notes, accidentals, etc.
  \hide Dots
  \hide NoteHead
  \override NoteHead.no-ledgers = ##t
  %% assume that any Beam inherits transparency from its parent Stem
  \hide Stem
  \hide Accidental
  \hide Rest
  \hide MultiMeasureRest
  \hide Script

  %% Unlike \hideNotes, don't hide TabNoteHead
  %% \hide TabNoteHead

  %% Omit Slurs and Ties too
  \omit Staff.Slur \omit Staff.Tie
}

dead = {
  \once \deadNotesOn
}

stopStaffNotTabStaff = {
  \stopStaff
  \omit Staff.Clef \omit Staff.ClefModifier
  \omit Staff.TimeSignature

  #(context-spec-music #{ \startStaff \undo \omit Staff.Clef #} 'TabStaff)
  \hideNotesNotTabStaff
}

restartStaff = {
  \once \omit Staff.BarLine
  #(context-spec-music #{ \undo \omit Staff.BarLine #} 'TabStaff)
  \undo \omit Staff.Clef \undo \omit Staff.ClefModifier

  %% This is awesomely bad...
  \undo \omit Staff.Slur \undo \omit Staff.Tie
  \omit TabStaff.Slur \omit TabStaff.Tie

  \undo \omit Staff.TimeSignature

  \startStaff \unHideNotes
  \undo \hide MultiMeasureRest
  \undo \hide Script
  %% \once \override Staff.BarLine.break-visibility = #end-of-line-invisible
}

gridGetCellMusic =
#(define-music-function (parser location part segment) (string? number?)
   (check-grid)
   (check-coords part segment)
   (cell:music (get-music-cell part segment)))

%% https://bitbucket.org/sinbad/drum-music/src/0ef24490e1b6ef4704539f561886a076d594608a/sjs_drumconfig.ly?at=master&fileviewer=file-view-default
flam = \drummode {
  \once \override Stem.length = #4
  \once \override Slur.height-limit = #0.5
  \acciaccatura { sn8 }
}


%% http://lilypondcookbook.com/post/75066991189/drum-music-9-flams-and-drags
drag = \drummode {
  \once \override Stem.length = #4
  \once \override Slur.height-limit = #0.5
  \appoggiatura { sn8-\omit\ppp [ sn-\omit\ppp ] }
}


bye =
#(define-music-function (parser location) ()
   #{
     \stopStaff \hideNotes
     \omit Staff.Rest \omit Staff.MultiMeasureRest
     \once {
       \omit Staff.Clef \omit Staff.ClefModifier
       \omit Staff.TimeSignature
     }
  #})


hi =
#(define-music-function (parser location) ()
   #{
     \startStaff \unHideNotes
     \undo \omit Staff.Rest \undo \omit Staff.MultiMeasureRest
   #})
