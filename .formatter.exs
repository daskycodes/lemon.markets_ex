# Used by "mix format"
[
  inputs: ["{mix,.formatter}.exs", "{config,lib,test}/**/*.{ex,exs}"],
  line_length: 140,
  locals_without_parens: [
    plug: :*,
    adapter: :*
  ]
]
