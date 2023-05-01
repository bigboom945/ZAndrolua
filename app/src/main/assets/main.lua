CodePath="/storage/emulated/0/AndroLua/"
base = activity.getSharedPreferences("Startupmain",activity.MODE_PRIVATE);
isFirstStart = base.getBoolean("isFirstStart",true);
luajava.bindClass("com.androlua.LuaActivityShare").setData("CodePaths",CodePath)

if(isFirstStart)
  luajava.bindClass("com.androlua.LuaUtil").copyDir(tostring(activity.getFilesDir()).."/lua",activity.getLuaLibPath())
  editor = base.edit();
  editor.putBoolean("isFirstStart",false);
  editor.commit();
end

require "import"
import "android.os.Build"
import "android.app.AlertDialog"
import "android.view.MenuItem"
import "android.graphics.drawable.*"
import "android.webkit.MimeTypeMap"
import "java.io.FileInputStream"
import "java.util.zip.ZipOutputStream"
import "android.content.ClipData"
import "java.util.Arrays"
import "android.view.SubMenu"
import "android.content.Context"
import "android.graphics.Color"
import "java.io.FileOutputStream"
import "android.app.AlertDialogBuilder"
import "android.graphics.drawable.ColorDrawable"
import "android.view.KeyEvent"
import "android.view.View"
import "android.net.Uri"
import "java.util.zip.ZipFile"
import "java.io.File"
import "android.app.Dialog"
import "android.widget.*"
import "java.util.zip.ZipEntry"
import "android.app.ProgressDialog"
import "android.content.Intent"
import "xaplugControls"
import "getAnno"
import "xalstd"
import "console"
import "bin"
import "cjson"
import "autotheme"
import "luacstrlib"
require "layout"
activity.setTitle('ZAndroLua+')
activity.setTheme(autotheme())
openPoject=...
AppSharedPreferences=activity.getSharedPreferences("xasetfil", Context.MODE_PRIVATE)
version = Build.VERSION.SDK_INT;
h = tonumber(os.date("%H"))
setsets=AppSharedPreferences.edit()
backPath=CodePath.."backup/"

