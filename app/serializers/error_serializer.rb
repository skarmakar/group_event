# JSON API Specification for error: https://jsonapi.org/examples/#error-objects-error-codes
class ErrorSerializer < ActiveModel::Serializer
  def self.serialize(object)
    object.errors.messages.map do |field, errors|
      errors.map do |error_message|
        {
          status: 422,
          source: {pointer: "/data/attributes/#{field}"},
          detail: error_message
        }
      end
    end.flatten
  end
end
