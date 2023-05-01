function getAnno()
  --调用水仙平台API。
  --2974349657是本项目作者自己的水仙平台账号。
  --没有密码信息，别想盗号。
  --攻击更别想，水仙平台可不是那么好打的
  AannPrd=ProgressDialog.show(activity,nil,'加载中')
  Http.post("http://shuixian.ltd/main/api/bulletin/bulletin.php",{admin="2974349657"},nil,nil,function(code,content)
    AannPrd.hide()
    if code==200
      local jsonData=cjson.decode(content)
      if jsonData.code==1
        AlertDialog.Builder(this)
        .setView(loadlayout({
          LinearLayout;
          layout_height="60%h";
          layout_width="90%w";
          orientation="vertical";
          {
            TextView;
            gravity="center";
            Text="公告";
            layout_width="fill";
            layout_height="5%h";
            TextColor="#FF000000";
            textSize="25";
          };
          {View;
            backgroundColor="#FF7F7F7F";
            layout_width="fill";
            layout_height="0.1%h";
          };
          {
            TextView;
            layout_width="fill";
            layout_height="-1";
            Text=jsonData.data;
            TextIsSelectable=true;
            TextColor="#FF000000";
            TextSize="18";
          };
          {
            TextView;
            layout_width="fill";
            Text="@2023 水仙平台提供服务器和技术支持";
          };
        }))
        .show()
       else
        print("获取公告失败或程序错误！")
      end
     else
      print("服务器错误！")
    end

  end)

end