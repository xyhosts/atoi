import 'dart:core';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:atoi/utils/http_request.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:atoi/utils/constants.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'dart:convert';
import 'package:photo_view/photo_view.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:atoi/models/models.dart';
import 'package:atoi/models/manager_model.dart';
import 'package:atoi/widgets/build_widget.dart';

class ManagerAssignPage extends StatefulWidget {
  static String tag = 'mananger-assign-page';

  ManagerAssignPage({Key key, this.request}) : super(key: key);
  final Map request;
  @override
  _ManagerAssignPageState createState() => new _ManagerAssignPageState();

}

class _ManagerAssignPageState extends State<ManagerAssignPage> {

  var _isExpandedBasic = true;
  var _isExpandedDetail = false;
  var _isExpandedAssign = false;
  String departureDate = '';
  String dispatchDate;
  var _desc = new TextEditingController();

  Map<String, dynamic> _request = {};

  String _userName = '';
  String _mobile = '';

  Future<Null> getRole() async {
    var prefs = await _prefs;
    var userName = prefs.getString('userName');
    var mobile = prefs.getString('mobile');
    setState(() {
      _userName = userName;
      _mobile = mobile;
    });
  }

  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  List<dynamic> imageBytes = [];

  List _handleMethods = [
    '现场服务',
    '电话解决',
    '远程解决',
    '待第三方支持'
  ];

  List _priorities = [
    '普通',
    '紧急'
  ];

  List _assignTypes = [
    '维修',
    '保养',
    '强检',
    '巡检',
    '校正',
    '设备新增',
    '不良事件',
    '合同档案',
    '验收安装',
    '调拨',
    '借用',
    '盘点',
    '报废',
    '其他服务'
  ];

  List _levels = [
    '普通',
    '紧急'
  ];

  List _isRecall = [
    '是',
    '否'
  ];

  List _deviceStatuses = [
    '正常',
    '勉强使用',
    '停机'
  ];

  List _maintainType = [
    '原厂保养',
    '第三方保养',
    'FMTS保养'
  ];
  List _faultType = [
    '未知'
  ];
  List _mandatory = [
    '政府要求',
    '医院要求',
    '自主强检'
  ];
  List _badSource = [
    '政府通报',
    '医院自检',
    '召回事件'
  ];

  List _engineerNames = [];

  Map<String, int> _engineers = {};
  //final String roleName = await LocalStorage().getStorage('roleName', String);

  List<DropdownMenuItem<String>> _dropDownMenuItems;
  List<DropdownMenuItem<String>> _dropDownMenuPris;
  List<DropdownMenuItem<String>> _dropDownMenuTypes;
  List<DropdownMenuItem<String>> _dropDownMenuLevels;
  List<DropdownMenuItem<String>> _dropDownMenuStatuses;
  List<DropdownMenuItem<String>> _dropDownMenuNames;
  List<DropdownMenuItem<String>> _dropDownMenuMaintain;
  List<DropdownMenuItem<String>> _dropDownMenuFault;
  List<DropdownMenuItem<String>> _dropDownMenuSource;
  List<DropdownMenuItem<String>> _dropDownMenuMandatory;
  List<DropdownMenuItem<String>> _dropDownMenuRecall;


  var _leaderComment = new TextEditingController();

  String _currentMethod;
  String _currentPriority;
  String _currentType;
  String _currentLevel;
  String _currentStatus;
  String _currentName;
  String _currentMaintain;
  String _currentFault;
  String _currentSource;
  String _currentMandatory;
  String _currentRecall;


