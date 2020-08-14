require 'rb-inotify'

class AutoMirror
  attr_reader :mirrorables, :notifier

  def initialize(*mirrorables)
    @mirrorables = mirrorables.flatten
    @notifier = INotify::Notifier.new
    addnotifs
  end

  def addnotifs
    @mirrorables.each do |mirrorable|
      notifier.watch(mirrorable.origin, :close_write) do
        puts "File '#{mirrorable.origin.split('/').last}' modified. Mirroring."
        mirrorable.mirror
      end
    end
  end

  def start
    notifier.run
  end
end
