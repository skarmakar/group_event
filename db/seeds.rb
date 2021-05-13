5.times { FactoryBot.create(:group_event, :with_all_attributes) }
5.times { FactoryBot.create(:group_event, :with_all_attributes, is_published: true) }

