def parsed_jsonapi_response(response, options = {})
  parsed = JSON.parse(response.body)
  
  if options[:data_only]
    parsed['data']
  else
    parsed
  end
end

def jsonapi_response_errors(response, options = {})
  parsed = JSON.parse(response.body)['errors']

  if options[:details_with_pointer]
    parsed.collect do |error|
      "#{error['source']['pointer'].split('/').last} #{error['detail']}"
    end
  else
    parsed
  end
end

def post_request_params(object_name, attributes)
  {
    data: {
      type: object_name,
      attributes: attributes
    }
  }
end

def yyyy_mm_dd(date)
  date.strftime('%Y/%m/%d')
end
