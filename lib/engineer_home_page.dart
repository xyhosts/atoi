import 'package:flutter/material.dart';
import 'package:atoi/pages/manager/manager_menu.dart';
import 'package:atoi/pages/manager/manager_to_audit_page.dart';
import 'package:badges/badges.dart';
import 'package:atoi/pages/engineer/engineer_to_start.dart';


class EngineerHomePage extends StatefulWidget {
  static String tag = 'engineer-home-page';
  @override
  _EngineerHomePageState createState() => new _EngineerHomePageState();
}

class _EngineerHomePageState extends State<EngineerHomePage>
    with SingleTickerProviderStateMixin{
  TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = new TabController(length: 3, vsync: this, initialIndex: 0);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text('ATOI医疗设备管理系统'),
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
          bottom: new TabBar(
            indicatorColor: Colors.white,
            controller: _tabController,
            tabs: <Widget>[
              new Tab(
                  icon: new Badge(
                    badgeContent: Text(
                      '3',
                      style: new TextStyle(
                          color: Colors.white
                      ),
                    ),
                    child: new Icon(Icons.assignment_late),
                  ),
                  text: '待开始工单'
              ),
              new Tab(
                icon: new Badge(
                  badgeContent: Text(
                    '2',
                    style: new TextStyle(
                        color: Colors.white
                    ),
                  ),
                  child: new Icon(Icons.hourglass_full),
                ),
                text: '作业中工单',
              ),
              new Tab(
                  icon: new Icon(Icons.add_to_photos),
                  text: '新增服务'
              ),
            ],
          ),
          actions: <Widget>[
            new Icon(Icons.face),
            new Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 19.0),
              child: const Text('Jin'),
            ),
          ],
        ),
        body: new TabBarView(
          controller: _tabController,
          children: <Widget>[
            new EngineerToStart(),
            new ManagerToAuditPage(),
            new ManagerMenu(),
          ],
        )
    );
  }
}