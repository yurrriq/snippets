\version "2.16.2"

\include "oll-core/package.ily"
\loadModule snippets.input-shorthands.easy-custom-dynamics
%\include "definitions.ily"

{
  c'1 \dynamic sfffzppppp
}
{
  c' \dynamic "molto f ekspressivvo"
}
{
  c' \dynamic fff_I_can_use_underscores
}
{
  c' \dynamic \markup { lolish \huge \dynamic pp \italic ekspress, \caps "markups ftw!" }
}