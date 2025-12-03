class CreateTags < ActiveRecord::Migration[8.0]
  def change
    create_table :tags do |t|
      t.string :name, null: false
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end

    # 同一ユーザー内でタグ名が重複しないようにする
    add_index :tags, [ :user_id, :name ], unique: true
  end
end
