%%% =========================================================== [ __init__.ily ]
%%% Description: Naptaker - Engraving Naptaker scores with GNU LilyPond
%%% Copyright:   (c) 2016-2018 Eric Bailey
%%% TODO: License:     see LICENSE
%%% ==================================================================== [ EOH ]

\declareLibrary "Naptaker" \with {
  maintainers = #'("Eric Bailey <naptakerband@gmail.com>")
  version = "0.1.0"
  short-description = "Engraving Naptaker scores with GNU LilyPond"
  description = "Longer description, used as an introduction to the library."
  % The following option is "unreal" and only used to demonstrate "known options"
  lilypond-min-version = "2.19.24"
}

\useLibrary gridly

\include "preamble.ily"
\include "instruments.ily"

%%% ======================================================== [ Default Options ]

\registerOption naptaker.extra-layout { }

\registerOption naptaker.guitar-capo #3
\registerOption naptaker.guitar-tabs ##f
\registerOption naptaker.guitar-tuning #guitar-open-d-tuning

\registerOption naptaker.paper-orientation #'landscape
\registerOption naptaker.paper-size #"letter"

\registerOption naptaker.staff-size #14

#(oll:log "Initialized Naptaker ~a" "")

%%% ==================================================================== [ EOF ]
