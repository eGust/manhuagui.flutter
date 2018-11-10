import 'package:flutter/material.dart';

import './sub_router.dart';
import '../list_top_bar.dart';
import '../../store.dart';
import '../../models.dart';

class RouteConfiguration extends StatefulWidget {
  static final router = SubRouter(
    'settings',
    Icons.settings,
    () => RouteConfiguration(),
  );

  @override
  _RouteConfigurationState createState() => _RouteConfigurationState();
}

class _RouteConfigurationState extends State<RouteConfiguration> {
  static bool _isBlocked(final Filter filter) =>
      globals.blacklistSet.contains(filter.link);

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          TopBarFrame(),
          Container(
            padding: const EdgeInsets.fromLTRB(18.0, 8.0, 0.0, 4.0),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.orange)),
            ),
            child: const Text('黑名单', style: TextStyle(fontSize: 24.0)),
          ),
          Container(
            padding: const EdgeInsets.all(5.0),
            decoration: const BoxDecoration(
              border:
                  Border(bottom: BorderSide(color: Colors.brown, width: 2.0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: globals.metaData.comicFilterGroupList
                  .map(
                    (grp) => Container(
                        padding:
                            const EdgeInsets.fromLTRB(10.0, 6.0, 10.0, 6.0),
                        child: Wrap(
                          spacing: 9.0,
                          runSpacing: 4.0,
                          children: grp.filters
                              .map((filter) => _BlacklistButton(
                                    filter,
                                    blocked: _isBlocked(filter),
                                    onPressed: () {
                                      setState(() {
                                        if (_isBlocked(filter)) {
                                          globals.blacklistSet
                                              .remove(filter.link);
                                        } else {
                                          globals.blacklistSet.add(filter.link);
                                        }
                                        globals.save();
                                      });
                                    },
                                  ))
                              .toList(),
                        )),
                  )
                  .toList(),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(18.0, 8.0, 0.0, 4.0),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.orange)),
            ),
            child: const Text('杂项', style: TextStyle(fontSize: 24.0)),
          ),
          Container(
            padding: const EdgeInsets.all(5.0),
            decoration: const BoxDecoration(
              border:
                  Border(bottom: BorderSide(color: Colors.brown, width: 2.0)),
            ),
            child: Wrap(
              children: [
                RaisedButton(
                  color: Colors.lightBlue[800],
                  onPressed: () async {
                    var cleanning = false;
                    await showDialog<void>(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => SimpleDialog(
                            title: const Text('清除缓存'),
                            children: [
                              cleanning
                                  ? const Text('清除中...')
                                  : RaisedButton(
                                      onPressed: () async {
                                        setState(() {
                                          cleanning = true;
                                        });
                                        await globals.cleanCacheManager();
                                        setState(() {
                                          cleanning = false;
                                        });
                                      },
                                      child: const Text('清理'),
                                    ),
                              RaisedButton(
                                onPressed: cleanning
                                    ? null
                                    : () {
                                        Navigator.pop(context);
                                      },
                                child: const Text('关闭'),
                              ),
                            ],
                          ),
                    );
                  },
                  child: const Text('缓存',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                      )),
                ),
              ],
            ),
          ),
        ],
      );
}

class _BlacklistButton extends StatelessWidget {
  _BlacklistButton(
    this.filter, {
    @required this.blocked,
    @required this.onPressed,
  });

  final Filter filter;
  final bool blocked;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Container(
        child: RawMaterialButton(
          constraints: const BoxConstraints(minWidth: 50.0),
          shape: RoundedRectangleBorder(
            side: BorderSide(
              color: blocked ? Colors.red[900] : Colors.green,
              width: 2.0,
            ),
            borderRadius: const BorderRadius.all(Radius.circular(9.0)),
          ),
          fillColor: blocked ? Colors.red : Colors.white,
          padding: const EdgeInsets.fromLTRB(20.0, 9.0, 20.0, 9.0),
          child: Text(filter.title,
              style: TextStyle(
                fontSize: 17.0,
                color: blocked ? Colors.black : Colors.green[900],
              )),
          onPressed: onPressed,
        ),
      );
}
