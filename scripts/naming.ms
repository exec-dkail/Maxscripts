function checkNames xFile =
(
  nameCollectorArr = #()
  invalidNaming = #()
  allNames = #()
  --The Dotnet Assembly
  xmlDoc = dotNetObject "System.Xml.XmlDocument"		
  xmlDoc.Load xFile

  --XML Tree
  xQuery = xmlDoc.SelectNodes"Car/Parts"

  --Loops entire XML Document (Parts Children)
  for i = 0 to xQuery.count-1 do
  (	
    --Get the Maximum LOD of the Object
    maxLODCount = xQuery.ItemOf[i].getAttribute"maxLOD"

    --Collects the Entire Name from x0 - x6 to a massive Array (nameCollectorArr)
    for j = 0 to (maxLODCount as integer) do
    (
      AppendIfUnique nameCollectorArr ("x"+j as string+"_"+xQuery.ItemOf[i].InnerXML)		
    )
  )
  --added two cases, if naming is not correct and if naming is same with other Object
  --Loops entire object also check if the objects are Geometry , irrespective of any modifiers applied
  for o in objects where superClassOf o == GeometryClass do
  (
    uniqName = o.name
    indx = findItem nameCollectorArr o.name
    if indx == 0 then
    (
      appendIfUnique invalidNaming o
    )			
  )			
  for obj in objects do
  (
    if findItem allNames obj.name == 0 then append allNames obj.name 
    else append invalidNaming obj
  )
  return invalidNaming		
)

function getDataFromXML xFile =
(
  --The Dotnet Assembly
  xmlDoc = dotNetObject "System.Xml.XmlDocument"		
  xmlDoc.Load xFile

  --XML Tree
  xQuery = xmlDoc.SelectNodes"Car/Parts"

  --Loops entire XML Document (Parts Children)
  nameCollectorArr = for i = 0 to xQuery.count-1 collect
  (
    xQuery.ItemOf[i].InnerXML
  )		
  return nameCollectorArr
)
function renameObject obj newName selType:unsupplied =
(
  if selType == "Whole" do
  (
    if(getNodeByName(newName)) == undefined then
    (
      obj.name = newName
    )
    else
    (
      MessageBox (newName + " : " + " -- Already Exist ")
    )
  )
  if selType == "Selection" do
  (
    if (getNodeByName(newName)) == undefined then
    (
      polyOp.detachFaces obj (polyOp.getFaceSelection obj) asNode:true name:newName node:&nObj
    )
    else
    (
      MessageBox (newName + " : " + " -- Already Exist ")
    )
  )
)
