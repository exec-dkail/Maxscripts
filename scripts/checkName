function checkNames xFile =
(
  nameCollectorArr = #()
  invalidNaming = #()

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
  --Loops entire object also check if the objects are Geometry , irrespective of any modifiers applied
  for o in objects where superClassOf o == GeometryClass do
  (
    indx = findItem nameCollectorArr o.name
    if indx == 0 then
    (
      appendIfUnique invalidNaming o
    )
  )		
  return invalidNaming
)
