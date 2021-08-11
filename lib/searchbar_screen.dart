import 'dart:developer';

import 'package:flutter/material.dart';

class SearchBar extends StatefulWidget {
  SearchBar({Key? key, required this.function}) : super(key: key);
  Function function;

  @override
  _SearchBarState createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  final TextEditingController _filter = TextEditingController();

  // 검색할 화면에서 사용할 text 에 대한 control

  // SearchBar 에 커서 상태를 저장하는 위젯
  FocusNode focusNode = FocusNode();
  String _searchText = "";

  _SearchBarState() {
    _filter.addListener(() {
      setState(() {
        _searchText = _filter.text;
      });
    });
    //print(_filter.text);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Container(
            color: Colors.black,
            padding: const EdgeInsets.fromLTRB(5, 10, 5, 10),
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 6,
                  child: TextField(
                    textInputAction: TextInputAction.go,
                    // textField 에 대한 Enter Event on
                    onSubmitted: (value) {
                      // When Pressed Enter, Event 처리 부분
                      log('Enter Pressed : $_searchText');
                      widget.function(_searchText);
                    },

                    focusNode: focusNode,
                    style: const TextStyle(fontSize: 15, color: Colors.white),
                    autofocus: true,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white12,
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Colors.white60,
                        size: 20,
                      ),
                      suffixIcon: focusNode.hasFocus
                          ? IconButton(
                              onPressed: () {
                                _filter.clear();
                                _searchText = "";
                              },
                              icon: const Icon(
                                Icons.cancel,
                                size: 20,
                                color: Colors.white,
                              ))
                          : Container(),
                      hintText: '검색',
                      hintStyle: const TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                      labelStyle: const TextStyle(color: Colors.white),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.transparent),
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.transparent),
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      border: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.transparent),
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                    ),
                    controller: _filter,
                  ),
                ),
                focusNode.hasFocus
                    ? Expanded(
                        child: TextButton(
                        onPressed: () {
                          setState(() {
                            _filter.clear();
                            _searchText = "";
                            focusNode.unfocus();
                          });
                        },
                        child: const Text(
                          '취소',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ))
                    : Expanded(
                        flex: 0,
                        child: Container(),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
