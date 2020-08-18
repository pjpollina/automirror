require 'fileutils'

class Mirrorable
  attr_reader :origin, :reflection, :broken

  def initialize(origin, reflection)
    @broken = false
    set_origin(origin)
    set_reflection(reflection)
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

  private

  def set_origin(origin)
    @origin = origin
    unless(File.readable?(origin) && File.writable?(origin))
      if(File.exist?(origin))
        puts "Error: Read and/or write permission denied for origin file #{origin}. Cannot mirror file."
        @broken = true
      else
        unless(File.writable?(origin.split('/')[0..-2].join('/')))
          puts "Error: Origin file #{origin} does not exist and cannot be created. Cannot mirror file."
          @broken = true
        end
      end
    end
  end

  def set_reflection(reflection)
    @reflection = reflection
    unless(File.readable?(reflection) && File.writable?(reflection))
      if(File.exist?(reflection))
        puts "Error: Read and/or write permission denied for reflection file #{reflection}. Cannot mirror file."
        @broken = true
      else
        unless(File.writable?(reflection.split('/')[0..-2].join('/')))
          puts "Error: Reflection file #{reflection} does not exist and cannot be created. Cannot mirror file."
          @broken = true
        end
      end
    end
  end
end
