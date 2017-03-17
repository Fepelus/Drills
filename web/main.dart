//	Copyright (c) 2017, Patrick Borgeest. All rights reserved.
//	Use of this source code is governed by a BSD-style license
//	that can be found in the LICENSE file.

import 'dart:html';
import 'dart:math';
import './data.dart';

/// Represents a single pair of one question and one answer.
class Drill {
  final String question, answer;

  Drill(this.question, this.answer);

  /// Marks-up the question inside a DIV element.
  Element questionDiv() {
    return _makeDiv('question', this.question);
  }

  /// Marks-up the answer inside a DIV element.
  Element answerDiv() {
    return _makeDiv('answer', this.answer);
  }

  DivElement _makeDiv(String classname, String text) {
    var div = new DivElement();
    div.className = classname;
    div.text = text;
    return div;
  }
}

/// Represents the collection of all available pairs of questions and answers.
class Drills {
  List<Drill> _drills;

  /// Fills the collection with the given data.
  Drills(List<List<String>> inputDrillData) {
    this._drills = new List<Drill>();
    inputDrillData.forEach((drill) =>
      this._drills.add(new Drill(drill.elementAt(0), drill.elementAt(1)))
    );
  }

  /// Returns one of the entries in the collection chosen at random.
  Drill randomDrill() {
    final _random = new Random();
    return this._drills[_random.nextInt(this._drills.length)];
  }
}

/// Parent class of the two State objects.
abstract class State {

  /// Returns the State that must follow the current
  /// State in this state machine.
  State nextState();

  /// Returns all of the elements that should appear
  /// when the app is in a particular state.
  List<Element> _elements();

  /// Appends to the argument all of the elements that should
  /// appear in a concrete state.
  void appendElementsTo(Element root) {
    this._elements().forEach((element) => root.append(element));
  }
}

/// Represents the state of the app when it is displaying the question
/// only and is not showing the answer.
class StartState extends State {
  Drill _currentDrill;

  StartState() {
    // When the app changes to this state then a Drill to display is taken
    // at random from the data.
    this._currentDrill = new Drills(data).randomDrill();
  }

  /// When the app is in the StartState then display the question
  /// inside its DIV element and also a button that will move the
  /// app to the next state.
  @override
  List<Element> _elements() {
    return [
      this._currentDrill.questionDiv(),
      new NextStateButton().element()
      ];
  }

  /// The next state will be ResultState.
  ///
  /// The drill that was randomly chosen when this object was created
  /// will here be passed to the ResultState so that the app can show
  /// the right answer to the question.
  @override
  State nextState() {
    return new ResultState(this._currentDrill);
  }
}

/// Represents the state of the app when it is displaying the question
/// along with its answer
class ResultState extends State {
   Drill _currentDrill;

  ResultState(this._currentDrill);

   /// When the app is in the ResultState then display the question
   /// inside its DIV element, the answer inside its DIV element,
   /// and also a button that will move the app to the next state.
   @override
  List<Element> _elements() {
    return [
      this._currentDrill.questionDiv(),
      this._currentDrill.answerDiv(),
      new NextStateButton().element()
    ];
  }

  /// The next state will be to return to the StartState.
  @override
  State nextState() {
    return new StartState();
  }
}

/// A button that tells the app to move to the next state
class NextStateButton {
  Element _button;
  NextStateButton() {
	this._button = new ButtonElement();
    this._button.text = "click";
    this._button.onClick.listen((e) => app.displayNextState());
  }

  Element element() {
    return this._button;
  }

}

/// Represents the visual app in front of the user.
class App {
  /// The current State to be displayed
  State _state;
  /// The Node to which the markup that this app generates is to be appended
  Element _htmlNode;
  /// Draws the initial state
  App(this._htmlNode, this._state) {
    this._redraw();
  }
  void _redraw() {
    this._htmlNode.children.clear();
    this._state.appendElementsTo(this._htmlNode);
  }
  /// Moves the app to the next state
  /// and then generates the markup for that state.
  void displayNextState() {
    this._state = this._state.nextState();
    this._redraw();
  }
}

// on the global object so that the NextStateButton can call it
App app;

void main() {
  // The HTML in the index.html file has a DIV with 'output' as its ID.
  app = new App(querySelector('#output'), new StartState());
}
