function iniFile bFile =
(
  try
  (
    gc()
    try(deleteFile bFile)catch()	
    fStream = createFile bFile	
    return fStream
  )catch()
)
fn fltStr str arg =
(
  newArr = filterString str arg
  return newArr
)
function changeToDepot pFile pDrive pDepot =
(
  try
  (
    depotPath = SubstituteString (SubstituteString pFile @"\" "/") pDrive pDepot
    return depotPath
  )catch()
)
function writeData port client type filePath:unsupplied changelistDescription:unsupplied =
(
  try
  (
    p4_port = "SET P4PORT="+port
    p4_client = "SET P4CLIENT="+client
    p4_cmd = ("p4 "+ type)

    if filePath != unsupplied then
    (
      p4_path = "\""+filePath+"\""
      procArr = 	p4_port+"\n"+p4_client+"\n"+p4_cmd+p4_path
    )
    else
    (
      procArr = 	p4_port+"\n"+p4_client+"\n"+p4_cmd
    )
    return procArr
  )catch()
)
function addCommandstoFile stringData fs =
(
  try
  (
    format "@echo off\n" to:fs
    format "echo Performing Perforce Commands from UserName : %\n" (sysInfo.userName) to:fs
    format "%" stringData to:fs
    close fs
  )catch()
)		
function sLaunch file=
(
  try
  (
    ShellLaunch file ""
  )catch()
)
