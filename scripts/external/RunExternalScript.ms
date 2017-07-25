/*
Custom Tool
-----------------------------------------
Add Downloaded Scripts to List and Run
-----------------------------------------
FIXED :
While drag and drop event is called it checks for special characters and removes it
When changing script name it checks for Regular Expression and disables if any special character is pressed except underscore or hyphen.
Script image calls from UserIcons.
*/
try(destroyDialog CM_KL_ExternalTool)catch()
rollout CM_KL_ExternalTool "External Tools" width:200 height:300
(
	local scriptDataFile = (getDir #userscripts + @"\CM_KL_VehicleTool_ExternalScriptXML.xml")	
	local imageFile = (getDir #userIcons + @"\CM_KL_VehicleTool_ExternalScriptIcon.png")
	
	local scriptName = #()	
	local Cursor = dotnetClass "System.Windows.Forms.Cursor"
	local ContextMenuStrip = dotnetObject "System.Windows.Forms.ContextMenuStrip"
	local ImageList = dotNetObject "System.Windows.Forms.ImageList"
	local changeScriptName_MenuButton = dotnetClass "System.Windows.Forms.ToolStripItem"
	local changeScriptPath_MenuButton = dotnetClass "System.Windows.Forms.ToolStripItem"
	local delScript_MenuButton = dotnetClass "System.Windows.Forms.ToolStripItem"
	local delAllScript_MenuButton = dotnetClass "System.Windows.Forms.ToolStripItem"
	
	local txtBox_Padding = 2.5
	local txtBox = dotNetObject "System.Windows.Forms.TextBox"
	local xmlDoc = dotNetObject "System.XML.XMLDocument"
		
	dotNetControl scriptListView "System.Windows.Forms.ListView" pos:[0,0] width:CM_KL_ExternalTool.width height:CM_KL_ExternalTool.height
	
	--XML Create, Read, Write, Replace and Delete Functions
	function createXML =
	(
		if not doesFileExist scriptDataFile then
		(
			root=xmlDoc.createElement "ScriptFiles"
			xmlDoc.appendChild root
			xmlDoc.Save scriptDataFile		
		)
	)	
	function readXMLData =
	(
		try
		(
			createXML()
			xmlDoc.Load scriptDataFile
			rEle = xmlDoc.DocumentElement.Name
			rNode = xmlDoc.SelectNodes rEle
			fNames = for i = 0 to (rNode.ItemOf[0].ChildNodes.Count-1) collect
			(
				rNode.ItemOf[0].ChildNodes.ItemOf[i].GetAttribute"Name"
			)
			return fNames
		)catch()
	)
	function addXMLData filename filepath =
	(
		try
		(
			createXML()
			xmlDoc.Load scriptDataFile
			root=xmlDoc.DocumentElement
			for i = 1 to filename.count do
			(
				newElement=xmlDoc.createElement filename[i]
				newElement.setAttribute "Name" "" filename[i]
				newElement.InnerXML = filepath[i]
				root.appendChild newElement
			)
			xmlDoc.Save scriptDataFile
		)catch()
	)
	function removeXMLData filename =
	(
		try
		(
			createXML()
			xmlDoc.Load scriptDataFile
			rEle = (xmlDoc.DocumentElement.Name+"/*[@Name='"+filename+"']")
			rNode = xmlDoc.SelectNodes rEle 
			rNode.ItemOf[0].ParentNode.RemoveChild rNode.ItemOf[0]
			xmlDoc.Save scriptDataFile
		)catch()
	)
	function removeAllXMLData =
	(
		try
		(
			createXML()
			xmlDoc.Load scriptDataFile
			rEle = (xmlDoc.DocumentElement.Name+"/*")
			rNode = xmlDoc.SelectNodes rEle 
			for i = 0 to rNode.Count-1 do
			(
				rNode.ItemOf[i].ParentNode.RemoveChild rNode.ItemOf[i]
			)
			xmlDoc.Save scriptDataFile
		)catch()
	)
	function replaceXMLData filename filepath newFilename =
	(
		try
		(
			createXML()
			xmlDoc.Load scriptDataFile
			rEle = (xmlDoc.DocumentElement.Name+"/*[@Name='"+filename+"']")
			rNode = xmlDoc.SelectNodes rEle
			nNode = xmlDoc.CreateNode (dotNetClass "System.Xml.XmlNodeType").Element (substituteString newFilename " " "") ""
			nNode.setAttribute "Name" "" newFilename
			nNode.InnerXML = filepath
			rNode.ItemOf[0].ParentNode.ReplaceChild nNode rNode.ItemOf[0]
			xmlDoc.Save scriptDataFile
		)catch()
	)
	function getData nodeString:unsupplied searchItem:unsupplied =
	(
		try(createXML())catch()
		xmlDoc.Load scriptDataFile
		if nodeString != unsupplied do
		(
			rEle = (xmlDoc.DocumentElement.Name+"/*")
			rNode = xmlDoc.SelectNodes rEle	
			theFiles = for i = 0 to rNode.count-1 collect
			(
				rNode.ItemOf[i].InnerXML
			)
			fIndex = findItem theFiles nodeString
			if fIndex != 0 then
			(
				return true
			)
			else
			(
				return false
			)
		)
		if searchItem != unsupplied do
		(
			rEle = (xmlDoc.DocumentElement.Name+"/*[@Name='"+searchItem+"']")
			rNode = xmlDoc.SelectNodes rEle	
			theFiles = for i = 0 to rNode.count-1 collect
			(
				rNode.ItemOf[i].InnerXML
			)
			if theFiles[1] != undefined then
			(
				return theFiles[1]
			)
			else
			(
				return false
			)
		)
	)
	function getName scrName =
	(
		try(createXML())catch()
		xmlDoc.Load scriptDataFile
		rEle = (xmlDoc.DocumentElement.Name+"/*")
		rNode = xmlDoc.SelectNodes rEle	
		theFiles = for i = 0 to rNode.count-1 collect
		(
			rNode.ItemOf[i].GetAttribute"Name"
		)		
		fIndex = findItem theFiles scrName
		if fIndex != 0 then
		(
			return true
		)
		else
		(
			return false
		)
	)	
	--Main Function to Change Data to ListView
	function changeData type:unsupplied =
	(
		try
		(
			if type == "Name" then
			(
				newName = txtBox.Text
				existName = getName newName
				if newName != "" and newName != (scriptListView.SelectedItems.Item[0].SubItems.Item[1].Text) and existName != true then
				(
					scrName
					replaceXMLData (scriptListView.SelectedItems.Item[0].SubItems.Item[1].Text) (getData searchItem:(scriptListView.SelectedItems.Item[0].SubItems.Item[1].Text)) newName
					scriptListView.SelectedItems.Item[0].SubItems.Item[1].Text = txtBox.Text
				)
			)
			if type == "Path" then
			(
				newScriptPath = getOpenFileName caption:"Select a new script file" types:"Maxscript Files(*.ms , *.mcr , *.mse) |*.ms;*.mcr;*.mse"		
				existFile = getData nodeString:newScriptPath			
				if newScriptPath != undefined and existFile == false then
				(
					replaceXMLData (scriptListView.SelectedItems.Item[0].SubItems.Item[1].Text) newScriptPath (scriptListView.SelectedItems.Item[0].SubItems.Item[1].Text)
				)
			)
		)catch()
	)		
	--Initialize ListView
	function initLv theLv =
	(
		
		theLv.AllowDrop = true
		theLv.FullRowSelect = true
		theLv.MultiSelect = false
		theLv.TabIndex = 0
		theLv.View = (dotNetClass "System.Windows.Forms.View").Details
		theLv.gridlines = true
		theLv.BackColor = (dotNetClass "System.Drawing.Color").FromArgb 230 230 230
		img = dotNetObject "System.Drawing.Bitmap" imageFile
		ImageList.ColorDepth = (dotNetClass"System.Windows.Forms.ColorDepth").Depth32Bit
		ImageList.ImageSize = dotNetObject "System.Drawing.Size" 24 24		
		--Adds Images to IMAGELIST	
		ImageList.Images.Add(img)			
		--Adds IMAGELIST to the LISTVIEW
		theLv.SmallImageList = ImageList
	)		
	function addColumns theLv =
	(
		theLv.columns.add "#" 34 (dotNetClass "System.Windows.Forms.HorizontalAlignment").Left
		theLv.columns.add "Scripts" (theLv.width-((dotNetClass "System.Windows.Forms.SystemInformation").VerticalScrollBarWidth)-38) (dotNetClass "System.Windows.Forms.HorizontalAlignment").Left
	)	
	--Textbox Events
	function onKeyPress e =
	(
		regEx = dotnetObject "System.Text.RegularExpressions.Regex" "^[a-zA-Z0-9-_\b\s]*$"
		if regEx.IsMatch e.KeyChar != true then
		(
			e.Handled = true
		)
		else
		(
			e.Handled = false
		)		
	)
	function onKeyUp e =
	(
		if (e.KeyCode == e.KeyCode.Enter or e.KeyCode == e.KeyCode.Return) then
		(
			changeData type:"Name"
			txtBox.Visible = false
		)
	)
	function onLostFocus e =
	(
		changeData type:"Name"
		txtBox.Visible = false
	)	
	--Initialize Textbox 
	function initTextBox theLv=
	(
		theLv.Controls.Add txtBox
		txtBox.Width = theLv.SelectedItems.Item[0].SubItems.Item[1].Bounds.Width
		txtBox.Height = theLv.SelectedItems.Item[0].SubItems.Item[1].Bounds.Height
		txtBox.Location.X = theLv.SelectedItems.Item[0].SubItems.Item[1].Bounds.Left
		txtBox.Location.Y = (theLv.SelectedItems.Item[0].SubItems.Item[1].Bounds.Top)+txtBox_Padding
		txtBox.Font = dotNetObject "System.Drawing.Font" "Microsoft Sans Serif" 8		
		txtBox.Visible = true
		txtBox.BringToFront()
		txtBox.Focus()
		txtBox.Text = theLv.SelectedItems.Item[0].SubItems.Item[1].Text
		txtBox.Select()
		txtBox.SelectAll()
		dotnet.addEventHandler txtBox "KeyUP" onKeyUp
		dotnet.addEventHandler txtBox "LostFocus" onLostFocus
		dotnet.addEventHandler txtBox "KeyPress" onKeyPress 
	)	
	-- ListView Functions
	function addFilesToList theLv items = 
	(	
		theLv.BeginUpdate()	
		ListViewItem = dotNetObject "System.Windows.Forms.ListViewItem"
		ListViewItem.ImageIndex = 0
		ListViewItem.SubItems.Add(items)
		if not theLv.Items.Contains(ListViewItem) then
		(
			theLv.Items.Add(ListViewItem)
		)
		theLv.EndUpdate()
	)
	function addInitialData theLv =
	(
		scriptName = readXMLData()
		if scriptName.count > 0 then
		(
			for i = 1 to scriptName.count do
			(
				addFilesToList scriptListView scriptName[i]
			)
		)
	)	
	--MenuBox Events
	function changeScriptName =
	(		
		initTextBox scriptListView
		changeData type:"Name"
	)
	function changeScriptPath =
	(
		changeData type:"Path"
	)
	function delScript =
	(
		scrName = (scriptListView.SelectedItems.Item[0].SubItems.Item[1].Text)
		removeXMLData (scriptListView.SelectedItems.Item[0].SubItems.Item[1].Text)
		scriptListView.Items.Clear()
		addInitialData scriptListView
	)
	function delAllScript =
	(
		If QueryBox "Do You Want to Delete All the Scripts\nPress Yes To Continue" beep:true then
		(
			scriptListView.Items.Clear()
			removeAllXMLData()
		)
	)
	function openExplorer =
	(
		thePath = getData searchItem:(scriptListView.SelectedItems.Item[0].SubItems.Item[1].Text)
		ShellLaunch (getFileNamePath thePath) ""
	)
	function openTextEditor =
	(
		thePath = getData searchItem:(scriptListView.SelectedItems.Item[0].SubItems.Item[1].Text)
		ShellLaunch "notepad.exe" (thePath)
	)	
	-- Initialize MenuBox 
	function initMenuStrip contextMenuStrip =
	(		
		changeScriptName_MenuButton = ContextMenuStrip.Items.Add("Change Script Name   ")
		changeScriptName_MenuButton.ShortcutKeyDisplayString = "F2"
		changeScriptPath_MenuButton = ContextMenuStrip.Items.Add("Change Script Path   ")	
		changeScriptPath_MenuButton.ShortcutKeyDisplayString = "F12"		
		ContextMenuStrip.Items.Add("-")			
		delScript_MenuButton = ContextMenuStrip.Items.Add("Delete Script   ")		
		delScript_MenuButton.ShortcutKeyDisplayString = "Del"		
		delAllScript_MenuButton = ContextMenuStrip.Items.Add("Delete All Script   ")
		delAllScript_MenuButton.ShortcutKeyDisplayString = "Shift+Del"	
		ContextMenuStrip.Items.Add("-")		
		openExplorer_MenuButton = ContextMenuStrip.Items.Add("Open in File Explorer   ")
		openExplorer_MenuButton.ShortcutKeyDisplayString = "Ctrl+O"		
		openTextEditor_MenuButton = ContextMenuStrip.Items.Add("Open in Text Editor   ")
		openTextEditor_MenuButton.ShortcutKeyDisplayString = "Ctrl+T"
		
		dotnet.addEventHandler changeScriptName_MenuButton "Click" changeScriptName
		dotnet.addEventHandler changeScriptPath_MenuButton "Click" changeScriptPath
		dotnet.addEventHandler delScript_MenuButton "Click" delScript
		dotnet.addEventHandler delAllScript_MenuButton "Click" delAllScript
		dotnet.addEventHandler openExplorer_MenuButton "Click" openExplorer
		dotnet.addEventHandler openTextEditor_MenuButton "Click" openTextEditor
	)
	--Form Open Event
	on CM_KL_ExternalTool open do
	(
		initLv scriptListView
		initMenuStrip ContextMenuStrip
		addColumns scriptListView
		addInitialData scriptListView
	)
	on CM_KL_ExternalTool close do
	(
		gc()
	)
	--ListView ColumnWidthChanging Event
	on scriptListView ColumnWidthChanging e do 
	(
		if e.ColumnIndex == 0 then
		(
			e.NewWidth = 34
		)
		if e.ColumnIndex == 1 then
		(
			e.NewWidth = (scriptListView.width-((dotNetClass "System.Windows.Forms.SystemInformation").VerticalScrollBarWidth)-38)
		)
		e.Cancel = true
	)	
	--ListView Mouse Event
	on scriptListView MouseUp e do 
	(
		if e.Button == e.Button.Right do
		(
			if (scriptListView.SelectedItems.Count) != 0 then
			(				
				scriptListView.ContextMenuStrip = ContextMenuStrip
				ContextMenuStrip.Show(Cursor.Position)
			)
			else
			(
				scriptListView.ContextMenuStrip = dotNetObject "System.Windows.Forms.ContextMenuStrip"
			)
		)
	)	
	on scriptListView DoubleClick e do
	(
		try(filein (getData searchItem:(scriptListView.SelectedItems.Item[0].SubItems.Item[1].Text)))catch()
	)	
	--ListView Key Events
	on scriptListView KeyDown e do
	(
		if e.KeyCode == e.KeyCode.F2 then
		(
			changeScriptName()
		)
		if e.KeyCode == e.KeyCode.F12 then
		(
			changeScriptPath()
		)
		if e.KeyData.ToString() == "Delete" then
		(
			if scriptListView.SelectedItems.Count > 0 then
			(
				delScript()
			)
		)
		if e.KeyData.ToString() == "Delete, Shift" then
		(
			delAllScript()
		)
		if e.KeyData.ToString() == "O, Control" then
		(
			openExplorer()
		)
		if e.KeyData.ToString() == "T, Control" then
		(
			openTextEditor()
		)
	)
	--ListView Drag and Drop Files Event
	on scriptListView DragEnter e do
	(
		 if e.Data.GetDataPresent((dotNetClass"System.Windows.DataFormats").FileDrop) do
		(
			e.Effect = (dotNetClass "System.Windows.Forms.DragDropEffects").Copy
		)
	)	
	on scriptListView DragDrop e do 
	(
		filename = #()
		filepath = #()		
		files = (e.Data.GetData((dotNetClass"System.Windows.DataFormats").FileDrop))
		regEx = dotnetObject "System.Text.RegularExpressions.Regex" "[$&+,:;=?@#|'<>.^*()%!]"
		for i in files do
		(
			existFile = getData nodeString:i
			if getFileNameType i == ".ms" or getFileNameType i == ".mcr" or getFileNameType i == ".mse" do
			(
				if not existFile do
				(
					if scriptListView.FindItemWithText(getFileNameFile i) == undefined do
					(
						fname = regEx.Replace (getFileNameFile i) ""
						addFilesToList scriptListView fName
						AppendIfUnique filename fName
						AppendIfUnique filepath i
					)
				)
			)			
		)
		if filename[1] != undefined and filepath[1] != undefined do
		(
			addXMLData filename filepath
		)
	)
	
)
createDialog CM_KL_ExternalTool
