# frozen_string_literal: true

Dir.glob('tasks/*.rake').each do |task|
  import task
end

desc 'Run the hermetic unit test suite'
task default: 'test:unit'
