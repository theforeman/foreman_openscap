object @result

attributes :errors

child :results => :results do
  extends 'api/v2/compliance/scap_contents/index'
end
