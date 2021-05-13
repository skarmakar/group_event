class CreateGroupEvents < ActiveRecord::Migration[6.1]
  def change
    create_table :group_events do |t|
      t.integer :user_id, null: false
      t.string :name
      t.text :description
      t.date :start_date
      t.date :end_date
      t.integer :duration
      t.string :location_name
      t.boolean :is_published, default: false
      t.datetime :deleted_at
      t.timestamps
    end

    add_index :group_events, :user_id
    add_index :group_events, [:name, :start_date, :end_date], unique: true
  end
end
