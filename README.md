# Crontab RB

[![Gem Version](https://badge.fury.io/rb/crontab_rb.svg)](https://badge.fury.io/rb/crontab_rb)

crontab_rb is a Ruby gem that provides easy and safe way to manage your cron jobs unix file via CRUD.

### Installation

```sh
$ gem install crontab_rb
```

Or with Bundler in your Gemfile.

```ruby
gem 'crontab_rb'
```
Run bundle install to install the backend and crontab_rb gems.

### Getting started

Add new a cron job at every 10th minute.
```ruby
# */10 * * * * /bin/bash -l -c 'cd path_to_rails_app && bundle exec rake backup_db'

CrontabRb::Cron.create(name: 'Backup database', time: '1', at: '10', command: 'rake backup_db')
```

Delete a cron job
```ruby
CrontabRb::Cron.destroy("64f4f0bc-ad80-48ef-bbb9-98c9c17624bd")
```

Get list cron jobs
```ruby
CrontabRb::Cron.all
```

Update a cron job
```ruby
# 30 * * * * /bin/bash -l -c 'cd path_to_rails_app && bundle exec rake remove_log'

CrontabRb::Cron.destroy("64f4f0bc-ad80-48ef-bbb9-98c9c17624bd", {name: 'Remove log file', time: '60', at: '30', command: 'rake remove_log'})
```

### Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/Nguyenanh/crontab_rb.


### Contribute
Fork Crontab UI and contribute to it. Pull requests are encouraged.

### License
[MIT](LICENSE.md)
