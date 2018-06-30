class CreateWords < ActiveRecord::Migration[5.2]
  def change
    enable_extension 'citext'

    create_table :words do |t|
      t.string :word, unique: true, null: false

      t.timestamps
    end
  end
end
