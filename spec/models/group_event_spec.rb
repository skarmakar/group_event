require 'rails_helper'

RSpec.describe GroupEvent, type: :model do
  context 'before validation' do
    it 'start date and end date present, is expcted to set duration' do
      group_event = build(:group_event, start_date: '2021/05/08', end_date: '2021/05/10')
      expect(group_event.duration).to be_blank
      group_event.valid?
      expect(group_event.duration).to eq(3)
    end

    it 'start date and duration present, is expcted to set end date' do
      group_event = build(:group_event, start_date: '2021/05/08', duration: 2)
      group_event.valid?
      expect(group_event.end_date).to eq(Date.parse('2021/05/09'))
    end

    it 'end date and start date is present, is expcted to set start date' do
      group_event = build(:group_event, end_date: '2021/05/09', duration: 2)
      group_event.valid?
      expect(group_event.start_date).to eq(Date.parse('2021/05/08'))
    end
  end

  context 'validations' do
    context 'not published' do
      context 'is expected to be invalid' do
        it 'when user_id is blank' do
          group_event = build(:group_event, user_id: nil)
          result = group_event.valid?
          expect(result).to be_falsy
          expect(group_event.errors[:user_id]).to be_present
        end

        it 'when user id is present, but rest of the attributes are blank' do
          group_event = build(:group_event)
          result = group_event.valid?
          expect(result).to be_falsy
          expect(group_event.errors[:user_id]).to be_blank
          expect(group_event.errors[:base]).to be_present
        end
      end

      context 'is expected to be valid' do
        GroupEvent.new.attributes.keys.without(GroupEvent::SKIP_KEYS).each do |attr|
          it "when only #{attr} is present" do
            group_event = build(:group_event)
            
            value = if %w(start_date end_date).include?(attr)
              Date.today  
            elsif attr == 'duration'
              10
            else
              'Some random text'
            end

            group_event[attr] = value
            expect(group_event.valid?).to be_truthy
          end
        end
      end
    end

    context 'published' do
      context 'is expected to be invalid' do
        GroupEvent.new.attributes.keys.without(GroupEvent::SKIP_KEYS).each do |attr|
          it "if #{attr} is missing" do
            group_event = build(:group_event, :with_all_attributes, is_published: true)
            expect(group_event).to be_valid

            group_event[attr] = nil

            if %w(start_date end_date duration).include?(attr)
              # as they will be automatically set
              expect(group_event.valid?).to be_truthy
            else
              expect(group_event.valid?).to be_falsy
            end
          end
        end
      end

      context 'is expected to be valid' do
        it 'if all the attributes are present' do
          group_event = build(:group_event, :with_all_attributes, is_published: true)
          expect(group_event).to be_valid
          expect { group_event.save }.to change { GroupEvent.count }.by(1)
        end
      end
    end

    context '#validate_dates_and_duration' do
      it 'is expected to be invalid if start date > end_date' do
        group_event = build(:group_event, :with_all_attributes, start_date: Date.today, end_date: 1.day.ago.to_date)
        group_event.valid?
        expect(group_event.errors[:end_date].first).to eq(I18n.t('group_event.validation.end_date'))
      end

      it 'is expected to be invalid if provided duration does not match with calculated duration' do
        group_event = build(:group_event, :with_all_attributes, start_date: Date.today, end_date: 1.day.from_now, duration: 30)
        group_event.valid?
        expect(group_event.errors[:duration].first).to eq(I18n.t('group_event.validation.duration'))
      end
    end
  end

  context '#destroy' do
    it 'is expected to set deleted at, not destroy from database' do
      group_event = create(:group_event, :with_all_attributes)
      expect(group_event.deleted_at).to be_blank
      expect { group_event.destroy }.not_to change { GroupEvent.count }
      expect(group_event.deleted_at).not_to be_blank
    end
  end
end
