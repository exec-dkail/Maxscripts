function setLocalFaceRotation obj type index:unsupplied  =
(
  case type of
  (
    #Poly:
    (
      ResetXForm obj 
      ConvertTo obj Editable_Poly
      getPolyFaceNormal = matrixfromNormal(polyop.getFaceNormal obj index) as quat
      inverseRotation = inverse getPolyFaceNormal 				
      with redraw on
      (
        animate off in coordsys local obj.rotation*=inverseRotation
        obj.objectoffsetrot *= inverseRotation
        obj.objectoffsetpos *= inverseRotation
      )
    )
    #Mesh:
    (
      ResetXForm obj 
      ConvertTo obj Editable_mesh
      getFaceSel = getFaceSelection $ as array
      getPolyFaceNormal = matrixfromNormal(((meshop.getFaceRNormals $ getFaceSel[1])[1]+(meshop.getFaceRNormals $ getFaceSel[2])[1])/2) as quat
      inverseRotation = inverse getPolyFaceNormal 				
      with redraw on
      (
        animate off in coordsys local obj.rotation*=inverseRotation
        obj.objectoffsetrot *= inverseRotation
        obj.objectoffsetpos *= inverseRotation
      )					
    )
  )
)	
function pivotToCenter =
(
  if selection.count > 0 then
  (
    for i in selection do
    (
      i.pivot = i.center
    )			
  )
)
function pivotToWorld =
(
  if selection.count > 0 then
  (
    for i in selection do
    (
      i.pivot = [0,0,0]
    )
  )
)
function pivotToFaceCenter obj =
(
  getFaceIndex = polyop.getFaceSelection obj as array		
  if obj != undefined and getFaceIndex[1] != undefined then
  (
    on undo on
    (
      getFaceCenter = polyop.getFaceCenter obj (getFaceIndex[1])
      obj.pivot = getFaceCenter
    )
  )
)
function pivotToFaceLocal obj =
(
  if obj != undefined then
  (
    getFaceIndex = polyop.getFaceSelection obj as array			
    if obj != undefined and getFaceIndex[1] != undefined then
    (
      on undo on
      (
        ResetPivot obj					
        getFaceCenter = polyop.getFaceCenter obj (getFaceIndex[1])
        obj.pivot = getFaceCenter
        setLocalFaceRotation obj getFaceIndex[1]
      )
    )
  )
)
