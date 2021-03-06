module ShortcutsHelper

  # Register a keyboard shortcut for a given url. When the shortcut key is pressed,
  # document.location.href is set to the specified url via javascript.
  def shortcut key, url
    shortcut_function key, "document.location.href='#{url}';"
  end

  # Register a keyboard shortcut for a given url. When the shortcut key is pressed,
  # the url is called remotely via an Ajax call.
  def remote_shortcut key, url, options={:method=>:get}
   shortcut_function key, remote_function(options.merge(:url=>url))
  end

  # Register a custom javascript function to be executed when the shortcut key is pressed.
  def shortcut_function key, function
    javascript_tag("Shortcuts.register_shortcut('#{key}', function() { #{ function } });")
  end

  # Used to jump to locations using Ctrl + <char>
  def shortcut_ctrl key, url
    shortcut_ctrl_function key, "document.location.href='#{url}';"
  end

  # Register a keyboard shortcut for a given url. When the shortcut key is pressed,
  # the url is called remotely via an Ajax call.
  def remote_shortcut_ctrl key, url, options={:method=>:get}
   shortcut_ctrl_function key, remote_function(options.merge(:url=>url))
  end

  # Used to jump to locations using Ctrl + <char>
  def shortcut_ctrl_function key, function
    javascript_tag("Shortcuts.register_shortcut_ctrl('#{key}', function() { #{ function } });")
  end

  # Used to jump to locations using Fnkey
  def shortcut_fnkey key, url
    shortcut_fnkey_function key, "document.location.href='#{url}';"
  end

  # Register a keyboard shortcut for a given url. When the shortcut key is pressed,
  # the url is called remotely via an Ajax call.
  def remote_shortcut_fnkey key, url, options={:method=>:get}
   shortcut_fnkey_function key, remote_function(options.merge(:url=>url))
  end

  # Used to jump to locations using Fnkey
  def shortcut_fnkey_function key, function
    javascript_tag("Shortcuts.register_shortcut_fnkey('#{key}', function() { #{ function } });")
  end

end
