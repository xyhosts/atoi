import 'package:flutter/material.dart';
import 'package:atoi/widgets/build_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:atoi/utils/http_request.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class CompleteInfo extends StatefulWidget {
  _CompleteInfoState createState() => new _CompleteInfoState();
}

class _CompleteInfoState extends State<CompleteInfo> {

  Map userInfo = {};
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  TextEditingController _email = new TextEditingController();
  TextEditingController _addr = new TextEditingController();
  TextEditingController _newPass = new TextEditingController();
  List<String> departmentNames = [];
  List<dynamic> departments = [];
  var currentDepart;
  var dropdownItems;

  Future<Null> getUserInfo() async {
    var prefs = await _prefs;
    var _userInfo = prefs.getString('userInfo');
    print(_userInfo);
    var decoded = jsonDecode(_userInfo);
    setState(() {
      userInfo = decoded;
      _email.text = decoded['Email'];
      _addr.text = decoded['Address'];
      currentDepart = decoded['Department']['Name'];
    });
  }
  void initState() {
    super.initState();
    getUserInfo();
    getDepartments();
  }

  Future<Null> getDepartments() async {
    var resp = await HttpRequest.request(
      '/User/GetDepartments',
      method: HttpRequest.GET
    );
    if (resp['ResultCode'] == '00') {
      for(var depart in resp['Data']) {
        departmentNames.add(depart['Name']);
      }
      setState(() {
        departments = resp['Data'];
        departmentNames = departmentNames;
      });
      dropdownItems = getDropDownMenuItems(departmentNames);
      currentDepart = dropdownItems[0].value;
    }
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
      currentDepart = selectedMethod;
    });
  }

  Row buildDropdown(String title, String currentItem, List dropdownItems, Function changeDropdown) {
    return new Row(
      children: <Widget>[
        new Expanded(
          flex: 2,
          child: new Wrap(
            alignment: WrapAlignment.start,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              new Text(
                title,
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
          flex: 8,
          child: new DropdownButton(
            value: currentItem,
            items: dropdownItems,
            onChanged: changeDropdown,
            isDense: true,
            isExpanded: true,
          ),
        )
      ],
    );
  }

  Future<Null> submit() async {
    var _depart = departments.firstWhere((depart) => depart['Name']==currentDepart, orElse: () => null);
    var _data = {
      'info': {
        'ID': userInfo['ID'],
        'Name': userInfo['Name'],
        'Mobile': userInfo['Mobile'],
        'Department': {
          'ID': _depart['ID']
        },
        'Email': _email.text,
        'Address': _addr.text,
      }
    };
    var prefs = await _prefs;
    userInfo['Email'] = _email.text;
    userInfo['Address'] = _addr.text;
    userInfo['Department'] = _depart;
    prefs.setString('userInfo', jsonEncode(userInfo));
    if (_newPass.text.isNotEmpty) {
      _data['info']['LoginPwd'] = _newPass.text;
    }
    var resp = await HttpRequest.request(
      '/User/UpdateUserInfo',
      method: HttpRequest.POST,
      data: _data
    );
    if (resp['ResultCode'] == '00') {
      showDialog(context: context,
        builder: (context) => AlertDialog(
          title: new Text('更新信息成功'),
        )
      ).then((result) {
        Navigator.of(context, rootNavigator: true).pop();
      });
    }
  }

  List<Widget> buildInfo() {
    List<Widget> _list = [
      new SizedBox(height: 20.0,),
      BuildWidget.buildRow('手机号', userInfo['Mobile']),
      BuildWidget.buildRow('姓名', userInfo['Name']),
      BuildWidget.buildRow('用户角色', userInfo['Role']['Name']),
      BuildWidget.buildRow('账号状态', userInfo['VerifyStatus']['Name']),
      new Divider(),
      BuildWidget.buildInput('邮箱', _email),
      BuildWidget.buildInput('地址', _addr),
      BuildWidget.buildInput('新密码', _newPass),
      new Divider(),
      buildDropdown('科室', currentDepart, dropdownItems, changedDropDownMethod),
      new SizedBox(height: 20.0,),
      new Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          new RaisedButton(
            onPressed: () {
              submit();
            },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            padding: EdgeInsets.all(12.0),
            color: new Color(0xff2E94B9),
            child: Text(
                '提交信息',
                style: TextStyle(
                    color: Colors.white
                )
            ),
          )
        ],
      )
    ];
    return _list;
  }
  
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('完善信息'),
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
      ),
      body: userInfo.isEmpty?new Center(child: new SpinKitRotatingPlain(color: Colors.blue),):Center(
        child: ListView(
            shrinkWrap: false,
            padding: EdgeInsets.only(left: 24.0, right: 24.0),
            children: buildInfo()
        ),
      ),
    );
  }
}