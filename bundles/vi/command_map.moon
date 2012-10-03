state = ...
base_map = bundle_load 'base_map.moon'
import move, apply, repeat_last from state
import command from lunar

_G = _G

map = setmetatable {}, __index: base_map
setfenv 1, map

one_right = (editor) ->
  if editor.cursor.at_end_of_line
    editor\insert ' '
  else
    editor.cursor\right!

export *

to_insert = (editor) -> state.change_mode editor, 'insert'

name = 'VI'

escape = (editor) ->
  state.reset!

a = (editor) ->
  one_right editor
  to_insert editor

A = (editor) ->
  editor.cursor\line_end!
  to_insert editor

c = (editor) ->
  if state.change then apply editor, ->
    editor\copy_line!
    editor.cursor\home!
    editor\delete_to_end_of_line!
    to_insert editor
  else
    state.change = true

C = (editor) -> apply editor, ->
  editor\delete_to_end_of_line!
  to_insert editor

d = (editor) ->
  if state.delete then apply editor, ->
    editor\copy_line!
    editor\delete_line!
  else
    state.delete = true

D = (editor) -> apply editor, -> editor\delete_to_end_of_line!

G = (editor) -> apply editor, ->
  if state.count then editor.cursor.line = state.count
  else editor.cursor\eof!

i = to_insert

J = (editor) -> apply editor, -> editor\join_lines!

o = (editor) -> apply editor, ->
  A editor
  editor\smart_newline!

O = (editor) -> apply editor, ->
  current_indent = editor.current_line.indentation
  editor.cursor\home!
  editor\newline!
  editor.cursor\up!
  editor.current_line.indentation = current_indent
  editor.cursor.column = current_indent + 1
  to_insert editor

p = (editor) -> apply editor, ->
  one_right editor
  editor\paste!

P = (editor) -> apply editor, -> editor\paste!

u = (editor) -> editor.buffer\undo!

v = (editor) -> state.change_mode editor, 'visual'

x = (editor) -> apply editor, -> editor.buffer\delete editor.cursor.pos, 1

y = (editor) ->
  if state.yank
    apply editor, -> editor\copy_line!
  else
    state.yank = true

Y = (editor) -> editor\copy_line!

map['.'] = (editor) -> repeat_last editor
map[':'] = (editor) -> command.run!

return map
