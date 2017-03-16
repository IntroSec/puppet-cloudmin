require 'spec_helper'
describe 'cloudmin' do
  context 'with default values for all parameters' do
    it { should contain_class('cloudmin') }
  end
end