  Future<Null> getRequest() async {
    int requestId = widget.request['ID'];
    var prefs = await _prefs;
    var userId = prefs.getInt('userID');
    var params = {
      'userId': userId,
      'requestId': requestId
    };
    var resp = await HttpRequest.request(
      '/Request/GetRequestByID',
      method: HttpRequest.GET,
      params: params,
    );
    print(resp);
    if (resp['ResultCode'] == '00') {
      var files = resp['Data']['Files'];
      for (var file in files) {
        getImage(file['ID']);
      }
      setState(() {
        _request = resp['Data'];
        _currentType = _request['RequestType']['Name'];
        _desc.text = resp['Data']['FaultDesc'];
      });
      //if (resp['Data']['RequestType']['ID'] == 1) {
      //  setState(() {
      //    _currentFault = resp['Data']['FaultType']['Name'];
      //  });
      //}
      if (resp['Data']['RequestType']['ID'] == 2) {
        setState(() {
          _currentMaintain = resp['Data']['FaultType']['Name'];
        });
      }
      if (resp['Data']['RequestType']['ID'] == 3) {
        setState(() {
          _currentMandatory = resp['Data']['FaultType']['Name'];
        });
      }
      if (resp['Data']['RequestType']['ID'] == 7) {
        setState(() {
          _currentSource = resp['Data']['FaultType']['Name'];
        });
      }
    }
  }

  Future<Null> getImage(int fileId) async {
    var resp = await HttpRequest.request(
      '/Request/DownloadUploadFile',
      params: {
        'ID': fileId
      },
      method: HttpRequest.GET
    );
    print(resp);
    if (resp['ResultCode'] == '00') {
      setState(() {
        imageBytes.add(resp['Data']);
      });
    }
  }

  Future<Null> getEngineers() async {
    List<String> _listName = [
      '--请选择--'
    ];
    Map<String, int> _listID = {};
    var resp = await HttpRequest.request(
      '/User/GetAdmins',
      method: HttpRequest.GET
    );
    print(resp);
    if (resp['ResultCode'] == '00') {
      for (var item in resp['Data']) {
        _listName.add(item['Name']);
        _listID[item['Name']] = item['ID'];
      }
      print(_listID);
      setState(() {
        _engineerNames = _listName;
        _engineers = _listID;
        _dropDownMenuNames = getDropDownMenuItems(_engineerNames);
        _currentName = _dropDownMenuNames[0].value;
      });
    }
  }

  void initState() {
    getRole();
    var time = new DateTime.now();
    dispatchDate = '${time.year}-${time.month}-${time.day}';
    _dropDownMenuItems = getDropDownMenuItems(_handleMethods);
    _currentMethod = _dropDownMenuItems[0].value;
    _dropDownMenuPris = getDropDownMenuItems(_priorities);
    _currentPriority = _dropDownMenuPris[0].value;
    _dropDownMenuTypes = getDropDownMenuItems(_assignTypes);
    _dropDownMenuLevels = getDropDownMenuItems(_levels);
    _dropDownMenuStatuses = getDropDownMenuItems(_deviceStatuses);
    _currentLevel = _dropDownMenuLevels[0].value;
    _currentStatus = _dropDownMenuStatuses[0].value;
    _dropDownMenuFault = getDropDownMenuItems(_faultType);
    _currentFault = _dropDownMenuFault[0].value;
    _dropDownMenuMaintain = getDropDownMenuItems(_maintainType);
    _dropDownMenuSource = getDropDownMenuItems(_badSource);
    _dropDownMenuMandatory = getDropDownMenuItems(_mandatory);
    _dropDownMenuRecall = getDropDownMenuItems(_isRecall);
    _currentRecall = _dropDownMenuRecall[0].value;
    getRequest();
    getEngineers();
    ManagerModel model = MainModel.of(context);
    super.initState();
  }

  List<DropdownMenuItem<String>> getDropDownMenuItems(List list) {
    List<DropdownMenuItem<String>> items = new List();
    for (String method in list) {
      items.add(new DropdownMenuItem(
          value: method,
          child: new Text(method,
            style: new TextStyle(
              fontSize: 20.0
            ),
          )
      ));
    }
    return items;
  }

  void changedDropDownMethod(String selectedMethod) {
    setState(() {
      _currentMethod = selectedMethod;
    });
  }

  void changedDropDownPri(String selectedMethod) {
    setState(() {
      _currentPriority = selectedMethod;
    });
  }

  void changedDropDownType(String selectedMethod) {
    setState(() {
      _currentType = selectedMethod;
    });
  }

