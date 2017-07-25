function createPoint list tyre:unsupplied =
(
  objArr = #()
  allTyre = #()
  print list
  for i = 1 to list.count do
  (
    pointNode = Point name:(list[i]+"_group") pos:[0.0,0.0,0.0]
  )
  for i = 1 to list.count do
  (
    try
    (
      layer = layerManager.getLayerFromName list[i]
      layer.isHidden = false
      layer.select true
      objArr = selection as array
    )catch()
    if tyre != unsupplied do 
    (
      tyreArr = #()
      try(for j = 1 to tyre.count do
      (
        tlayer = layerManager.getLayerFromName (list[i]+"_"+tyre[j])
        tlayer.isHidden = false
        tlayer.select true
        for o in selection do AppendIfUnique tyreArr o
      ))catch()
    )
    try
    (	
      select objArr
      selectmore tyreArr
    )catch()
    if selection.count > 0 do
    (
      $.parent = execute("$"+list[i]+"_group")
      max select none
    )
  )
)
function positionLOD list =
(
  theDimension = 0
  padding = 50		
  try
  (
    if $x0_group != undefined then
    (
      select $x0_group.children
      theDimension = ($.max - $.min)
      max select none
      xDimension = for i = 2 to list.count collect
      (
        theDimension.x
      )
      yDimension = for i = 1 to list.count collect
      (
        (theDimension.y * i)
      )
      undo on
      (
        for i = 2 to list.count do
        (
          obj = getNodeByName (list[i]+"_group")
          obj.pos.y = -(yDimension[i-1]) 
          if (mod i 2) != 1.0 do
          (
            obj.pos.x = (xDimension[i]) 
          )
        )
      )
    )
  )catch()			
)
function resetLODPosition list =
(
  try
  (
    for i = 1 to list.count do
    (
      obj = getNodeByName(list[i]+"_group")
      obj.pos = [0,0,0]
      delete obj
    )
  )catch()

)
function loadCameraData xFile =
(
  xmlDoc = dotNetObject "System.XML.XMLDocument"
  xmlDoc.Load xFile
  getCameraNodes = #()
  getCameraData = #()

  xQuery = xmlDoc.SelectNodes ("CameraData/*")
  getCameras = for i = 0 to xQuery.count-1 collect xQuery.ItemOf[i].Name

  for i = 1 to getCameras.count do
  (
    xQuery = xmlDoc.SelectNodes ("CameraData/"+getCameras[i])
    for j = 0 to xQuery.Count-1 do
    (
      AppendIfUnique getCameraNodes (xQuery.ItemOf[j].ChildNodes) 
    )
  )

  getCameraData = for i = 1 to getCameraNodes.Count collect
  (
    for j = 1 to getCameraNodes[i].Count collect
    (
      getCameraNodes[i].ItemOf[j-1].InnerXML
    )
  )

  return getCameraData
)	
function createCamera cName cPos cTargetPos cFov =
(
  if LayerManager.current.Name != "0" then
  (
    layer = LayerManager.getLayerFromName "0"
    layer.current = true
  )
  try(delete (execute ("$"+cName)))catch()
  templateCamera = TargetCamera name:cName pos:cPos target:(TargetObject name:(cName+".Target") pos:cTargetPos)
  templateCamera.FOV = cFov
)
function fastScreenGrab cameraName filename =
(
  hideByCategory.cameras = true
  viewport.setCamera cameraName
  if viewport.getCamera() == cameraName then
  (
    redrawViews()
    img = gw.getViewportDib()
    img.filename = filename
    save img
    viewport.setType #view_persp_user
    img = undefined
  )
)
