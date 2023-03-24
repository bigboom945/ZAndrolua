require "import"
import "java.util.zip.ZipOutputStream"
import "android.net.Uri"
import "java.io.File"
import "android.widget.Toast"
import "java.util.zip.CheckedInputStream"
import "java.io.FileInputStream"
import "android.content.Intent"
import "java.security.Signer"
import "java.util.ArrayList"
import "java.lang.System"
import "java.util.zip.ZipFile"
import "java.io.FileOutputStream"
import "java.io.BufferedOutputStream"
import "java.util.zip.ZipInputStream"
import "java.io.BufferedInputStream"
import "java.util.zip.ZipEntry"
import "android.app.ProgressDialog"
import "java.util.zip.CheckedOutputStream"
import "java.util.zip.Adler32"
import "com.zajt.*"
require "xalstd"
require "xml"




local bin_dlg, error_dlg
local function update(s)
  bin_dlg.setMessage(s)
end

function OperZaGradle(gradlepath)

end


function WhetherExistTXTFile(dirs)

  file = File(dirs);

  filelist = file.listFiles();

  for k,f in pairs(luajava.astable(filelist))
    filename = f.getName();
    if(string.match(filename,".*%.(apk)"))


      return true;
    end
  end
  return false;
end
local function callback(s)
  LuaUtil.rmDir(File(activity.getLuaExtDir("bin/.temp")))
  bin_dlg.dismiss()

  if s:find("成功") then
    AlertDialog.Builder(activity)
    .setMessage(s)
    .show()
   else
    error_dlg.Message = s
    error_dlg.show()
  end

end

local function create_bin_dlg()
  if bin_dlg then
    return
  end
  bin_dlg = ProgressDialog(activity);
  bin_dlg.setTitle("正在打包");
  bin_dlg.setMax(100);
end



local function create_error_dlg2()
  if error_dlg then
    return
  end
  error_dlg = AlertDialogBuilder(activity)
  error_dlg.Title = "出错"
  error_dlg.setPositiveButton("确定", nil)
end

