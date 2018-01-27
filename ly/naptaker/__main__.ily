%%% =========================================================== [ __main__.ily ]
%%% Description: Naptaker - Engraving Naptaker scores with GNU LilyPond
%%% Copyright:   (c) 2016-2017 Eric Bailey
%%% TODO: License:     see LICENSE
%%% ==================================================================== [ EOH ]

\version "2.19.24"

%%%=========================================================== [ Paper Config ]

napPaper =
#(define-void-function
   (parser location) ()
   %% (set-default-paper-size "arch a" 'portrait)
   %% (set-default-paper-size "arch a" 'landscape)
   (set-default-paper-size
    #{ \getOption naptaker.paper-size #}
    #{ \getOption naptaker.paper-orientation #})
   (set-global-staff-size #{ \getOption naptaker.staff-size #}))

%%% ======================================================= [ Helper Functions ]

#(define (part-missing? part)
   (not (and (member part (hash-ref music-grid-meta #:parts))
             (let ((seg-empty? #f)
                   (num-segments (hash-ref music-grid-meta #:segments)))
               (do ((seg 1 (1+ seg)))
                   ((or seg-empty? (> seg num-segments)))
                 (set! seg-empty? (get-music-cell part seg)))))))

templateInit =
#(define-void-function
   (parser location parts segments) (list? list?)
   (ly:debug "===> Initializing template")
   (ly:debug (format #f " --> parts: ~{~a ~}" parts))
   (ly:debug (format #f " --> segment lengths: ~{~a ~}" segments))
   (let* ((segment    0)
          (bar-number 1))
     (cons #{ \gridInit #(length segments) $parts #}
           (map (lambda (len)
                  (let ((this-bar-number bar-number))
                    (set! segment (1+ segment))
                    ;; (set! bar-number (+ bar-number measures))
                    #{
                      \gridSetSegmentTemplate $segment
                      \with {
                        % barNumber = $this-bar-number
                        music     = {
                          #(make-music 'SkipEvent 'duration
                            (if (pair? len)
                                (ly:make-duration 0 0 (car len) (cdr len))
                                (ly:make-duration 0 0 len 1)))
                        }
                      }
                    #}))
                segments))))

%%% ================================================================= [ Chords ]

napChords =
#(define-music-function
   (parser location) ()
   (if (part-missing? "chords")
       (begin (ly:debug "No chords set") #{ #})
       #{
         <<
           \context ChordNames {
             \set chordChanges = ##t
             \set noChordSymbol = ##f
             \gridGetMusic "chords"
           }
           \context FretBoards {
             \set chordChanges = ##t
             \set stringTunings = \getOption naptaker.guitar-tuning
             \override FretBoard.fret-diagram-details.barre-type  = #'straight
             \override FretBoard.fret-diagram-details.finger-code = #'in-dot
             \override FretBoard.fret-diagram-details.number-type = #'arabic
             \override FretBoard.fret-diagram-details.orientation = #'landscape
             \gridGetMusic "chords"
           }
         >>
       #}))

%%% ================================================================= [ Vocals ]

colorLyrics =
#(define-music-function
   (parser location color) (list?)
   #{
     \override Lyrics.LyricText.color = $color
     \override Lyrics.LyricText.font-series = #'bold
     \override Lyrics.LyricHyphen.color = $color
     \override Lyrics.LyricExtender.color = $color
  #})

stanza =
#(define-music-function
   (parser location n) (number?)
   #{ \set stanza = #(format #f "~d. " n) #})

napVox =
#(define-music-function
   (parser location) ()
   (if (part-missing? "vox")
       (begin (ly:debug "No vox") #{ #})
       #{
         <<
           \new VoxVoice = vox <<
             { \gridGetMusic "meta" }
             { \gridGetMusic "vox" }
           >>
           #(if (defined? 'extraLyrics)
                #{ \extraLyrics #}
                #{ \new Lyrics \lyricsto vox { \gridGetLyrics "vox" } #})
         >>
       #}))

%%% ================================================================= [ Guitar ]

napGuitarStrum =
#(define-music-function
   (parser location) ()
   (cond
    ((part-missing? "guitar strum")
     (begin (ly:debug "No guitar strum part set") #{ #}))
    ((part-missing? "vox")
     #{
       \new RhythmicStaff \with {
         \RemoveEmptyStaves
         \override VerticalAxisGroup.remove-first = ##t
         \remove "Staff_performer"
         \remove "Time_signature_engraver"
         \consists Pitch_squash_engraver
       }
       <<
         { \gridGetMusic "meta" }
         { \improvisationOn
           \gridGetMusic "guitar strum" }
       >>
     #})
    (else
     #{
       \new RhythmicStaff \with {
         \RemoveEmptyStaves
         \override VerticalAxisGroup.remove-first = ##t
         \remove "Staff_performer"
         \consists Pitch_squash_engraver
       } {
         \improvisationOn
         \gridGetMusic "guitar strum"
       }
     #})))

napGuitarTab =
#(define-music-function
   (parser location) ()
   #{
     \new TabStaff \with {
       stringTunings       = \getOption naptaker.guitar-tuning
       %% FIXME: This is a bad hack.
       minimumFret         = \getOption naptaker.guitar-capo
       restrainOpenStrings = ##t
       \RemoveEmptyStaves
       \override VerticalAxisGroup.remove-first = ##t
       \remove "Staff_performer"
       \omit PercentRepeatCounter
       \omit DoublePercentRepeatCounter
     } {
       %% \tabFullNotation
       \gridGetMusic "guitar"
     }
   #})

%% TODO: move logic determing whether to engrave chords and tabs to their
%% respective functions
napGuitar =
#(define-music-function
   (parser location) ()
   (if (part-missing? "guitar")
       (begin (ly:debug "No guitar part") #{ #})
       #{
         \new StaffGroup <<
           \napGuitarStrum
           #(if (and (part-missing? "vox") (part-missing? "guitar strum"))
                #{
                  \new GuitarVoice = gtr <<
                    { \gridGetMusic "meta" }
                    { \gridGetMusic "guitar" }
                  >>
                #}
                #{
                  \new GuitarVoice = gtr { \gridGetMusic "guitar" }
                #})
         #(if #{ \getOption naptaker.guitar-tabs #}
              #{ \napGuitarTab #}
              #{ #})
       >>
     #}))

%%% =================================================================== [ Bass ]

napBass =
#(define-music-function
   (parser location) ()
   (if (part-missing? "bass")
        (begin (ly:debug "No bass part") #{ #})
        (if (and (part-missing? "vox") (part-missing? "guitar"))
            #{
              \new BassVoice = bass <<
                { \gridGetMusic "meta" }
                { \gridGetMusic "bass"  }
              >>
            #}
            #{
              \new BassVoice = bass \gridGetMusic "bass"
            #})))

%%% ================================================================== [ Drums ]

%% NOTE: http://web.mit.edu/merolish/Public/drums.pdf
#(define preston-drums
   (alist->hash-table
    '((ridecymbal    cross   #f          4)
      (crashcymbal   cross   #f          6)
      (splashcymbal  cross   #f          7)
      (hihat         cross   "stopped"   5)
      (closedhihat   cross   "stopped"   5)
      (openhihat     cross   "open"      5)
      (halfopenhihat cross   "halfopen"  5)
      (pedalhihat    cross   #f         -5)
      (snare         default #f          1)
      (sidestick     cross   #f          1)
      (hightom       default #f          3)
      (lowmidtom     default #f          0)
      (lowtom        default #f         -1)
      (bassdrum      default #f         -3))))

napDrums =
#(define-music-function
   (parser location) ()
   (cond
    ((part-missing? "drums up")
     (begin #(ly:debug "No drums up part set") #{ #}))
    ((part-missing? "drums down")
     (begin (ly:debug "No drums down part set") #{ #}))
    (else
     #{
       \new DrumStaff \with {
         drumStyleTable = #preston-drums
         instrumentName = "Drums"
         %% shortInstrumentName = "D"
         \RemoveEmptyStaves
         \override VerticalAxisGroup #'remove-first = ##t
       } {
         <<
           \new DrumVoice { \voiceOne \gridGetMusic "drums up" }
           \new DrumVoice \with {
             %% \remove "Rest_engraver"
             %% \remove "Multi_measure_rest_engraver"
           } {
             \voiceTwo \gridGetMusic "drums down"
           }
         >>
       }
     #})))

%%% ================================================================== [ Parts ]

napIncludes =
#(define-void-function
    (parser location) ()
    #{ \include "parts/meta.ily" #}
    (if (not (part-missing? "vox"))
        #{ \include "parts/vox.ily" #})
    (if (not (part-missing? "guitar"))
        #{ \include "parts/guitar.ily" #})
    (if (not (part-missing? "guitar strum"))
        #{ \include "parts/guitar_strum.ily" #})
    (if (not (part-missing? "chords"))
        #{ \include "parts/chords.ily" #})
    (if (not (part-missing? "bass"))
        #{ \include "parts/bass.ily" #})
    (if (not (and (part-missing? "drums up")
                    (part-missing? "drums down")))
        #{ \include "parts/drums.ily" #}))

%%% ================================================================== [ Score ]

Naptaker =
#(define-scheme-function () ()
   "Return the makings of a Naptaker score."
   #{ \napPaper \napIncludes #}
   (let ((score #{
           \score {
             <<
               \napChords
               \napVox
               \napGuitar
               \napBass
               \napDrums
             >>
           }
         #})
         (layout #{
           \layout {
             \getOption naptaker.extra-layout
             \override Score.BarNumber.padding = #3
             \override Score.BarNumber.stencil =
               #(make-stencil-boxer 0.1 0.25 ly:text-interface::print)
           }
         #}))
     (ly:score-add-output-def! score layout)
     score))

%%% ==================================================================== [ EOF ]