  void changedDropDownLevel(String selectedMethod) {
    setState(() {
      _currentLevel = selectedMethod;
    });
  }

  void changedDropDownStatus(String selectedMethod) {
    setState(() {
      _currentStatus = selectedMethod;
    });
  }

  void changedDropDownName(String selectedMethod) {
    setState(() {
      _currentName = selectedMethod;
    });
  }

  void changedDropDownFault(String selectedMethod) {
    setState(() {
      _currentFault = selectedMethod;
    });
  }
  void changedDropDownMaintain(String selectedMethod) {
    setState(() {
      _currentMaintain = selectedMethod;
    });
  }
  void changedDropDownSource(String selectedMethod) {
    setState(() {
      _currentSource = selectedMethod;
    });
  }
  void changedDropDownMandatory(String selectedMethod) {
    setState(() {
      _currentMandatory= selectedMethod;
    });
  }
  void changedDropDownRecall(String selectedMethod) {
    setState(() {
      _currentRecall= selectedMethod;
    });
  }
  Column buildImageColumn() {
    if (imageBytes == null) {
      return new Column();
    } else {
      List<Widget> _list = [];
      for(var file in imageBytes) {
        _list.add(new Container(
          child: new PhotoView(imageProvider: MemoryImage(base64Decode(file))),
          width: 400.0,
          height: 400.0,
        ));
      }
      return new Column(children: _list);
    }
  }

