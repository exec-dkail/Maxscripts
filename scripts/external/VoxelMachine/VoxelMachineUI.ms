try(destroyDialog VoxelMachineUI)catch()
rollout VoxelMachineUI "Voxel Machine" width:288 height:432
(
	GroupBox 'paletteSettings' "Palette Settings" pos:[8,8] width:272 height:64 align:#left
	label 'lbl1' "Palette Width" pos:[16,28] width:96 height:16 align:#left
	dropdownList 'ddlRows' "" pos:[120,24] width:48 height:21 items:#("2", "4", "8", "16") align:#left
	label 'lbl2' "Palette Height" pos:[16,50] width:96 height:16 align:#left
	dropdownList 'ddlColumns' "" pos:[120,48] width:48 height:21 items:#("2", "4", "8", "16") align:#left
	radiobuttons 'rdoGenerationType' "" pos:[184,32] width:85 height:32 labels:#("Generate", "Select Image") default:1 columns:1 align:#left
	GroupBox 'paletteBox' "Palette" pos:[8,104] width:272 height:280 align:#left
	dotNetControl 'grpSwatchButtons' "System.Windows.Forms.GroupBox" pos:[16,120] width:256 height:256 align:#left
	button 'btnGenerateSwatch' "Add / Generate Swatch" pos:[8,72] width:272 height:32 align:#left
	label 'lblnBlock' "Number Of Blocks" pos:[16,400] width:88 height:16 align:#left
	spinner 'spnBlock' "" pos:[112,400] width:48 height:16 range:[1,10,1] type:#integer scale:1 align:#left
	checkbutton 'ckbPlaceVoxel' "Place Voxels" pos:[168,392] width:104 height:32 align:#left
	
	local imageSize = Point2 0 0
	local swatchButtonHeight = 64
	local colorPalette = #()
	local maxButtonSize = 16
	local stopPlacement = false
	local curobj = undefined
	local voxelObjects = #()
	
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
	fn GetObjectFromPoint = 
	(
		screenToWorldRay = mapScreenToWorldRay (mouse.pos)
		if screenToWorldRay != undefined do
		(
			hit_nodes = for n in (intersectRayScene screenToWorldRay) where not n[1].isHidden collect #(n[1], n[2], distance screenToWorldRay.pos n[2].pos)
			if hit_nodes.count > 0 do
			(
				qsort hit_nodes sortByHitDistance
				obj = getNodeByName(hit_nodes[1][1].name)
				if obj != undefined do
				(
					return obj
				)
			)
		)
		return undefined
	)
	fn GetTransformMatrix = 
	(
		local transformMatrix = undefined
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
	fn CreateBox color =
	(
		obj = GetObjectFromPoint()
		if obj == undefined then
		(
			if (findItem voxelObjects [0,0,0]) == 0 do
			(			
				bx = Box width:10 height:10 length:10 pivot:[0,0,5] pos:[0,0,0] wirecolor:color
				Append voxelObjects bx.center
			)
		)
		else
		(
			tMatrix = GetTransformMatrix()			
			if tMatrix != undefined do
			(
				format "%\n" voxelObjects
				for i = 1 to spnBlock.value do 
				(	
					bx = Box length:10 width:10 height:10 wirecolor:color
					bx.transform = tMatrix
					bx.pos = tMatrix.row4
					bx.pos += (tMatrix.row3 * (i-1) * 10)				
					if (findItem voxelObjects bx.center) == 0 then
					(	
						Append voxelObjects bx.center
					)
					else
					(
						delete bx
					)
				)
			)				
		)
	)
	fn FormatLog msg =
	(	
		dateTime = dotNetClass "System.DateTime"
		format "% | %\n" ((dateTime.Now).ToString("MM/dd/yyyy h:mm tt")) msg 
	)
	-- Events
	fn rdoCheckedChanged o e =
	(
		if o.Checked do 
		(
			curobj = o
			o.FlatAppearance.BorderSize = 4
			o.FlatAppearance.BorderColor = (dotNetClass "System.Drawing.Color").White
		)
		if not o.Checked do
		(
			o.FlatAppearance.BorderSize = 0
		)
	)
	-- Polpulation
	fn GenerateSwatches = 
	(
		colorPalette = #()
		case rdoGenerationType.state of
		(
			1 :
			(
				for x = 1 to ((ddlRows.Selected as integer)*(ddlColumns.Selected as integer)) do
				(
					Append colorPalette ((dotNetClass "System.Drawing.Color").FromArgb (random 0 255) (random 0 255) (random 0 255))
				)
				FormatLog "Log : Palette Image Generated"
				if QueryBox "Do you want to save the Generated Image ?" beep:true title:"Save Image" do
				(
					saveFileDialog = dotNetObject "System.Windows.Forms.SaveFileDialog"
					saveFileDialog.Filter = "PNG Image (*.png)|*.png"
					local saveFileName
					if saveFileDialog.ShowDialog() == (dotNetClass "System.Windows.Forms.DialogResult").OK then
					(
						saveFileName = saveFileDialog.Filename
						-- Generate Bitmap
						bitmp = dotNetObject "System.Drawing.Bitmap" (ddlRows.Selected as integer) (ddlColumns.Selected as integer)
						i = 0
						for x = 0 to bitmp.Width-1 do
						(
							for y = 0 to bitmp.Height-1 do
							(
								bitmp.SetPixel x y colorPalette[i+1]
								i += 1
							)
							if i == colorPalette.Count do exit
						)	
						bitmp.Save saveFileName
						bitmp.Dispose()
						FormatLog ("Log : Image Saved | " + saveFileName)
					)
					else FormatLog "Log : Save Image Failed | User Cancelled"		
				)
			)
			2 :
			(
				bmpFile = undefined
				local bitmp
				openFileDialog = dotNetObject "System.Windows.Forms.OpenFileDialog"
				openFileDialog.Filter = "PNG Image (*.png)|*.png" 
				if openFileDialog.ShowDialog() == (dotNetClass "System.Windows.Forms.DialogResult").OK do
				(
					bmpFile = openFileDialog.Filename
					if doesFileExist bmpFile do
					(
						bitmp = (dotNetClass "System.Drawing.Bitmap").FromFile bmpFile
						imageSize = [bitmp.Width,bitmp.Height]
						if bitmp.Width <= maxButtonSize and bitmp.Height <= maxButtonSize then
						(
							for x = 0 to bitmp.Width-1 do
							(
								for y = 0 to bitmp.Height-1 do
								(
									Append colorPalette (bitmp.GetPixel x y)
								)
							)
							bitmp.Dispose()
						)
						else MessageBox ("Texture more than 16x16 pixels is not allowed")
					)
					FormatLog "Log : Generating Palette Buttons"				
				)
			)
		)
	)
	fn PopulateSwatches =
	(
		if colorPalette.count > 0 do
		(
			grpSwatchButtons.Controls.Clear()	
			for i = 1 to colorPalette.count do
			(
				btn = dotNetObject "System.Windows.Forms.RadioButton"
				btn.Appearance = (dotNetClass "System.Windows.Forms.Appearance").Button
				btn.Name = "swatchButton_" + i as string
				btn.Size = dotNetObject "System.Drawing.Size" maxButtonSize maxButtonSize
				btn.FlatStyle = btn.FlatStyle.Flat
				btn.FlatAppearance.BorderSize = 0
				btn.UseVisualStyleBackColor = false
				btn.BackColor = (dotNetClass "System.Drawing.Color").FromArgb colorPalette[i].r colorPalette[i].g colorPalette[i].b
				dotnet.addEventHandler btn "CheckedChanged" rdoCheckedChanged
				grpSwatchButtons.Controls.Add btn
			)
			case rdoGenerationType.state of
			(
				1 :
				(
					i = 0
					for x = 0 to ((ddlRows.Selected as integer)-1) do
					(
						for y = 0 to ((ddlColumns.Selected as integer)-1) do
						(
							grpSwatchButtons.Controls.Item[i].Left = (x * grpSwatchButtons.Controls.Item[i].Width)
							grpSwatchButtons.Controls.Item[i].Top = (y * grpSwatchButtons.Controls.Item[i].Height)
							i += 1
						)			
						if i == colorPalette.count do exit
					)
					grpSwatchButtons.Size = dotNetObject "System.Drawing.Size" ((ddlRows.Selected as integer) *maxButtonSize) ((ddlColumns.Selected as integer)*maxButtonSize)	
					FormatLog ("Generated Button | " + ddlRows.Selected + " x " + ddlColumns.Selected)
				)
				2 :
				(
					i = 0
					for x = 0 to (imageSize.x as integer)-1 do
					(
						for y = 0 to (imageSize.y as integer)-1 do
						(
							grpSwatchButtons.Controls.Item[i].Left = (x * grpSwatchButtons.Controls.Item[i].Width)
							grpSwatchButtons.Controls.Item[i].Top = (y * grpSwatchButtons.Controls.Item[i].Height)
							i += 1
						)			
						if i == colorPalette.count do exit
					)
					grpSwatchButtons.Size = dotNetObject "System.Drawing.Size" ((imageSize.x as integer) *maxButtonSize) ((imageSize.y as integer)*maxButtonSize)
					FormatLog ("Generated Button | " + ((imageSize.x as integer) as string) + " x " + ((imageSize.y as integer) as string))
				)
			)
			paletteBox.Height = grpSwatchButtons.Height + 24
			lblnBlock.pos.y = paletteSettings.height + (swatchButtonHeight - 8) + paletteBox.height
			spnBlock.pos.y = paletteSettings.height + (swatchButtonHeight - 8) + paletteBox.height
			ckbPlaceVoxel.pos.y = paletteSettings.height + (swatchButtonHeight - 16) + paletteBox.height
			VoxelMachineUI.Height = paletteSettings.height + swatchButtonHeight + paletteBox.height + 24
		)
	)
	on VoxelMachineUI open do
	(
		grpSwatchButtons.BackColor = (dotNetClass "System.Drawing.Color").FromArgb 64 64 64
		grpSwatchButtons.Size = dotNetObject "System.Drawing.Size" 0 0
		grpSwatchButtons.Enabled = false
	)
	on btnGenerateSwatch pressed do
	(
		GenerateSwatches()	
		PopulateSwatches()
	)
	on ckbPlaceVoxel changed state do
	(
		if state then
		(
			voxelObjects = for obj in objects where obj.length == 10 and obj.width == 10 and obj.height == 10 collect obj.center
			grpSwatchButtons.Enabled = true
			stopPlacement = false
			--voxelObjects = for obj in objects where superClassOf obj == GeometryClass collect obj.pos
			while (stopPlacement != true) do
			(
				max create mode				
				pPoint = PickPoint()
				case of
				(
					(pPoint == #rightClick) :
					(					
						stopPlacement = true
						ckbPlaceVoxel.state = false
						grpSwatchButtons.Enabled = false
						exit					
					)
					((classOf pPoint) == Point3) :
					(
						if curobj != undefined do
						(
							CreateBox (color curobj.BackColor.r curobj.BackColor.g curobj.BackColor.b)							
						)						
					)
				)
			)
		)
		else
		(
			stopPlacement = true
			grpSwatchButtons.Enabled = false
		)
	)
)
createDialog VoxelMachineUI
