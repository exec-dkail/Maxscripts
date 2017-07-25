function checkMaterialID idList xLod =
(
  invalidMat = #()
  for j = 1 to idList.count do
  (
    for i in (execute xLod) do
    (
      polyop.setFaceSelection i #None
      i.selectByMaterial idList[j]		
      if ((polyop.getFaceSelection i) as array)[1] != undefined and (GetNodeByName i.name) != undefined then
      (
        AppendIfUnique invalidMat i.name
      )
      polyop.setFaceSelection i #None
    )	
    return invalidMat
  )
)
function checkPosition lodList =
(
  invalidObj = #()
  for i = 1 to lodList.count do
  (
    for o in (execute("$"+lodList[i]+"_*l")) do
    (
      if o.pos.x < 0 do
      (
        AppendIfUnique invalidObj o
      )
    )
    for o in (execute("$"+lodList[i]+"_*r"))do
    (
      if o.pos.x > 0 do
      (
        AppendIfUnique invalidObj o
      )
    )
  return invalidObj
  )
)
function checkWrongLayer lodList exList:unsupplied tyre:unsupplied tyreInitials:unsupplied =
(
  newList = #()
  --GET ALL OBJECT...EXCEPT TYRES..CHECK  IF ANYONE MISSING FROM ITS LAYER AND AUTO MOVE IT......IF LAYER IS NOT PRESENT AUTO CREATE IT
  if tyre == unsupplied and tyreInitials == unsupplied do
  (
    for i = 1 to lodList.count do
    (
      for j = 1 to exList.count do
      (
        newList[j] = (lodList[i]+"_"+exList[j])
      )
      for o in (execute("$"+lodList[i]+"*")) where superClassOf o == GeometryClass do
      (
        if findItem newList o.name == 0 then
        (
          if o.layer.name != (lodList[i]) then
          (
            mainLayer = LayerManager.getLayerFromName lodList[i]
            if mainLayer == undefined then
            (
              mainLayer = LayerManager.newLayerFromName lodList[i]
              format "Created New Layer : %\n" (mainLayer.name)
            )
            format "% " o.name
            format "was in : %" (o.layer.name)	
            mainLayer.addNode o
            format "\tAuto Moved To : %\n" (lodList[i])
          )
        )
      )	
    )
  )

  -- GET THE TYRE TYPES and INITIALS ..CHECK IF ANYONE MISSING FROM ITS LAYER AND AUTO MOVE IT...IF LAYER IS NOT PRESENT AUTO CREATE IT
  if tyre != unsupplied and tyreInitials != unsupplied do
  (
    for i = 1 to lodList.count do
    (
      for j = 1 to tyreInitials.count do
      (
        for o in (execute("$*"+lodList[i]+"*_"+tyreInitials[j]+"*")) do
        (
          if o.layer.name != (lodList[i]+"_"+tyre[j]) then
          (
            mainLayer = LayerManager.getLayerFromName (lodList[i]+"_"+tyre[j])
            if mainLayer == undefined then
            (
              mainLayer = LayerManager.newLayerFromName (lodList[i]+"_"+tyre[j])
              format "Created New Layer : %\n" (mainLayer.name)
            )
            format "% " o.name
            format "was in : %" (o.layer.name)
            mainLayer.addNode o	
            format "\tAuto Moved To : %\n" (lodList[i]+"_"+tyre[j])
          )
        )
      )
    )
  )
)
function flipWingMirror obj =
(		
  if obj != undefined then
  (
    if obj.name[obj.name.count] == "l" then
    (
      newName = SubstituteString obj.name "_l" "_r"
    )
    else if obj.name[obj.name.count] == "r" then
    (
      newName = SubstituteString obj.name "_r" "_l"
    )
    else
    (
      newName = undefined 
    )		
    if newName != undefined do
    (
      maxOps.cloneNodes obj cloneType:#copy newNodes:&nnl
      nnl.name = newName
      newObj = getNodeByName newName	
      max select none 
      select newObj
      newObj.transform = newObj.transform * (matrix3 [-1,0,0] [0,1,0] [0,0,1] [0,0,0])
      resetXFormSelection flipNormal:true
      newObj.selectByMaterial 10
      polyop.setFaceMatID newObj (polyop.getFaceSelection newObj as bitarray) 11

    )
  )
)
function fixTyrePosition maxLOD =
(
  --fix x0 first 
  for i in $x0_wheel* do
  (
    tyreStr = SubstituteString i.name "wheel" "tyre"
    wheelPos = i.pos 
    tyreObj = (getNodeByName tyreStr)
    tyreObj.pos = wheelPos
  )
  --fix x1 to maximum lod specified 
  for i = 1 to maxLOD do
  (
    for j in (execute("$x"+i as string+"_tyre*")) do
      (
        firstObj = SubstituteString j.name ("x"+i as string) "x0"
        initialPos = (getNodeByName firstObj)
        j.pos = initialPos.pos
      )
  )		
)
