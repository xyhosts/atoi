import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:atoi/widgets/build_widget.dart';
import 'package:atoi/utils/constants.dart';
import 'dart:convert';
import 'package:atoi/utils/http_request.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:atoi/widgets/search_bar_vendor.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class EngineerReportAccessory extends StatefulWidget {
  _EngineerReportAccessoryState createState() => _EngineerReportAccessoryState();
}

class _EngineerReportAccessoryState extends State<EngineerReportAccessory> {

  var _name = new TextEditingController();
  var _newCode = new TextEditingController();
  var _amount = new TextEditingController();
  var _qty = new TextEditingController();
  var _oldCode = new TextEditingController();
  var _imageNew;
  var _imageOld;
  String _currentSource;
  String _currentVendor;
  List _sources = [
    '外部供应商',
    '备件库'
  ];

  List _vendorList = [];
  var _vendors;
  var _vendor;

  List<DropdownMenuItem<String>> _dropDownMenuSources;
  List<DropdownMenuItem<String>> _dropDownMenuVendors;

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

  Future<Null> getVendors() async {
    var resp = await HttpRequest.request(
      '/DispatchReport/GetSuppliers?filterText=',
      method: HttpRequest.GET
    );
    print(resp);
    if (resp['ResultCode'] == '00') {
      var vendors = resp['Data'];
      for (var vendor in vendors) {
        //_vendorList.add(vendor['Name'].length>8?vendor['Name'].substring(0,8):vendor['Name']);
        _vendorList.add(vendor['Name']);
      }
      setState(() {
        _vendors = vendors;
        _dropDownMenuVendors = getDropDownMenuItems(_vendorList);
        _currentVendor = _dropDownMenuVendors[0].value;
      });
    }
  }

  void changedDropDownSource(String selectedMethod) {
    setState(() {
      _currentSource = selectedMethod;
    });
  }

  void changedDropDownVendor(String selectedMethod) {
    setState(() {
      _currentVendor = selectedMethod;
    });
  }

