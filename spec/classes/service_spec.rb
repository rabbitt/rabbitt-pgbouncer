require 'spec_helper'

describe 'pgbouncer::service', :type => :class do
  describe 'compiles successfully' do
    it { should compile.and_raise_error(/pgbouncer::service is private/) }
  end
end
