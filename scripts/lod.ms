function identifyLOD obj = 
(
  splittedNumber = (substring (obj.name) 2 1) as integer
  nextLODName = substituteString obj.name (splittedNumber as string) ((splittedNumber+1)as string) 
  return nextLODName
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
function cloneObject obj maxLod mirror:false =
(
  newName = identifyLOD obj
  minLod = (substring (newName) 2 1) as Integer
  if minLod <= (maxLod-1) then
  (	
    if (getNodeByName newName) == undefined then
    (
      maxOps.cloneNodes obj cloneType:#copy newNodes:&nnl
      nnl.name = newName		
      xLod = (substring (newName) 1 2)			
      moveToLayer (getNodeByName newName) xLod
    )
    else 
    (
      format "Skipped : % - object already exist\n" newName 
    )
  )
)
function fixLODPivot maxLOD =
(
  for i in $x0* do
  (
    basePivot = i.pivot 
    trimObjName = replace i.name 1 3 ""
    try
      (
        for i = 1 to maxLOD-1 do
        (
          try
          (
            theNode = getNodeByName("x" + i as string + "_" + trimObjName)
            if theNode.pivot != basePivot then
            (
              theNode.pivot = basePivot
            )
          )catch()
        )
      )
      catch()
  )
)

/*LOD Triangle Counter*/
function updateEntireScript xtimer func =
(	
  dotnet.addEventHandler xtimer "tick" func
  xtimer.interval = 500
)
function roundDecimal val =
(
  roundValue = (floor ((val * 10) + 0.5)) / 10
  return roundValue
)
function updatePercentage current target =
(
  decrease = (current as float) - (target as float)
  percentage = (decrease/current)*100.0
  percentage = roundDecimal percentage
  return percentage
)
function getCountFromOriginalObj obj =
(
  if selection.count > 0 and obj.name[2] != "0" do
  (
    objName = obj.name
    objName[2] = "0"
    if (getNodeByName objName) != undefined then
    (
      triCount = ((getTriMeshFaceCount (getNodeByName objName))[1]) as float
      return triCount
    )
  )
)
function getCountFromObject obj =
(
  if selection.count == 1 and obj.name[2] != "0" do
  (		
    triCount = ((getTriMeshFaceCount obj)[1]) as float
    return triCount
  )
)
function getEntireLODCount exArr lodCount maxCount:unsupplied type:unsupplied =
(
  try
  (
    if type == "Selection" do
    (
        filteredExcludedObject = #()
        triCount = 0
        getInitial = substring $.name 1 2					
        for i = 1 to exArr.count do
        (
          filteredExcludedObject[i] = (getInitial+"_"+exArr[i])
        )
        for i in (execute ("$"+getInitial+"*")) do
        (
          if (findItem filteredExcludedObject i.name) == 0 then
          (
            triCount = triCount + ((getTriMeshFaceCount i)[1])
          )
        )
        triCount = (getInitial + " : " + ((dotNetClass "System.String").Format "{0:n0}" triCount) as String)
        return triCount
    )
    if type == "Entire" do
    (
      filteredExcludedObject = #()
      countArr = #()
      newCount = #()
      for i = 1 to lodCount do
      (
        triCount = 0				
        for o = 1 to exArr.count do
        (
          filteredExcludedObject[o] = ("x"+(i-1)as string+"_"+exArr[o])
        )						
        for j in (execute("$x"+(i-1)as string+"*")) where j.layer.name == ("x"+(i-1)as string) do
        (
          if (findItem filteredExcludedObject j.name) == 0 then
          (
            triCount = triCount + ((getTriMeshFaceCount j)[1]) as Integer
          )
        )
        if triCount > maxCount[i] then
        (
          newCount[i] = ((dotNetClass "System.String").Format "{0:n0}" triCount) as string + ("\t| BUDGET : " + ((dotNetClass "System.String").Format "{0:n0}" maxCount[i]))
        )
        else
        (
          newCount[i] = ((dotNetClass "System.String").Format "{0:n0}" triCount) as string
        )
        countArr[i] = newCount[i]
      )
      return countArr
    )
  )catch()
)	
function showLODCount mainTriCountArr =
(
    if selection.count == 1 and $.name[2] != "0" do
    (
      budgetCount = 0
      OriginalPercentage = updatePercentage (mainTriCountArr[1]) (mainTriCountArr[($.name[2] as integer + 1)])
      maxCount = getCountFromOriginalObj $
      if maxCount != undefined then
      (
        countNeeded = floor(maxCount- ((maxCount* OriginalPercentage ) / 100))
        currCount = getCountFromObject $					
        if currCount > countNeeded then
        (
          budgetCount = ("Count : " + ((dotNetClass "System.String").Format "{0:n0}" (currCount as Integer))as String + "\nOverBudget : " + ((dotNetClass "System.String").Format "{0:n0}" ((currCount - countNeeded) as Integer)) as String)
          return budgetCount 
        )
        else
        (
          budgetCount = ("Count : " + ((dotNetClass "System.String").Format "{0:n0}" (currCount as Integer))as String + "\nUnderBudget : " + ((dotNetClass "System.String").Format "{0:n0}" (-(currCount - countNeeded) as Integer)) as String)
          return budgetCount 
        )
      )
      else
      (
        budgetCount = "No x0 found for current object"
        return budgetCount
      )
    )
)	
