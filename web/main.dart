// Copyright (c) 2017, Patrick Borgeest. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:html';
import 'dart:math';
import './data.dart';


class Drill {
  final String question, answer;

  Drill(this.question, this.answer);

  Node questionDiv() {
    return _makeDiv('question', this.question);
  }

  Node answerDiv() {
    return _makeDiv('answer', this.answer);
  }

  DivElement _makeDiv(String classname, String text) {
    var div = new DivElement();
    div.className = classname;
    div.text = text;
    return div;
  }
}


class Drills {
  List<Drill> _drills;

  Drills() {
    this._drills = new List<Drill>();
    data.forEach((drill) =>
        this.add(drill.elementAt(0), drill.elementAt(1))
    );
  }
  void add(String question, String answer) {
    this._drills.add(new Drill(question, answer));
  }
  Drill randomDrill() {
    final _random = new Random();
    return this._drills[_random.nextInt(this._drills.length)];
  }
}


abstract class State {
  State nextState();
  List<Element> _elements();
  void appendElementsTo(Element root) {
    this._elements().forEach((element) => root.append(element));
  }
  Element button() {
    Element button = new ButtonElement();
    button.text = "click";
    button.onClick.listen((e) => app.displayNextState());
    return button;
  }
}

class StartState extends State {
  Drill _currentDrill;

  StartState() {
    this._currentDrill = new Drills().randomDrill();
  }

  @override
  List<Element> _elements() {
    return [
      this._currentDrill.questionDiv(),
      this.button()
      ];
  }

  @override
  State nextState() {
    return new ResultState(this._currentDrill);
  }
}

class ResultState extends State {
   Drill _currentDrill;

  ResultState(this._currentDrill);

  @override
  List<Element> _elements() {
    return [
      this._currentDrill.questionDiv(),
      this._currentDrill.answerDiv(),
      this.button()
    ];
  }

  @override
  State nextState() {
    return new StartState();
  }
}

class App {
  State _state;
  Element _htmlNode;
  App(this._htmlNode, this._state) {
    this._redraw();
  }
  void _redraw() {
    this._htmlNode.children.clear();
    this._state.appendElementsTo(this._htmlNode);
  }
  void displayNextState() {
    this._state = this._state.nextState();
    this._redraw();
  }
}

App app;

void main() {
  app = new App(querySelector('#output'), new StartState());
}
