class ShortcutsGenerator < Rails::Generator::Base
  def manifest
    record do |m|
      m.directory('public/javascripts')
      m.file('shortcuts.js', 'public/javascripts/shortcuts.js')
    end
  end
end