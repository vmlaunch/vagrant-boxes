module VagrantBoxes

  class Template

    attr_accessor :environment
    attr_accessor :path

    def initialize(environment, path)
      @environment = environment
      @path = path
    end

    def path_relative
      Pathname.new(path).relative_path_from(Pathname.new(environment.path))
    end

    def name
      path_relative.sub(/.json$/, '').to_s
    end

    def output_path(builder)
      template_data = JSON.parse(IO.read(path))
      box_path = template_data['post-processors'][0]['output']
      box_path.sub!('{{.Provider}}', builder)
      File.join(File.dirname(path), box_path).to_s
    end

    def exec(command)
      output = ''
      Dir.chdir(File.dirname(path)) do
        io = IO.popen(command, :err => [:child, :out]).each do |line|
          puts line
          output += line
        end
        io.close
        if $?.exitstatus > 0
          raise "Failure executing command `#{command}`."
        end
      end
      output
    end
  end
end
