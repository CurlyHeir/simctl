require 'cfpropertylist'

module SimCtl
  class DeviceSettings
    attr_reader :path

    def initialize(path)
      @path = path
    end

    # Disables the keyboard helpers
    #
    # @return [void]
    def disable_keyboard_helpers!
      edit_plist(path.preferences_plist) do |plist|
        %w(
          KeyboardAllowPaddle
          KeyboardAssistant
          KeyboardAutocapitalization
          KeyboardAutocorrection
          KeyboardCapsLock
          KeyboardCheckSpelling
          KeyboardPeriodShortcut
          KeyboardPrediction
          KeyboardShowPredictionBar
        ).each do |key|
          plist[key] = false
        end
      end
    end

    def edit_plist(path, &block)
      plist = File.exists?(path) ? CFPropertyList::List.new(file: path) : CFPropertyList::List.new
      content = CFPropertyList.native_types(plist.value) || {}
      yield content
      plist.value = CFPropertyList.guess(content)
      plist.save(path, CFPropertyList::List::FORMAT_BINARY)
    end

    # Sets the device language
    #
    # @return [void]
    def set_language(language)
      edit_plist(path.global_preferences_plist) do |plist|
        key = 'AppleLanguages'
        plist[key] = [] unless plist.has_key?(key)
        plist[key].unshift(language).uniq!
      end
    end
  end
end