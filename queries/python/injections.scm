;; Highlight triple-quoted strings as Turtle if they contain "@prefix"
((string_literal) @turtle
 (#match? @turtle "@prefix")
 (#set! injection.language "turtle"))
