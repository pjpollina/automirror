require 'rb-inotify'

class AutoMirror
  attr_reader :mirrorables, :notifier

  def initialize(*mirrorables)
    @mirrorables = mirrorables.flatten
    @notifier = INotify::Notifier.new
    addnotifs
  end

  def addnotifs
    unbroken.each do |mirrorable|
      if(File.exists?(mirrorable.origin))
        puts "File '#{mirrorable.origin.split('/').last}' modified. Mirroring."
        mirrorable.mirror
      else
        puts "Warning: File '#{mirrorable.origin.split('/').last}' deleted. Mirroring ceased."
      end
    end
  end

  def unbroken
    mirrorables.reject {|m| m.broken?}
  end

  def start
    notifier.run
  end
end
