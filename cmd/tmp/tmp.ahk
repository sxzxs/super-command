#include C:\Users\ahker\Desktop\我的AHK程序\库\v1\json.ahk

json_path := A_ScriptDir . "/json.json"
config := {}
loadconfig(config, json_path)
config.parameter1 := "ahk2"
saveconfig(config, json_path)
loadconfig(ByRef config, json_path)
{
    FileRead, OutputVar,% json_path
    config := json_toobj(outputvar)
}

saveconfig(config, json_path)
{
    str := json_fromobj(config)
    FileDelete, % json_path
    FileAppend,% str,% json_path
}