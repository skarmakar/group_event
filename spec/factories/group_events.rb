FactoryBot.define do
  factory :group_event do
    user_id { 1 }    
  end

  trait :with_dates do
    start_date { Date.today }
    end_date   { Date.today + 30.days }
  end

  trait :with_dates_and_duration do
    start_date { Date.today }
    end_date   { Date.today + 29.days }
    duration   { 30 }
  end

  trait :with_all_attributes do
    name          { "#{FFaker::SportUS.name} #{DateTime.now.strftime("%Q")}" }
    description   { FFaker::HTMLIpsum.body }
    start_date    { Date.today }
    end_date      { Date.today + 29.days }
    duration      { 30 }
    location_name { 'Kolkata, India' }
  end
end