  Row buildDropdown(String title, String currentItem, List dropdownItems, Function changeDropdown) {
    return new Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        new Expanded(
          flex: 4,
          child: new Padding(
            padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 8.0),
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
          flex: 6,
          child: new DropdownButton(
            value: currentItem,
            items: dropdownItems,
            onChanged: changeDropdown,
            isExpanded: true,
            isDense: true,
            style: new TextStyle(
              fontSize: 10.0,
              color: Colors.black54
            ),
          ),
        )
      ],
    );
  }
  
  void initState() {
    getVendors();
    _dropDownMenuSources = getDropDownMenuItems(_sources);
    _currentSource = _dropDownMenuSources[0].value;
    super.initState();
  }

  Padding buildInput(String labelText, TextEditingController controller) {
    return new Padding(
      padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 8.0),
      child: new Row(
        children: <Widget>[
          new Expanded(
            flex: 4,
            child: new Wrap(
              alignment: WrapAlignment.end,
              children: <Widget>[
                new Text(
                  labelText,
                  style: new TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.w600
                  ),
                ),
              ],
            )
          ),
          new Expanded(
            flex: 1,
            child: new Text(
              '：',
              style: new TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.w600
              ),
            ),
          ),
          new Expanded(
            flex: 6,
            child: new TextField(
              enabled: true,
              controller: controller,
              style: new TextStyle(
                  fontSize: 18.0
              ),
            ),
          )
        ],
      ),
    );
  }

  void saveAccessory() async {
    if (_name.text.isEmpty) {
      showDialog(context: context,
        builder: (context) => AlertDialog(
          title: new Text('名称不可为空'),
        )
      );
      return;
    }
    if (_newCode.text.isEmpty) {
      showDialog(context: context,
          builder: (context) => AlertDialog(
            title: new Text('新装编号不可为空'),
          )
      );
      return;
    }
    if (_oldCode.text.isEmpty) {
      showDialog(context: context,
          builder: (context) => AlertDialog(
            title: new Text('拆下不可为空'),
          )
      );
      return;
    }
    if (_amount.text.isEmpty) {
      showDialog(context: context,
          builder: (context) => AlertDialog(
            title: new Text('新装部件金额不可为空'),
          )
      );
      return;
    }
    if (_qty.text.isEmpty) {
      showDialog(context: context,
          builder: (context) => AlertDialog(
            title: new Text('数量不可为空'),
          )
      );
      return;
    }
    if (_currentSource == '外部供应商' && _vendor == null) {
      showDialog(context: context,
        builder: (context) => AlertDialog(
          title: new Text('请选择供应商'),
        )
      );
      return;
    }
    var _supplier = _vendor;
    print(_supplier);
    var imageNew;
    var imageOld;
    List<Map> _files = [];
    if (_imageNew != null) {
      var _newByte = await _imageNew.readAsBytes();
      var _compressed = await FlutterImageCompress.compressWithList(_newByte, minWidth: 480, minHeight: 600);
      imageNew = base64Encode(_compressed);
      _files.add(
        {
          'FileName': _imageNew.path,
          'ID': 0,
          'FileType': 1,
          'FileContent': imageNew
        }
      );
    }
    if (_imageOld != null) {
      var _oldByte = await _imageOld.readAsBytes();
      var _compressed = await FlutterImageCompress.compressWithList(_oldByte, minWidth: 480, minHeight: 600);
      imageOld = base64Encode(_compressed);
      _files.add(
        {
          'FileName': _imageOld.path,
          'ID': 0,
          'FileType': 2,
          'FileContent': imageOld
        }
      );
    }
    var data = {
      'Name': _name.text,
      'Source': {
        'Name': _currentSource,
        'ID': AppConstants.AccessorySourceType[_currentSource]
      },
      'Supplier': _currentSource=='备件库'?{'ID': 0}:_supplier,
      'NewSerialCode': _newCode.text,
      'OldSerialCode': _oldCode.text,
      'Qty': _qty.text,
      'Amount': _amount.text,
      'FileInfos': _files
    };
    Navigator.of(context).pop(data);
  }

  Padding buildRowVendor(String labelText, String vendor) {
    return new Padding(
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
              '：',
              style: new TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          new Expanded(
            flex: 3,
              child: new Text(
                vendor,
                style: new TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.w400,
                    color: Colors.black54
                ),
              )
          ),
          new Expanded(
              flex: 2,
              child: new IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () async {
                    final _searchResult = await showSearch(context: context, delegate: SearchBarVendor(), hintText: '请输入供应商名称');
                    print(_searchResult);
                    if (_searchResult != null && _searchResult != 'null') {
                      setState(() {
                        _vendor = jsonDecode(_searchResult);
                      });
                    }
                  }
              )
          ),
        ],
      ),
    );
  }

  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('新增零配件'),
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
      body: _vendorList.isEmpty?new Center(child: SpinKitRotatingPlain(color: Colors.blue,),):new Center(
        child: new ListView(
          children: <Widget>[
            new Card(
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  BuildWidget.buildInput('名称', _name),
                  BuildWidget.buildDropdown('来源', _currentSource, _dropDownMenuSources, changedDropDownSource),
                  new SizedBox(
                    height: 5.0,
                  ),
                  _currentSource=='外部供应商'?buildRowVendor('外部供应商', _vendor==null?'':_vendor['Name']):new Container(),
                  BuildWidget.buildInput('新装编号', _newCode),
                  new Padding(
                    padding: EdgeInsets.symmetric(horizontal: 95.0),
                    child: new Row(
                      children: <Widget>[
                        new Text('附件：',
                          style: new TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.w600
                          ),
                        ),
                        new IconButton(icon: Icon(Icons.add_a_photo), onPressed: () async {
                          _imageNew = await ImagePicker.pickImage(
                              source: ImageSource.camera,
                            imageQuality: 1
                          );
                        }),
                      ],
                    )
                  ),
                  new Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      _imageNew==null?new Container():
                      new Stack(
                        alignment: FractionalOffset(1.0, 0),
                        children: <Widget>[
                          new Container(
                            width: 150.0,
                            child: Image.file(_imageNew),
                          ),
                          new Padding(
                            padding: EdgeInsets.symmetric(horizontal: 0.0),
                            child: new IconButton(icon: Icon(Icons.cancel), color: Colors.white, onPressed: (){
                              setState(() {
                                _imageNew = null;
                              });
                            }),
                          )
                        ],
                      )
                    ],
                  ),
                  BuildWidget.buildInput('新装部件金额（元/件）', _amount, inputType: TextInputType.numberWithOptions(
                    decimal: true,
                    signed: false
                  )),
                  BuildWidget.buildInput('数量', _qty, inputType: TextInputType.number),
                  BuildWidget.buildInput('拆下编号', _oldCode),
                  new Padding(
                    padding: EdgeInsets.symmetric(horizontal: 95.0),
                    child: new Row(
                      children: <Widget>[
                        new Text('附件：',
                          style: new TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.w600
                          ),
                        ),
                        new IconButton(icon: Icon(Icons.add_a_photo), onPressed: () async {
                          _imageOld = await ImagePicker.pickImage(
                              source: ImageSource.camera,
                            imageQuality: 1
                          );
                        }),
                      ],
                    )
                  ),
                  new Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      _imageOld==null?new Container():
                      new Stack(
                        alignment: FractionalOffset(1.0, 0),
                        children: <Widget>[
                          new Container(
                            width: 150.0,
                            child: Image.file(_imageOld),
                          ),
                          new Padding(
                            padding: EdgeInsets.symmetric(horizontal: 0.0),
                            child: new IconButton(icon: Icon(Icons.cancel), color: Colors.white, onPressed: (){
                              setState(() {
                                _imageOld = null;
                              });
                            }),
                          )
                        ],
                      )
                    ],
                  ),
                  ButtonTheme.bar( // make buttons use the appropriate styles for cards
                    child: ButtonBar(
                      children: <Widget>[
                        RaisedButton(
                          child: const Text('保存', style: TextStyle(color: Colors.white),),
                          color: AppConstants.AppColors['btn_main'],
                          onPressed: () {
                            saveAccessory();
                          },
                        ),
                        RaisedButton(
                          child: const Text('取消', style: TextStyle(color: Colors.white),),
                          color: AppConstants.AppColors['btn_cancel'],
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        )
      )
    );
  }
}