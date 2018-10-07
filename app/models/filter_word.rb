class FilterWord < ActiveRecord::Base

  TYPE_BLOCK_FULL = 1   # block word [ass]
  TYPE_BLOCK_PICE = 2   # block ass like [123ass11]
  TYPE_ALLOW = 3        # allowed words [class, pass]
  
  def initialize
    
  end
end
