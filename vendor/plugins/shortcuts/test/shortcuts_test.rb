require 'test/unit'
require 'shortcuts_helper'

#
# Javascript unit testing.
#
class ShortcutsTest < Test::Unit::TestCase
  include ShortcutsHelper

  def test_shortcut
    result = shortcut('g', "http://www.google.com")
    assert result == "<script>Shortcuts.register_shortcut('g', function() { document.location.href='http://www.google.com'; });</script>"
  end

  def test_shortcut_function
    result = shortcut_function('a', "alert('hello world');")
    assert result == "<script>Shortcuts.register_shortcut('a', function() { alert('hello world'); });</script>"
  end

  def test_shortcut_fnkey
    result = shortcut_fnkey('2', "http://www.google.com")
    assert result == "<script>Shortcuts.register_shortcut_fnkey('2', function() { document.location.href='http://www.google.com'; });</script>"
  end

  def test_shortcut_fnkey_function
    result = shortcut_fnkey_function('1', "alert('F1 pressed');")
    assert result == "<script>Shortcuts.register_shortcut_fnkey('1', function() { alert('F1 pressed'); });</script>"
  end

  def test_shortcut_ctrl
    result = shortcut_ctrl('g', "http://www.google.com")
    assert result == "<script>Shortcuts.register_shortcut_ctrl('g', function() { document.location.href='http://www.google.com'; });</script>"
  end

  def test_shortcut_ctrl_function
    result = shortcut_ctrl_function('1', "alert('Ctrl 1 pressed');")
    assert result == "<script>Shortcuts.register_shortcut_ctrl('1', function() { alert('Ctrl 1 pressed'); });</script>"
  end

  protected

  def javascript_tag content
    "<script>#{content}</script>"
  end

end
