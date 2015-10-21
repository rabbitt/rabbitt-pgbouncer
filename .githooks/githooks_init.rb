require 'yaml'
require 'githooks'

GitHooks::Hook.register 'pre-commit' do
  commands :ruby, :erb, :puppet, :file

  limit(:type).to :modified, :added, :untracked, :tracked
  limit(:path).to %r/\.(rb|erb|pp|ya?ml)$/i

  section 'Validate Content' do
    action 'ASCII Only Manifests' do
      limit(:path).to %r|\.pp$|i

      on_each_file do |file|
        valid = true
        IO.readlines(file.full_path).each_with_index do |line, n|
          unless line.ascii_only?
            $stderr.puts "#{file.path}: Non-ASCII characters found on the following lines" if valid
            $stderr.puts "#{file.path}:#{n+1}: #{line}"
            valid = false
          end
        end
        valid
      end
    end
  end

  section 'Validate Syntax' do
    action 'Puppet Manifest' do
      limit(:path).to %r|\.pp$|i

      on_all_files do |files|
        puppet('parser', 'validate', files.collect(&:full_path)) do |result|
          next false if result.output.size > 0
        end
      end
    end

    action 'Puppet Template' do
      limit(:path).to %r|\.erb$|i

      on_each_file do |file|
        erb *%W[-P -x -T '-' #{file.full_path} ], prefix_output: file.path, post_pipe: 'ruby -c'
      end
    end

    action 'Ruby' do
      limit(:path).to %r|\.rb$|i

      on_each_file do |file|
        ruby '-c', file.full_path, prefix_output: file.path
      end
    end

    action 'YAML' do
      limit(:path).to %r|\.ya?ml$|i

      on_each_file do |file|
        begin
          YAML.load(IO.read(file.full_path)).tap { puts "#{file.path}" }
        rescue StandardError => e
          $stderr.puts "#{file.path}\n\t#{e.class.name}: #{e.message}"
          false
        end
      end
    end

    action 'No Leading Tabs in Puppet Manifest or Ruby files' do
      limit(:path).to %r/\.(rb|pp)$/i

      on_each_file do |file|
        puts file.path
        file.grep(/^[ ]*(\t+)/).tap do |matches|
          matches.each do |line_number, line_text|
            line_text.gsub!(/^[ ]*(\t+)/) do
              ('_' * $1.size).failure!
            end
            $stderr.printf "%#{matches.last.first.to_s.size}d: %s\n", line_number, line_text
          end
        end.empty?
      end
    end
  end
end