local function binapk(luapath, apkpath)
  require "import"
  compile "mao"
  compile "sign"
  compile "dx-1.14"
  import "console"
  import "java.util.zip.*"
  import "java.io.*"
  import "xml"
  import "mao.util.*"
  import "mao.res.*"
  import "apksigner.*"
  import "com.android.dx.merge.DexMerger"
  import "com.android.dx.merge.CollisionPolicy"
  import "com.android.dx.dex.file.DexFile"
  import "com.android.dx.dex.DexOptions"
  import "com.android.dex.Dex"
  import "com.android.dx.command.dexer.DxContext"
  import "java.io.ByteArrayOutputStream"
  import "java.io.ByteArrayInputStream"
  import "tl"
  local b = byte[65536]
  -----2 ^ 16
  local CompileWarnings=""


  local function copy(input, output)
    LuaUtil.copyFile(input, output)
    input.close()
    --[[local l=input.read(b)
      while l>1 do
        output.write(b,0,l)
        l=input.read(b)
      end]]
  end



  local function isalylibErr(path,name,dir)

    if (NotLuaCompile[dir..name] or NotLuaCompileAll)
      local f,st=io.open(path)
      if st then
        return nil,st
       else
        return path
      end
    end

    return console.build_aly(path)
  end

  local function islualibErr(path,name,dir)
    if (NotLuaCompile[dir..name] or NotLuaCompileAll)
      local rf,err=loadfile(path, "bt", {})
      if err~=nil
        return nil,err
       else
        return path,nil
      end
    end

    return console.build(path)
  end

  local function v2k(tab)
    for k,v in ipairs(tab)
      tab[v]=true;
    end
  end




  local function copy2(input, output)
    LuaUtil.copyFile(input, output)
  end

  local temp = File(apkpath).getParentFile();
  if (not temp.exists()) then

    if (not temp.mkdirs()) then
      error("create file " .. temp.getName() .. " fail");
    end

  end


  local tmp = luajava.luadir .. "/tmp.apk"
  local info = activity.getApplicationInfo()
  local ver = activity.getPackageManager().getPackageInfo(activity.getPackageName(), 0).versionName
  local code = activity.getPackageManager().getPackageInfo(activity.getPackageName(), 0).versionCode

  --local zip=ZipFile(info.publicSourceDir)

  local zipFile = File(info.publicSourceDir)
  local fis = FileInputStream(zipFile);
  --local checksum = CheckedInputStream(fis, Adler32());
  local zis = ZipInputStream(BufferedInputStream(fis));

  local fot = FileOutputStream(tmp)
  --local checksum2 = CheckedOutputStream(fot, Adler32());

  local out = ZipOutputStream(BufferedOutputStream(fot))
  local f = File(luapath)
  local errbuffer = {}
  local replace = {}
  local checked = {}
  local lualib = {}
  local md5s = {}
  local libs = File(activity.ApplicationInfo.nativeLibraryDir).list()
  libs = luajava.astable(libs)
  for k, v in ipairs(libs) do
    --libs[k]="lib/armeabi/"..libs[k]
    replace[v] = true
  end

  local mdp = activity.Application.MdDir
  local function getmodule(dir)
    local mds = File(activity.Application.MdDir .. dir).listFiles()
    mds = luajava.astable(mds)
    for k, v in ipairs(mds) do
      if mds[k].isDirectory() then
        getmodule(dir .. mds[k].Name .. "/")
       else
        mds[k] = "lua" .. dir .. mds[k].Name
        replace[mds[k]] = true
      end
    end
  end

  getmodule("/")

  local function checklib(path,str)
    if checked[path] then
      return
    end
    local cp, lp,s
    checked[path] = true

    if(str)
      s=str
     else
      local f = io.open(path)
      s = f:read("*a")
      f:close()
    end

    for m, n in s:gmatch("require *%(? *\"([%w_]+)%.?([%w_]*)") do
      cp = string.format("lib%s.so", m)
      if n ~= "" then
        lp = string.format("lua/%s/%s.lua", m, n)
        m = m .. '/' .. n
       else
        lp = string.format("lua/%s.lua", m)
      end
      if replace[cp] then
        replace[cp] = false
      end
      if replace[lp] then
        checklib(mdp .. "/" .. m .. ".lua")
        replace[lp] = false
        lualib[lp] =mdp .. "/"..m .. ".lua"
      end
    end

    for m, n in s:gmatch("import *%(? *\"([%w_]+)%.?([%w_]*)") do
      cp = string.format("lib%s.so", m)
      if n ~= "" then
        lp = string.format("lua/%s/%s.lua", m, n)
        m = m .. '/' .. n
       else
        lp = string.format("lua/%s.lua", m)
      end
      if replace[cp] then
        replace[cp] = false
      end
      if replace[lp] then
        checklib(mdp .. "/" .. m .. ".lua")
        replace[lp] = false
        lualib[lp] =mdp .. "/" ..m .. ".lua"
      end
    end
  end





  replace["libluajava.so"] = false
  --此处false实际上作用为true
  replace["lassets/"]=true

  local function addDir(out, dir, f)

    if dir=="so/"
      return
    end


    if dir=="BuildScript/"
      return
    end

    if(NoAddDir[dir]~=nil)
      return
    end


    local entry = ZipEntry("assets/" .. dir)
    out.putNextEntry(entry)
    local ls = f.listFiles()
    for n = 0, #ls - 1 do
      local name = ls[n].getName()
      if name==(".using") then
        checklib(luapath .. dir .. name)
       elseif NotAddFile[name]~= nil then
       elseif(isRemoveInitLua and name=="init.lua")
        local path=luapath .. dir .. name
        if(debugmode)
          path=path.."c"
          io.open(path,'wb'):write("debugmode=true"):close()
          if replace["assets/" .. dir .. name] then
            table.insert(errbuffer, dir .. name .. "/.aly")
          end

          local entry = ZipEntry("assets/" .. dir .. name)
          out.putNextEntry(entry)
          replace["assets/" .. dir .. name] = true
          copy(FileInputStream(File(path)), out)
          table.insert(md5s, LuaUtil.getFileMD5(path))
          os.remove(path)
        end

       elseif name:find("%.apk$") or name:find("%.luac$") or name:find("^%.") then
        --- elseif(no_pack_file_b[name])
       elseif name:find("%.lua$") then
        checklib(luapath .. dir .. name)
        local path, err= islualibErr(luapath .. dir .. name,name,dir)
        if path then
          if replace["assets/" .. dir .. name] then
            table.insert(errbuffer, dir .. name .. "/.aly")
          end

          local entry = ZipEntry("assets/" .. dir .. name)
          out.putNextEntry(entry)
          replace["assets/" .. dir .. name] = true
          copy(FileInputStream(File(path)), out)
          table.insert(md5s, LuaUtil.getFileMD5(path))
          os.remove(path)
         else
          table.insert(errbuffer, err)
        end

       elseif (name:find("%.tl$") and OpenTeal) then

        if(not (Teal.TypeDescFile or {})[dir..name])

          package.path=luapath ..dir.."?.lua;"
          package.path=package.path..activity.getLuaLibPath().."/TealTypeModel/?.lua;"

          local name2, err,GenCode,warnings= console.build_tl(luapath .. dir .. name,name,dir,not ((NotLuaCompile[dir..name] or NotLuaCompileAll)))

          if(warnings)
            CompileWarnings=CompileWarnings..luapath .. dir ..name..":"..warnings.."\n"
          end

          if name2 then

            local path=luapath .. dir ..name2

            checklib(path,GenCode)

            if replace["assets/" .. dir .. name2] then
              table.insert(errbuffer, dir .. name2 .. "/.aly")
            end

            local entry = ZipEntry("assets/" .. dir .. name2)
            out.putNextEntry(entry)

            replace["assets/" .. dir .. name2] = true
            copy(FileInputStream(File(path)), out)
            table.insert(md5s, LuaUtil.getFileMD5(path))
            os.remove(path)

           else
            table.insert(errbuffer, err)
          end
        end

       elseif name:find("%.dex$") then
        if(MergeDex[dir..name] or MergeDexAll)
          table.insert(MergeDexList,Dex(File(luapath..dir..name)))
         else
          local entry = ZipEntry("assets/" .. dir .. name)
          out.putNextEntry(entry)
          replace["assets/" .. dir .. name] = true
          copy(FileInputStream(ls[n]), out)
          table.insert(md5s, LuaUtil.getFileMD5(ls[n]))
        end

       elseif name:find("%.aly$") then

        local path, err = isalylibErr(luapath .. dir .. name,name,dir)

        if path then

          if (not (NotLuaCompile[dir..name] or NotLuaCompileAll))
            name = name:gsub("aly$", "lua")
          end

          if replace["assets/" .. dir .. name] then
            table.insert(errbuffer, dir .. name .. "/.aly")
          end
          local entry = ZipEntry("assets/" .. dir .. name)
          out.putNextEntry(entry)

          replace["assets/" .. dir .. name] = true
          copy(FileInputStream(File(path)), out)
          table.insert(md5s, LuaUtil.getFileMD5(path))
          os.remove(path)
         else
          table.insert(errbuffer, err)
        end

       elseif ls[n].isDirectory() then
        addDir(out, dir .. name .. "/", ls[n])
       else
        local entry = ZipEntry("assets/" .. dir .. name)
        out.putNextEntry(entry)
        replace["assets/" .. dir .. name] = true
        copy(FileInputStream(ls[n]), out)
        table.insert(md5s, LuaUtil.getFileMD5(ls[n]))
      end
    end
  end


  this.update("正在编译...");
  if f.isDirectory() then
    require "permission"
    dofile(luapath .. "init.lua")


    if MainBuildScript~=nil and MainBuildScript~=""
      dofile(luapath..MainBuildScript..".lua")
     else
      if File(luapath.."buildScript/main.lua").exists()==true
        dofile(luapath.."buildScript/main.lua")
      end
    end

    NoAddDir=NoAddDir or {}
    --不添加进安装包里面的文件夹

    NotLuaCompile=NotLuaCompile or {}

    if(NotLuaCompile=="All")
      NotLuaCompileAll=true
      NotLuaCompile={}
     else
      NotLuaCompileAll=false
    end

    --不编译的代码文件

    MergeDex=MergeDex or {}

    if(MergeDex=="All")
      MergeDexAll=true
      MergeDex={}
     else
      MergeDexAll=false
    end

    --要合并的项目中dex文件

    NotAddFile=NotAddFile or {}
    --不添加进安装包里面的文件

    NotLuaLibCompile=NotLuaLibCompile or {}


    if(NotLuaLibCompile=="All")
      NotLuaLibCompileAll=true
      NotLuaLibCompile={}
     else
      NotLuaLibCompileAll=false
    end


    Teal=Teal or {}

    MergeDexList={}
    v2k(NoAddDir)
    v2k(NotLuaCompile)
    v2k(NotAddFile)
    v2k(MergeDex)
    v2k(NotLuaLibCompile)
    v2k(Teal.TypeDescFile or {})


    if user_permission
      for k, v in ipairs(user_permission) do
        user_permission[v] = true
      end
    end

    local ss, ee = pcall(addDir, out, "", f)

    if not ss then
      table.insert(errbuffer, ee)
    end


    local z1sf
    local z1s

    if File(luapath.."so").isDirectory()
      --添加用户自定义so
      lpats=luajava.astable(File(luapath.."so").list())
      for k,v in ipairs(lpats)
        z1sf=File(luapath.."so/"..tostring(lpats[k]).."/")
        if z1sf.isDirectory()
          z1s=luajava.astable(z1sf.listFiles())
          for k2,v2 in ipairs(z1s)
            local welx = z1s[k2]
            local entry = ZipEntry("lib/"..tostring(lpats[k]).."/"..z1s[k2].getName())

            out.putNextEntry(entry)
            copy(FileInputStream(welx), out)
          end
        end

      end

    end


    local wel = File(luapath .. "icon.png")
    if wel.exists() then
      local entry = ZipEntry("res/drawable/icon.png")
      out.putNextEntry(entry)
      replace["res/drawable/icon.png"] = true
      copy(FileInputStream(wel), out)
    end
    local wel = File(luapath .. "welcome.png")
    if wel.exists() then
      local entry = ZipEntry("res/drawable/welcome.png")
      out.putNextEntry(entry)
      replace["res/drawable/welcome.png"] = true
      copy(FileInputStream(wel), out)
    end
   else
    return "error"
  end

  for name, v in pairs(lualib) do
    --local path
    local path, err;

    if (NotLuaLibCompile[name] or NotLuaLibCompileAll)
      local rf,err=loadfile(v, "bt", {})
      if err~=nil
        path,err=nil,err
       else
        path,err=v,nil
      end
     else
      path,err=console.build(v)
    end

    if path
      then
      local entry = ZipEntry(name)
      out.putNextEntry(entry)
      copy(FileInputStream(File(path)), out)
      table.insert(md5s, LuaUtil.getFileMD5(path))
      os.remove(path)
     else
      table.insert(errbuffer, err)
    end
  end

  function touint32(i)
    local code = string.format("%08x", i)
    local uint = {}
    for n in code:gmatch("..") do
      table.insert(uint, 1, string.char(tonumber(n, 16)))
    end
    return table.concat(uint)
  end

  this.update("正在打包...")
  local entry = zis.getNextEntry();

  while entry do
    local name = entry.getName()
    local lib = name:match("([^/]+%.so)$")
    if replace[name] then
     elseif lib and replace[lib] then
     elseif name:find("^assets/") then
     elseif name:find("^lua/") then
     elseif name:find("META%-INF") then
     elseif (name=="classes.dex") and ((#MergeDexList)>0) then
      table.insert(MergeDexList,Dex(LuaUtil.readAll(zis)))
     else
      local entry = ZipEntry(name)
      out.putNextEntry(entry)
      if entry.getName() == "AndroidManifest.xml" then
        if path_pattern and #path_pattern > 1 then
          path_pattern = ".*\\\\." .. path_pattern:match("%w+$")
        end
        local list = ArrayList()
        local xmls = AXmlDecoder.read(list, zis)

        local req = {
          [activity.getPackageName()] = packagename,
          [info.nonLocalizedLabel] = appname,
          [ver] = appver,
          [".*\\\\.alp"] = path_pattern or "",
          [".*\\\\.lua"] = "",
          [".*\\\\.luac"] = "",
        }
        for n = 0, list.size() - 1 do
          local v = list.get(n)
          if req[v] then
            list.set(n, req[v])
           elseif user_permission then
            local p = v:match("%.permission%.([%w_]+)$")
            if p and (not user_permission[p]) then
              list.set(n, "")
            end
          end
        end
        local pt =activity.getLuaPath(".tmp")

        local fo = FileOutputStream(pt)
        xmls.write(list, fo)
        local code = activity.getPackageManager().getPackageInfo(activity.getPackageName(), 0).versionCode
        fo.close()
        local f = io.open(pt)
        local s = f:read("a")
        f:close()
        s = string.gsub(s, touint32(code), touint32(tointeger(appcode) or 1),1)
        s = string.gsub(s, touint32(18), touint32(tointeger(appsdk) or 18),1)
        s = string.gsub(s, touint32(23), touint32(tointeger(appSdk_target) or 23),1)
        local f = io.open(pt, "w")
        f:write(s)
        f:close()

        local fi = FileInputStream(pt)
        copy(fi, out)
        os.remove(pt)

       elseif not entry.isDirectory() then
        copy2(zis, out)
      end
    end

    entry = zis.getNextEntry()
  end


  if((#MergeDexList)>0)
    local dexc=DxContext()
    local dexs=DexMerger(Dex(MergeDexList),CollisionPolicy.FAIL,dexc).merge();
    local entry = ZipEntry("classes.dex")
    out.putNextEntry(entry)
    dexs.writeTo(out)
    table.insert(md5s, LuaUtil.getFileMD5(ByteArrayInputStream(dexs.getBytes())))
  end

  out.setComment(table.concat(md5s))
  --print(table.concat(md5s,"/n"))

  zis.close();
  out.closeEntry()
  out.close()

  if #errbuffer == 0 then
    this.update("正在签名...");

    os.remove(apkpath)
    Signer.sign(tmp, apkpath)
    activity.installApk(apkpath)
    --[[import "android.net.*"
        import "android.content.*j"
        i = Intent(Intent.ACTION_VIEW);
        i.setDataAndType(activity.getUriForFile(File(apkpath)), "application/vnd.android.package-archive");
        i.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
        i.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        this.update("正在打开...");
        activity.startActivityForResult(i, 0);]]

    if(CompileWarnings~="")
      CompileWarnings="\nTealWarnings:\n"..CompileWarnings
    end

    return "打包成功:"..apkpath.."\n编译信息:"..CompileWarnings
   else
    os.remove(tmp)
    return "打包出错:\n " .. table.concat(errbuffer, "\n").."\nTealWarnings:\n"..CompileWarnings
  end

end

--luabindir=activity.getLuaExtDir("bin")
--print(activity.getLuaExtPath("bin","a"))
local function bin(path)
  local p={}
  local e, s = pcall(loadfile(path .. "init.lua", "bt", p))
  if e then
    create_error_dlg2()
    create_bin_dlg()
    bin_dlg.show()
    activity.newTask(binapk, update, callback).execute { path, activity.getLuaExtPath("bin", p.appname .. "_" .. p.appver .. ".apk") }
   else
    Toast.makeText(activity, "工程配置文件错误." .. s, Toast.LENGTH_SHORT).show()
  end
  System.gc()
end

--bin(activity.getLuaExtDir("project/demo").."/")
return bin