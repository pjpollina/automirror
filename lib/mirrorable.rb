require 'fileutils'

class Mirrorable
  attr_reader :origin, :reflection, :broken

  def initialize(origin, reflection)
    @broken = false
    @origin = origin
    @reflection = reflection
    unless(broken? || File.exist?(origin))
      if(File.exist?(reflection))
        puts "Warning: Origin file #{origin} does not exist but reflection does. Copying from reflection."
        FileUtils.cp(reflection, origin)
      else
        puts "Warning: Origin file #{origin} does not exist. Creating empty file."
        FileUtils.touch(origin)
      end
    end
  end

  def mirror
    FileUtils.cp(origin, reflection)
    FileUtils.touch(reflection, mtime: File.mtime(origin))
  end

  alias_method(:broken?, :broken)
end
