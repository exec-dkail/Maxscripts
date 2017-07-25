/*
*****************************************************************************************
KL VEHICLE TOOL
*****************************************************************************************
Contents :
		LOD Selection
			Select LOD	
			
		Materials
			Apply Materials for COLOR ID
			
		Naming Tool
			Check Names for the all objects
			Set name to object		
			
		Pivots
			Set Pivots To World Center
			Set Pivots To Object Center
			Set Pivots To Face Center
			Set Pivots To Face Local	
			
		Asset Tracker
			Change Texture Path from Asset Tracker	
			
		Vertex Colors
			Change,View and Remove Vertex Colors	
			
		Common
			Check Smooting & Non Quad
			Check and Auto Fix Wrong Layers
			MIrror WingMirrors and Auto Fix ID
			Unhide All Faces of all Objects
			Reset XFORM for all Objects
			Force Reset XForm
			Camera to UV Projection
			Custom Script Tool	
			
		Perforce
			Checkout Current Max File
			Checkin Current Max File
			Create a Startup Auto Run for Selected Folder
			
		UV
			Hide ID on Mesh and UV
			Render ID
			Render Channel
			Render Mask	
			
		LOD
			Copy Selected to Next LOD
			Fix All LOD's Pivots to x0
			Show Count on Object Selected
			Show All LOD Count
			
		Project Settings
			Change Project Settings
			
*****************************************************************************************
WORK IN PROGRESS
*****************************************************************************************
UV
	View UV : Mesh ID with UV Channel together
	Render UV : Mesh ID with UV Channel together
*****************************************************************************************
Author : Kailash Diengdoh		
Email : kailash.diengdoh@outlook.com | kailash.diengdoh@codemasters.com
*****************************************************************************************
*/
--Script starts here
--userFolder
CURRENT_USER_SETTINGS = (getDir #maxData + @"\CM_KL_VehicleTool_Settings.ini")
--Get Save INI Settings 
function LoadINI iniFile ini_section:unsupplied ini_keys:unsupplied =
(
	if ini_section == unsupplied and ini_keys == unsupplied then
	(
		theVal = getINISetting iniFile
		return theVal
	)
	else
	(
		theVal = getINISetting iniFile ini_section ini_keys
		return theVal
	)
)
function SaveINI iniFile ini_section:unsupplied ini_keys:unsupplied ini_value:unsupplied =
(
	if ini_section == unsupplied and ini_keys == unsupplied then
	(
		setINISetting iniFile
	)
	else
	(
		setINISetting iniFile ini_section ini_keys ini_value
	)
)
--Set Project in Local User Folder
function setProjects userFile project = 
(
	SaveINI userFile ini_section:"CURRENT_PROJECT" ini_keys:"ProjectName" ini_value:project
)
function breakStringToArray str =
(
	newArr = filterString str ","  
	return newArr
)

--Initialize Projects and Settings
PROJECT_SETTINGS_DIR = (getFileNamePath(getThisScriptFilename()))
CM_KL_PROJECT_SELECTED = undefined 
CM_KL_PROJECT_SETTINGS = undefined
	
--Rollout width and height
initializeRolloutDimensions = [220,330]	

--Project Select
try(destroyDialog CM_KL_VehicleTool_ProjectSettings)catch()
rollout CM_KL_VehicleTool_ProjectSettings "Load Project Settings" width:216 height:88
(
	dropDownList projectList "Project" pos:[8,8] width:200 height:10
	button btn_loadProject "Load Project" pos:[16,56] width:184 height:24		
	on CM_KL_VehicleTool_ProjectSettings open do
	(		
		projects = LoadINI (PROJECT_SETTINGS_DIR +"CM_KL_VehicleTools_ProjectSettings.ini")
		projectList.items = projects
	)
	on btn_loadProject pressed do
	(
		CM_KL_PROJECT_SELECTED = projectList.selected
		CM_KL_PROJECT_SETTINGS = PROJECT_SETTINGS_DIR + (LoadINI (PROJECT_SETTINGS_DIR+"CM_KL_VehicleTools_ProjectSettings.ini") ini_section:CM_KL_PROJECT_SELECTED ini_keys:"INISettingFile")			
		if queryBox ("Changing Project Settings to : "+ CM_KL_PROJECT_SELECTED + "\n\nPress Yes to Continue") beep:true title:"Project Change" then
		(
			setProjects CURRENT_USER_SETTINGS CM_KL_PROJECT_SELECTED
			try
			(
				destroyDialog CM_KL_VehicleTool_ProjectSettings
			)catch()
			createDialog CM_KL_VehicleTool
		)
	)		
)
--Main Tool Start
try(destroyDialog CM_KL_VehicleTool)catch()
rollout CM_KL_VehicleTool ("Vehicle Tool | "+CM_KL_PROJECT_SELECTED) width:initializeRolloutDimensions[1] height:initializeRolloutDimensions[2]
(	
	subRollout CM_KL_VehicleTool_SubTool width:(initializeRolloutDimensions[1]) height:(initializeRolloutDimensions[2]) pos:[0,0]
	
	--Calling all scripts from the script folder as a local scope function using ::
	function loadScript =
	(
		clearListener()
		scrDir = (PROJECT_SETTINGS_DIR + "scripts")
		scrFiles = getFiles (scrDir+@"\*.ms")
		for i in scrFiles do
		(
			fileIn i
			format "Script Loaded from : %\n" i
		)
	)
	
	local rollPadding = 4
	local lodList
	local isSeperateTyreLayer
	local curLODSel	
	local tyresArr
	
	rollout CM_KL_VehicleTool_Selection "Selection" rolledup:false
	(
		dropdownList ddl_lodList "" pos:[8,8] width:175 height:21
		dropdownList ddl_tyreList "Tyres" pos:[8,32] width:192 height:5
		checkbox chkAutoSelect "" pos:[188,10] width:14 height:16
		
		on CM_KL_VehicleTool_Selection open do
		(
			lodList = LoadINI CM_KL_PROJECT_SETTINGS ini_section:"LOD_LIST" ini_keys:"Value"
			lodList = breakStringToArray lodList			
			tyreList = LoadINI CM_KL_PROJECT_SETTINGS ini_section:"TYRES" ini_keys:"Value"
			ddl_lodList.items = lodList		
			if tyreList[1] != undefined then
			(
				tyreList = breakStringToArray tyreList
				ddl_tyreList.items = tyreList
				ddl_tyreList.enabled = true
				isSeperateTyreLayer = true
				tyresArr = tyreList
			)
			else
			(
				ddl_tyreList.enabled = false
				isSeperateTyreLayer = false
			)
			curLODSel = ddl_lodList.selected
		)
		on ddl_lodList selected sel do
		(
			try
			(
				if chkAutoSelect.checked == true and ddl_tyreList.enabled == true do
				(
					::selectLOD ddl_lodList.selected tyre:ddl_tyreList.selected
				)
				if chkAutoSelect.checked == true and ddl_tyreList.enabled == false do
				(
					::selectLOD ddl_lodList.selected
				)				
				curLODSel = ddl_lodList.selected
			)
			catch()
		)
		on ddl_tyreList selected sel do
		(
			try
			(
				if chkAutoSelect.checked != false and ddl_tyreList.enabled != false then
				(
					::selectLOD ddl_lodList.selected tyre:ddl_tyreList.selected
				)				
				curLODSel = ddl_lodList.selected
			)
			catch()
		)		
		--The Expand and Collapse State
		on CM_KL_VehicleTool_Selection rolledUp bState do
		(
			if (bState == true) then
			(
				CM_KL_VehicleTool.height += CM_KL_VehicleTool_Selection.height
				CM_KL_VehicleTool_SubTool.height += CM_KL_VehicleTool_Selection.height
				CM_KL_VehicleTool.height += rollPadding
			)
			else
			(
				CM_KL_VehicleTool.height -= CM_KL_VehicleTool_Selection.height
				CM_KL_VehicleTool_SubTool.height -= CM_KL_VehicleTool_Selection.height
				CM_KL_VehicleTool.height -= rollPadding
			)								
		)
	)
	rollout CM_KL_VehicleTool_Naming "Naming" rolledup:true	
	(
		dropdownList partList "Part Name" pos:[8,8] width:192 height:20				
		button btn_detachRename "Detach and Rename" pos:[8,56] width:192 height:24
		button btn_renameObj "Rename Object" pos:[8,80] width:192 height:24
		button btn_checkNames "Check Names" pos:[8,104] width:192 height:24	
		
		local xmlFile = undefined
		local xmlDoc= dotNetObject "system.xml.xmlDocument"	
		local errorObjects = #()
		local objectNaming =#()
		
		rollout invalidNaming "Object with Invalid Names" width:208 height:368
 		(
			multilistbox list_invalidNaming "Object with Invalid Names" pos:[8,8] width:192 height:23
			button btn_selectObject "Select Objects" pos:[8,336] width:192 height:24
			
			local newObjectToSelect = #()
			local newList = #()
			
			on invalidNaming open do
 			( 	
				for i = 1 to errorObjects.count do
				(
					newList[i] = errorObjects[i].name
				)
				list_invalidNaming.items = newList
 			)
			on list_invalidNaming doubleClicked clicked do
			(
				selectedObj =  list_invalidNaming.selection  as array
				for i = 1 to selectedObj.count do
				(
					select (getNodeByName(list_invalidNaming.items[selectedObj[i]]))
				)
			)
			on btn_selectObject pressed do
			(
				selectedObj =  list_invalidNaming.selection  as array
				for i = 1 to selectedObj.count do
				(
					selectmore (getNodeByName(list_invalidNaming.items[selectedObj[i]]))
				)
			)
 		)		
		on btn_renameObj pressed do
		(
			undo on
			(
				if selection.count == 1 do
				(
					::renameObject $ (curLODSel+"_"+partList.selected) selType:"Whole"
				)
			)
		)
		on btn_detachRename pressed do
		(
			undo on
			(
				if selection.count == 1 do
				(
					::renameObject  $ (curLODSel+"_"+partList.selected) selType:"Selection"
				)
			)
		)
		on btn_checkNames pressed do
		(
			undo on
			(
				if (doesFileExist xmlFile) then
				(
					errorObjects = ::checkNames xmlFile
				)
				else 
				(
					MessageBox "No XML File Found"
				)
					
				if errorObjects[1] != undefined then
				(
					try(destroyDialog invalidNaming)catch()
					createDialog invalidNaming
				)
				else
				(
					MessageBox "All Object Naming are Correctly Assigned" title:"NAMING_CORRECT"
				)
			)
		)
		on CM_KL_VehicleTool_Naming open do
		(
			xmlFile = PROJECT_SETTINGS_DIR + (LoadINI CM_KL_PROJECT_SETTINGS ini_section:"NAMING_XML" ini_keys:"Path")
			if doesFileExist xmlFile then
			(
				objectNaming = ::getDataFromXML xmlFile
			)
			else
			(
				MessageBox "No XML File Found"
			)
			if objectNaming[1] != undefined then
			(
				partList.items = objectNaming
			)
		)		
		
		--The Expand and Collapse State
		on CM_KL_VehicleTool_Naming rolledUp bState do
		(
			if (bState == true) then
			(
				CM_KL_VehicleTool.height += CM_KL_VehicleTool_Naming.height
				CM_KL_VehicleTool_SubTool.height += CM_KL_VehicleTool_Naming.height
				CM_KL_VehicleTool_SubTool.height += rollPadding
				CM_KL_VehicleTool.height += rollPadding
			)
			else
			(
				CM_KL_VehicleTool.height -= CM_KL_VehicleTool_Naming.height
				CM_KL_VehicleTool_SubTool.height -= CM_KL_VehicleTool_Naming.height
				CM_KL_VehicleTool_SubTool.height -= rollPadding
				CM_KL_VehicleTool.height -= rollPadding
			)
		)
	)
	rollout CM_KL_VehicleTool_Pivot "Pivots" rolledup:true
	(
		radiobuttons pivotOption "" pos:[16,8] width:176 height:32 labels:#("World Center", "Object Center", "Face Center", "Face Local") default:1 columns:2
		button btn_setPivot "Set Pivot" pos:[8,48] width:192 height:24
		
		on btn_setPivot pressed do
		(
			undo on
			(
				case (pivotOption.state) of
				(
					1:
					(
						::pivotToWorld()
					)
					2:
					(
						::pivotToCenter()
					)
					3:
					(
						if selection.count == 1 then
						(
							::pivotToFaceCenter $
						)
						else
						(
							MessageBox "Select One Object to Process" title:"_PIVOT"
						)
					)
					4:
					(
						if selection.count == 1 then
						(
							::pivotToFaceLocal $
						)
						else
						(
							MessageBox "Select One Object to Process" title:"_PIVOT"
						)					
					)
				)
			)
		)
		--The Expand and Collapse State
		on CM_KL_VehicleTool_Pivot rolledUp bState do
		(
			if (bState == true) then
			(
				CM_KL_VehicleTool.height += CM_KL_VehicleTool_Pivot.height
				CM_KL_VehicleTool_SubTool.height += CM_KL_VehicleTool_Pivot.height
				CM_KL_VehicleTool_SubTool.height += rollPadding
				CM_KL_VehicleTool.height += rollPadding
					
			)
			else
			(
				CM_KL_VehicleTool.height -= CM_KL_VehicleTool_Pivot.height
				CM_KL_VehicleTool_SubTool.height -= CM_KL_VehicleTool_Pivot.height
				CM_KL_VehicleTool_SubTool.height -= rollPadding
				CM_KL_VehicleTool.height -= rollPadding
			)
		)
	)
	rollout CM_KL_VehicleTool_AssetTracker "Asset Tracker" rolledup:true
	(
		label lbl1 "Find" pos:[8,8] width:24 height:16		
		label lbl2 "Replace" pos:[8,32] width:40 height:16
		edittext txtFind "" pos:[56,8] width:120 height:16
		edittext txtReplace "" pos:[56,32] width:120 height:16
		button btn_swap "{}" pos:[179,8] width:21 height:40		
		button btn_repathTexture "Repath Textures" pos:[8,56] width:190 height:24
		
		on btn_swap pressed do
		(
			swapF = txtFind.text
			swapR = txtReplace.text
			txtFind.text = swapR
			txtReplace.text = swapF
		)
		on btn_repathTexture pressed do
		(
			undo on
			(
				if txtFind.text != "" and txtReplace != "" then
				(
					::repathTexture txtFind.text txtReplace.text
				)
			)
		)		
		--The Expand and Collapse State	
		on CM_KL_VehicleTool_AssetTracker rolledUp bState do
		(
			if (bState == true) then
			(
				CM_KL_VehicleTool.height += CM_KL_VehicleTool_AssetTracker.height
				CM_KL_VehicleTool_SubTool.height += CM_KL_VehicleTool_AssetTracker.height
				CM_KL_VehicleTool_SubTool.height += rollPadding
				CM_KL_VehicleTool.height += rollPadding
			)
			else
			(
				CM_KL_VehicleTool.height -= CM_KL_VehicleTool_AssetTracker.height
				CM_KL_VehicleTool_SubTool.height -= CM_KL_VehicleTool_AssetTracker.height
				CM_KL_VehicleTool_SubTool.height -= rollPadding
				CM_KL_VehicleTool.height -= rollPadding
			)
		)
	)
	rollout CM_KL_VehicleTool_VertexColors "Vertex Color" rolledup:true
	(
			button btn_applyVertexColor "Apply Vertex Color" pos:[8,8] width:192 height:24 tooltip:"Press Shift in Vertex Mode to Apply on Selected Vertices"
			button btn_removeVertexColor "Remove Vertex Color" pos:[8,32] width:192 height:24
			button btn_displayVertexColor "Display Vertex Color" pos:[8,56] width:192 height:24
			
			on btn_applyVertexColor pressed do
			(
				undo on
				(
					
					mainColor = LoadINI CM_KL_PROJECT_SETTINGS ini_section:"VERTEX_COLOR" ini_keys:"Main"
					if keyboard.shiftPressed == true  do
					(
						if selection.count == 1 do
						(	
							::applyVertexColor $ (color ((execute mainColor)[1] as Integer)((execute mainColor)[2] as Integer)((execute mainColor)[3] as Integer)) sel:"SELECTED"
						)
					)
					if  keyboard.shiftPressed == false do
					(
						if selection.count > 0 do 
						(
							for i in selection do
							(
								::applyVertexColor i (color ((execute mainColor)[1] as Integer)((execute mainColor)[2] as Integer)((execute mainColor)[3] as Integer)) sel:"NON_SELECTED"
							)
						)
					)
				)
			)
			on btn_removeVertexColor pressed do
			(
				defaultColor = LoadINI CM_KL_PROJECT_SETTINGS ini_section:"VERTEX_COLOR" ini_keys:"Default"
				undo on
				(
					if keyboard.shiftPressed == true  do
					(
						if selection.count == 1 do
						(	
							::applyVertexColor $ (color ((execute defaultColor)[1] as Integer)((execute defaultColor)[2] as Integer)((execute defaultColor)[3] as Integer)) sel:"SELECTED"
						)
					)
					if  keyboard.shiftPressed == false do
					(
						if selection.count > 0 do 
						(
							for i in selection do
							(
								::applyVertexColor i (color ((execute defaultColor)[1] as Integer)((execute defaultColor)[2] as Integer)((execute defaultColor)[3] as Integer)) sel:"NON_SELECTED"
							)
						)
					)
				)
			)
			on btn_displayVertexColor pressed  do
			(
				undo on
				(
					::toggleVertexColor()
				)
			)			
			--The Expand and Collapse State
			on CM_KL_VehicleTool_VertexColors rolledUp bState do
			(
				if (bState == true) then
				(
					CM_KL_VehicleTool.height += CM_KL_VehicleTool_VertexColors.height
					CM_KL_VehicleTool_SubTool.height += CM_KL_VehicleTool_VertexColors.height
					CM_KL_VehicleTool_SubTool.height += rollPadding
					CM_KL_VehicleTool.height += rollPadding
				)
				else
				(
					CM_KL_VehicleTool.height -= CM_KL_VehicleTool_VertexColors.height
					CM_KL_VehicleTool_SubTool.height -= CM_KL_VehicleTool_VertexColors.height
					CM_KL_VehicleTool_SubTool.height -= rollPadding
					CM_KL_VehicleTool.height -= rollPadding
				)
			)
	)
	rollout CM_KL_VehicleTool_UV "UV" rolledup:true
	(
		
		label lbl4 "Mesh ID" pos:[8,8] width:64 height:16
		spinner materialIDVal "" pos:[144,8] width:56 height:16 type:#integer	
		
		label lbl3 "Map Channel" pos:[8,24] width:72 height:16			
		spinner mapChannel "" pos:[144,24] width:56 height:16 type:#integer
		
		button btn_showUVID "Show ID in UV" pos:[8,48] width:192 height:24		
		label lbl2 "Render Size" pos:[8,80] width:64 height:16
		
		spinner renderSize "" pos:[144,80] width:56 height:16 range:[16,16384,512] type:#integer		
		button btn_renderMaterialID "Render ID" pos:[8,104] width:192 height:24				
		button btn_renderMapChannel "Render Channel" pos:[8,128] width:192 height:24
		button btn_renderMask "Render Mask" pos:[8,152] width:192 height:24
		
		local maxMaterialID = undefined
		local maxUVChannel = undefined 
		
		--The Expand and Collapse State

		on CM_KL_VehicleTool_UV open do
		(
			maxMaterialID = LoadINI CM_KL_PROJECT_SETTINGS ini_section:"MAX_MATERIAL_ID" ini_keys:"ID"
			maxMaterialID = maxMaterialID as Integer
			if maxMaterialID != undefined then
			(
				materialIDVal.range = [1,maxMaterialID,1]
			)
			maxUVChannel = LoadINI CM_KL_PROJECT_SETTINGS ini_section:"MAX_UV_CHANNEL" ini_keys:"Channel"
			maxUVChannel = maxUVChannel as Integer
			if maxUVChannel != undefined then
			(
				mapChannel.range = [1,maxUVChannel,1]
			)
		)
		on CM_KL_VehicleTool_UV rolledUp bState do
		(
			if (bState == true) then
			(
				CM_KL_VehicleTool.height += CM_KL_VehicleTool_UV.height
				CM_KL_VehicleTool_SubTool.height += CM_KL_VehicleTool_UV.height
				CM_KL_VehicleTool_SubTool.height += rollPadding
				CM_KL_VehicleTool.height += rollPadding
			)
			else
			(
				CM_KL_VehicleTool.height -= CM_KL_VehicleTool_UV.height
				CM_KL_VehicleTool_SubTool.height -= CM_KL_VehicleTool_UV.height
				CM_KL_VehicleTool_SubTool.height -= rollPadding
				CM_KL_VehicleTool.height -= rollPadding
			)
		)
		on btn_showUVID pressed do
		(
			undo on
			(
				::showMeshByID (materialIDVal.value) (mapChannel.value)
			)
		)
		on btn_renderMaterialID pressed do
		(
			undo on
			(
				::showMeshByID (materialIDVal.value) (mapChannel.value)
				::RenderToTexture renderSize.value id:(materialIDVal.value) renderBy:"MaterialID"
				collapseStack selection
				::unhideAllFaces()
			)
		)
		on btn_renderMapChannel pressed do
		(
			undo on
			(
				::RenderToTexture renderSize.value mapChannel:(mapChannel.value) renderBy:"UVLayout"
				collapseStack selection
				::unhideAllFaces()
			)
		)
		on btn_renderMask pressed do
		(
			undo on
			(
				::showMeshByID (materialIDVal.value) (mapChannel.value)
				::RenderToTexture renderSize.value id:(materialIDVal.value) mapChannel:(mapChannel.value) renderBy:"Mask"
				collapseStack selection
				::unhideAllFaces()
			)
		)
	)
	rollout CM_KL_VehicleTool_Material "Material" rolledup:true
	(
		dropdownList listMaterials "Materials" pos:[8,8] width:192 height:40
		button btn_assignMaterial "Assign Material" pos:[8,56] width:192 height:24
		spinner rendersizeValue "" pos:[112,88] width:80 height:16 range:[16,16384,512] type:#integer
		label lbl3 "Render Size" pos:[8,88] width:96 height:16
		label lbl5 "Padding" pos:[8,104] width:96 height:16		
		spinner paddingValue "" pos:[112,104] width:80 height:16 range:[1,64,1] type:#integer
		label lbl6 "UV Channel" pos:[8,120] width:96 height:16
		spinner uvchannelValue "" pos:[112,120] width:80 height:16 range:[1,10,1] type:#integer
		button btn_renderColorMap "Render Color Map" pos:[8,144] width:192 height:24
		
		local xmlFile
		local xmlDoc = dotNetObject "System.XML.XMLDocument"
		
		on CM_KL_VehicleTool_Material open do
		(
			xmlFile = (PROJECT_SETTINGS_DIR + (LoadINI CM_KL_PROJECT_SETTINGS ini_section:"MATERIAL_XML" ini_keys:"Path"))
			listMaterials.Items = ::loadXMLData xmlDoc xmlFile
		)
		on btn_assignMaterial pressed do
		(
			id = (::getMaterialData xmlDoc xmlFile listMaterials.selected)[1] as integer
			mName = (::getMaterialData xmlDoc xmlFile listMaterials.selected)[2]
			mColor = (execute ("color "+(::getMaterialData xmlDoc xmlFile listMaterials.selected)[3]))
			
			if selection.count == 1 do 
			(
				::addIDtoFace $ id mName mColor
			)
		)
		on btn_renderColorMap pressed do
		(
			if selection.count == 1 do ::bakeColorMap $ rendersizeValue.Value uvchannelValue.Value paddingValue.value
		)
		--The Expand and Collapse State
		on CM_KL_VehicleTool_Material rolledUp bState do
		(
			if (bState == true) then
			(
				CM_KL_VehicleTool.height += CM_KL_VehicleTool_Material.height
				CM_KL_VehicleTool_SubTool.height += CM_KL_VehicleTool_Material.height
				CM_KL_VehicleTool_SubTool.height += rollPadding
				CM_KL_VehicleTool.height += rollPadding
			)
			else
			(
				CM_KL_VehicleTool.height -= CM_KL_VehicleTool_Material.height
				CM_KL_VehicleTool_SubTool.height -= CM_KL_VehicleTool_Material.height
				CM_KL_VehicleTool_SubTool.height -= rollPadding
				CM_KL_VehicleTool.height -= rollPadding	   
			)
		)
	)
	rollout CM_KL_VehicleTool_LOD "LOD" rolledup:true
	(
		button btn_copyToNextLod "Copy selected to next LOD" pos:[8,8] width:192 height:24				
		button btn_fixLODPivots "Fix All LOD Pivot to x0" pos:[8,32] width:192 height:24		
		checkbutton btn_showCountPerObject "Show Count Per Object" pos:[8,56] width:192 height:24
		checkbutton btn_showAllLODCount "Show All LOD Count" pos:[8,80] width:192 height:24	
		
		local allLODCount = #()
		local maxTriCount
		local currentLODTriCount = 0
		local triCountToRemove = 0
		local excludedObject = #()
		local theTimer = dotNetObject "System.Windows.Forms.Timer"
		
		function drawCurrentLODCount =
		(
			screenWidth = (getViewSize())[1]/2
			gw.wtext [screenWidth,10,0] (currentLODTriCount as string) color:Yellow
		)	
		function drawCountPerObject =
		(
			if selection.count == 1 then
			(
				gw.setTransform(Matrix3 1)
				gw.wtext [10,130,0] ($.name) color:Yellow
				gw.wtext [10,150,0] (triCountToRemove as string) color:Yellow
			)
		)
		function drawAllLODCount =
		(
			for i = 1 to lodList.count do
			(				
				gw.wText [10,50+(i*20),0] ("x" + (i-1) as string +" : "+ allLODCount[i]) color:Yellow
			)
		)		
		on CM_KL_VehicleTool_LOD open do
		(
			maxTriCount = LoadINI CM_KL_PROJECT_SETTINGS ini_section:"LOD_COUNT" ini_keys:"Count"
			maxTriCount = breakStringToArray maxTriCount
			for i = 1 to maxTriCount.count do
			(
				maxTriCount[i] = maxTriCount[i] as Integer
			)
			excludedObject = LoadINI CM_KL_PROJECT_SETTINGS ini_section:"LOD_EXCLUDED_OBJECT" ini_keys:"Objects"
			excludedObject = breakStringToArray excludedObject
			
			UnRegisterRedrawViewsCallback drawCountPerObject
			UnRegisterRedrawViewsCallback drawCurrentLODCount
			UnRegisterRedrawViewsCallback drawAllLODCount
			UnRegisterRedrawViewsCallback drawCurrentLODCount
			UnRegisterRedrawViewsCallback drawSwitchLOD
			RedrawViews()
		)
		on CM_KL_VehicleTool_LOD close do
		(
			UnRegisterRedrawViewsCallback drawCountPerObject
			UnRegisterRedrawViewsCallback drawCurrentLODCount
			UnRegisterRedrawViewsCallback drawAllLODCount
			UnRegisterRedrawViewsCallback drawCurrentLODCount	
			UnRegisterRedrawViewsCallback drawSwitchLOD			
			theTimer.stop()
			RedrawViews()
		)
		on btn_copyToNextLod pressed do
		(
			undo on
			(
				if selection.count > 0 do
				(
					for i in selection do
					(
						::cloneObject i lodList.count
					)
				)
			)
		)
		on btn_fixLODPivots pressed do
		(
			undo on
			(
				::fixLODPivot lodList.count
			)
		)
		on btn_showCountPerObject changed state do
		(
			
			if state == true then
			(
				fn repeatTask =
				(
					triCountToRemove = ::showLODCount maxTriCount
					currentLODTriCount = ::getEntireLODCount excludedObject lodList.count type:"Selection"
				)
				if selection.count == 1 and $.name[2] != "0" then
				(
						btn_showAllLODCount.state = false				
						theTimer.start()
						::updateEntireScript theTimer repeatTask
						RegisterRedrawViewsCallback drawCountPerObject
						RegisterRedrawViewsCallback drawCurrentLODCount
						UnRegisterRedrawViewsCallback drawAllLODCount
						RedrawViews()			
				)
				else
				(
					btn_showCountPerObject.state = false
				)
			)
			else
			(
				UnRegisterRedrawViewsCallback drawCountPerObject
				UnRegisterRedrawViewsCallback drawCurrentLODCount
				RedrawViews()
				theTimer.stop()
			)		
		)
		on btn_showAllLODCount changed state do
		(		
			if state == true then
			(				
				btn_showCountPerObject.state = false
				allLODCount = ::getEntireLODCount excludedObject lodList.count maxCount:maxTriCount type:"Entire"
				UnRegisterRedrawViewsCallback drawCountPerObject
				UnRegisterRedrawViewsCallback drawCurrentLODCount
				RegisterRedrawViewsCallback drawAllLODCount
				RedrawViews()
			)
			else
			(
				UnRegisterRedrawViewsCallback drawAllLODCount
				RedrawViews()
			)	
		)
		--The Expand and Collapse State
		on CM_KL_VehicleTool_LOD rolledUp bState do
		(
			if (bState == true) then
			(
				CM_KL_VehicleTool.height += CM_KL_VehicleTool_LOD.height
				CM_KL_VehicleTool_SubTool.height += CM_KL_VehicleTool_LOD.height
				CM_KL_VehicleTool_SubTool.height += rollPadding
				CM_KL_VehicleTool.height += rollPadding
			)
			else
			(
				CM_KL_VehicleTool.height -= CM_KL_VehicleTool_LOD.height
				CM_KL_VehicleTool_SubTool.height -= CM_KL_VehicleTool_LOD.height
				CM_KL_VehicleTool_SubTool.height -= rollPadding
				CM_KL_VehicleTool.height -= rollPadding		    
			)
		)
	)
	rollout CM_KL_VehicleTool_Common "Common" rolledUp:true
	(
		
		GroupBox check_Group "Check" pos:[8,8] width:192 height:120
		button btn_checkSmoothing "Check Smoothing Group" pos:[16,24] width:176 height:24
		button btn_checkNonQuad "Check Non Quad" pos:[16,48] width:176 height:24
		button btn_checkMirror "Check Left / Right" pos:[16,72] width:176 height:24	
			
		GroupBox autoFix_Group "Auto Fix" pos:[8,128] width:192 height:168
		button btn_zeroFaceArea "Check Zero Area of Face" pos:[16,96] width:176 height:24
		button btn_checkWrongLayer "Auto Fix Wrong Layer" pos:[16,144] width:176 height:24
		button btn_fixTyrePosition "Auto Fix Tyre Position" pos:[16,168] width:176 height:24
		button btn_flipWingMirror "Flip WingMirror and Fix ID" pos:[16,192] width:176 height:24
		button btn_unhideAllFaces "Unhide All Faces" pos:[16,216] width:176 height:24
		button btn_resetXForm "Reset XForm Selection" pos:[16,240] width:176 height:24		
		button btn_forceResetXForm "Force Reset XForm" pos:[16,264] width:176 height:24
		
		GroupBox externalTool_Group "External Tools" pos:[8,296] width:192 height:72
		button btn_cameraProjection "Camera Projection" pos:[16,312] width:176 height:24
		button btn_customTools "Custom Tools" pos:[16,336] width:176 height:24
		
		local maxTyreLOD = undefined
		local excludedList = undefined 
		local tyres = undefined
		local tyreInitials = undefined
		
		--The Expand and Collapse State		
		on CM_KL_VehicleTool_Common open do
		(
			maxTyreLOD = LoadINI CM_KL_PROJECT_SETTINGS ini_section:"TYRES" ini_keys:"MaxLOD"
			
			if isSeperateTyreLayer == true then
			(
				excludedList = LoadINI CM_KL_PROJECT_SETTINGS ini_section:"LOD_EXCLUDED_OBJECT" ini_keys:"Objects"
				excludedList = breakStringToArray excludedList
				tyres = LoadINI CM_KL_PROJECT_SETTINGS ini_section:"TYRES" ini_keys:"Value"
				tyres = breakStringToArray tyres
				tyreInitials = LoadINI CM_KL_PROJECT_SETTINGS ini_section:"TYRES" ini_keys:"Initials"
				tyreInitials = breakStringToArray tyreInitials
				sort excludedList
				sort tyres
				sort tyreInitials
			)
			else
			(
				excludedList = undefined
				tyres = undefined
				tyreInitials = undefined
			)
		)
		on CM_KL_VehicleTool_Common rolledUp bState do
		(
			if (bState == true) then
			(
				CM_KL_VehicleTool.height += CM_KL_VehicleTool_Common.height
				CM_KL_VehicleTool_SubTool.height += CM_KL_VehicleTool_Common.height
				CM_KL_VehicleTool_SubTool.height += rollPadding
				CM_KL_VehicleTool.height += rollPadding
			)
			else
			(
				CM_KL_VehicleTool.height -= CM_KL_VehicleTool_Common.height
				CM_KL_VehicleTool_SubTool.height -= CM_KL_VehicleTool_Common.height
				CM_KL_VehicleTool_SubTool.height -= rollPadding
				CM_KL_VehicleTool.height -= rollPadding
			)
		)
		on btn_checkSmoothing pressed do
		(
			undo on
			(
				::checkNonSmoothing()
			)
		)
		on btn_checkNonQuad pressed do
		(
			undo on
			(
				::checkNonQuad()
			)
		)
		on btn_checkMirror pressed do
		(
			undo on
			(
				eObj = #()
				eObj = ::checkPosition lodList
				if eObj[1] != undefined then
				(
					eStr = "Object with Invalid Position\n\n"
					for i = 1 to eObj.count do
					(
						eStr = eStr + eObj[i].name + "\n"
					)
					select eObj
					MessageBox eStr beep:false title:"INVALID_POSITION"
				)
			)
		)
		on btn_zeroFaceArea pressed do
		(
			if selection.count == 1 do
			(
				::checkZeroFaceArea $
			)
		)
		on btn_checkWrongLayer pressed do
		(
			undo on
			(
				if isSeperateTyreLayer == false do
				(
					::checkWrongLayer lodList exList:#()
				)
				if isSeperateTyreLayer == true and tyres != undefined and tyreInitials != undefined do
				(
					::checkWrongLayer lodList exList:excludedList
					::checkWrongLayer lodList tyre:tyres tyreInitials:tyreInitials				
				)
			)
		)
		on btn_fixTyrePosition pressed do
		(
			undo on
			(
				if maxTyreLOD != "" then
				(
					::fixTyrePosition (maxTyreLOD as Integer)
				)
			)
		)
		on btn_flipWingMirror pressed do
		(
			undo on
			(
				::flipWingMirror $
			)
		)
		on btn_unhideAllFaces pressed do
		(
			::unhideAllFaces()
		)
		on btn_resetXForm pressed do
		(
			undo on
			(
				::resetXFormSelection flipNormal:false
			)
		)
		on btn_forceResetXForm pressed do
		(
			::forceResetXForm()
		)
		on btn_cameraProjection pressed do
		(
			fileIn (PROJECT_SETTINGS_DIR+@"scripts\external\CM_KL_CameraToUV.ms")
		)
		on btn_customTools pressed do
		(
			fileIn (PROJECT_SETTINGS_DIR+@"scripts\external\CM_KL_RunExternalScript.ms")
		)
	)
	rollout CM_KL_VehicleTool_Perforce "Perforce" rolledUp:true
	(
		dotNetControl lbl_info "System.Windows.Forms.Label" pos:[8,8] width:192 height:40
		button btn_checkoutFile "Checkout Current Max File" pos:[8,56] width:192 height:24
		label lbl_changeList "Changelist Description" pos:[9,86] width:113 height:16		
		dotNetControl txt_changelistDesc "System.Windows.Forms.TextBox" pos:[8,104] width:192 height:64			
		dotNetControl btn_checkinFile "System.Windows.Forms.Button" pos:[8,176] width:192 height:24		
		button btn_createStartUpdate "Create Startup" pos:[8,208] width:168 height:24
		button btn_openStartUpFolder "..." pos:[176,208] width:24 height:24

		local _WINSTARTUPFOLDER = (dotnetClass "System.Environment").GetFolderPath((dotnetClass "System.Environment+SpecialFolder").Startup)
		
		local _MAXDEFFORMCOLOR = (dotNetClass "System.Drawing.Color").FromArgb 68 68 68
		local _MAXDEFBLKCOLOR = (dotNetClass "System.Drawing.Color").FromArgb 11 11 11
		local _MAXDEFWHITECOLOR = (dotNetClass "System.Drawing.Color").FromArgb 235 235 235
		local _MAXDEFBTNCOLOR = (dotNetClass "System.Drawing.Color").FromArgb 60 130 220
		local _MAXDEFERRBTNCOLOR = (dotNetClass "System.Drawing.Color").FromArgb 221 54 21
		
		local p4username
		local p4machine
		local p4port
		local p4client
		local p4depot
		local p4map
		
		local batchOutFile = (getDir #temp+ @"\p4_batchProcess.bat")	
		
		fn initDotnet =
		(
			--LABELS
			lbl_info.backColor = _MAXDEFFORMCOLOR
			lbl_info.foreColor = _MAXDEFWHITECOLOR
			
			--TEXTBOX
			txt_changelistDesc.AcceptsReturn = true
			txt_changelistDesc.Multiline = true			
			txt_changelistDesc.WordWrap = true
			txt_changelistDesc.ShortcutsEnabled = true
			txt_changelistDesc.ScrollBars = (dotNetClass "System.Windows.Forms.ScrollBars").Vertical
			
			--BUTTONS
			btn_checkinFile.FlatAppearance.BorderSize = 1
			btn_checkinFile.FlatStyle = btn_checkinFile.FlatStyle.Flat
			btn_checkinFile.BackColor = _MAXDEFFORMCOLOR
			btn_checkinFile.ForeColor = _MAXDEFWHITECOLOR
			btn_checkinFile.FlatAppearance.CheckedBackColor = _MAXDEFFORMCOLOR 
			btn_checkinFile.FlatAppearance.MouseDownBackColor = _MAXDEFBTNCOLOR 
			btn_checkinFile.FlatAppearance.MouseOverBackColor = _MAXDEFFORMCOLOR 
			btn_checkinFile.FlatAppearance.BorderColor = _MAXDEFBLKCOLOR
			btn_checkinFile.Text = "Checkin Files"
			
		)			
		--The Expand and Collapse State	

		on CM_KL_VehicleTool_Perforce open do
		(
			initDotnet()			
			p4username = sysInfo.userName
			p4machine = sysInfo.computername			
			p4port = LoadINI CM_KL_PROJECT_SETTINGS ini_section:"PERFORCE" ini_keys:"PORT"
			p4client = LoadINI CM_KL_PROJECT_SETTINGS ini_section:"PERFORCE" ini_keys:"CLIENT"
			p4depot = LoadINI CM_KL_PROJECT_SETTINGS ini_section:"PERFORCE" ini_keys:"DEPOT"
			p4map = LoadINI CM_KL_PROJECT_SETTINGS ini_section:"PERFORCE" ini_keys:"MAPDRIVE"
			
			lbl_info.text = "User : " + p4username +"\nWorkspace : \n" + p4machine+"."+p4client			
						
			if (maxFilePath+maxFileName) != "" and txt_changelistDesc.Text != "" then
			(
				btn_checkinFile.enabled = true
				btn_checkinFile.BackColor = _MAXDEFFORMCOLOR
				btn_checkinFile.FlatAppearance.CheckedBackColor = _MAXDEFFORMCOLOR
				btn_checkinFile.Text = "Checkin Current Max File"				
			)
			else
			(
				btn_checkinFile.enabled = false
				btn_checkinFile.BackColor = _MAXDEFERRBTNCOLOR
				btn_checkinFile.FlatAppearance.CheckedBackColor = _MAXDEFERRBTNCOLOR 
				btn_checkinFile.Text = "Enter Changelist Description"
			)	
		)
		on CM_KL_VehicleTool_Perforce rolledUp bState do
		(
			if (bState == true) then
			(
				CM_KL_VehicleTool.height += CM_KL_VehicleTool_Perforce.height
				CM_KL_VehicleTool_SubTool.height += CM_KL_VehicleTool_Perforce.height
				CM_KL_VehicleTool_SubTool.height += rollPadding
				CM_KL_VehicleTool.height += rollPadding
			)
			else
			(
				CM_KL_VehicleTool.height -= CM_KL_VehicleTool_Perforce.height
				CM_KL_VehicleTool_SubTool.height -= CM_KL_VehicleTool_Perforce.height
				CM_KL_VehicleTool_SubTool.height -= rollPadding
				CM_KL_VehicleTool.height -= rollPadding
			)
		)
		on btn_checkoutFile pressed do
		(
			if (maxFilePath+maxFileName) != "" then
			(
				::addCommandstoFile (::writeData p4port (p4username+"."+p4machine+"."+p4client) "edit -c default " filePath:(::changeToDepot (maxFilePath+maxFileName) p4map p4depot)) (::iniFile batchOutFile)
				::sLaunch batchOutFile
			)
		)
		on txt_changelistDesc keyDown e do
		(
			if e.Control and e.KeyCode == e.KeyCode.A then
			(
				txt_changelistDesc.SelectAll()
				e.SuppressKeyPress = true
			)
		)
		on txt_changelistDesc TextChanged e do
		(
			if (maxFilePath+maxFileName) != "" and txt_changelistDesc.text != "" then
			(
				btn_checkinFile.enabled = true
				btn_checkinFile.BackColor = _MAXDEFFORMCOLOR
				btn_checkinFile.FlatAppearance.CheckedBackColor = _MAXDEFFORMCOLOR 
				btn_checkinFile.Text = "Checkin Current Max File"	
			)
			else if (maxFilePath+maxFileName) == "" and txt_changelistDesc.Text != "" then
			(
				btn_checkinFile.enabled = false
				btn_checkinFile.BackColor = _MAXDEFERRBTNCOLOR
				btn_checkinFile.FlatAppearance.CheckedBackColor = _MAXDEFERRBTNCOLOR 
				btn_checkinFile.Text = "No Max File Opened"
			)
			else
			(
				btn_checkinFile.enabled = false
				btn_checkinFile.BackColor = _MAXDEFERRBTNCOLOR
				btn_checkinFile.FlatAppearance.CheckedBackColor = _MAXDEFERRBTNCOLOR 
				btn_checkinFile.Text = "Enter Changelist Description"
			)
		)
		on btn_checkinFile mouseUp e do
		( 
			if (maxFilePath+maxFileName) != "" and txt_changelistDesc.text != "" then
			(
				::addCommandstoFile (::writeData p4port (p4username+"."+p4machine+"."+p4client) ("submit -d \""+txt_changelistDesc.text+"\" ") filePath:(::changeToDepot (maxFilePath+maxFileName) p4map p4depot)) (::iniFile batchOutFile)
				::sLaunch batchOutFile
			)
			txt_changelistDesc.text = ""
		)
		on btn_createStartUpdate pressed do
		(
			updateDir = getSavePath caption:"Select the Update Directory" initialDir:p4map
			if updateDir != undefined then
			(
				updateDir = updateDir+"\..."
				::addCommandstoFile (::writeData p4port (p4username+"."+p4machine+"."+p4client) "sync -f " filePath:(::changeToDepot updateDir p4map p4depot)) (::iniFile (_WINSTARTUPFOLDER + @"\p4_autoUpdate.bat"))
			)
			else
			(
				MessageBox "Select a Directory"
			)
		)
		on btn_openStartUpFolder pressed do
		(
			Shelllaunch _WINSTARTUPFOLDER ""
		)
	)
	rollout CM_KL_VehicleTool_Screenshot "Screenshot" rolledup:true
	(
		button btn_createCamera "Create Camera" pos:[8,8] width:192 height:24
		button btn_screenShot "Take All Camera Screenshot" pos:[8,32] width:192 height:24
		groupBox groupLOD "LOD's" pos:[8,56] width:192 height:80
		button btn_resetPosition "Reset Position" pos:[16,104] width:176 height:24
		button btn_postitionLOD "Position LOD's" pos:[16,80] width:176 height:24
		
		local cameraPosFile
		
		on CM_KL_VehicleTool_Screenshot open do
		(
			cameraPosFile = PROJECT_SETTINGS_DIR + LoadINI CM_KL_PROJECT_SETTINGS ini_section:"CAMERA_XML" ini_keys:"Path"
		)
		on btn_createCamera pressed do
		(
			getCameraData = ::loadCameraData cameraPosFile
			for i = 1 to getCameraData.count do
			(
				::createCamera getCameraData[i][1] (execute getCameraData[i][2]) (execute getCameraData[i][3]) (getCameraData[i][4] as float)
			)
		)
		on btn_screenShot pressed do
		(
			hideByCategory.cameras = true
			imgLocation = GetSavePath caption:"Select Folder to Save ScreenShot"
			vpTM = viewport.getTM()
			if imgLocation != undefined do
			(
				if selection.count > 0 then
				(
					try
					(					
						for i in selection where superClassOf i == camera and (findString i.name ".Target") == undefined do
						(
							::fastScreenGrab i (imgLocation+@"\_"+i.name+".jpg")
						)
					)catch()
				)
				else
				(
					try
					(
						for i in $templateCamera* where (findString i.name ".Target") == undefined do
						(
							::fastScreenGrab i (imgLocation+@"\_"+i.name+".jpg")
						)
					)catch()
				)
			)
			viewport.setType #view_persp_user
			viewport.setTM vpTM
		)
		on btn_postitionLOD pressed do
		(
			max create mode
			if isSeperateTyreLayer == true then
			(
				::createPoint lodList tyre:tyresArr
			)
			else
			(
				::createPoint lodList
			)
			::positionLOD lodList
			hideByCategory.helpers = true
		)
		on btn_resetPosition pressed  do
		(
			::resetLODPosition lodList
			hideByCategory.helpers = false
		)		
		--The Expand and Collapse State
		on CM_KL_VehicleTool_Screenshot rolledUp bState do
		(
			if (bState == true) then
			(
				CM_KL_VehicleTool.height += CM_KL_VehicleTool_Screenshot.height
				CM_KL_VehicleTool_SubTool.height += CM_KL_VehicleTool_Screenshot.height
				CM_KL_VehicleTool_SubTool.height += rollPadding
				CM_KL_VehicleTool.height += rollPadding
			)
			else
			(
				CM_KL_VehicleTool.height -= CM_KL_VehicleTool_Screenshot.height
				CM_KL_VehicleTool_SubTool.height -= CM_KL_VehicleTool_Screenshot.height
				CM_KL_VehicleTool_SubTool.height -= rollPadding
				CM_KL_VehicleTool.height -= rollPadding
			)
		)
	)
	rollout CM_KL_VehicleTool_Project "Project Settings" rolledup:true
	(
		button btn_changeProject "Change Project Settings" pos:[8,8] width:192 height:24
		on btn_changeProject pressed do
		(
			try
				(destroyDialog CM_KL_VehicleTool)catch()
				createDialog CM_KL_VehicleTool_ProjectSettings
		)
		--The Expand and Collapse State
		on CM_KL_VehicleTool_Project rolledUp bState do
		(
			if (bState == true) then
			(
				CM_KL_VehicleTool.height += CM_KL_VehicleTool_Project.height
				CM_KL_VehicleTool_SubTool.height += CM_KL_VehicleTool_Project.height
				CM_KL_VehicleTool_SubTool.height += rollPadding
				CM_KL_VehicleTool.height += rollPadding
			)
			else
			(
				CM_KL_VehicleTool.height -= CM_KL_VehicleTool_Project.height
				CM_KL_VehicleTool_SubTool.height -= CM_KL_VehicleTool_Project.height
				CM_KL_VehicleTool_SubTool.height -= rollPadding
				CM_KL_VehicleTool.height -= rollPadding
			)
		)		
	)	
	--Adds all the SubRollout to MainRollout
	on CM_KL_VehicleTool open do
	(
			loadScript()
			addSubRollout CM_KL_VehicleTool_SubTool CM_KL_VehicleTool_Selection
			addSubRollout CM_KL_VehicleTool_SubTool CM_KL_VehicleTool_Naming
			addSubRollout CM_KL_VehicleTool_SubTool CM_KL_VehicleTool_Pivot
			addSubRollout CM_KL_VehicleTool_SubTool CM_KL_VehicleTool_AssetTracker
			addSubRollout CM_KL_VehicleTool_SubTool CM_KL_VehicleTool_VertexColors
			addSubRollout CM_KL_VehicleTool_SubTool CM_KL_VehicleTool_Material
			addSubRollout CM_KL_VehicleTool_SubTool CM_KL_VehicleTool_Common	
			addSubRollout CM_KL_VehicleTool_SubTool CM_KL_VehicleTool_UV
			addSubRollout CM_KL_VehicleTool_SubTool CM_KL_VehicleTool_LOD	
			addSubRollout CM_KL_VehicleTool_SubTool CM_KL_VehicleTool_Perforce
			addSubRollout CM_KL_VehicleTool_SubTool CM_KL_VehicleTool_Screenshot
			addSubRollout CM_KL_VehicleTool_SubTool CM_KL_VehicleTool_Project
			--Units Setup on Startup
			sysScale = (LoadINI CM_KL_PROJECT_SETTINGS ini_section:"UNITS" ini_keys:"SystemScale" as float)
			sysType = (LoadINI CM_KL_PROJECT_SETTINGS ini_section:"UNITS" ini_keys:"SystemType")			
			::initializeUnitSetup sysScale sysType
	)
	on CM_KL_VehicleTool close do
	(
		gc()
	)
	--Stores the Position on the Rollout
	on CM_KL_VehicleTool moved pos do
	(
		thePosition = #()
		thePosition[1] = (GetDialogPos CM_KL_VehicleTool)[1]
		thePosition[2] = (GetDialogPos CM_KL_VehicleTool)[2]
		SaveINI CURRENT_USER_SETTINGS ini_section:"DIALOG_POS" ini_keys:"Value" ini_value:(thePosition as string)  
	)
)
--End Of Main Tool

--Checks if Projects Settings are in place
if (doesFileExist CURRENT_USER_SETTINGS) then
(	
	CM_KL_PROJECT_SELECTED = LoadINI CURRENT_USER_SETTINGS ini_section:"CURRENT_PROJECT" ini_keys:"ProjectName"
	CM_KL_PROJECT_SETTINGS = PROJECT_SETTINGS_DIR + (LoadINI (PROJECT_SETTINGS_DIR+"CM_KL_VehicleTools_ProjectSettings.ini") ini_section:CM_KL_PROJECT_SELECTED ini_keys:"INISettingFile")
	DIALOG_POS = LoadINI CURRENT_USER_SETTINGS ini_section:"DIALOG_POS" ini_keys:"Value"
	if DIALOG_POS != "" then
	(
		DIALOG_POS = execute DIALOG_POS
		
		createDialog CM_KL_VehicleTool pos:[DIALOG_POS[1],DIALOG_POS[2]]
	)
	else
	(
		createDialog CM_KL_VehicleTool
	)
)
else
(createDialog CM_KL_VehicleTool_ProjectSettings)
