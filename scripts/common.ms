function initializeUnitSetup sysScale sysType =
(
  units.SystemScale = sysScale
  units.SystemType = (execute sysType)
  units.DisplayType = #Metric
  units.MetricType = (execute sysType)
)
function hideAllLayers =
(
  for i = 0 to (LayerManager.count-1) do
  (
    theLayer = LayerManager.getLayer i
    if theLayer.ishidden != true do
    (
      theLayer.ishidden = true
    )
  )
)
function selectLOD lodIdx tyre:unsupplied =
(

  hideAllLayers()
  tLayer = LayerManager.getLayerFromName lodIdx
  tLayer.isHidden = false 			
  hide $*
  max select none

  for i in (execute("$*" + lodIdx + "*")) do
  (			
    unhide i
    selectmore i
  )
  if tyre != unsupplied then
  (
    try
    (
      tyreLayer = LayerManager.getLayerFromName (lodIdx+"_"+tyre)
      tyreLayer.isHidden = false
    )catch()
  )

  max select none
)
function moveToLayer obj layerName =
(
  theLayer = LayerManager.getLayerFromName layerName
  if theLayer != undefined then
  (
    theLayer.addNode obj
  )
  else
  (
    newLayer = LayerManager.newLayerFromName layerName
    newLayer.addNode obj
  )
)
function cloneObject obj objName layerName mirror:false=
(
  newName = substituteString obj.name (substring (obj.name) 1 2) objName
  maxOps.cloneNodes obj cloneType:#copy newNodes:&nnl
  nnl.name = newName
  newObj = getNodeByName newName
  moveToLayer (getNodeByName newObj) layerName
)	
function resetXFormSelection flipNormal:false =
(
  if selection.count > 0 then
  (
    for i in selection where superClassOf i == GeometryClass do
    (
      if flipNormal == false then
      (
        ResetXForm i
        CollapseStack i
      )
      else
      (
        normalMod = NormalModifier()
        ResetXForm i
        ModPanel.AddModToSelection normalMod
        normalMod.flip = true
        CollapseStack i
      )
    )
  )
)
function checkNonSmoothing =
(
  max select all
  if selection.count > 0 then
  (
    local objs = #()

    for i in selection where i.isHidden == false do
    (
      objTotalFace = polyop.getNumFaces i 
      faceArr = #()
      for f = 1 to objTotalFace do
      (
        sFaces = polyop.getFaceSmoothGroup i f
        if sFaces == 0 then
        (
          appendIfUnique faceArr f
          appendIfUnique objs i
        )
      )
      polyop.setFaceSelection i #none
      polyop.setFaceSelection i faceArr
    )
    max select none
    select objs
  )
)
function checkNonQuad =
(
  max select all
  if selection.count > 0 do 
  (
    local objs = #()
    for i in selection where i.isHidden == false do 
    (
      local face_selection = #{}
      local num_faces = polyop.getNumFaces i
      for f = 1 to num_faces do
      (
        num_face_verts = polyop.getFaceDeg i f
        if num_face_verts > 4 do 
        (
          face_selection[f] = true
          appendIfUnique objs i
        )
      )
      polyop.setFaceSelection i face_selection
    )
    max select none
    select objs
  )
)
fn checkZeroFaceArea obj =
(
  try
  (
    zeroFaceArea = #()	
    for i = 1 to (polyop.getNumFaces obj) do
    (
      if (polyop.getFaceArea obj i) == 0.0 then
      (
        AppendIfUnique zeroFaceArea i
      )
    )
    zeroFaceArea = zeroFaceArea as BitArray
    polyop.setFaceSelection obj #None
    polyop.setFaceSelection obj zeroFaceArea

  )catch()
)
function unhideFacesVerts=
(
  for i in objects where superclassof i == GeometryClass do
  (
    try
    (
      getHiddenFaces = polyop.getHiddenFaces i as array
      if getHiddenFaces[1] != undefined do
      (
        polyop.unHideAllFaces i
        format "Object with Hidden Faces : %\n" i.name
      )
      getHiddenVerts = polyop.getHiddenVerts i as array
      if getHiddenVerts[1] != undefined do
      (
        polyop.unHideAllVerts i
        format "Object With Hidden Verts : %\n" i.name
      )
    )catch()
  )
  redrawViews()
)
--SELECTION SET FUNCTION START
fn getObjProperties obj =
(
  return (getUserProp obj "setName")
)
fn getSelectionSetName obj =
(
  local selSetName
  for i = 1 to selectionSets.count do
  (
    for j = 1 to selectionSets[i].count do
    (
      if (matchPattern (selectionSets[i][j].name) pattern:obj.name) == true do
      (
        selSetName = (selectionSets[i].name)
      )
    )
  )
  return selSetName
)
fn addToSelectionSet obj setName = 
(
  try(oldObj = for i in selectionSets[setName] collect i)catch(oldObj = #())
  select obj
  newObj = selection as array
  selectionSets[setName] = (oldObj + newObj)
)			
--SELECTION SET FUNCTION END
function forceResetXForm =
(
  if selection.count > 0 then
  (
    for i in selection where superClassOf i == GeometryClass do
    (
      theBox = Box width:10 height:10 length:10
      theLayer = LayerManager.getLayerFromName i.layer.name
      if theLayer != undefined then
      (
        theLayer.addNode theBox
      )
      if (getSelectionSetName i) != undefined do setUserProp theBox "setName" (getSelectionSetName i)
      theBox.parent = i.parent
      theBox.pivot = theBox.center
      theBox.pos = i.pos
      theBox.pivot = i.pivot
      theBox.name = i.name+"_resetBox"
      theBox.material = i.material
      theBox.wirecolor = i.wirecolor
      ConvertTo theBox Editable_Poly
      polyop.setFaceSelection i #none
      polyop.setFaceSelection theBox #all
    )
    for i in $*_resetBox do
    (
      polyop.deleteFaces i (polyop.getFaceSelection i)
      i.attach (getNodeByName((substituteString i.name "_resetBox" ""))) i
      i.name = (substituteString i.name "_resetBox" "")
      if (getObjProperties i) != undefined do
      (
        addToSelectionSet i (getObjProperties i)
        setUserPropBuffer i ""
      )
    )
    max select none
  )
)
