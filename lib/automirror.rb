require 'fileutils'
require 'rb-inotify'

class Mirrorable
  attr_reader :origin, :reflection, :lastmod

  def initialize(origin, reflection, lastmod=nil)
    @origin = origin
    @reflection = reflection
    unless(File.exist?(origin))
      if(File.exist?(reflection))
        puts "Warning: Origin file #{origin} does not exist but reflection does. Copying from reflection."
        FileUtils.cp(reflection, origin)
      else
        puts "Warning: Origin file #{origin} does not exist. Creating empty file."
        FileUtils.touch(origin)
      end
    end
    @lastmod = lastmod || File.mtime(origin)
  end

  def mirror
    update_lastmod
    FileUtils.cp(origin, reflection)
    FileUtils.touch(reflection, mtime: lastmod)
  end

  def update_lastmod
    @lastmod = File.mtime(origin)
  end
end

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
