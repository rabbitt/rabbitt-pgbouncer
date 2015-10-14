require 'spec_helper'

describe 'pgbouncer::config', :type => :class do
  describe 'compiles successfully' do
    it { should compile.and_raise_error(/pgbouncer::config is private/) }
  end
end
