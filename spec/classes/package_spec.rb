require 'spec_helper'

describe 'pgbouncer::package', :type => :class do
  describe 'compiles successfully' do
    it { should compile.and_raise_error(/pgbouncer::package is private/) }
  end
end
