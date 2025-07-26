(fenced_code_block) @code_fence.outer
(fenced_code_block
  (code_fence_content) @code_fence.content)

(html_block) @code_fence.outer
((html_block) @code_fence.content)

(document . (section . (thematic_break) (_) @code_fence.content (thematic_break)))

([(minus_metadata) (plus_metadata)] @code_fence.content)

; ((inline) @code_fence.content)
