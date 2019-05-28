try(destroyDialog VoxelMachine)catch()
rollout VoxelMachine "Untitled" width:160 height:48
(
	local stopPlacement = false
	local voxelObjects = #()
	checkbutton 'btnStartVoxelPlacement' "Place Voxel" pos:[8,8] width:144 height:32 align:#left	
	fn sortByHitDistance n1 n2 = 
	(
		if n1[3] < n2[3] then -1 
		else if n1[3] > n2[3] then 1 
		else 0 
	)
	fn GetFaceIndexFromNormal obj normalVector = 
	(
		for f in 1 to obj.faces.count where (polyop.getFaceNormal obj f) == normalVector do return f
	)
	fn GetMatrixFromNormal obj faceIndex =
	(
		theFaceCenter=polyOp.getFaceCenter obj faceIndex
		theNormal=polyop.getFaceNormal obj faceIndex		 
		theUp = [0,0,1]
		theX = if acos (dot theUp theNormal) < 0.001 then [1,0,0]	
		else normalize (cross theNormal theUp)
		theY = normalize (cross theNormal theX)
		return (matrix3 theX theY theNormal theFaceCenter)
	)	
	fn GetTransformMatrix = 
	(
		local transformMatrix = matrix3 1
		screenToWorldRay = mapScreenToWorldRay (mouse.pos)		
		if screenToWorldRay != undefined do
		(
			hit_nodes = for n in (intersectRayScene screenToWorldRay) where not n[1].isHidden collect #(n[1], n[2], distance screenToWorldRay.pos n[2].pos)
			if hit_nodes.count > 0 do
			(
				qsort hit_nodes sortByHitDistance
				obj = getNodeByName(hit_nodes[1][1].name)
				cloneMesh = ConvertTo (copy obj) Editable_Mesh
				r = screenToWorldRay
				getObjectData = intersectRayEx cloneMesh r
				faceNormal = getFaceNormal cloneMesh getObjectData[2]
				ConvertTo cloneMesh Editable_Poly
				faceIndex = (GetFaceIndexFromNormal cloneMesh faceNormal)
				transformMatrix = GetMatrixFromNormal cloneMesh faceIndex
				delete cloneMesh
			)
		)
		return transformMatrix		
	)
	on btnStartVoxelPlacement changed state do
	(
		if state then
		(
			try
			(
				stopPlacement = false
				voxelObjects = for obj in objects where superClassOf obj == GeometryClass collect obj.pos
				while (stopPlacement != true) do
				(
					max create mode				
					pPoint = PickPoint()
					case of
					(
						(pPoint == #rightClick) :
						(					
							stopPlacement = true
							btnStartVoxelPlacement.state = false
							exit
						)
						((classOf pPoint) == Point3) :
						(
							if btnStartVoxelPlacement.state == true do
							(
								tMatrix = GetTransformMatrix()		
								if voxelObjects.count == 0 do 
								(
									bx = Box width:10 height:10 length:10
									bx.pivot = bx.center
									bx.pos = [0,0,0]
									AppendIfUnique voxelObjects bx.pos
								)
								if (findItem voxelObjects tMatrix.row4) == 0 do
								(
									bx = Box width:10 height:10 length:10 pos:tMatrix.row4
									bx.transform = tMatrix
									AppendIfUnique voxelObjects bx.pos
								)
							)
						)
					)
				)
			)
			catch(format "Exception : %\n" getCurrentException())
		)
		else
		(
			stopPlacement = true
		)
	)
	on VoxelMachine open do
	(
		voxelObjects = for obj in objects where superClassOf obj == GeometryClass collect obj.pos	
		if (findItem voxelObjects [0,0,0]) == 0 do
		(
			bx = Box width:10 height:10 length:10
			bx.pivot = bx.center
			bx.pos = [0,0,0]
		)				
	)
	on VoxelMachine close do
	(		
		voxelObjects = #()
		btnStartVoxelPlacement.state = false
	)
)
createDialog VoxelMachine

