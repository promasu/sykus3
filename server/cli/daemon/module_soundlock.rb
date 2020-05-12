module SoundLock
  def self.hooks(scheduler)
    scheduler.every '1s' do
      set CliInfo.get[:soundlock]
    end
  end

  private
  def self.set(state)
    return unless Session.is_student?

    # action: unlock
    if !state && @state
      Util.userdo 'pactl set-sink-mute 0 0'
    end

    # action: locked, run constantly
    if state
      Util.userdo 'pactl set-sink-mute 0 1'
    end

    @state = state
  end
end

