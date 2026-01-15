# Fish Food - Test Suite

This project uses **GdUnit4** for automated testing.

## Setup

1. **Install GdUnit4** via Godot's AssetLib:
   - Open Godot Editor
   - Go to AssetLib tab
   - Search for "GdUnit4"
   - Click Download, then Install

2. **Enable the plugin**:
   - Go to Project > Project Settings > Plugins
   - Enable "GdUnit4"

3. **Restart Godot** after installation

## Running Tests

### From Editor
- Open the GdUnit4 dock (usually appears on the left side)
- Click "Run All" to run all tests
- Or right-click a specific test file to run it

### From Command Line
```bash
# Run all tests
godot --headless -s addons/gdUnit4/bin/GdUnitCmdTool.gd --run-all

# Run specific test
godot --headless -s addons/gdUnit4/bin/GdUnitCmdTool.gd --run tests/status_effect_manager_test.gd
```

## Test Structure

```
tests/
├── README.md                      # This file
├── status_effect_manager_test.gd  # StatusEffectManager tests
├── damage_number_pool_test.gd     # DamageNumberPool tests
├── player_stats_test.gd           # Player stat calculation tests
└── entity_registry_test.gd        # EntityRegistry performance tests
```

## Writing Tests

Tests extend `GdUnitTestSuite` and follow this pattern:

```gdscript
class_name MySystemTest
extends GdUnitTestSuite

func before_test() -> void:
    # Setup before each test

func after_test() -> void:
    # Cleanup after each test

func test_something_works() -> void:
    # Arrange
    var thing = create_thing()

    # Act
    thing.do_action()

    # Assert
    assert_bool(thing.is_done).is_true()
```

### Key Assertions
- `assert_bool(value).is_true()` / `.is_false()`
- `assert_int(value).is_equal(expected)`
- `assert_float(value).is_equal_approx(expected, tolerance)`
- `assert_str(value).is_equal(expected)`
- `assert_object(value).is_not_null()` / `.is_same(other)`

### Memory Management
Use `auto_free()` for nodes created in tests to prevent memory leaks:

```gdscript
var node = auto_free(Node.new())
```

## Test Categories

### Unit Tests
Test individual functions in isolation:
- Stat calculations
- Color blending
- Pool management

### Integration Tests
Test systems working together:
- Status effects with managers
- Damage numbers with pooling
- Upgrades affecting player stats

### Performance Tests
Verify optimization patterns work:
- EntityRegistry lookup speed
- Pool reuse efficiency
- Cache invalidation behavior
