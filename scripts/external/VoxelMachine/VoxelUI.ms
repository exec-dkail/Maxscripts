try(destroyDialog VoxelMachine)catch()
rollout VoxelMachine "Untitled" width:160 height:48
(
	local stopPlacement = false
	checkbutton 'btnStartVoxelPlacement' "Place Voxel" pos:[8,8] width:144 height:32 align:#left	
	fn sortByHitDistance n1 n2 = 
	(
		if n1[3] < n2[3] then -1 
		else if n1[3] > n2[3] then 1 
		else 0 
	)
	fn GetFaceIndexFromNormal obj v = 
	(
		for i = 1 to (polyop.getNumFaces obj) do
		(
			fNormal = polyop.getFaceNormal obj i
			if fNormal == v do
			(
				return i
			)
		)
	)
	fn GetFaceCenterPos = 
	(
		try
		(
			screenToWorldRay = mapScreenToWorldRay (mouse.pos)		
			hit_nodes = for n in (intersectRayScene screenToWorldRay) where not n[1].isHidden collect #(n[1], n[2], distance screenToWorldRay.pos n[2].pos)
			qsort hit_nodes sortByHitDistance
			obj = getNodeByName(hit_nodes[1][1].name)
			cloneMesh = ConvertTo (copy obj) Editable_Mesh
			r = screenToWorldRay
			getObjectData = intersectRayEx cloneMesh r
			faceNormal = getFaceNormal cloneMesh getObjectData[2]
			ConvertTo cloneMesh Editable_Poly
			faceIndex = (GetFaceIndexFromNormal cloneMesh faceNormal)
			faceCenter = (polyop.getFaceCenter cloneMesh faceIndex)
			delete cloneMesh
			return #(faceNormal,faceCenter)
		)
		catch(return [0,0,0])
	)
	fn GetAmaxDimension obj faceNormal =
	(
		getDimension = (obj.max - obj.min)/2
		dimensionArray = #()
		dimensionArray[1] = abs faceNormal.x
		dimensionArray[2] = abs faceNormal.y
		dimensionArray[3] = abs faceNormal.z
		case (findItem dimensionArray (amax dimensionArray)) of
		(
			1 : return (faceNormal * getDimension.x)
			2 : return (faceNormal * getDimension.y)
			3 : return (faceNormal * getDimension.z)
		)
		return undefined
	)
	on btnStartVoxelPlacement changed state do
	(
		if state then
		(
			stopPlacement = false
			while (stopPlacement != true) do
			(
				pPoint = PickPoint()
				case of
				(
					(pPoint == undefined) :
					(
						bx = Box width:10 height:10 length:10
						bx.pivot = bx.center
						bx.pos = [0,0,0]
					)
					(pPoint == #rightClick) :
					(					
						stopPlacement = true
						btnStartVoxelPlacement.state = false
						exit
					)
					((classOf pPoint) == Point3) :
					(
						faceCenterPos = (GetFaceCenterPos())
						bx = Box width:10 height:10 length:10 
						bx.pivot = bx.center
						if (classOf faceCenterPos == Array) then
						(
							bx.pos = faceCenterPos[2] + (GetAmaxDimension bx faceCenterPos[1])
						)
						else
						(
							bx.pos = faceCenterPos
						)
					)
				)
			)
		)
		else
		(
			stopPlacement = true
		)
	)
)
createDialog VoxelMachine

