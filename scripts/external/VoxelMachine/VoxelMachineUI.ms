try(destroyDialog VoxelMachineUI)catch()
rollout VoxelMachineUI "Voxel Machine" width:288 height:392
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
	
	local swatchButtonHeight = 32
	local colorPalette = #()
	local maxButtonSize = 16
	fn FormatLog msg =
	(	
		dateTime = dotNetClass "System.DateTime"
		format "% | %\n" ((dateTime.Now).ToString("MM/dd/yyyy h:mm tt")) msg 
	)
	on VoxelMachineUI open do
	(
		clearListener()
		grpSwatchButtons.BackColor = (dotNetClass "System.Drawing.Color").FromArgb 64 64 64
		grpSwatchButtons.Size = dotNetObject "System.Drawing.Size" 0 0
	)
	on btnGenerateSwatch pressed do
	(
		colorPalette = #()
		if rdoGenerationType.state == 1 then
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
					FormatLog ("Log : Image Saved | " + saveFileName)
				)
				else FormatLog "Log : Save Image Failed | User Cancelled "
		
			)
			grpSwatchButtons.Size = dotNetObject "System.Drawing.Size" ((ddlRows.Selected as integer)*maxButtonSize) ((ddlColumns.Selected as integer)*maxButtonSize)
		)
		else
		(
			bmpFile = undefined
			local bitmp
			openFileDialog = dotNetObject "System.Windows.Forms.OpenFileDialog"
			openFileDialog.Filter = "PNG Image (*.png)|*.png" 
			if openFileDialog.ShowDialog() == (dotNetClass "System.Windows.Forms.DialogResult").OK do
			(
				bmpFile = openFileDialog.Filename
			)
			if doesFileExist bmpFile do
			(
				bitmp = (dotNetClass "System.Drawing.Bitmap").FromFile bmpFile
			)
			if bitmp.Width < maxButtonSize and bitmp.Height < maxButtonSize then
			(
				for x = 0 to bitmp.Width-1 do
				(
					for y = 0 to bitmp.Height-1 do
					(
						Append colorPalette (bitmp.GetPixel x y)
					)
				)
			)
			else MessageBox ("Texture more than 16x16 pixels is not allowed")
			grpSwatchButtons.Size = dotNetObject "System.Drawing.Size" (sqrt(colorPalette.Count)*maxButtonSize) (sqrt(colorPalette.Count)*maxButtonSize)			
		)		
		FormatLog "Log : Generating Palette Buttons"
		grpSwatchButtons.Controls.Clear()		
		for i = 1 to colorPalette.count do
		(
			btn = dotNetObject "System.Windows.Forms.RadioButton"
			btn.Appearance = (dotNetClass "System.Windows.Forms.Appearance").Button
			btn.Name = "swatchButton_" + i as string
			btn.Size = dotNetObject "System.Drawing.Size" maxButtonSize maxButtonSize
			btn.FlatStyle = btn.FlatStyle.Flat
			btn.FlatAppearance.BorderSize = 0
			btn.BackColor = (dotNetClass "System.Drawing.Color").FromArgb colorPalette[i].r colorPalette[i].g colorPalette[i].b
			grpSwatchButtons.Controls.Add btn
		)
		if rdoGenerationType.state == 1 then
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
			FormatLog ("Generated Button | " + ddlRows.Selected + " x " + ddlColumns.Selected)
			paletteBox.Height = grpSwatchButtons.Height + 24	
			VoxelMachineUI.Height = paletteSettings.height + swatchButtonHeight + paletteBox.height + 16
		)	
		else
		(
			i = 0
			for x = 0 to (sqrt(colorPalette.Count)-1) do
			(
				for y = 0 to (sqrt(colorPalette.Count)-1) do
				(
					grpSwatchButtons.Controls.Item[i].Left = (x * grpSwatchButtons.Controls.Item[i].Width)
					grpSwatchButtons.Controls.Item[i].Top = (y * grpSwatchButtons.Controls.Item[i].Height)
					i += 1
				)			
				if i == colorPalette.count do exit
			)
			FormatLog ("Generated Button | " + (sqrt(colorPalette.Count) as string) + " x " + (sqrt(colorPalette.Count) as string))
			paletteBox.Height = grpSwatchButtons.Height + 24	
			VoxelMachineUI.Height = paletteSettings.height + swatchButtonHeight + paletteBox.height + 16
		)		
	)
)
createDialog VoxelMachineUI





