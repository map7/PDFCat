require 'test/unit'
require 'shortcuts_helper'

class ShortcutsTest < Test::Unit::TestCase
  include ShortcutsHelper

  def test_shortcut_function
    result = shortcut_function('a', "alert('hello world');")
    assert result == "<script>Shortcuts.register_shortcut('a', function() { alert('hello world'); });</script>"
  end
  
  protected
  
  def javascript_tag content
    "<script>#{content}</script>"
  end
  
end
