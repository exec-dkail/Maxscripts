function repathTexture findStr repStr =
(
  if findStr != undefined and repStr != undefined or findStr != "" and repStr != "" do
  (
    local asset_name = #()
    local fileName
    local assetID		
    sceneroot = (for r in (refs.dependents rootnode) where (classof r == Scene) collect r)[1] 
    ATSOps.GetSelectedFiles &asset_name
    for i in asset_name do
    (
      ATSOps.GetSelectedFiles i
      ATSOps.ClearSelection() 
      ATSOps.SelectFiles i 
      assetID = AssetManager.GetAssetID i #Bitmap
      fileName = SubstituteString (AssetManager.GetFileName assetID) findStr repStr
      ATSOps.RetargetAssets sceneroot i fileName CreateOutputFolder:false
      ATSOps.Refresh()
    )
  )
)
