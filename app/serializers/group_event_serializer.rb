class GroupEventSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :start_date, :end_date, :location_name, :created_at, :updated_at
end
