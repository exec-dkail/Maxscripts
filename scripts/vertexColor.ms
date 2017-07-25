function applyVertexColor obj col sel:unsupplied =
(
    if sel == "SELECTED" do
    (
      polyop.setFaceColor obj 0 (polyop.getFaceSelection obj) col			
    )
    if sel == "NON_SELECTED" do
    (
      for i in obj do
      (
        polyop.setFaceSelection i #all
        polyop.setFaceColor i 0 (polyop.getFaceSelection i) col
      )
    )
)
function toggleVertexColor =
(
  max create mode
  for i in selection do
  (
    state = not i.showVertexColors
    i.showVertexColors = state
    i.vertexColorsShaded = not state

  )
  completeRedraw()
)
