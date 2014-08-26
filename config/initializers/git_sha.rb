ENV['GIT_SHA'] = `git rev-parse HEAD`.chomp
ENV['GIT_DATE'] = `git show -s --format=%ci HEAD`.chomp
