require 'spec_helper'
require 'digest/md5'

describe 'pgbouncer::database', type: :define do
  let(:title) { 'test' }
  describe 'compiles successfully' do
    it { should compile.and_raise_error(/pgbouncer::database is private/) }
  end
end