function loadHelpData()
  local list={}
  for t,c in LuaUtil.readString(activity.getLuaDir().."/helpText.txt"):gmatch("(%b@@)\n*(%b@@)") do
    --print(t)
    t=t:sub(2,-2)
    c=c:sub(2,-2)
    list[t]=c
    list[#list+1]=t
  end
  LuaActivityShare.setData("HelpText",list)
end

loadHelpData()

if(AppSharedPreferences.getString("debugft",nil)=="true")
  debugisvar=true
end

function setSharedPreferences(setname)
  return AppSharedPreferences.getString(setname,null)
end

function setSharedPreferences(key,value)
  setsets.putString(key,value)
  setsets.commit()
end


function onVersionChanged(n, o)
  local dlg = AlertDialogBuilder(activity)
  local title = "更新" .. o .. ">" .. n
  local msg = [[
    0.0.1
    软件开始制作
  0.0.2
  做了一些小更新
  0.0.3
  添加用户自定义so功能
  0.0.4
  提升LuaActivity加载速度
  ，增加activity.isXposed、activity.prevent_Xpose
  方法
  0.0.8
  lposix模块强化(注意lposix模块加载后需要使用lposix.init()函数进行初始化，否则可能会出现不可知错误)
  1.0.0
  全面优化软件
  1.0.1
  全面优化软件，新增模块luacstrlib，用于解决大文本文件处理。
  新增LuaListView用于处理ScrollView嵌套LuaListView的特殊情况。
  1.0.2
  LuaWebView可以设置WebChromeClient了
  1.0.3
  lposix模块全面更改，不再使用lposix.init()函数
  更多更改优化。
  1.0.4
  增加对于Teal(lua的类型化方言)的支持，增加更多的init.lua配置选项，
  修复大量bug。增加公告功能、dex合并功能。
  1.0.5
  修复bug，项目可以添加jar库了，加强帮助选项的内容。修复一系列bug，
  并且解决原来无法给项目添加ZAndrolua+本身没有的权限的问题。
  1.0.6
  添加模板功能，修复bug。增加编译Java代码功能(打包时进行编译)。
  ]]
  if o == "" then
    File("/sdcard/AndroLua/xaplug").mkdir()
    title = "欢迎使用ZAndroLua+ " .. n
    msg = [[
    
   Zandrolua基于Androlua,与XAndrolua是同一作者
   AndroLua+是由nirenr开发的在安卓使用Lua语言开发应用的工具
  ，该项目基于开源项目luajava和AndroLua优化加强，修复了原版的bug，并加入了很多新的特性，使开发更加简单高效，使用该软件完全免费，如果你喜欢这个项目欢迎捐赠或者宣传他。
    在使用之前建议详细阅读程序自带帮助文档。
    用户协议
    作者不对使用该软件产生的任何直接或间接损失负责。
    勿使用该程序编写恶意程序以损害他人。
    继续使用表示你已知晓并同意该协议。
    
]].. msg
  end
  dlg.setTitle(title)

  dlg.setMessage(msg)
  dlg.setPositiveButton("确定", nil)
  dlg.setNegativeButton("帮助", { onClick =func.help })
  dlg.show()
end


function xacfImport(paths,pathnames)
  local dialog=AlertDialog.Builder(this)
  .setTitle("是否导入"..pathnames)
  .setMessage("该文件为xandrolua资源文件是否导入")
  .setPositiveButton("确认",{onClick=function(v)
      if luaproject
        ZipUtil.unzip(paths,luaproject)
       else
        ZipUtil.unzip(paths,CodePath)
      end
  end})
  .setNeutralButton("取消",nil)
  .show()
  dialog.create()
end



function xacfExports(paths)
  local editexts=EditText(activity)
  editexts.Hint="没有输入内容，导出的xacf文件自动为当前文件夹名.xacf"
  AlertDialog.Builder(this)
  .setTitle("请输入xacf文件名称")
  .setIcon(android.R.drawable.ic_dialog_info)
  .setView(editexts)
  .setPositiveButton("确定", function()
    ZipUtil.zip(paths,backPath)
    zipnamea=xalstd.string.split(paths,"/")
    zipname=zipnamea[#zipnamea-1]
    if (editexts.Text=="")
      File(backPath..zipname..".zip").renameTo(File(backPath..zipnamea..".xacf"))
     else
      File(backPath..zipname..".zip").renameTo(File(backPath..editexts.Text..".xacf"))
    end
  end)
  .setNegativeButton("取消", nil)
  .show();
end

function ext(f)
  local f=io.open(f)
  if f then
    f:close()
    return true
  end
  return false
end

if h <= 6 or h >= 22 then
  theme = activity.getLuaExtDir("fonts") .. "/night.lua"
 else
  theme = activity.getLuaExtDir("fonts") .. "/day.lua"
end

if not ext(theme) then
  theme = activity.getLuaExtDir("fonts") .. "/theme.lua"
end


local function day()
  if version >= 21 then
    return (android.R.style.Theme_Material_Light)
   else
    return (android.R.style.Theme_Holo_Light)
  end
end

local function night()
  if version >= 21 then
    return (android.R.style.Theme_Material)
   else
    return (android.R.style.Theme_Holo)
  end
end
local p = {}
local e = pcall(loadfile(theme, "bt", p))
if e then
  for k, v in pairs(p) do
    if k == "theme" then
      if v == "day" then
        activity.setTheme(day())
       elseif v == "night" then
        activity.setTheme(night())
      end
     else
      layout.main[2][k] = v
    end
  end
end


activity.getWindow().setSoftInputMode(0x10)

--activity.getActionBar().show()

luahist = luajava.luadir .. "/lua.hist"
luadir = luajava.luaextdir or "/sdcard/androlua/"
luaconf = luajava.luadir .. "/lua.conf"
luaproj = luajava.luadir .. "/lua.proj"
---lualib = luajava.luadir .. "/libs/"
pcall(dofile, luaconf)
pcall(dofile, luahist)
history = history or {}
luapath = luapath or luadir .. "new.lua"
luadir = luapath:match("^(.-)[^/]+$")
pcall(dofile, luaproj)
luaproject = luaproject

if luaproject then
  local p = {}
  local e = pcall(loadfile(luaproject .. "init.lua", "bt", p))
  isProjetCompil=p.OpenJava or p.OpenTeal
  if e then
    activity.setTitle(tostring(p.appname))
    Toast.makeText(activity, "打开工程." .. p.appname, Toast.LENGTH_SHORT ).show()
  end
end
activity.getActionBar().setDisplayShowHomeEnabled(false)
luabindir = luajava.luaextdir .. "/bin/"
code = [===[
require "import"
import "android.widget.*"
import "android.view.*"

]===]
pcode = [[
require "import"
import "android.app.*"
import "android.os.*"
import "android.widget.*"
import "android.view.*"
import "layout"
--activity.setTitle('AndroLua+')
--activity.setTheme(android.R.style.Theme_Holo_Light)
activity.setContentView(loadlayout(layout))
]]

lcode = [[
{
  LinearLayout,
  orientation="vertical",
  layout_width="fill",
  layout_height="fill",
  {
    TextView,
    text="hello AndroLua+",
    layout_width="fill",
  },
}
]]
upcode = [[
user_permission={
  "INTERNET",
  "WRITE_EXTERNAL_STORAGE",
}
isRemoveInitLua=false
NotAddFile={"setting.luas"}
]]

local BitmapDrawable = luajava.bindClass("android.graphics.drawable.BitmapDrawable")
m = {
  { MenuItem,
    title = "运行",
    id = "play",
    icon = "play", },
  { MenuItem,
    title = "撤销",
    id = "undo",
    icon = "undo", },
  { MenuItem,
    title = "重做",
    id = "redo",
    icon = "redo", },
  { MenuItem,
    title = "打开",
    id = "file_open", },
  { MenuItem,
    title = "最近",
    id = "file_history", },
  { SubMenu,
    title = "文件...",
    { MenuItem,
      title = "保存",
      id = "file_save", },
    { MenuItem,
      title = "新建",
      id = "file_new", },
    { MenuItem,
      title = "编译",
      id = "file_build", },
  },
  { SubMenu,
    title = "Android相关网站",
    { MenuItem,
      title = "打开中文Android官网",
      id = "openweb_openandroweb", },
    { MenuItem,
      title = "打开中文java官网",
      id = "openweb_openjavaweb", },
    { MenuItem,
      title = "打开英文java官网",
      id = "openweb_openjavaenweb", },
  },
  { SubMenu,
    title = "工程...",
    { MenuItem,
      title = "打开",
      id = "project_open", },
    { MenuItem,
      title = "打包",
      id = "project_build", },
    { MenuItem,
      title = "新建",
      id = "project_create", },
    { MenuItem,
      title = "导出",
      id = "project_export", },
    { MenuItem,
      title = "属性",
      id = "project_info", },
  },
  { SubMenu,
    title = "代码...",
    { MenuItem,
      title = "格式化",
      id = "code_format", },
    { MenuItem,
      title = "导入分析",
      id = "code_import", },
    { MenuItem,
      title = "查错",
      id = "code_check", },
  },
  { SubMenu,
    title = "转到...",
    { MenuItem,
      title = "搜索",
      id = "goto_seach", },
    { MenuItem,
      title = "转到",
      id = "goto_line", },
    { MenuItem,
      title = "导航",
      id = "goto_func", },
  },
  { SubMenu,
    title = "设置和文档(帮助)",
    { MenuItem,
      title = "设置",
      id = "more_setting", },
    { MenuItem,
      title = "帮助",
      id = "more_help", },
    { MenuItem,
      title = "手册",
      id = "more_manual", },

  },
  { MenuItem,
    title = "插件...",
    id = "plugin", },
  { SubMenu,
    title = "更多...",
    {MenuItem,
      title = "本软件github仓库",
      id = "more_gits"},
    {MenuItem,
      title = "公告",
      id = "more_Anno"},
    { MenuItem,
      title = "APK提取",
      id = "more_apke", },
    { MenuItem,
      title = "布局助手",
      id = "more_helper", },
    { MenuItem,
      title = "日志",
      id = "more_logcat", },
    { MenuItem,
      title = "Java浏览器",
      id = "more_java", },
    { MenuItem,
      title = "联系Androlua作者",
      id = "more_qq", },
    { MenuItem,
      title = "关于",
      id = "more_about", },
    { MenuItem,
      title = "导出当前文件夹为xacf文件",
      id = "more_xacfExport", }
  },
}

optmenu = {}
function onCreateOptionsMenu(menu)
  loadmenu(menu, m, optmenu, 3)
  menuobjs=menu

end
xpalugmenu={}
function switch2(s)
  return function(t)

    local f = t[s]
    if not f then
      for k, v in pairs(t) do
        if s.equals(k) then
          f = v
          break
        end
      end
    end
    if (xpalugmenu[f])
      f = f or t.default2
     else
      f=f
    end
    return f and f()
  end
end

function donothing()
  print("功能开发中")
end


luaprojectdir = luajava.luaextdir .. "/project/"

function create_project()
  local appname = project_appName.getText().toString()
  local packagename = project_packageName.getText().toString()
  local f = File(luaprojectdir .. appname)
  if f.exists() then
    print("工程已存在")
    return
  end
  if not f.mkdirs() then
    print("工程创建失败")
    return
  end

  luadir = luaprojectdir .. appname .. "/"
  if projectTemple
    ZipUtil.unzip(projectTemple,luadir)
    local init=io.open(luadir .. "init.lua")
    write(luadir .. "init.lua",init:read("*a"):gsub("%$appname%$",[["]]..appname..[["]]):gsub("%$packagename%$",[["]]..packagename..[["]]))
    init:close()
   else
    write(luadir .. "init.lua", string.format("appname=\"%s\"\nappver=\"1.0\"\nappsdk=\"15\"\nappSdk_target=\"18\"\npackagename=\"%s\"\n%s", appname, packagename, upcode))
    write(luadir .. "main.lua", pcode)
    --  write(luadir .. "libs/", pcode)
    write(luadir .. "layout.aly", lcode)
    --project_dlg.hide()
  end
  luapath = luadir .. "main.lua"
  read(luapath)
end

function update(s)
  bin_dlg.setMessage(s)
end

function callback(s)
  bin_dlg.hide()
  bin_dlg.Message = ""
  if not s:find("成功") then
    create_error_dlg()
    error_dlg.Message = s
    error_dlg.show()
  end
end

function reopen(path)
  local f = io.open(path, "r")
  if f then
    local str = f:read("*all")
    if tostring(editor.getText()) ~= str then
      editor.setText(str, true)
    end
    f:close()
  end
end

function read(path)

  local f = io.open(path, "r")
  if f == nil then
    --Toast.makeText(activity, "打开文件出错."..path, Toast.LENGTH_LONG ).show()
    error()
    return
  end
  local str = f:read("*all")
  f:close()
  if str~="" then
    local c=string.byte(str);
    if c <= 0x1c and c>= 0x1a and c!=" " and c!="\t" then
      Toast.makeText(activity, "不能打开已编译文件." .. path, Toast.LENGTH_LONG ).show()
      return
    end
  end
  initUserAdds()
  editor.setText(str)

  activity.getActionBar().setSubtitle(".." .. path:match("(/[^/]+/[^/]+)$"))
  luapath = path
  if history[luapath] then
    editor.setSelection(history[luapath])
  end
  table.insert(history, 1, luapath)
  for n = 2, #history do
    if n > 50 then
      history[n] = nil
     elseif history[n] == luapath then
      table.remove(history, n)
    end
  end
  write(luaconf, string.format("luapath=%q", path))
  if luaproject and path:find(luaproject, 1, true) then
    --Toast.makeText(activity, "打开文件."..path, Toast.LENGTH_SHORT ).show()
    activity.getActionBar().setSubtitle(path:sub(#luaproject))
    return
  end

  local dir = luadir
  local p = {}
  local e = pcall(loadfile(dir .. "init.lua", "bt", p))
  while not e do
    dir, n = dir:gsub("[^/]+/$", "")
    if n == 0 then
      break
    end
    e = pcall(loadfile(dir .. "init.lua", "bt", p))
  end

  if e then
    activity.setTitle(tostring(p.appname))
    luaproject = dir
    isProjetCompil=p.OpenJava or p.OpenTeal
    activity.getActionBar().setSubtitle(path:sub(#luaproject))
    write(luaproj, string.format("luaproject=%q", luaproject))
    --Toast.makeText(activity, "打开工程."..p.appname, Toast.LENGTH_SHORT ).show()
   else
    activity.setTitle("ZAndroLua+")
    luaproject = nil
    isProjetCompil=false
    write(luaproj, "luaproject=nil")
    --Toast.makeText(activity, "打开文件."..path, Toast.LENGTH_SHORT ).show()
  end

end

function write(path, str)
  local sw = io.open(path, "wb")
  if sw then
    sw:write(str)
    sw:close()
   else
    Toast.makeText(activity, "保存失败." .. path, Toast.LENGTH_SHORT ).show()
  end
  return str
end

function save()
  if xaplugClick.saves~=nil
    xaplugClick.saves(luaPath)
  end
  history[luapath] = editor.getSelectionEnd()
  local str = ""
  local f = io.open(luapath, "r")
  if f then
    str = f:read("*all")
    f:close()
  end
  local src = editor.getText().toString()
  if src ~= str then
    write(luapath, src)
  end
  return src
end

function click(s)
  func[s.getText()]()
end

function create_lua()
  luapath = luadir .. create_e.getText().toString() .. ".lua"
  if not pcall(read, luapath) then
    f = io.open(luapath, "a")
    f:write(code)
    f:close()
    table.insert(history, 1, luapath)
    editor.setText(code)
    write(luaconf, string.format("luapath=%q", luapath))
    Toast.makeText(activity, "新建文件." .. luapath, Toast.LENGTH_SHORT ).show()
    create_dlg.hide()
   else
    Toast.makeText(activity, "打开文件." .. luapath, Toast.LENGTH_SHORT ).show()
    create_dlg.hide()
  end
  write(luaconf, string.format("luapath=%q", luapath))
  activity.getActionBar().setSubtitle(".." .. luapath:match("(/[^/]+/[^/]+)$"))
  create_dlg.hide()
end

function create_dir()
  luadir = luadir .. create_e.getText().toString() .. "/"
  if File(luadir).exists() then
    Toast.makeText(activity, "文件夹已存在." .. luadir, Toast.LENGTH_SHORT ).show()
    create_dlg.hide()
   elseif File(luadir).mkdirs() then
    Toast.makeText(activity, "创建文件夹." .. luadir, Toast.LENGTH_SHORT ).show()
    create_dlg.hide()
   else
    Toast.makeText(activity, "创建失败." .. luadir, Toast.LENGTH_SHORT ).show()
    create_dlg.hide()
  end
end

function create_tl()
  luapath = luadir .. create_e.getText().toString() .. ".tl"

  if not pcall(read, luapath) then
    f = io.open(luapath, "a")
    f:write(code)
    f:close()
    table.insert(history, 1, luapath)
    editor.setText(code)
    Toast.makeText(activity, "新建文件." .. luapath, Toast.LENGTH_SHORT ).show()
    create_dlg.hide()
   else
    Toast.makeText(activity, "打开文件." .. luapath, Toast.LENGTH_SHORT ).show()
    create_dlg.hide()
  end

  activity.getActionBar().setSubtitle(".." .. luapath:match("(/[^/]+/[^/]+)$"))
  create_dlg.hide()
end


function create_aly()
  luapath = luadir .. create_e.getText().toString() .. ".aly"
  if not pcall(read, luapath) then
    f = io.open(luapath, "a")
    f:write(lcode)
    f:close()
    table.insert(history, 1, luapath)
    editor.setText(lcode)
    write(luaconf, string.format("luapath=%q", luapath))
    Toast.makeText(activity, "新建文件." .. luapath, Toast.LENGTH_SHORT ).show()
    create_dlg.hide()
   else
    Toast.makeText(activity, "打开文件." .. luapath, Toast.LENGTH_SHORT ).show()
    create_dlg.hide()
  end
  write(luaconf, string.format("luapath=%q", luapath))
  activity.getActionBar().setSubtitle(".." .. luapath:match("(/[^/]+/[^/]+)$"))
  create_dlg.hide()
end

function open(p)
  if p == luadir then
    return nil
  end

  if p:find("%.%./") then
    luadir = luadir:match("(.-)[^/]+/$")
    list(listview, luadir)
   elseif p:find("/") then
    luadir = luadir .. p

    list(listview, luadir)
   elseif p:find("%.alp$") then
    imports(luadir .. p)
    open_dlg.hide()
   else
    read(luadir .. p)
    open_dlg.hide()
    if File(luadir.."init.lua").isFile()
      luaproject=luadir
     else
      luaproject=nil
    end
  end
end

function PlayProject()
  if luaproject then
    local path=luaproject.."/main.lua"
    if debugisvar
      activity.newActivity(luaproject,[[require("debugs")]])
     else
      activity.newActivity(luaproject)
    end
   else
    activity.newActivity(luapath)
  end
end

function sort(a, b)
  if string.lower(a) < string.lower(b) then
    return true
   else
    return false
  end
end

function adapter(t)
  return ArrayListAdapter(activity, android.R.layout.simple_list_item_1, String(t))
end
function IsInTable(value, tbl)
  for k,v in ipairs(tbl) do
    if v == value then
      return true;
    end
  end
  return false;
end

FileSuffix={
  ["lua"]=true,
  ["html"]=true,
  ["aly"]=true,
  ["txt"]=true,
  ["java"]=true,
}
BitFileSuffix={
  ["jpg"]=true,
  ["alp"]=true,
  ["png"]=true,
  ["dex"]=true,
  ["so"]=true,
  ["pk8"]=true,
  ["mp4"]=true,
  ["mp3"]=true,
  ["tl"]=true,
  ["xacf"]=true,
  ["jar"]=true,
  ["luac"]=true
}


function list(v, p)
  --显示的文件的后缀名类型。
  local f = File(p)
  if not f then
    open_title.setText(p)
    local adapter = ArrayAdapter(activity, android.R.layout.simple_list_item_1, String {})
    v.setAdapter(adapter)
    return
  end

  local fs = f.listFiles()
  fs = fs or String[0]
  Arrays.sort(fs)
  local t = {}
  local ses
  local td = {}
  local tf = {}
  local bffs
  if p ~= "/" then
    table.insert(td, "../")
  end

  for n = 0, #fs - 1 do

    local name = fs[n].getName()
    ses=string.find(string.reverse(name),".",1,true)
    bffs=string.reverse(string.sub(string.reverse(name),1,(ses or 1)-1))
    if fs[n].isDirectory()
      table.insert(td, name .. "/")

     elseif FileSuffix[bffs] or BitFileSuffix[bffs]
      table.insert(tf, name)
    end
  end
  table.sort(td, sort)
  table.sort(tf, sort)
  for k, v in ipairs(tf) do
    table.insert(td, v)
  end
  open_title.setText(p)
  --local adapter=ArrayAdapter(activity,android.R.layout.simple_list_item_1, String(td))
  --v.setAdapter(adapter)
  open_dlg.setItems(td)
end

function list2(v, p)
  local adapter = ArrayListAdapter(activity, android.R.layout.simple_list_item_1, String(history))
  v.setAdapter(adapter)
  plist = history
end

function export(pdir)
  local function copy(input, output)
    local b = byte[2 ^ 16]
    local l = input.read(b)
    while l > 1 do
      output.write(b, 0, l)
      l = input.read(b)
    end
    input.close()
  end

  local f = File(pdir)
  local date = os.date("%y%m%d%H%M%S")
  local tmp = activity.getLuaExtDir("backup") .. "/" .. f.Name .. "_" .. date .. ".alp"
  local p = {}
  local e, s = pcall(loadfile(f.Path .. "/init.lua", "bt", p))
  if e then
    if p.mode then
      tmp = string.format("%s/%s_%s_%s-%s.%s", activity.getLuaExtDir("backup"), p.appname,p.mode, p.appver:gsub("%.", "_"), date,p.ext or "alp")
     else
      tmp = string.format("%s/%s_%s-%s.%s", activity.getLuaExtDir("backup"), p.appname, p.appver:gsub("%.", "_"), date,p.ext or "alp")
    end
  end
  local out = ZipOutputStream(FileOutputStream(tmp))
  local using={}
  local using_tmp={}
  function addDir(out, dir, f)
    local ls = f.listFiles()
    --entry=ZipEntry(dir)
    --out.putNextEntry(entry)
    for n = 0, #ls - 1 do
      local name = ls[n].getName()
      if name:find("%.apk$") or name:find("%.luac$") or name:find("^%.") then
       elseif p.mode and name:find("%.lua$") and name ~= "init.lua" then
        local ff=io.open(ls[n].Path)
        local ss=ff:read("a")
        ff:close()
        for u in ss:gmatch([[require *%b""]]) do
          if using_tmp[u]==nil then
            table.insert(using,u)
            using_tmp[u]=true
          end
        end
        local path, err = console.build(ls[n].Path)
        if path then
          entry = ZipEntry(dir .. name)
          out.putNextEntry(entry)
          copy(FileInputStream(File(path)), out)
          os.remove(path)
         else
          error(err)
        end
       elseif p.mode and name:find("%.aly$") then
        name = name:gsub("aly$", "lua")
        local path, err = console.build_aly(ls[n].Path)
        if path then
          entry = ZipEntry(dir .. name)
          out.putNextEntry(entry)
          copy(FileInputStream(File(path)), out)
          os.remove(path)
         else
          error(err)
        end
       elseif ls[n].isDirectory() then
        addDir(out, dir .. name .. "/", ls[n])
       else
        entry = ZipEntry(dir .. name)
        out.putNextEntry(entry)
        copy(FileInputStream(ls[n]), out)
      end
    end
  end

  addDir(out, "", f)
  local ff=io.open(f.Path.."/.using","w")
  ff:write(table.concat(using,"\n"))
  ff:close()
  entry = ZipEntry(".using")
  out.putNextEntry(entry)
  copy(FileInputStream(f.Path.."/.using"), out)

  out.closeEntry()
  out.close()
  return tmp
end
function getalpinfo(path)
  local app = {}
  loadstring(tostring(String(LuaUtil.readZip(path, "init.lua"))), "bt", "bt", app)()
  local str = string.format("名称: %s\
版本: %s\
包名: %s\
作者: %s\
说明: %s\
路径: %s",
  app.appname,
  app.appver,
  app.packagename,
  app.developer,
  app.description,
  path
  )
  return str, app.mode
end

function imports(path)
  create_imports_dlg()
  local mode
  imports_dlg.Message, mode = getalpinfo(path)
  if mode == "plugin" or path:match("^([^%._]+)_plugin") then
    imports_dlg.setTitle("导入插件")
   elseif mode == "build" or path:match("^([^%._]+)_build") then
    imports_dlg.setTitle("打包安装")
  end
  imports_dlg.show()
end

function importx(path, tp)
  local function copy(input, output)
    local b = byte[2 ^ 16]
    local l = input.read(b)
    while l > 1 do
      output.write(b, 0, l)
      l = input.read(b)
    end
    output.close()
  end

  local f = File(path)
  local app = {}
  loadstring(tostring(String(LuaUtil.readZip(path, "init.lua"))), "bt", "bt", app)()

  local s = app.appname or f.Name:match("^([^%._]+)")
  local out = activity.getLuaExtDir("project") .. "/" .. s

  if tp == "build" then
    out = activity.getLuaExtDir("bin/") .. "/" .. s
   elseif tp == "plugin" then
    out = activity.getLuaExtDir("plugin") .. "/" .. s
  end
  local d = File(out)
  if autorm then
    local n = 1
    while d.exists() do
      n = n + 1
      d = File(out .. "-" .. n)
    end
  end
  if not d.exists() then
    d.mkdirs()
  end
  out = out .. "/"
  local zip = ZipFile(f)
  local entries = zip.entries()
  for entry in enum(entries) do
    local name = entry.Name
    local tmp = File(out .. name)
    local pf = tmp.ParentFile
    if not pf.exists() then
      pf.mkdirs()
    end
    if entry.isDirectory() then
      if not tmp.exists() then
        tmp.mkdirs()
      end
     else
      copy(zip.getInputStream(entry), FileOutputStream(out .. name))
    end
  end
  zip.close()
  function callback2(s)
    LuaUtil.rmDir(File(activity.getLuaExtDir("bin/.temp")))
    bin_dlg.hide()
    bin_dlg.Message = ""
    if s==nil or not s:find("成功") then
      create_error_dlg()
      error_dlg.Message = s
      error_dlg.show()
    end
  end

  if tp == "build" then
    bin(out)
    return out
   elseif tp == "plugin" then
    Toast.makeText(activity, "导入插件." .. s, Toast.LENGTH_SHORT ).show()
    return out
  end
  luadir = out
  luapath = luadir .. "main.lua"
  read(luapath)
  Toast.makeText(activity, "导入工程." .. luadir, Toast.LENGTH_SHORT ).show()
  return out
end

func = {}
func.open = function()
  if BitFileSuffix[string.match(luapath,".*%.(.*)")]~=true
    save()
  end
  create_open_dlg()
  list(listview, luadir)
  open_dlg.show()
  if xaplugClick.OpenFile~=nil
    xaplugClick.OpenFile(luapath)
  end

end

func.new = function()
  save()
  create_create_dlg()
  create_dlg.setMessage(luadir)
  create_dlg.show()
end

func.history = function()
  save()
  create_open_dlg2()
  list2(listview2)
  open_edit.Text = ""
  open_dlg2.show()
end

func.create = function()
  save()
  create_project_dlg()
  project_dlg.show()
end

func.openproject = function()
  save()
  activity.newActivity("project/main.lua")
end
func.Anno=function()
  getAnno()
end

func.export = function()
  save()
  if luaproject then
    exportPrd = ProgressDialog(activity);
    exportPrd.setTitle("正在导出");
    exportPrd.show()
    task(export,luaproject,function(name)
      Toast.makeText(activity, "工程已导出." .. name, Toast.LENGTH_SHORT ).show()
      exportPrd.hide()
      activity.shareFile(name)
    end)

   else
    Toast.makeText(activity, "仅支持工程导出.", Toast.LENGTH_SHORT ).show()
  end
end

func.save = function()
  save()
end

func.play = function()

  if xaplugClick.runs~=nil
    xaplugClick.runs(luaPath,luaproject)
  end

  if func.check(true)
    then
    return
  end

  save()
  if isProjetCompil
    local dlg = AlertDialogBuilder(activity)
    dlg.setTitle("检测到项目可能为需要打包项目，是否继续运行。")
    dlg.setPositiveButton("取消", nil)
    dlg.setNegativeButton("确认", {onClick=PlayProject})
    dlg.show()
   else
    PlayProject()
  end
end

func.undo = function()
  editor.undo()
end

func.redo = function()
  editor.redo()
end

func.format = function()
  editor.format()
end

func.check = function(b)
  local src = editor.getText()
  src = src.toString()
  if luapath:find("%.aly$") then
    src = "return " .. src
  end
  local _, data = loadstring(src)
  if data then
    local _, _, line, data = data:find(".(%d+).(.+)")
    editor.gotoLine(tonumber(line))
    Toast.makeText(activity, line .. ":" .. data, Toast.LENGTH_SHORT ).show()
    return true
   elseif b then
   else
    Toast.makeText(activity, "没有语法错误", Toast.LENGTH_SHORT ).show()
  end
end

func.navi = function()
  create_navi_dlg()
  local str = editor.getText().toString()

  local fs = {}
  indexs = {}

  for si,sg,s in string.gfind(str,"([%w%._]* *=? *function *[%w%._]*%b())()")
    table.insert(fs,"Function: "..s)
    table.insert(indexs,si-1)
  end

  local adapter = ArrayAdapter(activity, android.R.layout.simple_list_item_1, String(fs))
  navi_list.setAdapter(adapter)
  navi_dlg.show()
end

func.seach = function()
  editor.search()
end

func.xacfExport=function()
  xacfExports(luadir)
end
func.gotoline = function()
  editor.gotoLine()
end

func.luac = function()
  save()
  local path, str = console.build(luapath)
  ---str是编译出错时的错误信息
 ---path是编译出来的luac文件名。
  --luapath是lua源文件名
  if path then
    Toast.makeText(activity, "编译完成: " .. path, Toast.LENGTH_SHORT ).show()
   else
    Toast.makeText(activity, "编译出错: " .. str, Toast.LENGTH_SHORT ).show()
  end
end

func.build = function()
  if xaplugClick.build~=nil
    xaplugClick.build(luaproject)
    --插件打包事件
  end
  save()
  if luaproject then
    console.bin(luaproject .. "/")
   else
    Toast.makeText(activity, "仅支持工程打包.", Toast.LENGTH_SHORT ).show()
    return
  end

end

buildfile = function()
  Toast.makeText(activity, "正在打包..", Toast.LENGTH_SHORT ).show()
  task(console.bin, luaPath.getText().toString(), appName.getText().toString(), appVer.getText().toString(), packageName.getText().toString(), apkPath.getText().toString(), function(s)
    status.setText(s or "打包出错!")
  end)
end

func.info = function()

  if not luaproject then
    Toast.makeText(activity, "仅支持修改工程属性.", Toast.LENGTH_SHORT ).show()
    return
  end

  save()
  activity.newActivity("projectinfo", { luaproject })
end

func.logcat = function()
  activity.newActivity("logcat")
end
func.help = function()
  activity.newActivity("help")
end
func.openjavaweb=function()
  activity.startActivity(Intent("android.intent.action.VIEW",Uri.parse("https://www.java.com/zh-CN/")))
end
func.java = function()
  activity.newActivity("javaapi/main")
end
func.gitWebsite=function()
  activity.startActivity(Intent("android.intent.action.VIEW",Uri.parse("https://github.com/MGLSIDE/ZAndrolua")))
end
func.openjavaenweb=function ()
  activity.startActivity(Intent("android.intent.action.VIEW",Uri.parse("https://www.java.com/en/")))
end
func.manual = function()
  activity.newActivity("luadoc")
end
func.openandroweb=function()
  activity.startActivity(Intent("android.intent.action.VIEW",Uri.parse("https://developer.android.google.cn/")))
end
func.helper = function()
  save()
  isupdate = true
  activity.newActivity("layouthelper/main", { luaproject, luapath })
end

key2 = [[N_9Rrnm8jJcdcXs7TQsXQBVA8Liq8mhU]]
key = [[QRDW1jiyM81x-T8RMIgeX1g_v76QSo6a]]
function joinQQGroup(key)
  local intent = Intent();
  intent.setData(Uri.parse("mqqopensdkapi://bizAgent/qm/qr?url=http%3A%2F%2Fqm.qq.com%2Fcgi-bin%2Fqm%2Fqr%3Ffrom%3Dapp%26p%3Dandroid%26k%3D" .. key));
  activity.startActivity(intent);
end
func.qq = function()
  joinQQGroup(key)
end
func.settingEditor = function()
  activity.newActivity("SettingEditors",{git_set_btn_onclick,luapath,luadir,luaproject})
end

func.about = function()
  onVersionChanged("", "")
end

func.fiximport = function()
  save()
  activity.newActivity("javaapi/fiximport", { luaproject, luapath })
end
func.plugin = function()
  activity.newActivity("plugin/main", { luaproject, luapath })
end

func.apke = function()

  activity.newActivity("apkExtract")
end

function onMenuItemSelected(id, item)
  --菜单事件
  switch2(item)
  {
    default2 = function()
      print("功能开发中。。。")
    end,
    [optmenu.play] = func.play,
    [optmenu.undo] = func.undo,
    [optmenu.redo] = func.redo,
    [optmenu.file_open] = func.open,
    [optmenu.file_history] = func.history,
    [optmenu.file_save] = func.save,
    [optmenu.file_new] = func.new,
    [optmenu.file_build] = func.luac,
    [optmenu.project_open] = func.openproject,
    [optmenu.project_build] = func.build,
    [optmenu.project_create] = func.create,
    [optmenu.project_export] = func.export,
    [optmenu.project_info] = func.info,
    [optmenu.code_format] = func.format,
    [optmenu.code_check] = func.check,
    [optmenu.code_import] = func.fiximport,
    [optmenu.goto_line] = func.gotoline,
    [optmenu.goto_func] = func.navi,
    [optmenu.goto_seach] = func.seach,
    [optmenu.more_helper] = func.helper,
    [optmenu.more_logcat] = func.logcat,
    [optmenu.more_java] = func.java,
    [optmenu.more_help] = func.help,
    [optmenu.more_manual] = func.manual,
    [optmenu.more_qq] = func.qq,
    [optmenu.more_about] = func.about,
    [optmenu.plugin] = func.plugin,
    [optmenu.more_gits]=func.gitWebsite,
    [optmenu.more_apke]=func.apke,
    [optmenu.more_setting]=func.settingEditor,
    [optmenu.openweb_openandroweb]=func.openandroweb,
    [optmenu.openweb_openjavaweb]=func.openjavaweb,
    [optmenu.openweb_openjavaenweb]=func.openjavaenweb,
    [optmenu.more_xacfExport]=func.xacfExport,
    [optmenu.more_Anno]=func.Anno,
  }
end
activity.setContentView(loadlayout(layout.main))
if AppSharedPreferences.getString("isxaplug",nil)=="true"
  xaplugControls.xaplugControl()
 else
  xaplugClick={}
end
function onCreate(s)
  if pcall(read, luapath) then
    last = last or 0
    if last < editor.getText().length() then
      editor.setSelection(last)
    end
   else
    luapath = activity.LuaExtDir .. "/new.lua"
    if not pcall(read, luapath) then
      write(luapath, code)
      pcall(read, luapath)
    end
  end
  --end
end

function onNewIntent(intent)
  local uri = intent.getData()
  if uri and uri.getPath():find("%.alp$") then
    imports(uri.getPath():match("/storage.+") or uri.getPath())
  end
end

function onResult(name, path,isprojet)
  --print(name,path)

  if name == "project/main.lua" then
    luadir = path .. "/"
    read(path .. "/main.lua")
    --open("main.lua")
   elseif name == "projectinfo" then
    activity.setTitle(path)
  end

end

function onActivityResult(req, res, intent)
  if res == 10000 then
    read(luapath)
    editor.format()
    return
  end
  if res ~= 0 then
    local data = intent.getStringExtra("data")
    local _, _, path, line = data:find("\n[	 ]*([^\n]-):(%d+):")
    if path == luapath then
      editor.gotoLine(tonumber(line))
    end
    local classes = require "javaapi.android"
    local c = data:match("a nil value %(global '(%w+)'%)")
    if c then
      local cls = {}
      c = "%." .. c .. "$"
      for k, v in ipairs(classes) do
        if v:find(c) then
          table.insert(cls, string.format("import %q", v))
        end
      end
      if #cls > 0 then
        create_import_dlg()
        import_dlg.setItems(cls)
        import_dlg.show()
      end
    end

  end
end

function onStart()
  reopen(luapath)
  if isupdate then
    editor.format()
  end
  isupdate = false
end

function onStop()
  if BitFileSuffix[string.match(luapath,".*%.(.*)")]~=true
    save()
    ---Toast.makeText(activity, "文件已保存."..luapath, Toast.LENGTH_SHORT ).show()
  end
  local f = io.open(luaconf, "wb")
  f:write( string.format("luapath=%q\nlast=%d", luapath, editor. getSelectionEnd() ))
  f:close()
  local f = io.open(luahist, "wb")
  f:write(string.format("history=%s", dump(history)))
  f:close()
end

--创建对话框
function create_navi_dlg()
  if navi_dlg then
    return
  end
  navi_dlg = Dialog(activity)
  navi_dlg.setTitle("导航")
  navi_list = ListView(activity)
  navi_list.onItemClick = function(parent, v, pos, id)

    editor.setSelection(indexs[pos + 1])
    navi_dlg.hide()
  end
  navi_dlg.setContentView(navi_list)
end

function create_imports_dlg()
  if imports_dlg then
    return
  end
  imports_dlg = AlertDialogBuilder(activity)
  imports_dlg.setTitle("导入")
  imports_dlg.setPositiveButton("确定", {
    onClick = function()
      local path = imports_dlg.Message:match("路径: (.+)$")
      if imports_dlg.Title == "打包安装" then
        importx(path, "build")
        imports_dlg.setTitle("导入")
       elseif imports_dlg.Title == "导入插件" then
        importx(path, "plugin")
        imports_dlg.setTitle("导入")
       else
        importx(path)
      end
  end })
  imports_dlg.setNegativeButton("取消", nil)
end

function create_delete_dlg()
  if delete_dlg then
    return
  end
  delete_dlg = AlertDialogBuilder(activity)
  delete_dlg.setTitle("删除文件")
  delete_dlg.setPositiveButton("确定", {
    onClick = function()
      if luapath:find(delete_dlg.Message) then
        Toast.makeText(activity, "不能删除正在打开的文件.", Toast.LENGTH_SHORT ).show()
       elseif LuaUtil.rmDir(File(delete_dlg.Message)) then
        Toast.makeText(activity, "已删除.", Toast.LENGTH_SHORT ).show()
        list(listview, luadir)
       else
        Toast.makeText(activity, "删除失败.", Toast.LENGTH_SHORT ).show()
      end
  end })
  delete_dlg.setNegativeButton("取消", nil)
end

TemplateConf=
{
  {
    name="无";
    projectTemple=nil
  },
  {
    name="网页转app";
    projectTemple="Web2APP.zip"
  },
  {
    name="简易帮助文档";
    projectTemple="EasyHelpDocument.zip"
  },
  {
    name="DrawerLayout";
    projectTemple="DrawerLayout.zip"
  },
  {
    name="TabBar";
    projectTemple="TabBar.zip"
  },
  {
    name="TitleBar";
    projectTemple="TitleBar.zip"
  },
  {
    name="TabBar and Drawer";
    projectTemple="TabBarAndDrawer.zip"
  }
}

TemplatePath=tostring(activity.getFilesDir()).."/Template/"

function ProjectTempleChoose()

  if not TemplateAdapter
    TemplateAdapter=LuaAdapter(activity,{
      LinearLayout;
      layout_width="fill";
      orientation="vertical";
      layout_height="fill";
      {TextView;
        textSize="22";
        gravity="center";
        TextColor="#000000";
        id="tv";
        layout_width="fill";
      },
      {View;
        layout_width="fill";
        layout_height="1%h";
    }})

    for k,v in pairs(TemplateConf)
      TemplateAdapter.add({tv={Text=v.name}})
    end

  end

  projectTempleDiaog=AlertDialog.Builder(activity)
  projectTempleDiaog.setView(loadlayout({
    LinearLayout;
    orientation="vertical";
    layout_width="fill";
    {
      ListView;
      layout_width="fill";
      Divider=ColorDrawable(0);
      Adapter=TemplateAdapter;
      OnItemClickListener={
        onItemClick=function(parent, v, pos,id)

          if TemplateConf[id].projectTemple
            projectTemple=TemplatePath..TemplateConf[id].projectTemple
           else
            projectTemple=nil
          end

          project_Temple.Text=TemplateConf[id].name
          projectTempleDiaog.hide()
        end
      }
    };
  }))

  projectTempleDiaog=projectTempleDiaog.show()
end

function imagdiog(imagpth,Title)
  limags= {LinearLayout;
    {
      ImageView;--图片控件
      id="lmagviews";
      src=imagpth;
      layout_width="1000";--图片宽度
      layout_height='2000';--图片高度
    };
  }
  local 图片对话框=Dialog(activity)--,R.Theme_AppLua_Dialog)--,R.style.BottomDialog)
  --设置弹窗布局
  图片对话框.setTitle(Title)
  图片对话框.setContentView(loadlayout(limags))
  --设置对话框标题
  图片对话框.getWindow().getAttributes().width=1000
  图片对话框.getWindow().getAttributes().height=2000
  图片对话框.show()
end

function create_open_dlg()
  if not open_dlg
    open_dlg = AlertDialogBuilder(activity)
    open_dlg.setTitle("打开")
    open_title = TextView(activity)
    listview = open_dlg.ListView
    listview.FastScrollEnabled = true

    listview.addHeaderView(open_title)
    listview.setOnItemClickListener(AdapterView.OnItemClickListener {
      onItemClick = function(parent, v, pos, id)

        if(string.match(v.Text,"%.xacf$")~=nil)
          xacfImport(luadir..v.Text,v.Text)
         elseif(string.match(v.Text,"%.png$")~=nil)
          imagdiog(luadir..v.Text,"图片查看器")
         else
          open(v.Text)
        end

      end
    })

    listview.onItemLongClick = function(parent, v, pos, id)
      if v.Text ~= "../" then
        create_delete_dlg()
        delete_dlg.setMessage(luadir .. v.Text)
        delete_dlg.show()
      end
      return true
    end

    --open_dlg.setItems{"空"}
    --open_dlg.setContentView(listview)
  end
end


function create_open_dlg2()
  if not open_dlg2
    open_dlg2 = AlertDialogBuilder(activity)
    --open_dlg2.getWindow().clearFlags(WindowManager.LayoutParams.FLAG_ALT_FOCUSABLE_IM);

    open_dlg2.setTitle("最近打开")
    open_dlg2.setView(loadlayout(layout.open2))

    --listview2=open_dlg2.ListView
    listview2.FastScrollEnabled = true
    --open_edit=EditText(activity)
    --listview2.addHeaderView(open_edit)

    open_edit.addTextChangedListener {
      onTextChanged = function(c)
        local s = tostring(c)
        if #s == 0 then
          listview2.setAdapter(adapter(plist))
        end
        local t = {}
        s = s:lower()
        for k, v in ipairs(plist) do
          if v:lower():find(s, 1, true) then
            table.insert(t, v)
          end
        end
        listview2.setAdapter(adapter(t))
      end
    }

    listview2.setOnItemClickListener(AdapterView.OnItemClickListener {
      onItemClick = function(parent, v, pos, id)
        if File(v.Text).exists() then
          luadir = v.Text:gsub("[^/]+$", "")
          read(v.Text)
          open_dlg2.hide()
         else
          listview2.adapter.remove(pos)
          table.remove(plist, id)
          Toast.makeText(activity, "文件不存在", 1000).show()
        end
      end
    })
  end
end

function create_create_dlg()
  if create_dlg then
    return
  end
  create_dlg = AlertDialogBuilder(activity)
  create_dlg.setMessage(luadir)
  create_dlg.setTitle("新建")
  create_dlg.setView(loadlayout({
    LinearLayout;
    layout_width="96%w";
    orientation="vertical";
    gravity="center";
    {
      EditText;
      layout_width="90%w";
      id="create_e";
    };
    {
      LinearLayout;
      layout_width="86%w";
      orientation="horizontal";
      {
        TextView;
        layout_width="16%w";
        textSize="26";
        Text=".ALY";
        onClick=create_aly;
        TextColor="#ff008577";
      };
      {
        TextView;
        layout_width="16%w";
        textSize="26";
        TextColor="#ff008577";
        onClick=create_dir;
        Text="DIR";
      };
      {
        TextView;
        layout_width="16%w";
        textSize="26";
        TextColor="#ff008577";
        onClick=create_lua;
        Text=".LUA";
      };
      {
        TextView;
        layout_width="16%w";
        TextColor="#ff008577";
        textSize="26";
        onClick=create_tl;
        Text=".TL";
      }
    }
  }))
end

create_create_dlg()

function create_project_dlg()
  if project_dlg then
    return
  end
  project_dlg = AlertDialogBuilder(activity)
  project_dlg.setTitle("新建工程")
  project_dlg.setView(loadlayout(layout.project))
  project_dlg.setPositiveButton("确定", { onClick = create_project })
  project_dlg.setNegativeButton("取消", nil)
  project_Temple.setOnClickListener({onClick=ProjectTempleChoose})
end

function create_build_dlg()
  if build_dlg then
    return
  end
  build_dlg = AlertDialogBuilder(activity)
  build_dlg.setTitle("打包")
  build_dlg.setView(loadlayout(layout.build))
  build_dlg.setPositiveButton("确定", { onClick = buildfile })
  build_dlg.setNegativeButton("取消", nil)
end

function create_bin_dlg()
  if bin_dlg then
    return
  end
  bin_dlg = ProgressDialog(activity);
  bin_dlg.setTitle("正在打包");
  bin_dlg.setMax(100);
end


cm = activity.getSystemService(activity.CLIPBOARD_SERVICE)

function copyClip(str)
  local cd = ClipData.newPlainText("label", str)
  cm.setPrimaryClip(cd)
  Toast.makeText(activity, "已复制到剪切板", 1000).show()
end

function create_import_dlg()
  if import_dlg then
    return
  end
  import_dlg = AlertDialogBuilder(activity)
  import_dlg.Title = "可能需要导入的类"
  import_dlg.setPositiveButton("确定", nil)

  import_dlg.ListView.onItemClick = function(l, v)
    copyClip(v.Text)
    import_dlg.hide()
    return true
  end
end

function create_error_dlg()
  if error_dlg then
    return
  end
  error_dlg = AlertDialogBuilder(activity)
  error_dlg.Title = "出错"
  error_dlg.setPositiveButton("确定", nil)
end

lastclick = os.time() - 2
function onKeyDown(e)
  local now = os.time()
  if e == 4 then

    if now - lastclick > 2 then
      --print("再按一次退出程序")
      Toast.makeText(activity, "再按一次退出程序.", Toast.LENGTH_SHORT ).show()
      lastclick = now
      return true
    end
  end
end
local cd1 = ColorDrawable(0x00ffffff)
local cd2 = ColorDrawable(0x88000088)

local pressed = android.R.attr.state_pressed;
local window_focused = android.R.attr.state_window_focused;
local focused = android.R.attr.state_focused;
local selected = android.R.attr.state_selected;

function click(v)
  editor.paste(v.Text)
end

function newButton(text)
  local sd = StateListDrawable()
  sd.addState({ pressed }, cd2)
  sd.addState({ 0 }, cd1)
  local btn = TextView()
  btn.TextSize = 20;
  local pd = btn.TextSize / 2
  btn.setPadding(pd, pd / 2, pd, pd / 4)
  btn.Text = text
  btn.setBackgroundDrawable(sd)
  btn.onClick = click
  return btn
end
local ps = { "(", ")", "[", "]", "{", "}", "\"", "=", ":", ".", ",", "_", "+", "-", "*", "/", "\\", "%", "#", "^", "$","--[[","]]","?", "&", "|", "<", ">", "~", ";", "'" };
for k, v in ipairs(ps) do
  ps_bar.addView(newButton(v))
end


function initUserAdds()

  if io.open((luaproject or luapath).."setting.luas")

    local SyntaxhintTable={}
    local Noerr=pcall(loadfile((luaproject or luapath).."setting.luas", "bt", SyntaxhintTable))

    if Noerr

      for k,v in pairs(SyntaxhintTable.addPackage or {})
        editor.addPackage(k,v)
      end

      editor.addNames(SyntaxhintTable.addName or {})

     else

      Toast.makeText(activity, "自定义语法提示配置文件错误。", Toast.LENGTH_SHORT ).show()

    end

  end
end
initUserAdds()

---部分输入补全提示。
local function adds()
  require "import"
  local classes = require "javaapi.android"

  local ms = { "onCreate",
    "onStart",
    "this",
    "onResume",
    "onPause",
    "onStop",
    "onDestroy",
    "onActivityResult",
    "onResult",
    "onCreateOptionsMenu",
    "onOptionsItemSelected",
    "onClick",
    "onTouch",
    "_VERSION",
    "LuaListView",
    "...",
    "onLongClick",
    "onItemClick",
    "onItemLongClick",
  }


  local buf = String[#ms + #classes]
  for k, v in ipairs(ms) do
    buf[k - 1] = v
  end
  local l = #ms
  for k, v in ipairs(classes) do
    buf[l + k - 1] = string.match(v, "%w+$")
  end
  return buf
end
task(adds, function(buf)
  editor.addNames(buf)
end)
local buf={}
local tmp={}
local curr_ms=luajava.astable(LuaActivity.getMethods())

for k,v in ipairs(curr_ms) do
  v=v.getName()
  if not tmp[v] then
    tmp[v]=true
    table.insert(buf,v)
  end
end

editor.addNames({"activity","javaClassTools","ZipIoTools","lposix"})
editor.addPackage("activity",buf)
editor.addPackage("javaClassTools",
{"getClassAttribute",
  "isObjectClass",
  "getClassMethodName",
  "getMethodArray",
  "getObjectClassAttribute"})
editor.addPackage("ZipIoTools",{
  "addfile",
  "extractZipComment"
})

function fix(c)
  local classes = require "javaapi.android"
  if c then
    local cls = {}
    c = "%." .. c .. "$"
    for k, v in ipairs(classes) do
      if v:find(c) then
        table.insert(cls, string.format("import %q", v))
      end
    end
    if #cls > 0 then
      create_import_dlg()
      import_dlg.setItems(cls)
      import_dlg.show()
    end
  end
end

function onKeyShortcut(keyCode, event)
  local filteredMetaState = event.getMetaState() & ~KeyEvent.META_CTRL_MASK;
  if (KeyEvent.metaStateHasNoModifiers(filteredMetaState)) then
    switch(keyCode)
     case
      KeyEvent.KEYCODE_O
      func.open();
      return true;
     case
      KeyEvent.KEYCODE_P
      func.openproject();
      return true;
     case
      KeyEvent.KEYCODE_S
      func.save();
      return true;
     case
      KeyEvent.KEYCODE_E
      func.check();
      return true;
     case
      KeyEvent.KEYCODE_R
      func.play();
      return true;
     case
      KeyEvent.KEYCODE_N
      func.navi();
      return true;
     case
      KeyEvent.KEYCODE_U
      func.undo();
      return true;
     case
      KeyEvent.KEYCODE_I
      fix(editor.getSelectedText());
      return true;
    end
  end
  return false;
end
