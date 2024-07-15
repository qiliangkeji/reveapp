import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/api/InfoApi.dart';
import 'package:file_preview/file_preview.dart';
import 'package:flutter_application_2/config/SlideUpPageRoute.dart';
import '../../api/AuthApi.dart';
import '../../enums/FileType.dart';
import '../../util/SpUtils.dart';

/// 主页
class Index extends StatefulWidget {
  Index({super.key});

  @override
  State<Index> createState() => _IndexState();
}

class _IndexState extends State<Index> with AutomaticKeepAliveClientMixin {
  // 文件控制器
  FilePreviewController controller = FilePreviewController();

  late List currentList = [];
  var title = "存储";
  String currentPath = ""; // 当前路径

  @override
  void initState() {
    super.initState();
    getRootFileList();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final pageWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView.builder(
          itemCount: currentList.length,
          itemExtent: 65,
          itemBuilder: (context, index) {
            var obj = currentList[index];
            return GestureDetector(
              onLongPressStart: (details) {
                _showContextMenu(context, details, obj);
              },
              child: ListTile(
                leading: IconTheme(
                  data: IconThemeData(size: 35),
                  child: Icon(
                    FileType.getIconByTypeAndName(obj['type'], obj['name']),
                    color: FileType.getColorByValue(obj['type'], obj['name']),
                  ),
                ),
                title: Text(
                  obj['name'],
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 16),
                ),
                subtitle: Text(
                  "修改于: ",
                  style: TextStyle(fontSize: 13, color: Colors.black54),
                ),
                onTap: () {
                  inDir(obj);
                },
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        shape: CircleBorder(),
        onPressed: () {
          _showBottomSheet(context);
        },
      ),
    );
  }

  void getRootFileList() async {
    var result = await InfoApi.getRootFileList();
    var objects = result['data']['objects'];
    setState(() {
      currentList = objects;
      currentPath = ""; // 根目录
    });
  }

  void inDir(obj) async {
    if (obj['type'] == FileType.DIR.value) {
      var currentMenu = currentPath + "/" + obj['name'];
      await SpUtils.setString('currentMenu', currentMenu);
      var result = await InfoApi.getRootFileList();
      var objects = result['data']['objects'];
      setState(() {
        title = obj['name'];
        currentList = objects;
        currentPath = currentMenu; // 更新当前路径
      });
    }
  }

  void _showContextMenu(BuildContext context, LongPressStartDetails details, var obj) {
    showMenu(
      context: context,
      surfaceTintColor: Colors.white,
      color: Colors.white,
      position: RelativeRect.fromLTRB(
        details.globalPosition.dx,
        details.globalPosition.dy,
        details.globalPosition.dx,
        details.globalPosition.dy,
      ),
      items: [
        PopupMenuItem(
          value: 'download',
          child: Row(
            children: [
              Icon(Icons.download),
              SizedBox(width: 8),
              Text('下载', style: TextStyle(fontSize: 15))
            ],
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete_forever, color: Colors.red),
              SizedBox(width: 8),
              Text('删除', style: TextStyle(fontSize: 15, color: Colors.red))
            ],
          ),
        ),
        PopupMenuItem(
          value: 'share',
          child: Row(
            children: [
              Icon(Icons.share_location, color: Colors.blue),
              SizedBox(width: 8),
              Text('分享', style: TextStyle(fontSize: 15, color: Colors.blue))
            ],
          ),
        ),
      ],
      elevation: 8.0,
    ).then((value) {
      if (value == 'download') {
        // 执行下载操作
      } else if (value == 'delete') {
        // 执行删除操作
      } else if (value == 'share') {
        // 执行分享操作
      }
    });
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.file_upload_outlined),
              title: Text('上传文件'),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.create_new_folder_outlined),
              title: Text('新建文件夹'),
              onTap: () {
                _showDialog(context, '新建文件夹', _createFolder);
              },
            ),
            ListTile(
              leading: Icon(Icons.add),
              title: Text('新建文件'),
              onTap: () {
                _showDialog(context, '新建文件', _createFile);
              },
            ),
          ],
        );
      },
    );
  }

  void _showDialog(BuildContext context, String title, Function(String) onConfirm) {
    TextEditingController _controller = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: _controller,
            decoration: InputDecoration(hintText: "请输入名称"),
          ),
          actions: <Widget>[
            TextButton(
              child: Text("取消"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("确定"),
              onPressed: () {
                String inputText = _controller.text;
                onConfirm(inputText);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // 新建文件夹
  void _createFolder(String name) async {
    var path = currentPath.isEmpty ? name : "$currentPath/$name";
    var result = await AuthApi.wenjj({'path': path});
    if (result['success']) {
      getRootFileList();
    }
  }

  // 新建文件
  void _createFile(String name) async {
    var path = currentPath.isEmpty ? name : "$currentPath/$name";
    var result = await AuthApi.wenj({'path': path});
    if (result['success']) {
      getRootFileList();
    }
  }

  Future<void> _refresh() async {
    var result = await InfoApi.getCurrentFileList();
    var objects = result['data']['objects'];
    setState(() {
      currentList = objects;
    });
  }

  @override
  bool get wantKeepAlive => true;
}