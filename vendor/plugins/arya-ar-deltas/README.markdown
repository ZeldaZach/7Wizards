# ActiveRecord Delta Updates
    model = Widget.find(1)
    puts model.number #=> 0
    model.number += 5
    model.save

    # Before:
    UPDATE `widgets` SET `number` = 5 WHERE `id` = 1;

    # After:
    UPDATE `widgets` SET `number` = `number` + 5 WHERE `id` = 1;

# Install
    sudo gem sources -a http://gems.github.com # unless you already have it
    sudo gem install arya-ar-deltas
    
# Use
    class Widget < ActiveRecord::Base
      delta_attributes :number_one, :number_two
    end
    
# Notes
  * Only works with numeric columns
  * Tested in with ActiveRecord 2.3.3 and 3.0.0pre
  * You don't have to use += or -=, it uses the changes hash to figure out the difference to apply
  * If you're using write-through caching, be careful about running into inconsistencies