class ShortcutsGenerator < Rails::Generator::Base
  def manifest
    record do |m|
      m.directory('public/javascripts')
      m.file('shortcuts.js', 'public/javascripts/shortcuts.js')
      m.file('select_mode.js', 'public/javascripts/select_mode.js')
    end
  end
end
