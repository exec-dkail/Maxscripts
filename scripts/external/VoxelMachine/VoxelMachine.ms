fn SafeLoadBitmap filename = 
(
	oBitmap = openBitmap filename
	nBitmap = copy oBitmap
	close oBitmap
	return nBitmap
)
fn GetSwatches filename = 
(
	bitmp = SafeLoadBitmap filename
	bitmapColorData = #()
	for x = 0 to bitmp.Width-1 do
	(
		for y = 0 to bitmp.Height-1 do
		(
			Append bitmapColorData (GetPixels bitmp [x,y] 1)[1]
		)
	)
	return bitmapColorData
)
try(maxform.Close())catch()
maxform = dotnetObject "MaxCustomControls.MaxForm"
maxform.Size = dotNetObject "System.Drawing.Size" 208 300	
maxform.MinimumSize = dotNetObject "System.Drawing.Size" 208 300
maxform.TopMost = true
colorPallete = GetSwatches @"D:\TechArt\Max\MyTools\VoxelMaker\Swatch.png"
fn GetBitmap clr =
(
	btmp = dotNetObject "System.Drawing.Bitmap" 24 24
	for x = 0 to 23 do
	(
		for y = 0 to 23 do
		(
			btmp.SetPixel x y ((dotNetClass "System.Drawing.Color").FromArgb clr.r clr.g clr.b)
		)
	)
	return btmp
)		
fn OnClick obj e =
(	
	colr = obj.BackColor
	format "R : %\nG : %\nB : %\n" colr.r colr.g colr.b
	Box width:10 height:10 length:10 wirecolor:(color colr.r colr.g colr.b)
)
fn GenerateSwatchButtons =
(	
	
	for i = 1 to colorPallete.count do
	(
		btn = dotNetObject "Button"
		btn.Name = "swatchButton_" + i as string
		btn.Width = 24
		btn.Height = 24
		btn.FlatStyle = btn.FlatStyle.Flat
		btn.FlatAppearance.BorderSize = 0
		btn.BackColor = (dotNetClass "System.Drawing.Color").FromArgb colorPallete[i].r colorPallete[i].g colorPallete[i].b	
		dotnet.addEventHandler btn "Click" OnClick
		maxform.Controls.Add btn
	)
	maxCount = maxform.Controls.Count
	rows = 9
	columns = 1
	i = 0
	for x = 0 to rows do
	(
		for y = 0 to columns do
		(
			if (findString maxform.Controls.Item[i].Name "swatchButton") != undefined do
			(
				maxform.Controls.Item[i].Left = (x * maxform.Controls.Item[i].Width)
				maxform.Controls.Item[i].Top = (y * maxform.Controls.Item[i].Height)
			)
			i += 1
		)		
		if i == maxCount do exit
	)	
)
GenerateSwatchButtons()
maxform.Show()
