module(...,package.seeall)
--by nirenr

local function ps(str)
  str = str:gsub("%b\"\"",""):gsub("%b\'\'","")
  local _,f= str:gsub ('%f[%w]function%f[%W]',"")
  local _,t= str:gsub ('%f[%w]then%f[%W]',"")
  local _,i= str:gsub ('%f[%w]elseif%f[%W]',"")
  local _,d= str:gsub ('%f[%w]do%f[%W]',"")
  local _,e= str:gsub ('%f[%w]end%f[%W]',"")
  local _,r= str:gsub ('%f[%w]repeat%f[%W]',"")
  local _,u= str:gsub ('%f[%w]until%f[%W]',"")
  local _,a= str:gsub ("{","")
  local _,b= str:gsub ("}","")
  return (f+t+d+r+a)*4-(i+e+u+b)*4
end


local function _format()
  local p=0
  return function(str)
    str=str:gsub("[ \t]+$","")
    str=string.format('%s%s',string.rep(' ',p),str)
    p=p+ps(str)
    return str
  end
end


function format(Text)
  local t=os.clock()
  local Format=_format()
  Text=Text:gsub('[ \t]*([^\r\n]+)',function(str)return Format(str)end)
  print('操作完成,耗时:'..os.clock()-t)
  return Text
end


function build(path)
  if path then
    local str,st=loadfile(path)
    if st then
      return nil,st
    end

    local path=path..'c'

    local st,str=pcall(string.dump,str,true)
    if st then
      f=io.open(path,'wb')
      f:write(str)
      f:close()
      return path
     else
      os.remove(path)
      return nil,str
    end
  end
end


function build_tl(path2,name,dir,isluac)

  package.path=path2.."?.lua;"
  package.path=package.path..activity.getLuaLibPath().."/TealTypeModel/?.lua;"


  local names=string.gsub(name,"tl$","lua")
  local path=string.gsub(path2,"tl$","lua")

  if(io.open(path))
    return nil,string.format("Teal (tl) files and Lua files cannot exist with the same name. ErroFile:%q,%q",name,names),""
  end


  local f=io.open(path2)
  local str=f:read("*a")
  f:close()

  local GenCode,CompileMassage=tl.gen(str)

  local ErrorMsg=""
  local warnings=""
  local isErr=false

  for k,v in ipairs(CompileMassage.syntax_errors)
    isErr=true
    ErrorMsg=ErrorMsg..string.format("Line %q,Char %q: %q",v.y,v.x,v.msg).."\n"
  end


  for k,v in ipairs(CompileMassage.type_errors)
    isErr=true
    ErrorMsg=ErrorMsg..string.format("Line %q,Char %q: %q",v.y,v.x,v.msg).."\n"
  end

  if(isErr)
    return nil,path2..":\n"..ErrorMsg,GenCode,warnings
  end

  for k,v in ipairs(CompileMassage.warnings)
    warnings=warnings..string.format("Line %q,Char %q,tag %q: %q",v.y,v.x,v.tag,v.msg).."\n"
  end


  if((isluac))
    if path then


      local str,st=loadstring(GenCode)

      if st then
        return nil,st,GenCode,warnings
      end

      local st,str=pcall(string.dump,str,true)

      if st then
        io.open(path,'wb'):write(str):close()
        return names,nil,GenCode,warnings
       else
        return nil,str,GenCode,warnings
      end

    end

   else
    io.open(path,'wb'):write(GenCode):close()
    return names,nil,GenCode,warnings
  end

end



function build_aly(path2)
  if path2 then
    local f,st=io.open(path2)

    if st then
      return nil,st
    end

    local str=f:read("*a")
    f:close()
    str=string.format("return \n%s",str)
    local path=path2..'c'
    str,st=loadstring(str,path2:match("[^/]+/[^/]+$"),"bt")
    if st then
      return nil,st:gsub("%b[]",path2,1)
    end

    local st,str=pcall(string.dump,str,true)

    if st then
      f=io.open(path,'wb')
      f:write(str)
      f:close()
      return path
     else
      os.remove(path)
      return nil,str
    end
  end
end

