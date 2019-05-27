(
	try(VMSetting_UI.Close())catch()
		
	local VMSetting_UI = dotNetObject "MaxCustomControls.MaxForm"
	local grpPaletteSetting = dotNetObject "System.Windows.Forms.GroupBox"	
	local label1 = dotNetObject "System.Windows.Forms.Label"	
	local numPaletteWidth = dotNetObject "System.Windows.Forms.NumericUpDown"
	local label2 = dotNetObject "System.Windows.Forms.Label"	
	local numPaletteHeight = dotNetObject "System.Windows.Forms.NumericUpDown"    
	local txtBrowsePaletteImage = dotNetObject "System.Windows.Forms.TextBox"
	local btnBrowsePaletteImage = dotNetObject "System.Windows.Forms.Button"
	local btnSetPaletteSettings = dotNetObject "System.Windows.Forms.Button"
	local paletteBrowser = dotNetObject "System.Windows.Forms.OpenFileDialog"
	
	local imageData = #()
	local paletteFileName = ""

	fn OnSetPaletteSettings_Click o e =
	(	
		
	)
	fn OnBrowserPaletteImage_Click o e =
	(
		if (paletteBrowser.ShowDialog() == ((dotNetClass "System.Windows.Forms.DialogResult").OK)) do
		(
			paletteFileName = paletteBrowser.FileName;
		)
		if ((dotNetClass "System.IO.File").Exists paletteFileName) do
		(
			txtBrowsePaletteImage.Text = (dotNetClass "System.IO.Path").GetFileName paletteFileName
		)
	)
	function InitializeComponent this =
	(	
		this.Size = dotNetObject "System.Drawing.Size" 188 174
		this.Text = "Palette Settings"
		this.Name = "VM_PaletteSettings"
		this.FormBorderStyle = this.FormBorderStyle.FixedToolWindow
		this.BackColor =( dotNetClass "System.Drawing.Color").FromArgb 68 68 68
		this.ClientSize = dotNetObject "System.Drawing.Size" 172 135
		this.TopMost = true
		
		-- Label settings
		label1.AutoSize = true
		label1.ForeColor = (dotNetClass "System.Drawing.Color").White
		label1.Location = dotNetObject "System.Drawing.Point" 9 23
		label1.Name = "label1"
		label1.Size = dotNetObject "System.Drawing.Size" 71 13
		label1.TabIndex = 0
		label1.Text = "Palette Width"
				
		label2.AutoSize = true
		label2.ForeColor = (dotNetClass "System.Drawing.Color").White
		label2.Location = dotNetObject "System.Drawing.Point" 9 44
		label2.Name = "label2"
		label2.Size = dotNetObject "System.Drawing.Size" 74 13
		label2.TabIndex = 0
		label2.Text = "Palette Height"
		
		-- Textbox settings
		
		txtBrowsePaletteImage.ForeColor = (dotNetClass "System.Drawing.Color").Black
		txtBrowsePaletteImage.Location = dotNetObject "System.Drawing.Point" 12 71
		txtBrowsePaletteImage.Name = "txtBrowsePaletteImage"
		txtBrowsePaletteImage.Size = dotNetObject "System.Drawing.Size" 112 20
		txtBrowsePaletteImage.TabIndex = 3
				
		-- NumericUpDown Settings
		numPaletteWidth.ForeColor = (dotNetClass "System.Drawing.Color").Black
		numPaletteWidth.Location = dotNetObject "System.Drawing.Point" 97 19
		numPaletteWidth.Name = "numPaletteWidth"
		numPaletteWidth.Size = dotNetObject "System.Drawing.Size" 58 20
		numPaletteWidth.TabIndex = 1
		numPaletteWidth.Value = 4
		
		numPaletteHeight.ForeColor = (dotNetClass "System.Drawing.Color").Black
		numPaletteHeight.Location = dotNetObject "System.Drawing.Point" 97 41
		numPaletteHeight.Name = "numPaletteHeight"
		numPaletteHeight.Size = dotNetObject "System.Drawing.Size" 58 20
		numPaletteHeight.TabIndex = 2
		numPaletteHeight.Value = 4
		
		--GroupBox Settings
		grpPaletteSetting.Text = "Palette Settings"
		grpPaletteSetting.ForeColor = (dotNetClass "System.Drawing.Color").White
		grpPaletteSetting.Location = dotNetObject "System.Drawing.Point" 2 0
		grpPaletteSetting.Size = dotNetObject "System.Drawing.Size" 167 133
		
		-- Button setting
		btnBrowsePaletteImage.ForeColor = (dotNetClass "System.Drawing.Color").Black
		btnBrowsePaletteImage.Location = dotNetObject "System.Drawing.Point" 130 70
		btnBrowsePaletteImage.Name = "btnBrowsePaletteImage"
		btnBrowsePaletteImage.Size = dotNetObject "System.Drawing.Size" 25 21
		btnBrowsePaletteImage.TabIndex = 4
		btnBrowsePaletteImage.Text = "..."
		btnBrowsePaletteImage.UseVisualStyleBackColor = true
		
		btnSetPaletteSettings.ForeColor = (dotNetClass "System.Drawing.Color").Black
		btnSetPaletteSettings.Location = dotNetObject "System.Drawing.Point" 12 97
		btnSetPaletteSettings.Name = "btnSetPaletteSettings"
		btnSetPaletteSettings.Size = dotNetObject "System.Drawing.Size" 143 28
		btnSetPaletteSettings.TabIndex = 5
		btnSetPaletteSettings.Text = "Set Palette Settings"
		btnSetPaletteSettings.UseVisualStyleBackColor = true
		
		-- GroupBox Settings
		grpPaletteSetting.Controls.Add numPaletteWidth
		grpPaletteSetting.Controls.Add numPaletteHeight
		grpPaletteSetting.Controls.Add label1
		grpPaletteSetting.Controls.Add label2
		grpPaletteSetting.Controls.Add btnBrowsePaletteImage
		grpPaletteSetting.Controls.Add btnSetPaletteSettings
		grpPaletteSetting.Controls.Add txtBrowsePaletteImage
		this.Controls.Add grpPaletteSetting
		
		-- Palette Browser Settings
		paletteBrowser.Filter = "PNG Image | *.png"
		
		-- Events 
		dotnet.addEventHandler btnBrowsePaletteImage "Click" OnBrowserPaletteImage_Click
		dotnet.addEventHandler btnSetPaletteSettings "Click" OnSetPaletteSettings_Click
	)
	InitializeComponent VMSetting_UI
	VMSetting_UI.Show()
)
