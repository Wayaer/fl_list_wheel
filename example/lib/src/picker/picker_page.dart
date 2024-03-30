import 'package:fl_list_wheel/fl_list_wheel.dart';
import 'package:flutter/material.dart';

final numberList = ['一', '二', '三', '四', '五', '六', '七', '八', '十'];

final List<String> letterList = ['A', 'B', 'C', 'D', 'E', 'F'];

final Map<String, dynamic> mapABC = {
  'A1': ['A2'],
  'B1': {
    'B2': [
      'B3',
      'B3',
      'B3',
    ],
    'B2-1': {
      'B3': [
        'B4',
        'B4',
        'B4',
      ]
    }
  },
  'C1': {
    'C2': {
      'C3': {
        'C4': {
          'C5': [
            'C6',
            'C6',
            'C6',
            'C6',
            'C6',
          ]
        }
      }
    },
    'C21': [
      'C3',
      'C3',
      'C3',
    ],
    'C22': [
      'C3',
      'C3',
      'C3',
    ]
  }
};

class BackCard extends Card {
  const BackCard(
    Widget child, {
    super.key,
    super.margin = const EdgeInsets.only(top: 10),
  }) : super(child: child);
}

class BasePickerOptions<T> extends PickerOptions<T> {
  BasePickerOptions(
      {super.cancel = const Text('取消'),
      super.title = const Row(
          mainAxisAlignment: MainAxisAlignment.center, children: [Text('选择器')]),
      super.confirm = const Text('确定'),
      super.top,
      super.decoration,
      super.bottom =
          const Divider(thickness: 0.5, height: 0.5, color: Colors.black12),
      super.padding = const EdgeInsets.symmetric(horizontal: 10),
      super.contentPadding,
      super.background,
      super.backgroundColor,
      super.verifyConfirm,
      super.verifyCancel,
      super.bottomNavigationBar = const Text('bottomNavigationBar')});
}
