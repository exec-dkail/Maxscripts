local materialArr
local theMat
local inSlot = 0

function loadXMLData xDoc xFile =
(
  xDoc.Load xFile
  xNodes = xDoc.SelectNodes "Materials/*"
  matNames = for i = 0 to xNodes.Count-1 collect xNodes.ItemOf[i].Name
  return matNames
)
function getMaterialData xDoc xFile mName = 
(
  loadXMLData xDoc xFile
  xDoc.Load xFile
  xNodes = xDoc.SelectNodes ("Materials/"+mName+"/*")
  matDef = for i = 0 to xNodes.Count-1 collect xNodes.ItemOf[i].InnerXML
  return matDef
)
function findMaterial =
(		
  materialArr = #()
  for i in scenematerials do
  (
    if i.name == "ColorID_Assigner" then
    (
      appendIfUnique materialArr i
    )
  )
  for i = 1 to 24 do
  (
    if meditMaterials[i].Name == "ColorID_Assigner" do
    (
      inSlot = i
    )
  )			
)
function createMaterial matID matName matColor =
(
  findMaterial()			
  if materialArr[1] == undefined and inSlot == 0 then
  (
    theMaterial = Multimaterial()
    theMaterial.materialList.count = 1
    theMaterial.Name = "ColorID_Assigner"
    theMaterial.materialIDList[theMaterial.materialList.count] = matID
    theMaterial.names[theMaterial.materialIDList.Count] = matName		
    nMat = theMaterial.materialList[theMaterial.materialList.Count]
    nMat.Name = matName
    nMat.Diffuse = matColor
    nMat.selfIllumAmount = 100
    meditMaterials[activeMeditSlot] = theMaterial
  )
  else
  (
    if inSlot == 0 then
    (
      macros.run "Medit Tools" "condense_medit_slots"
      meditMaterials[activeMeditSlot] = materialArr[1]
      theMaterial = materialArr[1]
    )
    else
    (
      theMaterial = meditMaterials[inSlot]
    )
  )
  return theMaterial
)	
function updateMaterialData matID matName matColor =
(
  theMat = createMaterial matID matName matColor
  sleep 0.4
  if theMat != undefined do
  (
    existingMatID = findItem (theMat.materialIDList) matID
    if existingMatID == 0 then
    (
      theMat.materialList.count = (theMat.materialList.count+1)
      theMat.materialIDList[theMat.materialList.count] = matID
      theMat.names[theMat.materialIDList.Count] = matName		
      nMat = theMat.materialList[theMat.materialList.Count]
      nMat.Name = matName
      nMat.Diffuse = matColor
      nMat.selfIllumAmount = 100	

    )
    else
    (
      format "Material Already Exist \n" 
    )
  )
)
function applyMaterial obj matID matName matColor =
(
  updateMaterialData matID matName matColor
  if obj != undefined and theMat != undefined then
  (
    obj.material = theMat
  )
)
function addIDtoFace obj matID matName matColor = 
(
  max modify mode 
  for i in selection where classOf i == Editable_Poly do
  (
    if subObjectLevel == 4 then
    (
      polyop.setFaceMatID i (polyop.getFaceSelection i) matID		
    )
    else
    (
      polyop.setFaceSelection i #All
      polyop.setFaceMatID i (polyop.getFaceSelection i) matID
    )
    subObjectLevel = 0	
    applyMaterial obj matID matName matColor			
  )
)
function bakeColorMap obj size cValue pValue =
(
  fileLocation = (getSavePath caption:"Select the folder of to Save the Render Files")
  if fileLocation != undefined do
  (
    --Clear all render elements 
    obj.iNodeBakeProperties.removeAllBakeElements() 
    --Preparing the Bake Elements:
    be1 = diffusemap() --instance of the bake element class
    be1.outputSzX = be1.outputSzY = size --set the size of the baked map --specifythe full file path, name and type:	
    be1.fileType = (fileLocation+"\\"+obj.name+"_colorID.tga")
    be1.fileName = filenameFromPath be1.fileType
    if Targa.getCompressed == true then
    (
      Targa.setCompressed false
    )
    if Targa.getColorDepth != 24 then
    (
      Targa.setColorDepth 24 
    )			
    be1.filterOn = true --enable filtering
    be1.shadowsOn = false --disable shadows
    be1.lightingOn = false --disable lighting
    be1.enabled = true --enable baking
    obj.INodeBakeProperties.addBakeElement be1 --add first element
    obj.INodeBakeProperties.bakeEnabled = true --enabling baking
    obj.INodeBakeProperties.bakeChannel = cValue --channel to bake
    obj.INodeBakeProperties.nDilations = pValue --expand the texturea bit

    select obj --we are baking the selection, so we select the object --Call the renderer to bake both elements:
    render rendertype:#bakeSelected vfb:off progressBar:true outputSize:[size,size]
    ShellLaunch (getFileNamePath be1.fileType) ""
  )
)
