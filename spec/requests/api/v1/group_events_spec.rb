require 'rails_helper'

# TODO - can be moved to a custom matcher
def is_a_group_event?(response_attrs)
  response_attr_keys = response_attrs['attributes'].keys

  response_attrs['id'].present? &&
    response_attrs['type'] == 'group-events' &&
    %w(name description start-date end-date location-name created-at updated-at)
      .all? {|key| response_attr_keys.include?(key) }
end

RSpec.describe 'Api::V1::GroupEvents', type: :request do
  describe 'GET /api/v1/group_events' do
    it 'is expected to get an array of non deleted group events' do
      2.times { create(:group_event, :with_all_attributes) }
      create(:group_event, :with_all_attributes).destroy
      expect(GroupEvent.count).to eq(3)

      get '/api/v1/group_events'
      parsed_response = parsed_jsonapi_response(response, data_only: true)
      expect(parsed_response.length).to eq(2)
      
      parsed_response.each do |response_data|
        expect(is_a_group_event?(response_data)).to be_truthy
      end
    end
  end

  describe 'POST create' do
    let(:create_url) { '/api/v1/group_events' }

    context 'invalid requests' do
      it 'is expected to throw error for empty payload' do
        post create_url, {
          params: post_request_params(:group_events, {})
        }
        
        expect(response.status).to eq(422)
        errors = jsonapi_response_errors(response, details_with_pointer: true)
        expect(errors).to include('base Please provide at least one of name, description, start_date, end_date, duration, location_name')
      end

      it 'is expected to throw error for invalid end date, when start date is greater than end date' do
        post create_url, {
          params: post_request_params(:group_events, {
            start_date: yyyy_mm_dd(1.day.from_now.to_date),
            end_date:   yyyy_mm_dd(Date.today)
          })
        }
        
        expect(response.status).to eq(422)
        errors = jsonapi_response_errors(response, details_with_pointer: true)
        expect(errors).to include('end_date should be greater than start date')
      end

      it 'is expected to throw error for invalid duration' do
        post create_url, {
          params: post_request_params(:group_events, {
            start_date: yyyy_mm_dd(Date.today),
            end_date: yyyy_mm_dd(Date.today + 2.days),
            duration: 10
          })
        }
        
        expect(response.status).to eq(422)
        errors = jsonapi_response_errors(response, details_with_pointer: true)
        expect(errors).to include('duration is not matching with start date and end date')
      end

      context 'published' do
        it 'is expected to throw error if published group event is created with any key missing' do
          group_event_attrs = build(:group_event, :with_all_attributes).attributes

          %w(name description location_name).each do |attr|
            post create_url, {
              params: post_request_params(:group_events, group_event_attrs.without(attr).merge(is_published: true))
            }
            
            expect(response.status).to eq(422)
            errors = jsonapi_response_errors(response, details_with_pointer: true)
            expect(errors).to include("#{attr} can't be blank")
          end
        end
      end
    end

    context 'valid requests with some of the attributes' do
      context 'not published' do
        it 'creates a group event with all attributes' do
          post create_url, {
            params: post_request_params(:group_events, {
              name: 'Developers Meetup 2021',
              description: 'Discuss about Rails 7',
              start_date: '2021/05/10',
              end_date: '2021/05/12',
              duration: 3,
              location_name: 'Barcelona'
            })
          }

          expect(response.status).to eq(201)
          response_data = parsed_jsonapi_response(response, data_only: true)
          expect(is_a_group_event?(response_data)).to be_truthy
        end

        it 'creates a group event only with name' do
          post create_url, {
            params: post_request_params(:group_events, {
              name: 'Developers meetup 2021'
            })
          }

          expect(response.status).to eq(201)
          response_data = parsed_jsonapi_response(response, data_only: true)
          expect(is_a_group_event?(response_data)).to be_truthy
        end
        
        it 'creates a group event only with description' do
          post create_url, {
            params: post_request_params(:group_events, {
              description: 'Some great description'
            })
          }

          expect(response.status).to eq(201)
          response_data = parsed_jsonapi_response(response, data_only: true)
          expect(is_a_group_event?(response_data)).to be_truthy
        end

        it 'creates a group event only with start date' do
          post create_url, {
            params: post_request_params(:group_events, {
              start_date: Date.today
            })
          }

          expect(response.status).to eq(201)
          response_data = parsed_jsonapi_response(response, data_only: true)
          expect(is_a_group_event?(response_data)).to be_truthy
        end

        it 'creates a group event only with end date' do
          post create_url, {
            params: post_request_params(:group_events, {
              end_date: Date.today
            })
          }

          expect(response.status).to eq(201)
          response_data = parsed_jsonapi_response(response, data_only: true)
          expect(is_a_group_event?(response_data)).to be_truthy
        end

        it 'creates a group event only with duration' do
          post create_url, {
            params: post_request_params(:group_events, {
              duration: 30
            })
          }

          expect(response.status).to eq(201)
          response_data = parsed_jsonapi_response(response, data_only: true)
          expect(is_a_group_event?(response_data)).to be_truthy
        end

        it 'creates a group event only with location name' do
          post create_url, {
            params: post_request_params(:group_events, {
              location_name: 'Barcelona'
            })
          }

          expect(response.status).to eq(201)
          response_data = parsed_jsonapi_response(response, data_only: true)
          expect(is_a_group_event?(response_data)).to be_truthy
        end
      end

      context 'published' do
        it 'creates a group event with all attributes' do
          post create_url, {
            params: post_request_params(:group_events, {
              name: 'Developers Meetup 2021',
              description: 'Discuss about Rails 7',
              start_date: '2021/05/10',
              end_date: '2021/05/12',
              duration: 3,
              location_name: 'Barcelona',
              is_published: true
            })
          }

          expect(response.status).to eq(201)
          response_data = parsed_jsonapi_response(response, data_only: true)
          expect(is_a_group_event?(response_data)).to be_truthy
        end
      end
    end
  end

  describe 'PUT update' do
    let(:unpublished_group_event) { create(:group_event, :with_all_attributes) }
    let(:unpublished_update_url)  { "/api/v1/group_events/#{unpublished_group_event.id}" }
    
    let(:published_group_event)   { create(:group_event, :with_all_attributes, is_published: true) }
    let(:published_update_url)    { "/api/v1/group_events/#{published_group_event.id}" }

    context 'invalid request' do
      context 'unpublished group event' do
        it 'is expected to throw error for invalid end date, when start date is greater than end date' do
          put unpublished_update_url, {
            params: post_request_params(:group_events, {
              start_date: yyyy_mm_dd(1.day.from_now.to_date),
              end_date:   yyyy_mm_dd(Date.today)
            })
          }
          
          expect(response.status).to eq(422)
          errors = jsonapi_response_errors(response, details_with_pointer: true)
          expect(errors).to include('end_date should be greater than start date')
        end

        it 'is expected to throw error for invalid duration' do
          put unpublished_update_url, {
            params: post_request_params(:group_events, {
              start_date: yyyy_mm_dd(Date.today),
              end_date: yyyy_mm_dd(Date.today + 2.days),
              duration: 10
            })
          }
          
          expect(response.status).to eq(422)
          errors = jsonapi_response_errors(response, details_with_pointer: true)
          expect(errors).to include('duration is not matching with start date and end date')
        end
      end

      context 'published group event' do
        it 'is expected to throw error if published group event is updated any key missing' do
          %w(name description location_name).each do |attr|
            put published_update_url, {
              params: post_request_params(:group_events, { attr => nil })
            }
            
            expect(response.status).to eq(422)
            errors = jsonapi_response_errors(response, details_with_pointer: true)
            expect(errors).to include("#{attr} can't be blank")
          end
        end
      end

      context 'publish a unpublished group event' do
        it 'is expected to throw error if unpublished published group event with key missing is published' do
          %w(name description location_name).each do |attr|
            unpublished_group_event.update(attr => nil)
            
            put unpublished_update_url, {
              params: post_request_params(:group_events, { is_published: true })
            }
            
            expect(response.status).to eq(422)
            errors = jsonapi_response_errors(response, details_with_pointer: true)
            expect(errors).to include("#{attr} can't be blank")
          end
        end
      end
    end

    context 'valid request' do
      context 'unpublished group event' do
        it 'is expected to update name, description, location name' do
          %w(name description location_name).each do |attr|
            put unpublished_update_url, {
              params: post_request_params(:group_events, { attr: 'Something else' })
            }

            expect(response.status).to eq(200)
          end
        end
      end

      context 'published group event' do
        it 'is expected to update name, description, location name' do
          %w(name description location_name).each do |attr|
            put published_update_url, {
              params: post_request_params(:group_events, { attr: 'Something else' })
            }
            
            expect(response.status).to eq(200)
          end
        end
      end
    end

    context 'requested group event does not exist' do
      it 'is exptected to get 404' do
        put '/api/v1/group_events/1000', {
          params: post_request_params(:group_events, { name: 'Something else' })
        }

        expect(response.status).to eq(404)
      end
    end
  end

  describe 'DELETE destroy' do
    let!(:group_event) { create(:group_event, :with_all_attributes) }

    context 'requested group event does not exist' do
      it 'is exptected to get 404' do
        delete '/api/v1/group_events/1000'
        expect(response.status).to eq(404)
      end

    end
    
    context 'requested group event already deleted' do
      it 'is exptected to get 404' do
        group_event.destroy
        delete "/api/v1/group_events/#{group_event.id}"
        expect(response.status).to eq(404)
      end
    end

    context 'requested group event exist' do
      it 'is expected to destroy the group event' do
        delete "/api/v1/group_events/#{group_event.id}"
        expect(response.status).to eq(204)
      end
    end
  end
end
