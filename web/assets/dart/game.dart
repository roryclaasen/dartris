part of dartris;

class GameRenderer {

    final int _width, _height;

    List<StateBase> _states;
    StateBase _currentState;

    GameRenderer(this._width, this._height) {
        _states = new List<StateBase>();
        _states.add(new StateMenu(this));
        _states.add(new StateGame(this));

        setState(0);
        setState(1);
    }

    void update(final double elapsed) => _currentState.update(elapsed);

    void render(final CanvasRenderingContext2D ctx) {
        ctx.clearRect(0, 0, width, height);
        _currentState.render(ctx);
    }

    void setState(int id) {
        if (_states != null && id >= 0) {
            if (_states.length > 0 && id < _states.length) {
                if (_currentState != null) _currentState.onStateLeave();
                _currentState = _states[id];
                _currentState.onStateEnter();
                log.info('Changed state to $_currentState');
            }
        }
    }

    int get width => _width;
    int get height => _height;
}

abstract class StateBase {
    final GameRenderer _renderer;

    List<StreamSubscription> _listeners;

    StateBase(this._renderer) {
        _listeners = new List<StreamSubscription>();
    }

    void update(final double elapsed);
    void render(final CanvasRenderingContext2D ctx);

    void onStateLeave() {
        listeners.forEach((l) => l.cancel());
        listeners.clear();
    }

    void onStateEnter() {}

    GameRenderer get renderer => _renderer;
    List<StreamSubscription> get listeners => _listeners;
}

class StateMenu extends StateBase {
    StateMenu(final GameRenderer renderer) : super(renderer) {}

    void onStateEnter() {
        super.onStateEnter();
        listeners.add(window.onKeyDown.listen((e) {
            if (e.keyCode == KeyCode.SPACE) {
                renderer.setState(1);
            }
        }));
    }

    void update(final double elapsed) {}

    void render(final CanvasRenderingContext2D ctx) {}
}

class StateGame extends StateBase {
    Grid _grid;

    int _gridSquare;
    StateGame(final GameRenderer renderer) : super(renderer) {
        _grid = new Grid();
        _gridSquare = renderer.width ~/ Grid.width;
    }

    void update(final double elapsed) {}

    void render(final CanvasRenderingContext2D ctx) {
        ctx.setFillColorRgb(0, 0, 0);
        for (int x = 0; x < Grid.width; x ++) {
            for (int y = 0; y < Grid.height; y ++) {
                int index = grid.array[x][y];
                if (index == null) continue;
                Tile tile = Tile.fromIndex(index);
                RgbColor color = tile.color.toRgbColor();
                ctx.setFillColorRgb(color.r, color.g, color.b);
                ctx.fillRect(x * _gridSquare, y * _gridSquare, _gridSquare, _gridSquare);
                //ctx..rect(x * _gridSquare, y * _gridSquare, _gridSquare, _gridSquare)..stroke();
            }
        }
    }

    Grid get grid => _grid;
}
