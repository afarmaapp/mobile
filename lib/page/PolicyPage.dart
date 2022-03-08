import 'package:afarma/model/PolicyOption.dart';
import 'package:afarma/repository/PolicyOptionRepository.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

class PolicyPage extends StatefulWidget {
  @override
  _PolicyPageState createState() => _PolicyPageState();
}

class _PolicyPageState extends State<PolicyPage> with TickerProviderStateMixin {
  List<PolicyOption> get _items => PolicyOptionRepository().options;

  bool loaded = false;

  @override
  void initState() {
    super.initState();
    _fetchPolicyLinks();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      child: Scaffold(
          appBar: AppBar(
              bottom: TabBar(
                labelStyle: TextStyle(fontSize: 20),
                indicatorColor: Colors.white,
                tabs: _tabBarItems(),
              ),
              title: Text('Sobre Nós')),
          body: _mainWidget()),
      length: _items.length,
    );
  }

  List<Tab> _tabBarItems() {
    List<Tab> ret = [];
    _items.forEach((item) => ret.add(Tab(
          icon: AutoSizeText(
            item.name,
            style: TextStyle(color: Colors.white, fontSize: 10),
            maxLines: 2,
          ),
        )));
    return ret;
  }

  Widget _mainWidget() {
    List<Widget> children = [];
    _items.forEach(
      (item) => children.add(
        SingleChildScrollView(
          child: loaded
              ? Html(data: item.text)
              : Container(
                  child: Text("Carregando informações..."),
                  padding: EdgeInsets.all(40),
                  alignment: Alignment.center,
                ),
        ),
      ),
    );

    return TabBarView(
      children: children,
    );
  }

  void _fetchPolicyLinks() {
    PolicyOptionRepository().getOptions().then((_) {
      loaded = true;
      setState(() {});
    });
  }
}