  TextField buildTextField(String labelText, String defaultText, bool isEnabled) {
    return new TextField(
      decoration: InputDecoration(
          labelText: labelText,
          labelStyle: new TextStyle(
              fontSize: 20.0
          ),
          disabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: Colors.grey,
              width: 1
            )
          )
      ),
      controller: new TextEditingController(text: defaultText),
      enabled: isEnabled,
      style: new TextStyle(
          fontSize: 16.0
      ),
    );
  }

  Padding buildRow(String labelText, String defaultText) {
    return new Padding(
      padding: EdgeInsets.symmetric(vertical: 5.0),
      child: new Row(
        children: <Widget>[
          new Expanded(
            flex: 4,
            child: new Wrap(
              //mainAxisAlignment: MainAxisAlignment.end,
              alignment: WrapAlignment.end,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: <Widget>[
                new Text(
                  labelText,
                  style: new TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.w600
                  ),
                )
              ],
            ),
          ),
          new Expanded(
            flex: 1,
            child: new Text(
              '',
              style: new TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.w600,
              ),
            ),
          ),
          new Expanded(
            flex: 6,
            child: new Text(
              defaultText,
              style: new TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.w400,
                  color: Colors.black54
              ),
            ),
          )
        ],
      ),
    );
  }

  Row buildDropdown(String title, String currentItem, List dropdownItems, Function changeDropdown) {
    return new Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        new Expanded(
          flex: 4,
          child: new Padding(
            padding: EdgeInsets.symmetric(vertical: 5.0),
            child: new Text(
              title,
              style: new TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.w600
              ),
            ),
          ),
        ),
        new Expanded(
          flex: 5,
          child: new DropdownButton(
            value: currentItem,
            items: dropdownItems,
            onChanged: changeDropdown,
          ),
        )
      ],
    );
  }

  Future<Null> terminate() async {
    var prefs = await _prefs;
    var userID = prefs.getInt('userID');
    Map<String, dynamic> _data = {
      'userID': userID,
      'requestID': _request['ID']
    };
    var resp = await HttpRequest.request(
      '/Request/EndRequest',
      method: HttpRequest.POST,
      data: _data
    );
    print(resp);
    if (resp['ResultCode'] == '00') {
      showDialog(context: context,
        builder: (context) => AlertDialog(
          title: new Text('终止请求成功'),
        )
      ).then((result) =>
        Navigator.of(context, rootNavigator: true).pop()
      );
    } else {
      showDialog(context: context,
        builder: (context) => AlertDialog(
          title: new Text(resp['ResultMessage']),
        )
      );
    }
  }

  Future assignRequest() async {
    if (_currentName == '--请选择--') {
      showDialog(context: context,
        builder: (context) => AlertDialog(
          title: new Text('请选择工程师'),
        )
      );
      return;
    }
    if (_desc.text.isEmpty) {
      showDialog(context: context,
          builder: (context) => AlertDialog(
            title: new Text(
              '${AppConstants.Remark[_request['RequestType']['ID']]}不可为空'
            ),
          )
      );
      return;
    }
    var prefs = await _prefs;
    var userID = prefs.getInt('userID');
    Map<String, dynamic> _data = {
      'userID': userID,
      'dispatchInfo': {
        'Request': {
          'ID': _request['ID'],
          'Priority': {
            'ID': AppConstants.PriorityID[_currentPriority],
          },
          'DealType': {
            'ID': AppConstants.DealType[_currentMethod]
          },
          'FaultDesc': _desc.text,
          'FaultType': {
            'ID': _request['FaultType']['ID']
          },
          'IsRecall': _request['IsRecall']
        },
        'Urgency': {
          'ID': AppConstants.UrgencyID[_currentLevel]
        },
        'Engineer': {
          'ID': _engineers[_currentName]
        },
        'MachineStatus': {
          'ID': AppConstants.MachineStatus[_currentStatus]
        },
        'ScheduleDate': dispatchDate,
        'LeaderComments': _leaderComment.text,
        'RequestType': {
          'ID': AppConstants.RequestType[_currentType]
        }
      }
    };
    var resp = await HttpRequest.request(
      '/Request/CreateDispatch',
      method: HttpRequest.POST,
      data: _data
    );
    print(resp);
    if (resp['ResultCode'] == '00') {
      showDialog(context: context,
        builder: (context) => AlertDialog(
          title: new Text('安排派工成功'),
        )
      ).then((result) =>
        Navigator.of(context, rootNavigator: true).pop(result)
      );
    } else {
      showDialog(context: context,
        builder: (context) => AlertDialog(
          title: new Text(resp['ResultMessage']),
        )
      );
    }
  }

  List<Widget> buildEquipment() {
    if (_request.isNotEmpty) {
      var _equipments = _request['Equipments'];
      List<Widget> _equipList = [];
      for (var _equipment in _equipments) {
        var _list = [
          BuildWidget.buildRow('系统编号', _equipment['OID']??''),
          BuildWidget.buildRow('名称', _equipment['Name']??''),
          BuildWidget.buildRow('型号', _equipment['EquipmentCode']??''),
          BuildWidget.buildRow('序列号', _equipment['SerialCode']??''),
          BuildWidget.buildRow('使用科室', _equipment['Department']['Name']??''),
          BuildWidget.buildRow('安装地点', _equipment['InstalSite']??''),
          BuildWidget.buildRow('设备厂商', _equipment['Manufacturer']['Name']??''),
          BuildWidget.buildRow('资产等级', _equipment['AssetLevel']['Name']??''),
          BuildWidget.buildRow('维保状态', _equipment['WarrantyStatus']??''),
          BuildWidget.buildRow('服务范围', _equipment['ContractScope']['Name']??''),
          new Padding(padding: EdgeInsets.symmetric(vertical: 8.0))
        ];
        _equipList.addAll(_list);
      }
      return _equipList;
    } else {
      return [];
    }
  }

  List<dynamic> _buildExpansion() {
    List<ExpansionPanel> _list = [];
    if (_request['RequestType']['ID'] != 14) {
      _list.add(new ExpansionPanel(
        headerBuilder: (context, isExpanded) {
          return ListTile(
              leading: new Icon(Icons.info,
                size: 24.0,
                color: Colors.blue,
              ),
              title: Text('设备基本信息',
                style: new TextStyle(
                    fontSize: 22.0,
                    fontWeight: FontWeight.w400
                ),
              ),
          );
        },
        body: new Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.0),
          child: new Column(
            children: buildEquipment(),
          ),
        ),
        isExpanded: _isExpandedBasic,
      ));
    }
    _list.add(new ExpansionPanel(
        headerBuilder: (context, isExpanded) {
          return ListTile(
              leading: new Icon(Icons.description,
                size: 24.0,
                color: Colors.blue,
              ),
              title: Text('请求内容',
                style: new TextStyle(
                    fontSize: 22.0,
                    fontWeight: FontWeight.w400
                ),
              ),
          );
        },
        body: new Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              BuildWidget.buildRow('类型', _request['SourceType']),
              BuildWidget.buildRow('主题', _request['SubjectName']),
              BuildWidget.buildInput(AppConstants.Remark[_request['RequestType']['ID']], _desc),
              _request['RequestType']['ID']==1?BuildWidget.buildDropdown('故障分类', _currentFault, _dropDownMenuFault, changedDropDownFault):new Container(),
              _request['RequestType']['ID']==2?BuildWidget.buildDropdown('保养类型', _currentMaintain, _dropDownMenuMaintain, changedDropDownMaintain):new Container(),
              _request['RequestType']['ID']==3?BuildWidget.buildDropdown('强检原因', _currentMandatory, _dropDownMenuMandatory, changedDropDownMandatory):new Container(),
              _request['RequestType']['ID']==7?BuildWidget.buildDropdown('来源', _currentSource, _dropDownMenuSource, changedDropDownSource):new Container(),
              _request['RequestType']['ID']==3?BuildWidget.buildRow('是否召回', _request['IsRecall']?'是':'否'):new Container(),
              BuildWidget.buildRow('请求人', _request['RequestUser']['Name']),
              BuildWidget.buildDropdown('处理方式', _currentMethod, _dropDownMenuItems, changedDropDownMethod),
              BuildWidget.buildDropdown('紧急程度', _currentPriority, _dropDownMenuPris, changedDropDownPri),
              BuildWidget.buildRow('请求附件', ''),
              buildImageColumn(),
              //new Row(
              //  mainAxisAlignment: MainAxisAlignment.start,
              //  children: <Widget>[
              //    new Padding(
              //      padding: const EdgeInsets.all(10.0),
              //      child: new Container(
              //        child: imageBytes.isEmpty?new Stack():new PhotoView(
              //            imageProvider: MemoryImage(imageBytes),
              //        ),
              //      ),
              //    ),
              //  ],
              //),
            ],
          ),
        ),
        isExpanded: _isExpandedDetail,
      ),
    );
    _list.add(new ExpansionPanel(
      headerBuilder: (context, isExpanded) {
        return ListTile(
            leading: new Icon(Icons.perm_contact_calendar,
              size: 24.0,
              color: Colors.blue,
            ),
            title: Text('派工内容',
              style: new TextStyle(
                  fontSize: 22.0,
                  fontWeight: FontWeight.w400
              ),
            ),
        );
      },
      body: new Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.0),
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            BuildWidget.buildDropdown('派工类型', _currentType, _dropDownMenuTypes, changedDropDownType),
            BuildWidget.buildDropdown('紧急程度', _currentLevel, _dropDownMenuLevels, changedDropDownLevel),
            _currentType!='其他服务'?BuildWidget.buildDropdown('机器状态', _currentStatus, _dropDownMenuStatuses, changedDropDownStatus):new Container(),
            _engineerNames.isEmpty?new Container():BuildWidget.buildDropdown('工程师姓名', _currentName, _dropDownMenuNames, changedDropDownName),
            new Padding(
              padding: EdgeInsets.symmetric(vertical: 5.0),
              child: new Row(
                children: <Widget>[
                  new Expanded(
                    flex: 4,
                    child: new Wrap(
                      alignment: WrapAlignment.end,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: <Widget>[
                        new Text(
                          '出发时间',
                          style: new TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.w600
                          ),
                        )
                      ],
                    ),
                  ),
                  new Expanded(
                    flex: 1,
                    child: new Text(
                      '：',
                      style: new TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  new Expanded(
                    flex: 4,
                    child: new Text(
                      dispatchDate,
                      style: new TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.w400,
                          color: Colors.black54
                      ),
                    ),
                  ),
                  new Expanded(
                    flex: 2,
                    child: new IconButton(
                      color: AppConstants.AppColors['btn_main'],
                      icon: Icon(Icons.calendar_today),
                      onPressed: () {
                        showDatePicker(
                            context: context,
                            initialDate: new DateTime.now(),
                            firstDate: new DateTime.now().subtract(new Duration(days: 30)), // 减 30 天
                            lastDate: new DateTime.now().add(new Duration(days: 30)),       // 加 30 天
                            locale: Locale('zh')
                        ).then((DateTime val) {
                          print(val); // 2018-07-12 00:00:00.000
                          var date = '${val.year}-${val.month}-${val.day}';
                          setState(() {
                            dispatchDate = date;
                          });
                        }).catchError((err) {
                          print(err);
                        });
                      },
                    ),
                  )
                ],
              ),
            ),
            new Padding(
              padding: EdgeInsets.symmetric(vertical: 5.0),
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  new Align(
                    alignment: Alignment(-0.62, 0),
                    child: new Text(
                      '主管备注：',
                      style: new TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.w600
                      ),
                    ),
                  ),
                  new TextField(
                    controller: _leaderComment,
                  )
                ],
              ),
            ),
          ],
        ),
      ),
      isExpanded: _isExpandedAssign,
    ));
    return _list;
  }

  @override
  Widget build(BuildContext context){
    return ScopedModelDescendant<MainModel>(
      builder: (context, child, model) {
        return new Scaffold(
          appBar: new AppBar(
            title: new Text('分配请求'),
            elevation: 0.7,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).accentColor
                  ],
                ),
              ),
            ),
            actions: <Widget>[
              new Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 19.0),
                child: Text(_userName),
              ),
            ],
          ),
          body: _request.isEmpty?new Center(child: SpinKitRotatingPlain(color: Colors.blue),):new Padding(
            padding: EdgeInsets.symmetric(vertical: 5.0),
            child: new Card(
              child: new ListView(
                children: <Widget>[
                  new ExpansionPanelList(
                    animationDuration: Duration(milliseconds: 200),
                    expansionCallback: (index, isExpanded) {
                      setState(() {
                        if (index == 0) {
                          if (_request['RequestType']['ID'] == 14) {
                            _isExpandedDetail = !isExpanded;
                          } else {
                            _isExpandedBasic = !isExpanded;
                          }
                        } else {
                          if (index == 1) {
                            if (_request['RequestType']['ID'] == 14) {
                              _isExpandedAssign = !isExpanded;
                            } else {
                              _isExpandedDetail = !isExpanded;
                            }
                          } else {
                            _isExpandedAssign =!isExpanded;
                          }
                        }
                      });
                    },
                    children: _buildExpansion(),
                  ),
                  SizedBox(height: 24.0),
                  new Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      new Padding(
                        padding: EdgeInsets.symmetric(horizontal: 5.0),
                        child: new RaisedButton(
                          onPressed: () {
                            assignRequest();
                            model.getRequests();
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          padding: EdgeInsets.all(12.0),
                          color: new Color(0xff2E94B9),
                          child: Text('安排派工', style: TextStyle(color: Colors.white)),
                        ),
                      ),
                      new Padding(
                        padding: EdgeInsets.symmetric(horizontal: 5.0),
                        child: new RaisedButton(
                          onPressed: () {
                            //terminate();
                            //model.getRequests();
                            showDialog(context: context,
                              builder: (context) => AlertDialog(
                                title: new Text('是否终止请求？'),
                                actions: <Widget>[
                                  RaisedButton(
                                    child: const Text('确认', style: TextStyle(color: Colors.white),),
                                    color: AppConstants.AppColors['btn_cancel'],
                                    onPressed: () {
                                      terminate();
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  RaisedButton(
                                    child: const Text('取消', style: TextStyle(color: Colors.white),),
                                    color: AppConstants.AppColors['btn_main'],
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              )
                            );
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          padding: EdgeInsets.all(12.0),
                          color: new Color(0xffD25565),
                          child: Text('终止请求', style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}