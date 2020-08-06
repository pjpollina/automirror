require 'fileutils'
require 'rb-inotify'

class Mirrorable
  attr_reader :origin, :reflection, :lastmod

  def initialize(origin, reflection, lastmod=nil)
    @origin = origin
    @reflection = reflection
    unless(File.exist?(origin))
      puts "Warning: Origin file #{origin} does not exist. Creating empty file."
      FileUtils.touch(origin)
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

#test = Mirrorable.new('/home/pj/Projects/automirror/test/foo.txt', '/home/pj/Projects/automirror/test/bar.txt')
#test.mirror
#puts "#{test.lastmod}\n#{File.mtime(test.reflection)}"

#notifier = INotify::Notifier.new
#notifier.watch('/home/pj/Projects/automirror/test/foo.txt', :modify) do
#  puts "File modified"
#end
#notifier.run

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

test = AutoMirror.new(Mirrorable.new('/home/pj/Projects/automirror/test/foo.txt', '/home/pj/Projects/automirror/test/bar.txt'))
test.start
