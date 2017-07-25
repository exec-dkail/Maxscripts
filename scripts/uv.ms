local objSel = #()
function confirmReset =
(
  local hwnd = dialogMonitorOps.getWindowHandle()
  if UIAccessor.GetWindowText hwnd == "Unwrap UVW" then
  (
    uiAccessor.pressDefaultButton()
    true
  )
  else false
)		
function ApplyUVW mapChannel:unsupplied =
(
  obj = selection as array
  if selection.count > 0 do
  (
    max modify mode
    UVWMod = UVWunwrap()
    ModPanel.AddModToSelection UVWMod			
    if mapChannel != unsupplied do
    (
      UVWMod = ModPanel.GetCurrentObject()
      dialogMonitorOps.unRegisterNotification id:#unwrap_reset
      dialogMonitorOps.enabled = true
      dialogMonitorOps.interactive = false
      dialogMonitorOps.registerNotification confirmReset id:#unwrap_reset
      UVWMod.unwrap.setMapChannel mapChannel
      UVWMod.unwrap.Reset()
      dialogMonitorOps.enabled = false
      ModPanel.setCurrentObject UVWMod
    )
    selectmore obj
    UVWMod.Edit()
  )			
)
function showMeshByID id mapChannel =
(
  if selection.count == 1 then
  (
    max modify mode
    subObjectLevel = 4
    $.selectByMaterial id
    if (polyop.getFaceSelection $ as array)[1] != undefined do
    (
      polyOp.setFaceSelection $ -(polyOp.getFaceSelection $)
      polyop.setHiddenFaces $ (polyop.getFaceSelection $)
      polyop.setFaceSelection $ #all
    )
    ApplyUVW mapChannel:mapChannel
  )
  if selection.count > 1 then
  (
    max modify mode
    subObjectLevel = 4
    for i in selection do
    (
      i.selectByMaterial id
      if (polyop.getFaceSelection i as array)[1] != undefined do
      (
        polyOp.setFaceSelection i -(polyOp.getFaceSelection i)
        polyop.setHiddenFaces i (polyop.getFaceSelection i)
        polyop.setFaceSelection i #all
      )
    )
    EditPoly = Edit_Poly()
    ModPanel.AddModToSelection EditPoly
    subobjectLevel = 4
    ApplyUVW mapChannel:mapChannel
  )
)	
function RenderUV renderSize fillMode:unsupplied =
(	
  fileName = getSaveFileName caption:"Save UV Render" types:"Truevision TGA *.tga |*.tga"
  if fileName != undefined then
  (
    max modify mode
    UVWMod = ModPanel.GetCurrentObject()
    UVWMod.renderuv_width = renderSize
    UVWMod.renderuv_height = renderSize
    UVWMod.renderuv_showframebuffer = false
    UVWMod.renderuv_force2sided = true
    UVWMod.renderuv_showoverlap = false
    UVWMod.renderuv_seamedges = false
    if fillMode == true then
    (
      UVWMod.renderuv_fillmode = 1
      UVWMod.renderuv_fillColor = (color 256 256 256)
    )
    else
    (
      UVWMod.renderuv_fillmode = 0
    )
    UVWMod.renderUV fileName
    ShellLaunch (getFileNamePath fileName) "" 
  )
  for i in objSel do
  (
    ConvertTo i Editable_Poly
  )
)	
function RenderToTexture renderSize id:unsupplied mapChannel:unsupplied renderBy:unsupplied =
(
  case renderBy of
  (
    "MaterialID":
    (
      RenderUV renderSize
    )			
    "UVLayout":
    (
      RenderUV renderSize				
    )
    "Mask":
    (
      RenderUV renderSize fillMode:true
    )
  )
)
